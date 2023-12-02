//
//  Day02.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 02/12/2023.
//

import Foundation
import Shared

public struct Day02: Day {
    static public let number = 2

    let input: String

    public init(input: String) {
        self.input = input
    }

    enum Color: String, CaseIterable {
        case red
        case green
        case blue
    }

    struct Game {
        var id: Int
        var sets: [[Color:Int]]
    }

    func parse() -> [Game] {
        input
            .split(separator: "\n")
            .enumerated()
            .map { (idx, line) -> Game in
                let setsStr = line.split(separator: ":").last!
                return .init(id: idx + 1, sets: setsStr.split(separator: ";").map { setStr -> [Color:Int] in
                    let cubes = setStr.split(separator: ",")
                    return .init(uniqueKeysWithValues: cubes.map { cStr -> (Color, Int) in
                        let parts = cStr.split(separator: " ").map { String($0) }
                        return (Color(rawValue: parts.last!)!, Int(parts.first!)!)
                    })
                })
            }
    }

    public func part01() -> String {
        let maxCubes: [Color: Int] = [
            .red: 12,
            .green: 13,
            .blue: 14
        ]
        let games = parse()
        let count = games
            .filter { game in
                game.sets.allSatisfy { s in
                    Color.allCases.allSatisfy { c in
                        (s[c] ?? 0) <= maxCubes[c]!
                    }
                }
            }
            .map(\.id)
            .reduce(0, +)
        return "\(count)"
    }

    public func part02() -> String {
        let games = parse()
        let sum = games
            .map { game in
                Color.allCases.compactMap { color in
                    game.sets
                        .compactMap { $0[color] }
                        .max()
                }
                .reduce(1, *)
            }
            .reduce(0, +)
        return "\(sum)"
    }
}
