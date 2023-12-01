//
//  Day01.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 01/12/2023.
//

import Foundation
import Shared

public struct Day01: Day {
    static public let number = 1

    let input: String
    
    public init(input: String) {
        self.input = input
    }
    
    func parse() -> [String] {
        input
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
    }
    
    public func part01() -> String {
        let lines = parse()
        let result = lines
        .compactMap { str in
            let digs = str.compactMap(\.wholeNumberValue)
            if digs.count == 0 { return nil }
            return digs.first! * 10 + digs.last!
        }
        .reduce(0, +)
        return "\(result)"
    }
    
    public func part02() -> String {
        let lines = parse()

        let allDigs = [
            ("one", 1),
            ("two", 2),
            ("three", 3),
            ("four", 4),
            ("five", 5),
            ("six", 6),
            ("seven", 7),
            ("eight", 8),
            ("nine", 9),
        ]

        let result = lines
        .compactMap { str in
            var (firstDig, lastDig): (Int?, Int?)
            var idx = 0
            var runStr = str
            while !runStr.isEmpty {
                var curDig: Int?
                for (name, dig) in allDigs {
                    if runStr.hasPrefix(name) {
                        curDig = dig
                        break
                    }
                }
                let ch = runStr.removeFirst()
                if ch.isNumber {
                    curDig = ch.wholeNumberValue
                }
                idx += 1

                firstDig = firstDig ?? curDig
                lastDig = curDig ?? lastDig
            }

            guard let f = firstDig, let l = lastDig else { return nil }
            return f * 10 + l
        }
        .reduce(0, +)
        return "\(result)"
    }
}
