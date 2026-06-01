//
//  FlappyBirdGame.swift
//  testing-xcode
//

import Foundation
import SwiftUI

struct Pipe: Identifiable, Equatable {
    let id = UUID()
    var x: CGFloat
    var gapCenterY: CGFloat
    var scored: Bool = false
}

enum FlappyPhase {
    case ready
    case playing
    case gameOver
}

@Observable
final class FlappyBirdGame {
    var birdY: CGFloat = 0
    var birdVelocity: CGFloat = 0
    var pipes: [Pipe] = []
    var score = 0
    var bestScore = 0
    var phase: FlappyPhase = .ready

    private var lastUpdate: Date?
    private var playfieldHeight: CGFloat = 600
    private var playfieldWidth: CGFloat = 350

    private let birdRadius: CGFloat = 18
    private let birdXRatio: CGFloat = 0.28
    private let gravity: CGFloat = 980
    private let flapVelocity: CGFloat = -320
    private let pipeWidth: CGFloat = 64
    private let gapHeight: CGFloat = 150
    private let pipeSpeed: CGFloat = 180
    private let pipeSpacing: CGFloat = 220

    init() {
        bestScore = UserDefaults.standard.integer(forKey: "flappy.bestScore")
    }

    var birdX: CGFloat { playfieldWidth * birdXRatio }

    func configure(width: CGFloat, height: CGFloat) {
        playfieldWidth = width
        playfieldHeight = height
        if phase == .ready {
            birdY = height * 0.45
        }
    }

    func tap() {
        switch phase {
        case .ready:
            start()
            flap()
        case .playing:
            flap()
        case .gameOver:
            reset()
        }
    }

    func update(at date: Date) {
        guard phase == .playing else {
            lastUpdate = date
            return
        }

        let delta = min(CGFloat(date.timeIntervalSince(lastUpdate ?? date)), 1 / 30)
        lastUpdate = date

        birdVelocity += gravity * delta
        birdY += birdVelocity * delta

        for index in pipes.indices {
            pipes[index].x -= pipeSpeed * delta
        }

        pipes.removeAll { $0.x + pipeWidth < -20 }

        if let lastPipe = pipes.last {
            if lastPipe.x < playfieldWidth - pipeSpacing {
                spawnPipe()
            }
        } else {
            spawnPipe(at: playfieldWidth + 80)
        }

        scorePipes()
        checkCollisions()
    }

    private func start() {
        phase = .playing
        score = 0
        pipes.removeAll()
        birdY = playfieldHeight * 0.45
        birdVelocity = 0
        spawnPipe(at: playfieldWidth + 80)
        lastUpdate = nil
    }

    private func reset() {
        phase = .ready
        score = 0
        pipes.removeAll()
        birdY = playfieldHeight * 0.45
        birdVelocity = 0
        lastUpdate = nil
    }

    private func flap() {
        birdVelocity = flapVelocity
    }

    private func spawnPipe(at x: CGFloat? = nil) {
        let minGap = gapHeight / 2 + 60
        let maxGap = playfieldHeight - gapHeight / 2 - 60
        let gapCenter = CGFloat.random(in: minGap...max(maxGap, minGap + 1))
        pipes.append(Pipe(x: x ?? playfieldWidth + pipeWidth, gapCenterY: gapCenter))
    }

    private func scorePipes() {
        for index in pipes.indices where !pipes[index].scored {
            if pipes[index].x + pipeWidth < birdX {
                pipes[index].scored = true
                score += 1
            }
        }
    }

    private func checkCollisions() {
        let top = birdY - birdRadius
        let bottom = birdY + birdRadius

        if top <= 0 || bottom >= playfieldHeight {
            endGame()
            return
        }

        for pipe in pipes {
            let pipeLeft = pipe.x
            let pipeRight = pipe.x + pipeWidth
            let birdRight = birdX + birdRadius
            let birdLeft = birdX - birdRadius

            guard birdRight > pipeLeft, birdLeft < pipeRight else { continue }

            let gapTop = pipe.gapCenterY - gapHeight / 2
            let gapBottom = pipe.gapCenterY + gapHeight / 2

            if top < gapTop || bottom > gapBottom {
                endGame()
                return
            }
        }
    }

    private func endGame() {
        phase = .gameOver
        if score > bestScore {
            bestScore = score
            UserDefaults.standard.set(bestScore, forKey: "flappy.bestScore")
        }
    }
}
