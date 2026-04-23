//
//  MediaRecentsService.swift
//  LumaKit
//
//  Created by Anton K on 15.04.2026.
//

import UIKit
import AVFoundation

public final class MediaRecentsService {
    public class RecentsUpdateEvent {}

    public enum RecordType: String, Codable {
        case image
        case video
    }

    public class ItemRecord: Codable, Equatable {
        let identifier: String
        let type: RecordType
        let url: URL

        init(identifier: String, type: RecordType, url: URL) {
            self.identifier = identifier
            self.type = type
            self.url = url
        }

        public static func == (lhs: ItemRecord, rhs: ItemRecord) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }

    enum Constants {
        static let metadata: String = "contents.json"
        static let storageLimit: Int = 100
    }

    public var recentsUpdatePipe: AsyncPipe<RecentsUpdateEvent> = .init(value: .init())

    private let storageURL: URL = .documents(path: "LumaKit/Storage/Media")
    private let fileManager: FileManager = .default

    private var records: [ItemRecord] = []

    public static var shared: MediaRecentsService = .init()

    private init() {
        if fileManager.fileExists(atPath: storageURL.path) == false {
            try? fileManager.createDirectory(at: storageURL, withIntermediateDirectories: true)
        }

        let recordsURL = storageURL.appendingPathComponent(Constants.metadata)
        if let data = try? Data(contentsOf: recordsURL) {
            records = (try? JSONDecoder().decode([ItemRecord].self, from: data)) ?? []
        }
    }

    private func makeURL(for item: MediaFetchService.Item) -> URL {
        let path = item.identifier.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? item.identifier
        let pathExtension: String = {
            switch item.content {
            case .image:
                return "png"
            case .asset(let asset):
                return (asset as? AVURLAsset)?.url.pathExtension ?? "mp4"
            }
        }()
        return storageURL.appendingPathComponent(path).appendingPathExtension(pathExtension)
    }

    private func updateRecordsCache() async throws {
        let recordsURL = storageURL.appendingPathComponent(Constants.metadata)
        let metadata = try JSONEncoder().encode(records)
        try metadata.write(to: recordsURL)

        await recentsUpdatePipe.send(.init())
    }

    public func store(item: MediaFetchService.Item) async throws {
        guard let data = item.makeData() else {
            return
        }

        let type: RecordType = {
            switch item.content {
            case .asset:
                return .video
            case .image:
                return .image
            }
        }()

        let url = makeURL(for: item)
        if fileManager.fileExists(atPath: url.deletingLastPathComponent().path) == false {
            try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        }
        try data.write(to: url)

        let record = ItemRecord(identifier: item.identifier, type: type, url: url.relativeURL)
        records.removeAll(matching: record)
        records.insert(record, at: 0)

        if records.count > Constants.storageLimit {
            for evictedRecord in records.suffix(from: Constants.storageLimit) {
                try? fileManager.removeItem(at: .resolving(relativeURL: evictedRecord.url))
            }
            records = Array(records.prefix(Constants.storageLimit))
        }

        try await updateRecordsCache()
    }

    public func remove(item: MediaFetchService.Item) async throws {
        records.removeAll { (record: ItemRecord) in
            return record.identifier == item.identifier
        }
        try await updateRecordsCache()

        let url = makeURL(for: item)
        try fileManager.removeItem(at: url)
    }

    public func hasRecords(type: RecordType? = nil) -> Bool {
        if let type = type {
            return records.contains(with: type, at: \.type)
        }

        return records.isEmpty == false
    }

    public func recordCount(type: RecordType? = nil) -> Int {
        guard let type = type else {
            return records.count
        }

        return records.count { (record: ItemRecord) in
            record.type == type
        }
    }

    public func fetch(type: RecordType? = nil, limit: Int? = nil) async throws -> [MediaFetchService.Item] {
        var records = records
        if let type = type {
            records = records.filter(with: type, at: \.type)
        }
        if let limit = limit {
            records = Array(records.prefix(limit))
        }

        return records.compactMap { (record: ItemRecord) in
            let content: MediaFetchService.Content
            let url = URL.resolving(relativeURL: record.url)
            switch record.type {
            case .video:
                content = .asset(AVURLAsset(url: url))
            case .image:
                guard let image = UIImage(contentsOfFile: url.path) else {
                    return nil
                }

                content = .image(image)
            }

            return .init(identifier: record.identifier, content: content)
        }
    }
}
