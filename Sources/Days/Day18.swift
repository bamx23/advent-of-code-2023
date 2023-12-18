//
//  Day18.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 18/12/2023.
//

import Foundation
import Shared

public struct Day18: Day {
    static public let number = 18

    let input: String

    struct Dig {
        var dir: Dir
        var len: Int
        var color: String
    }

    struct Line {
        var start: Pos
        var dir: Dir
        var len: Int
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [Dig] {
        input
            .split(separator: "\n")
            .map { line in
                let regex = #/(?<dir>[UDLR])\s+(?<len>\d+)\s+\(#(?<color>[0-9a-f]+)\)/#
                let match = line.matches(of: regex).first!.output
                return Dig(dir: .parseForDig(match.dir), len: Int(match.len)!, color: String(match.color))
            }
    }

    private func solve(digs: [Dig]) -> Int {
        var pos = Pos(x: 0, y: 0)
        var map: [Line] = []
        for dig in digs {
            map.append(.init(start: pos, dir: dig.dir, len: dig.len))
            pos = pos + dig.dir.delta * dig.len
        }

        let hLines = map
            .compactMap { line -> (y: Int, l: Int, r: Int)? in
                switch line.dir {
                case .up, .down: return nil
                case .left: return (line.start.y, line.start.x - line.len, line.start.x)
                case .right: return (line.start.y, line.start.x, line.start.x + line.len)
                }
            }
            .grouped(by: { $0.y })
            .mapValues { lines -> [ClosedRange<Int>] in
                lines
                    .sorted { $0.l < $1.l }
                    .map { $0.l...$0.r }
            }

        var result = 0
        var intervals = [ClosedRange<Int>]()
        var prevCount = 0
        var prevY = Int.min / 2
        for y in hLines.keys.sorted() {
            var newIntervals = [ClosedRange<Int>]()

            var thisCount = 0
            func addInterval(_ val: ClosedRange<Int>) {
                if let last = newIntervals.last, last.upperBound == val.lowerBound {
                    newIntervals[newIntervals.count - 1] = last.lowerBound...val.upperBound
                    thisCount += val.count - 1
                } else {
                    newIntervals.append(val)
                    thisCount += val.count
                }
            }

            var idx = 0
            for line in hLines[y]! {
                while intervals.indices.contains(idx) && intervals[idx].upperBound < line.lowerBound {
                    addInterval(intervals[idx])
                    idx += 1
                }
                if !intervals.indices.contains(idx) || intervals[idx].lowerBound > line.upperBound {
                    addInterval(line)
                    continue
                }
                let curInterval = intervals[idx]

                if curInterval == line {
                    // Remove full interval
                    thisCount += curInterval.count
                    idx += 1
                    continue
                }
                if curInterval.lowerBound == line.lowerBound {
                    // Same left point
                    intervals[idx] = line.upperBound...curInterval.upperBound
                    thisCount += line.count - 1
                    continue
                }
                if curInterval.upperBound == line.upperBound {
                    // Same right point
                    addInterval(curInterval.lowerBound...line.lowerBound)
                    thisCount += line.count - 1
                    idx += 1
                    continue
                }
                if curInterval.lowerBound == line.upperBound {
                    // Extend left
                    intervals[idx] = line.lowerBound...curInterval.upperBound
                    continue
                }
                if curInterval.upperBound == line.lowerBound {
                    // Extend right
                    addInterval(curInterval.lowerBound...line.upperBound)
                    idx += 1
                    continue
                }

                // Inside
                addInterval(curInterval.lowerBound...line.lowerBound)
                intervals[idx] = line.upperBound...curInterval.upperBound
                thisCount += line.count - 2
            }
            while intervals.indices.contains(idx) {
                addInterval(intervals[idx])
                idx += 1
            }

            intervals = newIntervals
            result += thisCount + (prevCount * (y - prevY - 1))
            prevY = y
            prevCount = intervals.map(\.count).reduce(0, +)
        }
        assert(intervals.isEmpty)
        return result
    }

    public func part01() -> String {
        let digs = parse()
        let result = solve(digs: digs)
        return "\(result)"
    }

    public func part02() -> String {
        let digs = parse()
            .map { dig in
                let len = Int(String(dig.color.dropLast()), radix: 16)!
                let dir = Dir.parseForDigColor(dig.color.last!)
                return Dig(dir: dir, len: len, color: "")
            }
        let result = solve(digs: digs)
        return "\(result)"
    }
}

private extension Dir {
    static func parseForDig(_ str: Substring) -> Self {
        switch str {
        case "U": return .up
        case "D": return .down
        case "L": return .left
        case "R": return .right
        default: fatalError("Unknown direction: \(str)")
        }
    }

    static func parseForDigColor(_ ch: Character) -> Self {
        switch ch {
        case "3": return .up
        case "1": return .down
        case "2": return .left
        case "0": return .right
        default: fatalError("Unknown direction: \(ch)")
        }
    }
}

private extension Day18.Line {
    func contains(_ pos: Pos) -> Bool {
        switch dir {
        case .up:       return pos.x == start.x && (start.y - len <= pos.y && pos.y <= start.y)
        case .down:     return pos.x == start.x && (start.y <= pos.y && pos.y <= start.y + len)
        case .left:     return pos.y == start.y && (start.x - len <= pos.x && pos.x <= start.x)
        case .right:    return pos.y == start.y && (start.x <= pos.x && pos.x <= start.x + len)
        }
    }
}
