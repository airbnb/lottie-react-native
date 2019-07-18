#if canImport(React)
import React
#endif

import Lottie

class ContainerView: RCTView {
    private var speed: CGFloat = 0.0
    private var progress: CGFloat = 0.0
    private var loop: LottieLoopMode = .playOnce
    private var sourceJson: String = ""
    private var resizeMode: String = ""
    private var sourceName: String = ""
    private var color:String = ""
    @objc var onAnimationFinish: RCTBubblingEventBlock?
    var animationView: AnimationView?

    @objc func setSpeed(_ newSpeed: CGFloat) {
        speed = newSpeed
    }

    @objc func setProgress(_ newProgress: CGFloat) {
        progress = newProgress
        animationView?.currentProgress = progress
    }

    override func reactSetFrame(_ frame: CGRect) {
        super.reactSetFrame(frame)
        animationView?.reactSetFrame(frame)
    }

    @objc func setLoop(_ isLooping: Bool) {
        loop = isLooping ? .loop : .playOnce
        animationView?.loopMode = loop
    }

    @objc func setSourceJson(_ newSourceJson: String) {
        sourceJson = newSourceJson

        guard let data = sourceJson.data(using: String.Encoding.utf8),
        let animation = try? JSONDecoder().decode(Animation.self, from: data) else {
            if (RCT_DEV == 1) {
                print("Unable to create the lottie animation obeject from the JSON source")
            }
            return
        }

        let starAnimationView = AnimationView()
        starAnimationView.animation = animation
        replaceAnimationView(next: starAnimationView)
    }

    @objc func setSourceName(_ newSourceName: String) {
        sourceName = newSourceName
    }

    @objc func setResizeMode(_ resizeMode: String) {
        switch (resizeMode) {
        case "cover":
            animationView?.contentMode = .scaleAspectFill
        case "contain":
            animationView?.contentMode = .scaleAspectFit
        case "center":
            animationView?.contentMode = .center
        default: break
        }
    }

    @objc func setColorFilter(_ newColor: String) {
        color = newColor
    }

    func play(fromFrame: AnimationFrameTime? = nil, toFrame: AnimationFrameTime, completion: LottieCompletionBlock? = nil) {
        animationView?.play(fromFrame: fromFrame, toFrame: toFrame, loopMode: self.loop, completion: completion);
    }

    func play(completion: LottieCompletionBlock? = nil) {
        animationView?.play(completion: completion)
    }

    func reset() {
        animationView?.currentProgress = 0;
        animationView?.pause()
    }

    // MARK: Private

    func replaceAnimationView(next: AnimationView) {
        animationView?.removeFromSuperview()

        let contentMode = animationView?.contentMode ?? .scaleAspectFit
        animationView = next
        addSubview(next)
        animationView?.contentMode = contentMode
        animationView?.reactSetFrame(frame)
        applyProperties()
    }

    func applyProperties() {
        animationView?.currentProgress = progress
        animationView?.animationSpeed = speed
        animationView?.loopMode = loop
        if (color != "") {
            let fillKeypath = AnimationKeypath(keypath: "**")
            let colorFilterValueProvider = ColorValueProvider(UIColor(rgba: color))
            animationView.setValueProvider(colorFilterValueProvider, keypath: fillKeypath)
        }
    }
}
