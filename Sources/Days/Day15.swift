//
//  Day15.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 15/12/2023.
//

import Foundation
import Shared

public struct Day15: Day {
    static public let number = 15

    let input: String

    public init(input: String) {
        self.input = input
    }

    func parse() -> [String] {
        input
            .trimmingCharacters(in: .newlines)
            .split(separator: ",")
            .map(String.init)
    }

    public func part01() -> String {
        let result = parse()
            .map(\.taskHash)
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let commands = parse()
            .map { line -> (String, Int?) in
                if line.hasSuffix("-") {
                    return (String(line.dropLast()), nil)
                }
                let pair = line.split(separator: "=")
                return (String(pair.first!), Int(pair.last!)!)
            }

        var hashmap = [[(String, Int)]].init(repeating: [], count: 256)
        for (label, lense) in commands {
            let idx = label.taskHash
            if let val = lense {
                var tmp = hashmap[idx]
                if let replaceIdx = tmp.firstIndex(where: { $0.0 == label }) {
                    tmp[replaceIdx] = (label, val)
                } else {
                    tmp.append((label, val))
                }
                hashmap[idx] = tmp
            } else {
                var tmp = hashmap[idx]
                if let removeIdx = tmp.firstIndex(where: { $0.0 == label }) {
                    tmp.remove(at: removeIdx)
                    hashmap[idx] = tmp
                }
            }
        }

        let result = hashmap
            .enumerated()
            .flatMap { (boxIdx, box) in
                box.enumerated()
                    .map { (slotIdx, slot) in
                        (boxIdx + 1) * (slotIdx + 1) * slot.1
                    }
            }
            .reduce(0, +)
        return "\(result)"
    }
}

private extension String {
    var taskHash: Int {
        self
            .compactMap(\.asciiValue)
            .map(Int.init)
            .reduce(0, { (($0 + $1) * 17) % 256 })
    }
}
