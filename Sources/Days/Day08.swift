//
//  Day08.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 08/12/2023.
//

import Foundation
import Shared

public struct Day08: Day {
    static public let number = 8

    let input: String

    enum Dir {
        case right
        case left
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> ([Dir], [String:(l: String, r: String)]) {
        let lines = input
            .split(separator: "\n")
        let dirs: [Dir] = lines.first!.map { $0 == "L" ? .left : .right }
        let map: [String: (String, String)] = lines.dropFirst()
            .reduce(into: [:], { (r, line) in
                let regex = #/(?<src>\w+) = \((?<left>\w+), (?<right>\w+)\)/#
                let match = line.matches(of: regex).first!.output
                r[String(match.src)] = (String(match.left), String(match.right))
            })
        return (dirs, map)
    }

    public func part01() -> String {
        let (dirs, map) = parse()
        var cur = "AAA"
        guard map[cur] != nil else { return "-" }
        var step = 0
        var dirIdx = 0
        while cur != "ZZZ" {
            cur = dirs[dirIdx] == .left ? map[cur]!.l : map[cur]!.r
            step += 1
            dirIdx = (dirIdx + 1) % dirs.count
        }
        return "\(step)"
    }

    public func part02() -> String {
        struct Key: Hashable {
            var dirIdx: Int
            var cur: String
        }
        let (dirs, map) = parse()
        let starts = map.keys.filter { $0.hasSuffix("A") }.sorted()
        let loops: [(first: Int, next: Int)] = starts
            .map { start in
                var cur: Key = .init(dirIdx: 0, cur: start)
                var step = 0
                var memo = [Key: Int]()
                var endStep = 0
                while memo[cur] == nil {
                    memo[cur] = step
                    if cur.cur.hasSuffix("Z") { endStep = step }

                    cur.cur = dirs[cur.dirIdx] == .left ? map[cur.cur]!.l : map[cur.cur]!.r
                    cur.dirIdx = (cur.dirIdx + 1) % dirs.count
                    step += 1
                }
                let loopLen = step - memo[cur]!
                return (endStep, loopLen)
            }
        // This is assumption that either whole path is a loop or first completion is enough
        // Yeah, it works
        let result = loops.map(\.first).lcm()
        return "\(result)"
    }
}

private extension Int {
    var primes: [Int: Int] {
        if self <= 1 { return [:] }

        var result = [Int: Int]()
        var val = self
        var x = 2
        while x <= val {
            while val % x == 0 {
                result[x, default: 0] += 1
                val /= x
            }
            if val == 1 { break }
            x += 1
        }
        return result
    }
}

private extension Array where Element == Int {
    func gcd() -> Int {
        let factors = self.map(\.primes)
        let commonPrimes = factors
            .map(\.keys).map(Set.init)
            .reduce(Set(), { $0.isEmpty ? $1 : $0.intersection($1) })
        return commonPrimes
            .map { val in (val, factors.compactMap{ $0[val] }.min()!) }
            .map { (val, factor) in Int(pow(Double(val), Double(factor))) }
            .reduce(1, *)
    }

    func lcm() -> Int {
        let gcd = self.gcd()
        return self.reduce(gcd, { $0 * ($1 / gcd) })
    }
}
