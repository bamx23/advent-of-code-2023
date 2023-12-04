//
//  Day04.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 04/12/2023.
//

import Foundation
import Shared

public struct Day04: Day {
    static public let number = 4

    let input: String

    struct Card {
        var winNums: Set<Int>
        var elfNums: Set<Int>
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [Card] {
        input
            .split(separator: "\n")
            .map { line in
                let pair = line
                    .split(separator: ":").last!
                    .split(separator: "|")
                    .map { p in p.split(separator: " ").map { Int(String($0))! } }
                return .init(winNums: .init(pair.first!), elfNums: .init(pair.last!))
            }
    }

    func wins() -> [Int] {
        let cards = parse()
        return cards.map { (card) -> Int in
            card.elfNums.intersection(card.winNums).count
        }
    }

    public func part01() -> String {
        let result = wins()
            .filter { $0 != 0 }
            .map { 1 << ($0 - 1) }
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let wins = wins()
        var totalCards = [Int](repeating: 1, count: wins.count)
        for (idx, winsNum) in wins.enumerated() {
            if winsNum == 0 { continue }
            for nIdx in (idx + 1)...(idx + winsNum) {
                if nIdx >= wins.count { break }
                totalCards[nIdx] += totalCards[idx]
            }
        }
        let result = totalCards.reduce(0, +)
        return "\(result)"
    }
}
