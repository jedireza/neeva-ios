// MIT License
//
// Copyright (c) 2020 Simon Bachmann
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

public struct RoundedCross: Shape {

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY / 3))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX / 3, y: rect.minY),
            control: CGPoint(x: rect.maxX / 3, y: rect.maxY / 3))
        path.addLine(to: CGPoint(x: 2 * rect.maxX / 3, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY / 3),
            control: CGPoint(x: 2 * rect.maxX / 3, y: rect.maxY / 3))
        path.addLine(to: CGPoint(x: rect.maxX, y: 2 * rect.maxY / 3))
        path.addQuadCurve(
            to: CGPoint(x: 2 * rect.maxX / 3, y: rect.maxY),
            control: CGPoint(x: 2 * rect.maxX / 3, y: 2 * rect.maxY / 3))
        path.addLine(to: CGPoint(x: rect.maxX / 3, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: 2 * rect.minX / 3, y: 2 * rect.maxY / 3),
            control: CGPoint(x: rect.maxX / 3, y: 2 * rect.maxY / 3))

        return path
    }
}

public struct SlimRectangle: Shape {

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: 4 * rect.maxY / 5))
        path.addLine(to: CGPoint(x: rect.maxX, y: 4 * rect.maxY / 5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        return path
    }
}

public struct Triangle: Shape {

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

public struct ConfettiCannon: View {
    @Binding var counter: Int
    let confettiConfig: ConfettiConfig
    @State var animate: [Bool] = []
    @State var finishedAnimationCouter = 0

    /// renders configurable confetti animaiton
    /// - Parameters:
    ///   - counter: on any change of this variable the animation is run
    ///   - num: amount of confettis
    ///   - colors: list of colors that is applied to the default shapes
    ///   - confettiSize: size that confettis and emojis are scaled to
    ///   - rainHeight: vertical distance that confettis pass
    ///   - fadesOut: reduce opacity towards the end of the animation
    ///   - opacity: maximum opacity that is reached during the animation
    ///   - openingAngle: boundary that defines the opening angle in degrees
    ///   - closingAngle: boundary that defines the closing angle in degrees
    ///   - radius: explosion radius
    ///   - repetitions: number of repetitions of the explosion
    ///   - repetitionInterval: duration between the repetitions

    public init(
        counter: Binding<Int>,
        num: Int = 20,
        openingAngle: Angle = .degrees(60),
        closingAngle: Angle = .degrees(120),
        radius: CGFloat = 300,
        repetitions: Int = 0,
        repetitionInterval: Double = 1.0
    ) {
        self._counter = counter
        self.confettiConfig = ConfettiConfig(
            num: num,
            openingAngle: openingAngle,
            closingAngle: closingAngle,
            radius: radius,
            repetitions: repetitions,
            repetitionInterval: repetitionInterval
        )
    }

    public var body: some View {
        ZStack {
            ForEach(finishedAnimationCouter..<animate.count, id: \.self) { i in
                ConfettiContainer(
                    finishedAnimationCouter: $finishedAnimationCouter,
                    confettiConfig: confettiConfig
                )
            }
        }
        .onChange(of: counter) { value in
            for i in 0...confettiConfig.repetitions {
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + confettiConfig.repetitionInterval * Double(i)
                ) {
                    animate.append(false)
                    if value < animate.count {
                        animate[value - 1].toggle()
                    }
                }
            }
        }
    }
}

struct ConfettiContainer: View {
    @Binding var finishedAnimationCouter: Int
    let confettiConfig: ConfettiConfig

    var body: some View {
        ZStack {
            ForEach(0...confettiConfig.num - 1, id: \.self) { _ in
                ConfettiView(confettiConfig: confettiConfig)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + confettiConfig.animationDuration) {
                self.finishedAnimationCouter += 1
            }
        }
    }
}

struct ConfettiView: View {
    let confettiConfig: ConfettiConfig

    @State var location = CGPoint(x: 0, y: 0)
    @State var opacity = 0.0

    var body: some View {
        ConfettiAnimationView()
            .offset(x: location.x, y: location.y)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.timingCurve(
                        0.61, 1, 0.88, 1, duration: confettiConfig.explosionAnimationDuration)
                ) {
                    opacity = 1.0
                    let randomAngle: CGFloat
                    if confettiConfig.openingAngle.degrees <= confettiConfig.closingAngle.degrees {
                        randomAngle = CGFloat.random(
                            in: CGFloat(
                                confettiConfig.openingAngle.degrees)...CGFloat(
                                    confettiConfig.closingAngle.degrees))
                    } else {
                        randomAngle = CGFloat.random(
                            in: CGFloat(
                                confettiConfig.openingAngle.degrees)...CGFloat(
                                    confettiConfig.closingAngle.degrees + 360)
                        ).truncatingRemainder(dividingBy: 360)
                    }

                    let distance = CGFloat.random(in: 0.5...1) * confettiConfig.radius
                    location.x = distance * cos(deg2rad(randomAngle))
                    location.y = -distance * sin(deg2rad(randomAngle))
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + confettiConfig.explosionAnimationDuration
                ) {
                    withAnimation(
                        Animation.timingCurve(
                            0.12, 0, 0.39, 0, duration: confettiConfig.rainAnimationDuration)
                    ) {
                        location.y += 600
                        opacity = 0
                    }
                }
            }
    }

    func deg2rad(_ number: CGFloat) -> CGFloat {
        return number * CGFloat.pi / 180
    }

}

enum ConfettiShape: CaseIterable {
    case circle, square, slimRectangle, roundedCross
}

struct ConfettiAnimationView: View {
    let color: Color = [
        Color(hex: 0x7A39C6), Color(hex: 0x7B3FC9), Color(hex: 0x7C55D6), Color(hex: 0x7D81F0),
    ].randomElement()!

    @State var move = false
    @State var confettiShape: ConfettiShape = ConfettiShape.allCases.randomElement()!
    @State var spinDirX = CGFloat.random(in: -1...1)
    @State var spinDirZ = CGFloat.random(in: -1...1)
    @State var xSpeed = Double.random(in: 1...2)
    @State var zSpeed = Double.random(in: 1...2)
    @State var anchor = CGFloat.random(in: 0...1).rounded()

    @ViewBuilder var shape: some View {
        switch confettiShape {
        case .circle:
            Circle()
        case .square:
            Rectangle()
        case .slimRectangle:
            SlimRectangle()
        case .roundedCross:
            RoundedCross()
        }
    }

    var body: some View {
        shape
            .foregroundColor(color)
            .frame(width: 10, height: 10)
            .rotation3DEffect(.degrees(move ? 360 : 0), axis: (x: spinDirX, y: 0, z: 0))
            .animation(
                Animation.linear(duration: xSpeed).repeatCount(10, autoreverses: false), value: move
            )
            .rotation3DEffect(
                .degrees(move ? 360 : 0), axis: (x: 0, y: 0, z: spinDirZ),
                anchor: UnitPoint(x: anchor, y: anchor)
            )
            .animation(
                Animation.linear(duration: zSpeed).repeatForever(autoreverses: false), value: move
            )
            .onAppear {
                move = true
            }
    }
}

struct ConfettiConfig {
    let num: Int
    let openingAngle: Angle
    let closingAngle: Angle
    let radius: CGFloat
    let repetitions: Int
    let repetitionInterval: Double

    var explosionAnimationDuration: Double {
        Double(radius / 1500)
    }

    var rainAnimationDuration: Double {
        Double((600 + radius) / 200)
    }

    var animationDuration: Double {
        return explosionAnimationDuration + rainAnimationDuration
    }

    var openingAngleRad: CGFloat {
        return CGFloat(openingAngle.degrees) * 180 / .pi
    }

    var closingAngleRad: CGFloat {
        return CGFloat(closingAngle.degrees) * 180 / .pi
    }
}
