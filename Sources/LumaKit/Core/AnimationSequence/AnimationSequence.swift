//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

/// Object that manages animations execution and synchronization.
public final class AnimationSequence {
    public typealias Handler = () -> Void
    public typealias Completion = (Bool) -> Void

    /// Object describing actions that need to be executed at each sequence step.
    private enum Step {
        case handler(Handler)
        case wait(TimeInterval, Handler)

        func execute() {
            switch self {
            case .handler(let handler):
                handler()
            case .wait(let interval, let completion):
                DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: completion)
            }
        }
    }

    /// Boolean indicating if `AnimationSequence` should retain itself while running.
    private var retainedSelf: AnimationSequence?

    /// Sequence steps to be executed.
    private var steps: [Step] = []

    /// Boolean indicating if sequence is currently running.
    public private(set) var isRunning: Bool = false

    /// Boolean indicating if sequence should be played continiously.
    /// If this value is `false`, sequence will need to be started manually using `start` call.
    /// Setting it to `true` will automatically start or continue the sequence.
    public var isContinuous: Bool = true {
        didSet {
            if isContinuous, isRunning == false {
                start()
            }
        }
    }

    public init() {}

    // MARK: - Animations

    /**
    Adds spring animation step.

    Calling this func will queue provided `animations` closure to be executed.
    If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     animation will be started instantly.

    - Parameter parameters: A `SpringAnimationParameters` object describing animation parameters.
    - Parameter animations: Closure that will be called in context of an animation configured
     with supplied parameters during step execution.
    - Parameter completion: Closure that will be called on animation completion.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func animate(with parameters: SpringAnimationParameters,
                        animations: @escaping Handler,
                        completion: Completion? = nil) -> Self {
        steps.append(.handler { [weak self] in
            UIView.animate(with: parameters, animations: animations, completion: { (isFinished: Bool) in
                completion?(isFinished)
                self?.next()
            })
        })

        continueIfNeeded()
        return self
    }

    /**
    Adds spring animation step.

    Calling this func will queue provided `animations` closure to be executed.
     If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     animation will be started instantly.

    - Parameter parameters: A `SpringAnimationParameters` object describing animation parameters.
    - Parameter animations: Closure that will be called in context of an animation configured
     with supplied parameters during step execution.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func animate(with parameters: SpringAnimationParameters,
                        animations: @escaping Handler) -> Self {
        return animate(with: parameters, animations: animations, completion: nil)
    }

    /**
    Adds spring animation step.

    Calling this func will queue provided `animations` closure to be executed.
     If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     animation will be started instantly.

    - Parameter duration: The total duration of the animations, measured in seconds.
     If you specify a negative value or 0, the changes are made without animating them.
    - Parameter delay: The amount of time (measured in seconds) to wait before beginning the animations.
     Specify a value of 0 to begin the animations immediately.
    - Parameter dampingRatio: The damping ratio for the spring animation as it approaches its quiescent state.
     To smoothly decelerate the animation without oscillation, use a value of 1.
     Employ a damping ratio closer to zero to increase oscillation.
    - Parameter velocity: The initial spring velocity.
     For smooth start to the animation, match this value to the view’s velocity as it was prior to attachment.
     A value of 1 corresponds to the total animation distance traversed in one second.
    - Parameter options: A mask of options indicating how you want to perform the animations.
     For a list of valid constants, see UIView.AnimationOptions.
    - Parameter animations: Closure that will be called in context of an animation configured
     with supplied parameters during step execution.
    - Parameter completion: Closure that will be called on animation completion.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func animate(withDuration duration: TimeInterval,
                        delay: TimeInterval = 0.0,
                        usingSpringWithDamping dampingRatio: CGFloat,
                        initialSpringVelocity velocity: CGFloat,
                        options: UIView.AnimationOptions = [],
                        animations: @escaping Handler,
                        completion: Completion? = nil) -> Self {
        let parameters = SpringAnimationParameters()
        parameters.duration = duration
        parameters.delay = delay
        parameters.dampingRatio = dampingRatio
        parameters.velocity = velocity
        parameters.options = options

        return animate(with: parameters, animations: animations, completion: completion)
    }

    /**
    Adds basic animation step.

    Calling this func will queue provided `animations` closure to be executed.
    If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     animation will be started instantly.

    - Parameter parameters: A `BaseAnimationParameters` object describing animation parameters.
    - Parameter animations: Closure that will be called in context of an animation configured
     with supplied parameters during step execution.
    - Parameter completion: Closure that will be called on animation completion.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func animate(with parameters: BaseAnimationParameters,
                        animations: @escaping Handler,
                        completion: Completion? = nil) -> Self {
        steps.append(.handler { [weak self] in
            UIView.animate(with: parameters, animations: animations, completion: { (isFinished: Bool) in
                completion?(isFinished)
                self?.next()
            })
        })

        continueIfNeeded()
        return self
    }

    /**
    Adds basic animation step.

    Calling this func will queue provided `animations` closure to be executed.
    If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     animation will be started instantly.

    - Parameter parameters: A `SpringAnimationParameters` object describing animation parameters.
    - Parameter animations: Closure that will be called in context of an animation configured
     with supplied parameters during step execution.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func animate(with parameters: BaseAnimationParameters,
                        animations: @escaping Handler) -> Self {
        return animate(with: parameters, animations: animations, completion: nil)
    }

    /**
    Adds basic animation step.

    Calling this func will queue provided `animations` closure to be executed.
    If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     animation will be started instantly.

    - Parameter duration: The total duration of the animations, measured in seconds.
     If you specify a negative value or 0, the changes are made without animating them.
    - Parameter delay: The amount of time (measured in seconds) to wait before beginning the animations.
     Specify a value of 0 to begin the animations immediately.
    - Parameter options: A mask of options indicating how you want to perform the animations.
     For a list of valid constants, see UIView.AnimationOptions.
    - Parameter animations: Closure that will be called in context of an animation configured
     with supplied parameters during step execution.
    - Parameter completion: Closure that will be called on animation completion.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func animate(withDuration duration: TimeInterval,
                        delay: TimeInterval = 0.0,
                        options: UIView.AnimationOptions = [],
                        animations: @escaping Handler,
                        completion: Completion? = nil) -> Self {
        let parameters = BaseAnimationParameters()
        parameters.duration = duration
        parameters.delay = delay
        parameters.options = options

        return animate(with: parameters, animations: animations, completion: completion)
    }

    // MARK: - Delays

    /**
    Adds wait step.

    Calling this func will queue a pause in the sequence.
     If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     execution of the sequence will be automatically started after specified duration.

    - Parameter duration: Duration in seconds for which sequence should be paused.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func wait(forDuration duration: TimeInterval) -> Self {
        steps.append(.wait(duration) { [weak self] in
            self?.next()
        })

        continueIfNeeded()
        return self
    }

    // MARK: - Synchronization

    /**
    Adds general sync execution step.

    Calling this func will queue a provided handler to be executed. Sequence execution will be paused until handler execution is completed.
     If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     execution will be started instantly.

    - Parameter handler: Closure that will be called during step execution.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func sync(_ handler: @escaping Handler) -> Self {
        steps.append(.handler { [weak self] in
            handler()
            self?.next()
        })

        continueIfNeeded()
        return self
    }

    /**
    Adds general async execution step.

    Calling this func will queue a provided handler to be executed.
     Sequence execution will be paused until closure provided to the handler as parameter is be called.
     If `isContinuous` var of the `AnimationSequence` is set to `true` and there weren't any steps added before,
     execution will be started instantly.

    - Parameter handler: Closure that will be called during step execution.
     Closure provided in the parameter should be called when execution is completed, otherwise sequence will stall.
    - Returns: Current `AnimationSequence` instance.
    */
    @discardableResult
    public func async(_ handler: @escaping (@escaping Handler) -> Void) -> Self {
        steps.append(.handler { [weak self] in
            handler {
                DispatchQueue.main.async {
                    self?.next()
                }
            }
        })

        continueIfNeeded()
        return self
    }

    // MARK: - Control

    /**
    Starts the sequence.

    This function will not have any effect if sequence is already running.

    - Parameter retainingSelf: Boolean which specifies if sequence should retain itself during execution. Default: `true`.
    */
    public func start(retainingSelf: Bool = true) {
        if retainingSelf {
            retain()
        }

        if isRunning == false {
            isRunning = true
            next()
        }
    }

    /**
    Forces execution of the next sequence step.
     Calling this function will result in immediate execution of the next queued step without waiting for previous step completion.
     If there're no pending steps, sequence will release itself.
    */
    public func step() {
        guard steps.isEmpty == false else {
            isRunning = false
            release()
            return
        }

        steps.removeFirst().execute()
    }

    /**
    Stops execution of the sequence and releases itself.
    */
    public func stop() {
        release()
        isRunning = false
    }

    /**
    Stops execution of the sequence and removes all pending execution steps.
    */
    public func reset() {
        stop()
        steps.removeAll()
    }

    // MARK: - Private

    private func next() {
        guard isRunning else {
            return
        }

        step()
    }

    private func retain() {
        retainedSelf = self
    }

    private func release() {
        retainedSelf = nil
    }

    private func continueIfNeeded() {
        guard isContinuous else {
            return
        }

        start()
    }
}
