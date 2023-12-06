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

    public func part01() -> String {
        let data = parse()
        let result = data
            .map { d in
                (1..<d.time)
                    .map { t in (d.time - t) * t }
                    .filter { $0 > d.dst }
                    .count
            }
            .reduce(1, *)
        return "\(result)"
    }

    public func part02() -> String {
        let data = parse()
        let time = Int(data.map(\.time.description).joined())!
        let dst = Int(data.map(\.dst.description).joined())!
        let result = (1..<time)
            .map { t in (time - t) * t }
            .filter { $0 > dst }
            .count
        return "\(result)"
    }
}
