import UIKit

class ViewController: UIViewController {
    let scene: Scene
    let sceneView = UIView()

    init(scene: Scene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        sceneView.layer.borderColor = UIColor.black.cgColor
        sceneView.layer.borderWidth = 1
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sceneView.widthAnchor.constraint(equalToConstant: scene.size.width),
            sceneView.heightAnchor.constraint(equalToConstant: scene.size.height),
            sceneView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scene.layers.forEach(add(figure:))
    }

    private func add(figure: Scene.Layer) {
        let layer = CAShapeLayer(figure: figure.figure)
        sceneView.layer.addSublayer(layer)

        figure.caAnimations.forEach { animation in
            layer.add(animation, forKey: nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        sceneView.layer.sublayers?.forEach { $0.pauseAnimation() }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        sceneView.layer.sublayers?.forEach { $0.resumeAnimation() }
    }
}

extension Scene {
    var totalDuration: TimeInterval {
        layers.map { $0.totalDuration }.max() ?? 0
    }
}

extension Scene.Layer {
    var totalDuration: TimeInterval {
        animations.map { $0.cycle ? 2 * $0.time : $0.time }.max() ?? 0
    }

    var caAnimations: [CAAnimation] {
        animations.map { animation in
            let caAnimation = animation.transform.caAnimation
            caAnimation.duration = animation.time
            caAnimation.autoreverses = animation.cycle
            return caAnimation
        }
    }
}

extension CAShapeLayer {
    convenience init(figure: Figure) {
        self.init()
        path = figure.cgPath
        fillColor = figure.color.cgColor
    }
}

extension Figure {
    var cgPath: CGPath {
        let path = CGMutablePath()
        switch shape {
        case let .rectangle(size, angle):
            let rect = CGRect(origin: center, size: size)
                .offsetBy(dx: -size.width / 2, dy: -size.height / 2)
            path.addRect(rect, transform: CGAffineTransform(rotationAngle: angle))
        case let .circle(radius):
            path.addArc(
                center: center,
                radius: radius,
                startAngle: 0,
                endAngle: CGFloat(M_2_PI),
                clockwise: true
            )
        }
        return path
    }
}

extension Animation.Transform {
    var layerKeyPath: String {
        switch self {
        case .move:
            return "position"
        case .rotate:
            return "transform.rotation.z"
        case .scale:
            return "transform"
        }
    }
}

extension Animation.Transform {
    var caAnimation: CAAnimation {
        let caAnimation = CABasicAnimation(keyPath: layerKeyPath)
        caAnimation.fillMode = CAMediaTimingFillMode.forwards
        caAnimation.isRemovedOnCompletion = false

        switch self {
        case let .move(x, y):
            caAnimation.toValue = NSValue(cgPoint: CGPoint(x: x, y: y))
        case let .rotate(angle):
            caAnimation.toValue = NSNumber(value: Double(angle))
        case let .scale(scale):
            caAnimation.toValue = NSValue(cgAffineTransform: CGAffineTransform(scaleX: scale, y: scale))
        }

        return caAnimation
    }
}

// From https://developer.apple.com/library/content/qa/qa1673/_index.html
extension CALayer {
    func pauseAnimation() {
        let pausedTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    func resumeAnimation() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}
