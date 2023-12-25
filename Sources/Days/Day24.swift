//
//  Day24.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 24/12/2023.
//

import Foundation
import Shared
import Algorithms

public struct Day24: Day {
    static public let number = 24

    let input: String

    struct Hailstone {
        var pos: Pos3f
        var speed: Pos3f
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [Hailstone] {
        input
            .split(separator: "\n")
            .map { line in
                let match = line.matches(of: #/(?<px>-?\d+),\s+(?<py>-?\d+),\s+(?<pz>-?\d+)\s+@\s+(?<vx>-?\d+),\s+(?<vy>-?\d+),\s+(?<vz>-?\d+)/#).first!.output
                return .init(
                    pos: .init(x: Double(match.px)!, y: Double(match.py)!, z: Double(match.pz)!),
                    speed: .init(x: Double(match.vx)!, y: Double(match.vy)!, z: Double(match.vz)!)
                )
            }
    }

    public func part01() -> String {
        let stones = parse()
        let testArea: ClosedRange<Double> = stones.count < 10 ? 7...27 : 200000000000000...400000000000000
        let result = stones
            .map { s -> Hailstone in .init(
                pos: .init(x: s.pos.x, y: s.pos.y, z: 0),
                speed: .init(x: s.speed.x, y: s.speed.y, z: 0)
            ) }
            .combinations(ofCount: 2)
            .compactMap { pair -> Pos3f? in
                let (a, b) = (pair.first!, pair.last!)
                return a.intersection(b)
            }
            .filter { testArea.contains($0.x) && testArea.contains($0.y) }
        return "\(result.count)"
    }

    public func part02() -> String {
        /*
         I've tried solving it with Genetics but with no success.
         Ended up solving 9 equations based on first 3 stones data (enough).
         */
        return "manual"
    }

    public func __part02() -> String {
        let stones = parse()
        let (a, b) = (stones[0], stones[1])

        struct Key: Hashable {
            var tA: Int
            var tB: Int
        }

        struct Opt: Hashable {
            var t: Key
            var s: Double
        }

        func line(_ t: Key) -> Hailstone {
            let posA = a.pos + a.speed * Double(t.tA)
            let posB = b.pos + b.speed * Double(t.tB)
            let speed = (posB - posA) / Double(t.tB - t.tA)
            let pos = posA - Double(t.tA) * speed
            let throwLine = Hailstone(pos: pos, speed: speed)
            return throwLine
        }

        func score(_ t: Key) -> Double {
            let throwLine = line(t)
            return stones
                .dropFirst(2)
                .map { s -> Double in
                    guard let (t1, t2) = throwLine.intersectionTimes(s) else {
                        return 1_000_000
                    }
                    return abs(t1 - t2)
                }
                .reduce(0, +)
        }
        if stones.count < 10 {
            assert(score(.init(tA: 5, tB: 3)) == 0)
        }

        let range = 0..<100_000_000_000
        let popSize = 10
        let mutSize = 90
        let mutFract = 0.5
//        let mutRange = -100_000...100_000
        let randSize = 20
        let crossSize = 0
        var population: [Opt] = (0..<popSize)
            .map { _ -> Key in .init(tA: range.randomElement()!, tB: range.randomElement()!) }
            .map { t in .init(t: t, s: score(t)) }
            .sorted(by: { $0.s < $1.s })
        var gen = 0
        var best = population.first!
        while true {
            let cross = population
                .map(\.t)
                .permutations(ofCount: 2)
                .randomSample(count: crossSize)
                .map { p -> Key in
                    Key(tA: (min(p[0].tA, p[1].tA)...max(p[0].tA, p[1].tA)).randomElement()!,
                        tB: (min(p[0].tB, p[1].tB)...max(p[0].tB, p[1].tB)).randomElement()!)
                }
            let mut = population
                .map(\.t)
                .randomSample(count: mutSize)
                .map { t -> Key in
                    let rangeA: ClosedRange<Int> =
                        Int(Double(t.tA) * (1 - mutFract))...Int(Double(t.tA) * (1 + mutFract))
                    let rangeB: ClosedRange<Int> =
                        Int(Double(t.tB) * (1 - mutFract))...Int(Double(t.tB) * (1 + mutFract))
                    return Key(tA: rangeA.randomElement()!.clamp(range),
                               tB: rangeB.randomElement()!.clamp(range))
//                    return Key(tA: (t.tA + mutRange.randomElement()!).clamp(range),
//                        tB: (t.tB + mutRange.randomElement()!).clamp(range))
                }
            let rand = (0..<randSize)
                .map { _ in Key(tA: range.randomElement()!, tB: range.randomElement()!) }

            let extra = (cross + mut + rand)
                .map { Opt(t: $0, s: score($0)) }
            population = Set(population + extra)
                .sorted(by: { $0.s < $1.s })
                .prefix(popSize)
                .map { $0 }

            if best.s > population.first!.s {
                best = population.first!
                print(String(format: "%07d %0.9f %@", gen, best.s, "\(best.t)"))
            }
            if best.s == 0 { break }
            gen += 1
        }
        return "\(0)"
    }
}

private extension Day24.Hailstone {
    func intersectionTimes(_ other: Self) -> (Double, Double)? {
        guard self.pos != other.pos else { return (0, 0) }

        // Check if the rays are parallel (cross product of their directions is zero)
        let crossProduct = speed.cross(other.speed)
        guard crossProduct.norm2() != 0 else {
            // Rays are parallel and may not intersect
            return nil
        }

//        guard (other.pos - pos).dot(crossProduct) == 0 else {
//            // Rays are not coplanar
//            return nil
//        }

        // Calculate parameters for the intersection point
        let delta = other.pos - pos
        let dd = crossProduct.dot(crossProduct)
        let t1 = crossProduct.dot(delta.cross(other.speed)) / dd
        let t2 = crossProduct.dot(delta.cross(speed)) / dd

        return (t1, t2)
    }

    func intersection(_ other: Self) -> Pos3f? {
        guard let (t1, t2) = intersectionTimes(other) else { return nil }
        guard t1 >= 0.0 && t2 >= 0.0 else { return nil }

        // Calculate the intersection point
        let intersectionPoint = pos + t1 * speed
        return intersectionPoint
    }
}

private extension Int {
    func clamp(_ range: Range<Int>) -> Int {
        self < range.lowerBound ? range.lowerBound : (self >= range.upperBound ? range.upperBound - 1 : self)
    }
}

private extension Array where Element == Pos3f {
    func angles() -> [Double] {
//        combinations(ofCount: 3)
//            .map { comb in
//                let (a, b, c) = (comb[0], comb[1], comb[2])
        (0..<count)
            .map { idx -> Double in
                let (a, b, c) = (self[idx], self[(idx + 1) % count], self[(idx + 2) % count])
                guard a != c && b != c else { return 0.0 }
                let denom = (b - a).norm()
                guard denom != 0.0 else { return 1.0 }
                let dist = ((b - a).cross(a - c)).norm() / denom
                let angle = atan2(dist, denom)
                return angle
            }
    }
}
