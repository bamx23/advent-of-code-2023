//
//  Day05.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 05/12/2023.
//

import Foundation
import Shared

public struct Day05: Day {
    static public let number = 5

    let input: String

    typealias RangeMap = (src: Range<Int>, dst: Range<Int>)
    struct Game {
        var seeds: [Int]
        var maps: [[RangeMap]]
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> Game {
        let lines = input
            .split(separator: "\n")
            .map(String.init)

        let seeds = lines
            .first!.split(separator: ":")
            .last!.split(separator: " ")
            .map(String.init).compactMap(Int.init)
        var maps = [[RangeMap]]()
        var curMaps = [RangeMap]()
        for line in lines[2...] {
            if line.hasSuffix(":") {
                maps.append(curMaps)
                curMaps.removeAll()
                continue
            }
            let nums = line.split(separator: " ")
                .map(String.init).compactMap(Int.init)
            let src = nums[1]..<(nums[1] + nums[2])
            let dst = nums[0]..<(nums[0] + nums[2])
            curMaps.append((src, dst))
        }
        maps.append(curMaps)

        return .init(seeds: seeds, maps: maps)
    }

    public func part01() -> String {
        let game = parse()
        var curState = game.seeds
        for maps in game.maps {
            for idx in curState.indices {
                let val = curState[idx]
                for range in maps {
                    if range.src.contains(val) {
                        curState[idx] = range.dst.lowerBound + (val - range.src.lowerBound)
                        break
                    }
                }
            }
        }
        return "\(curState.min()!)"
    }

    public func part02() -> String {
        let game = parse()
        var curState: [Range<Int>] = (0..<(game.seeds.count / 2))
            .map { (idx: Int) -> (s: Int, l: Int) in (game.seeds[2 * idx], game.seeds[2 * idx + 1]) }
            .map { pair -> Range<Int> in pair.s..<(pair.s + pair.l) }
        for maps in game.maps {
            var nextState = [Range<Int>]()
            while curState.isEmpty == false {
                var valRange = curState.removeFirst()
                for range in maps {
                    let (src, dst) = range
                    guard src.overlaps(valRange) else { continue }

                    if valRange.lowerBound >= src.lowerBound {
                        if valRange.upperBound <= src.upperBound {
                            nextState.append(valRange.mapRange(src, dst))
                            valRange = 0..<0
                            break
                        } else {
                            nextState.append((valRange.lowerBound..<src.upperBound).mapRange(src, dst))
                            valRange = src.upperBound..<valRange.upperBound
                        }
                    } else {
                        if valRange.upperBound <= src.upperBound {
                            nextState.append((src.lowerBound..<valRange.upperBound).mapRange(src, dst))
                            valRange = valRange.lowerBound..<src.lowerBound
                        } else {
                            nextState.append(dst)
                            let remain = src.upperBound..<valRange.upperBound
                            if remain.isEmpty == false { curState.append(remain) }
                            valRange = valRange.lowerBound..<src.lowerBound
                        }
                    }
                }
                if valRange.isEmpty == false {
                    nextState.append(valRange)
                }
            }
            curState = nextState
        }
        return "\(curState.map(\.lowerBound).min()!)"
    }
}

private extension Range where Bound == Int {
    func mapRange(_ src: Self, _ dst: Self) -> Self {
        let delta = dst.lowerBound - src.lowerBound
        return (self.lowerBound + delta)..<(self.upperBound + delta)
    }
}
