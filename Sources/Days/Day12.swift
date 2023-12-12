//
//  Day12.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 12/12/2023.
//

import Foundation
import Algorithms
import Shared

public struct Day12: Day {
    static public let number = 12

    let input: String

    enum Condition {
        case operational
        case damaged
        case unknown
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [([Condition], [Int])] {
        input
            .split(separator: "\n")
            .map { line in
                let pair = line.split(separator: " ")
                return (
                    pair.first!.map(Condition.parse), 
                    pair.last!.split(separator: ",").map(String.init).compactMap(Int.init)
                )
            }
    }

    private func solve(line: [Condition], nums: [Int]) -> Int {
        struct Key: Hashable {
            var lineIdx: Int
            var numIdx: Int
            var curNum: Int
            var inDamage: Bool
        }

        var (line, nums) = (line, nums)
        var memo = [Key: Int]()
        func sub(_ lineIdx: Int, _ numIdx: Int, _ inDamage: Bool) -> Int {
            guard lineIdx < line.count else {
                let isCorrect =
                    inDamage && (numIdx == nums.count - 1) && nums.last! == 0
                    || inDamage == false && numIdx == nums.count
                return isCorrect ? 1 : 0
            }
            switch line[lineIdx] {
            case .operational:
                if inDamage {
                    return nums[numIdx] == 0
                        ? sub(lineIdx + 1, numIdx + 1, false)
                        : 0
                }
                return sub(lineIdx + 1, numIdx, false)
            case .damaged:
                guard numIdx < nums.count && nums[numIdx] > 0 else { return 0 }
                nums[numIdx] -= 1
                let result = sub(lineIdx + 1, numIdx, true)
                nums[numIdx] += 1
                return result
            case .unknown:
                let key = Key(
                    lineIdx: lineIdx,
                    numIdx: numIdx,
                    curNum: (numIdx < nums.count ? nums[numIdx] : -1),
                    inDamage: inDamage
                )
                if let result = memo[key] { return result }

                line[lineIdx] = .operational
                let opResult = sub(lineIdx, numIdx, inDamage)
                line[lineIdx] = .damaged
                let damResult = sub(lineIdx, numIdx, inDamage)
                line[lineIdx] = .unknown
                let result = damResult + opResult
                memo[key] = result

                return result
            }
        }
        return sub(0, 0, false)
    }

    public func part01() -> String {
        let result = parse()
            .map(solve)
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let result = parse()
            .map { (l, n) -> ([Condition], [Int]) in
                (
                    l + [.unknown] + l + [.unknown] + l + [.unknown] + l + [.unknown] + l,
                    n + n + n + n + n
                )
            }
            .map(solve)
            .reduce(0, +)
        return "\(result)"
    }
}

extension Day12.Condition {
    static func parse(_ ch: Character) -> Self {
        switch ch {
        case ".": return .operational
        case "#": return .damaged
        case "?": return .unknown
        default: fatalError("Unknown condition: \(ch)")
        }
    }
}
