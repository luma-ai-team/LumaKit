//
//  PlayerSynchronizer.swift
//
//
//  Created by Anton Kormakov on 02.09.2024.
//

import AVFoundation

public final class PlayerSynchronizer {
    final class Record {
        weak var player: AVPlayer?
        var observation: NSKeyValueObservation?

        var isPlaying: Bool {
            return player?.rate != 0.0
        }

        init(player: AVPlayer, observation: NSKeyValueObservation) {
            self.player = player
            self.observation = observation
        }
    }

    public enum LoopTriggerRule {
        case none
        case any
        case all
    }

    var records: [Record] = []
    var isPlaying: Bool = false
    var loopTriggerRule: LoopTriggerRule = .any

    public init() {}

    deinit {
        stopTracking()
    }

    public func startTracking(with players: [AVPlayer], rule: LoopTriggerRule = .any) {
        stopTracking()

        loopTriggerRule = rule
        for player in players {
            player.automaticallyWaitsToMinimizeStalling = false
            let observation = player.observe(\.rate) { [weak self] (_, _) in
                DispatchQueue.main.async {
                    guard let self = self,
                          self.isPlaying,
                          player.rate == 0.0 else {
                        return
                    }

                    self.restartPlaybackIfNeeded()
                }
            }

            let record = Record(player: player, observation: observation)
            records.append(record)
        }
    }

    public func stopTracking() {
        for record in records {
            record.player = nil
        }
        cleanupRecords()
    }

    public func play() {
        isPlaying = true
        restart()
    }

    public func pause() {
        isPlaying = false
        for record in records {
            record.player?.pause()
        }
    }

    public func restart() {
        isPlaying = false

        let group = DispatchGroup()
        for record in records {
            group.enter()
            guard let player = record.player,
                  player.status != .readyToPlay else {
                group.leave()
                continue
            }

            var observation: NSKeyValueObservation?
            observation = player.observe(\.status) { (_, _) in
                observation?.invalidate()
                group.leave()
            }
        }

        group.notify(queue: .main, execute: startPlayback)
    }

    func startPlayback() {
        defer {
            cleanupRecords()
        }

        let hostTime = CMClockGetTime(CMClockGetHostTimeClock())
        for record in records {
            record.player?.setRate(1.0, time: .zero, atHostTime: hostTime)
        }
        isPlaying = true
    }

    func restartPlaybackIfNeeded() {
        defer {
            cleanupRecords()
        }

        switch loopTriggerRule {
        case .none:
            return
        case .any:
            break
        case .all:
            guard records.allSatisfy({ (record: Record) in
                return record.isPlaying == false
            }) else {
                return
            }
        }

        restart()
    }

    func cleanupRecords() {
        var removedRecords: [Record] = []
        for record in records where record.player == nil {
            record.observation?.invalidate()
            removedRecords.append(record)
        }

        records.removeAll { (record: Record) in
            removedRecords.containsReference(to: record)
        }
    }
}
