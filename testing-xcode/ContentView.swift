//
//  ContentView.swift
//  testing-xcode
//
//  Created by Dennis Zhang on 5/28/26.
//

import Combine
import SwiftUI

struct ContentView: View {
    @State private var pulses: [Pulse] = []
    @State private var energy: Double = 0
    @State private var glowPhase: Double = 0
    @State private var showSignature = false

    private let timer = Timer.publish(every: 1 / 30, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                background

                ForEach(pulses) { pulse in
                    PulseRing(pulse: pulse, size: geo.size)
                }

                VStack(spacing: 0) {
                    header
                    Spacer()
                    coreOrb(in: geo.size)
                    Spacer()
                    footer
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .contentShape(Rectangle())
            .gesture(
                SpatialTapGesture()
                    .onEnded { value in
                        spawnPulse(at: value.location, in: geo.size)
                    }
            )
            .onReceive(timer) { _ in
                glowPhase += 0.04
                prunePulses()
                if energy > 0 { energy *= 0.985 }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .sensoryFeedback(.impact(weight: .medium), trigger: pulses.count)
    }

    private var background: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.02, blue: 0.14),
                    Color(red: 0.08, green: 0.05, blue: 0.22),
                    Color(red: 0.02, green: 0.12, blue: 0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.35 + energy * 0.002),
                            .clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 280
                    )
                )
                .frame(width: 520, height: 520)
                .blur(radius: 40)
                .offset(y: -80)
                .scaleEffect(1 + sin(glowPhase) * 0.06)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.purple.opacity(0.28),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 220
                    )
                )
                .frame(width: 400, height: 400)
                .blur(radius: 50)
                .offset(x: 100, y: 200)
                .scaleEffect(1 + cos(glowPhase * 0.8) * 0.08)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("PULSE LAB")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .tracking(4)
                .foregroundStyle(.white.opacity(0.55))

            Text("Tap anywhere")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            EnergyBar(level: min(energy / 120, 1))
                .frame(height: 8)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func coreOrb(in size: CGSize) -> some View {
        let scale = 1 + min(energy / 200, 0.45)

        return ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [.cyan, .purple, .pink, .cyan],
                            center: .center
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 200 + CGFloat(i) * 36, height: 200 + CGFloat(i) * 36)
                    .opacity(0.25 - Double(i) * 0.06)
                    .rotationEffect(.degrees(glowPhase * (12 + Double(i) * 8)))
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            .white.opacity(0.95),
                            Color.cyan.opacity(0.7),
                            Color.purple.opacity(0.2),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 90
                    )
                )
                .frame(width: 140, height: 140)
                .shadow(color: .cyan.opacity(0.6), radius: 30)
                .scaleEffect(scale)
                .animation(.spring(response: 0.35, dampingFraction: 0.65), value: energy)

            Text("\(Int(energy.rounded()))")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.numericText())
                .animation(.snappy, value: Int(energy.rounded()))
        }
        .frame(maxWidth: .infinity)
        .onTapGesture {
            spawnPulse(
                at: CGPoint(x: size.width / 2, y: size.height / 2),
                in: size,
                boost: 18
            )
        }
    }

    private var footer: some View {
        HStack {
            Text("dennis was here")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(showSignature ? 0.7 : 0.35))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSignature.toggle()
                    }
                }

            Spacer()

            Text(pulses.count > 12 ? "🔥" : "✨")
                .font(.title2)
        }
    }

    private func spawnPulse(at point: CGPoint, in size: CGSize, boost: Double = 12) {
        let normalized = CGPoint(
            x: point.x / max(size.width, 1),
            y: point.y / max(size.height, 1)
        )
        let pulse = Pulse(
            id: UUID(),
            origin: normalized,
            hue: Double.random(in: 0...1),
            born: Date()
        )
        pulses.append(pulse)
        energy = min(energy + boost, 999)
    }

    private func prunePulses() {
        let cutoff = Date().addingTimeInterval(-2.2)
        pulses.removeAll { $0.born < cutoff }
    }
}

// MARK: - Models & components

private struct Pulse: Identifiable {
    let id: UUID
    let origin: CGPoint
    let hue: Double
    let born: Date
}

private struct PulseRing: View {
    let pulse: Pulse
    let size: CGSize

    @State private var expand = false

    private var color: Color {
        Color(hue: pulse.hue, saturation: 0.75, brightness: 0.95)
    }

    var body: some View {
        Circle()
            .stroke(color.opacity(expand ? 0 : 0.85), lineWidth: expand ? 1 : 3)
            .background(
                Circle()
                    .fill(color.opacity(expand ? 0 : 0.12))
            )
            .frame(width: expand ? 220 : 24, height: expand ? 220 : 24)
            .position(
                x: pulse.origin.x * size.width,
                y: pulse.origin.y * size.height
            )
            .blur(radius: expand ? 1 : 0)
            .onAppear {
                withAnimation(.easeOut(duration: 1.8)) {
                    expand = true
                }
            }
    }
}

private struct EnergyBar: View {
    let level: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.12))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * level)
                    .animation(.spring(response: 0.4), value: level)
            }
        }
    }
}

#Preview {
    ContentView()
}
