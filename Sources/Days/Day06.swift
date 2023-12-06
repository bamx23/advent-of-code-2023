//
//  Day06.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 06/12/2023.
//

import Foundation
import Shared

public struct Day06: Day {
    static public let number = 6

    let input: String

    public init(input: String) {
        self.input = input
    }

    func parse() -> [(time: Int, dst: Int)] {
        let nums = input
            .split(separator: "\n")
            .map { l in l.split(separator: " ").dropFirst().map(String.init).compactMap(Int.init) }
        return zip(nums.first!, nums.last!).map { (time: $0.0, dst: $0.1) }
    }

    private func solve(_ d: (time: Int, dst: Int)) -> Int {
        // time = a + b
        // a * b > dst <=> (time - b) * b > dst <=> -b^2 + time * b - dst > 0
        // Zeros: (time +- sqrt(time ^ 2 - 4 * dst) / 2
        let f = sqrt(Double(d.time * d.time - 4 * d.dst))
        var (b1, b2) = (
            Int((Double(d.time) - f) / 2.0),
            Int((Double(d.time) + f) / 2.0)
        )
        if (d.time - b1) * b1 <= d.dst { b1 += 1 }
        if (d.time - b2) * b2 <= d.dst { b2 -= 1 }
        return b2 - b1 + 1
    }

    public func part01() -> String {
        let result = parse().map(solve).reduce(1, *)
        return "\(result)"
    }

    public func part02() -> String {
        let data = parse()
        let time = Int(data.map(\.time.description).joined())!
        let dst = Int(data.map(\.dst.description).joined())!
        let result = solve((time, dst))
        return "\(result)"
    }
}
