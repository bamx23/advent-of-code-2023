//
//  Day09.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 09/12/2023.
//

import Foundation
import Shared

public struct Day09: Day {
    static public let number = 9

    let input: String

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Int]] {
        input
            .split(separator: "\n")
            .map { l in l.split(separator: " ").map(String.init).compactMap(Int.init) }
    }

    private func calcMaps() -> [[[Int]]] {
        parse().map { nums in
            var map = [nums]
            for d in 1..<nums.count {
                var allZeros = true
                var nextRow = [Int]()
                for x in 0..<(nums.count - d) {
                    let diff = map[d-1][x+1] - map[d-1][x]
                    if diff != 0 { allZeros = false }
                    nextRow.append(diff)
                }
                map.append(nextRow)
                if allZeros { break }
            }
            return map
        }
    }

    public func part01() -> String {
        let result = calcMaps()
            .map { $0.compactMap(\.last).reduce(0, +) }
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let result = calcMaps()
            .map { map in
                map.reversed().compactMap(\.first).reduce(0, { $1 - $0 })
            }
            .reduce(0, +)
        return "\(result)"
    }
}
