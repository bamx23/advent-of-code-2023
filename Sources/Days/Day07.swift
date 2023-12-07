//
//  Day07.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 07/12/2023.
//

import Foundation
import Shared

public struct Day07: Day {
    static public let number = 7

    let input: String

    enum Card: String {
        case ace
        case king
        case queen
        case jack
        case ten
        case nine
        case eight
        case seven
        case six
        case five
        case four
        case three
        case two
        case joker

        var priority: Int {
            switch self {
            case .ace:      return 0
            case .king:     return 1
            case .queen:    return 2
            case .jack:     return 3
            case .ten:  	return 4
            case .nine:     return 5
            case .eight:    return 6
            case .seven:    return 7
            case .six:      return 8
            case .five:     return 9
            case .four:     return 10
            case .three:    return 11
            case .two:      return 12
            case .joker:    return 13
            }
        }

        static func parse(_ ch: Character, hasJokers: Bool) -> Self {
            switch ch {
            case "A": return .ace
            case "K": return .king
            case "Q": return .queen
            case "J": return hasJokers ? .joker : .jack
            case "T": return .ten
            case "9": return .nine
            case "8": return .eight
            case "7": return .seven
            case "6": return .six
            case "5": return .five
            case "4": return .four
            case "3": return .three
            case "2": return .two
            default:
                fatalError()
            }
        }
    }

    enum HandType: String {
        case fiveOfKind
        case fourOfKind
        case fullHouse
        case threeOfKind
        case twoPair
        case onePair
        case highCard

        var priority: Int {
            switch self {
            case .fiveOfKind:   return 0
            case .fourOfKind:   return 1
            case .fullHouse:    return 2
            case .threeOfKind:  return 3
            case .twoPair:      return 4
            case .onePair:      return 5
            case .highCard:     return 6
            }
        }
    }

    struct Hand {
        let cards: [Card]
        let type: HandType

        init(_ cards: [Card]) {
            self.cards = cards
            self.type = Self.resolveType(cards)
        }

        private static func resolveType(_ cards: [Card]) -> HandType {
            var countsMap: [Card: Int] = cards
                .reduce(into: [:], { $0[$1, default: 0] += 1 })
            if let jokersCount = countsMap[.joker] {
                countsMap[.joker] = nil
                let counts: [Int] = countsMap.values.sorted().reversed()
                if counts.count <= 1 { return .fiveOfKind }
                switch (jokersCount, counts[0], counts[1]) {
                case (3, 1, 1): return .fourOfKind
                case (2, 2, 1): return .fourOfKind
                case (2, 1, 1): return .threeOfKind
                case (1, 3, 1): return .fourOfKind
                case (1, 2, 2): return .fullHouse
                case (1, 2, 1): return .threeOfKind
                case (1, 1, 1): return .onePair
                default:
                    fatalError("Unknown joker combination: \(cards)")
                }
            } else {
                let counts: [Int] = countsMap.values.sorted().reversed()
                if counts.count == 1 { return .fiveOfKind }
                switch (counts[0], counts[1]) {
                case (4, _): return .fourOfKind
                case (3, 2): return .fullHouse
                case (3, 1): return .threeOfKind
                case (2, 2): return .twoPair
                case (2, 1): return .onePair
                case (1, _): return .highCard
                default:
                    fatalError("Unknown combination: \(cards)")
                }
            }
        }
    }

    public init(input: String) {
        self.input = input
    }

    func parse(hasJokers: Bool) -> [(hand: Hand, bet: Int)] {
        input
            .split(separator: "\n")
            .map { line in
                let pair = line.split(separator: " ")
                let cards = pair.first!.map { Card.parse($0, hasJokers: hasJokers) }
                let bet = Int(String(pair.last!))!
                return (.init(cards), bet)
            }
    }

    private func solve(hasJokers: Bool) -> String {
        let result = parse(hasJokers: hasJokers)
            .sorted(by: { $0.hand < $1.hand })
            .reversed()
            .enumerated()
            .map { (idx, h) in (idx + 1) * h.bet }
            .reduce(0, +)
        return "\(result)"
    }

    public func part01() -> String {
        return solve(hasJokers: false)
    }

    public func part02() -> String {
        return solve(hasJokers: true)
    }
}

extension Day07.Hand: Comparable {
    static func < (lhs: Day07.Hand, rhs: Day07.Hand) -> Bool {
        guard lhs.type.priority == rhs.type.priority else {
            return lhs.type.priority < rhs.type.priority
        }
        for (lhsCard, rhsCard) in zip(lhs.cards, rhs.cards) {
            guard lhsCard == rhsCard else {
                return lhsCard.priority < rhsCard.priority
            }
        }
        return false
    }
}
