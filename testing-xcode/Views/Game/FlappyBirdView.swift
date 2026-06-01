//
//  FlappyBirdView.swift
//  testing-xcode
//

import SwiftUI

struct FlappyBirdView: View {
    @State private var game = FlappyBirdGame()

    private let skyTop = Color(red: 0.45, green: 0.78, blue: 0.98)
    private let skyBottom = Color(red: 0.62, green: 0.88, blue: 0.99)
    private let pipeGreen = Color(red: 0.28, green: 0.72, blue: 0.38)
    private let pipeDark = Color(red: 0.18, green: 0.55, blue: 0.28)

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                ZStack {
                    LinearGradient(
                        colors: [skyTop, skyBottom],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    cloudsLayer(in: geo.size)

                    ForEach(game.pipes) { pipe in
                        pipeView(pipe: pipe, height: geo.size.height)
                    }

                    groundLayer(width: geo.size.width, height: geo.size.height)

                    birdView
                        .position(x: game.birdX, y: game.birdY)

                    overlay(in: geo.size)
                }
                .contentShape(Rectangle())
                .onTapGesture { game.tap() }
                .onAppear {
                    game.configure(width: geo.size.width, height: geo.size.height)
                }
                .onChange(of: geo.size) { _, newSize in
                    game.configure(width: newSize.width, height: newSize.height)
                }
                .onChange(of: timeline.date) { _, date in
                    game.update(at: date)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
    }

    private var birdView: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 36, height: 36)
                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)

            Circle()
                .fill(.white)
                .frame(width: 12, height: 12)
                .offset(x: 8, y: -4)

            Circle()
                .fill(.black)
                .frame(width: 5, height: 5)
                .offset(x: 10, y: -4)

            Triangle()
                .fill(Color.orange)
                .frame(width: 14, height: 10)
                .rotationEffect(.degrees(game.birdVelocity < 0 ? -20 : 25))
                .offset(x: 14, y: 2)
        }
        .rotationEffect(.degrees(Double(game.birdVelocity) * 0.06))
        .animation(.easeOut(duration: 0.12), value: game.birdVelocity)
    }

    private func pipeView(pipe: Pipe, height: CGFloat) -> some View {
        let gapHalf: CGFloat = 75
        let gapTop = pipe.gapCenterY - gapHalf
        let gapBottom = pipe.gapCenterY + gapHalf

        return ZStack {
            pipeColumn(height: gapTop, y: gapTop / 2)
                .position(x: pipe.x + 32, y: gapTop / 2)

            pipeColumn(height: height - gapBottom, y: (height - gapBottom) / 2)
                .position(x: pipe.x + 32, y: gapBottom + (height - gapBottom) / 2)
        }
    }

    private func pipeColumn(height: CGFloat, y: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(pipeGreen)
            .frame(width: 64, height: max(height, 0))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(pipeDark)
                    .frame(width: 72, height: 28)
                    .offset(y: -6)
            }
    }

    private func groundLayer(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            Rectangle()
                .fill(Color(red: 0.88, green: 0.72, blue: 0.42))
                .frame(height: 72)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color(red: 0.42, green: 0.78, blue: 0.32))
                        .frame(height: 18)
                }
        }
        .frame(width: width, height: height)
    }

    private func cloudsLayer(in size: CGSize) -> some View {
        ZStack {
            cloud(at: CGPoint(x: size.width * 0.2, y: size.height * 0.15))
            cloud(at: CGPoint(x: size.width * 0.7, y: size.height * 0.22))
            cloud(at: CGPoint(x: size.width * 0.45, y: size.height * 0.08))
        }
    }

    private func cloud(at point: CGPoint) -> some View {
        ZStack {
            Circle().fill(.white.opacity(0.85)).frame(width: 36, height: 36)
            Circle().fill(.white.opacity(0.85)).frame(width: 28, height: 28).offset(x: -22, y: 6)
            Circle().fill(.white.opacity(0.85)).frame(width: 32, height: 32).offset(x: 22, y: 4)
        }
        .position(point)
    }

    @ViewBuilder
    private func overlay(in size: CGSize) -> some View {
        VStack {
            HStack {
                scoreBadge(title: "Score", value: game.score)
                Spacer()
                scoreBadge(title: "Best", value: game.bestScore)
            }
            .padding(.horizontal, 20)
            .padding(.top, 56)

            Spacer()

            switch game.phase {
            case .ready:
                promptCard(
                    title: "Flappy Cousin",
                    subtitle: "Tap to fly through the pipes!",
                    button: "Tap anywhere to start"
                )
            case .gameOver:
                promptCard(
                    title: "Ouch!",
                    subtitle: "Score: \(game.score)",
                    button: "Tap to try again"
                )
            case .playing:
                EmptyView()
            }
        }
        .frame(width: size.width, height: size.height)
    }

    private func scoreBadge(title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.85))
            Text("\(value)")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.2), radius: 2, y: 1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(.black.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func promptCard(title: String, subtitle: String, button: String) -> some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            Text(button)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
                .padding(.top, 4)
        }
        .multilineTextAlignment(.center)
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.black.opacity(0.28))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding(.horizontal, 24)
        .padding(.bottom, 120)
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    FlappyBirdView()
}
