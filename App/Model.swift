import UIKit

enum Color: String {
    case black
    case red
    case white
    case yellow
}

extension Color {
    var cgColor: CGColor {
        switch self {
        case .black:
            return UIColor.black.cgColor
        case .red:
            return UIColor.red.cgColor
        case .white:
            return UIColor.white.cgColor
        case .yellow:
            return UIColor.yellow.cgColor
        }
    }
}

struct Figure {
    enum Shape {
        case rectangle(size: CGSize, angle: CGFloat)
        case circle(radius: CGFloat)
    }

    let center: CGPoint
    let color: Color
    let shape: Shape
}

extension Figure {
    init(from string: String) {
        func rectange(_ values: [String]) -> Figure {
            Figure(
                center: CGPoint(x: CGFloat(values[0]), y: CGFloat(values[1])),
                color: Color(rawValue: values[5]) ?? .black,
                shape:
                .rectangle(
                    size: CGSize(width: CGFloat(values[2]), height: CGFloat(values[3])),
                    angle: CGFloat(values[4]) / 180 * CGFloat.pi
                )
            )
        }

        func circle(_ values: [String]) -> Figure {
            Figure(
                center: CGPoint(x: CGFloat(values[0]), y: CGFloat(values[1])),
                color: Color(rawValue: values[3]) ?? .black,
                shape:
                .circle(
                    radius: CGFloat(values[2])
                )
            )
        }

        let values = string.components(separatedBy: .whitespaces)
        switch values[0] {
        case "rectangle":
            self = rectange(Array(values.dropFirst()))
        case "circle":
            self = circle(Array(values.dropFirst()))
        default:
            fatalError("Unkwnown figure")
        }
    }
}

struct Animation {
    enum Transform {
        case move(x: CGFloat, y: CGFloat)
        case rotate(angle: CGFloat)
        case scale(scale: CGFloat)
    }

    let time: TimeInterval
    let cycle: Bool
    let transform: Transform
}

extension Animation {
    init(from string: String, startPoint: CGPoint) {
        func move(_ values: [String]) -> Animation {
            let cycle = values.count > 3 ? true : false
            return Animation(
                time: TimeInterval(msString: values[2]),
                cycle: cycle,
                transform: .move(
                    x: CGFloat(values[0]) - startPoint.x,
                    y: CGFloat(values[1]) - startPoint.y
                )
            )
        }

        func rotate(_ values: [String]) -> Animation {
            let cycle = values.count > 2 ? true : false
            return Animation(
                time: TimeInterval(msString: values[1]),
                cycle: cycle,
                transform: .rotate(
                    angle: CGFloat(values[0]) / 180 * CGFloat.pi
                )
            )
        }

        func scale(_ values: [String]) -> Animation {
            let cycle = values.count > 2 ? true : false
            return Animation(
                time: TimeInterval(msString: values[1]),
                cycle: cycle,
                transform: .scale(
                    scale: CGFloat(values[0])
                )
            )
        }

        let values = string.components(separatedBy: .whitespaces)
        let params = Array(values.dropFirst())
        switch values[0] {
        case "move":
            self = move(params)
        case "rotate":
            self = rotate(params)
        case "scale":
            self = scale(params)
        default:
            fatalError("Unkwnown animation")
        }
    }
}

struct Scene {
    struct Layer {
        let figure: Figure
        let animations: [Animation]
    }

    let size: CGSize
    let layers: [Layer]
}

// MARK: - Foundation Extensions
private extension CGFloat {
    init(_ string: String) {
        self = CGFloat(Double(string) ?? 0)
    }
}

private extension TimeInterval {
    init(msString: String) {
        self = (Double(msString) ?? 0) / 1000
    }
}

// MARK: - Input Data

func allScenes() -> [Scene] {
    return (0 ... 10).map { String($0) }.map(readScene)
}

private func readScene(from filePath: String) -> Scene {
    let path = Bundle.main.path(forResource: filePath, ofType: "txt")!
    let data = try! String(contentsOfFile: path, encoding: .utf8)
    let lines = data.components(separatedBy: .newlines)

    let sizeStr = lines[0].components(separatedBy: .whitespaces)
    let size = CGSize(width: Int(sizeStr[0])!, height: Int(sizeStr[1])!)

    let count = Int(lines[1])!

    var li = 2
    var layers = [Scene.Layer]()
    for _ in 0 ..< count {
        let figure = Figure(from: lines[li])
        li += 1
        let animationCount = Int(lines[li])!
        li += 1
        var figureAnimations = [Animation]()
        for _ in 0 ..< animationCount {
            figureAnimations.append(Animation(from: lines[li], startPoint: figure.center))
            li += 1
        }
        layers.append(Scene.Layer(figure: figure, animations: figureAnimations))
    }

    return Scene(
        size: size,
        layers: layers
    )
}
