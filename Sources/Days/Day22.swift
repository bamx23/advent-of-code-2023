//
//  Day22.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 22/12/2023.
//

import Foundation
import Shared

public struct Day22: Day {
    static public let number = 22

    let input: String

    struct Brick {
        enum BrickType {
            case x
            case y
            case z
        }
        var pos: Pos3
        var type: BrickType
        var len: Int

        init(a: Pos3, b: Pos3) {
            if a.x == b.x && a.y == b.y {
                pos = .init(x: a.x, y: a.y, z: min(a.z, b.z))
                type = .z
                len = abs(a.z - b.z) + 1
                return
            }
            if a.x == b.x && a.z == b.z {
                pos = .init(x: a.x, y: min(a.y, b.y), z: a.z)
                type = .y
                len = abs(a.y - b.y) + 1
                return
            }
            if a.y == b.y && a.z == b.z {
                pos = .init(x: min(a.x, b.x), y: a.y, z: a.z)
                type = .x
                len = abs(a.x - b.x) + 1
                return
            }
            fatalError("Unsupported brick")
        }

        init(pos: Pos3, type: BrickType, len: Int) {
            self.pos = pos
            self.type = type
            self.len = len
        }
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> [Brick] {
        input
            .split(separator: "\n")
            .map { line in
                let match = line.matches(of: #/(?<x1>\d+),(?<y1>\d+),(?<z1>\d+)~(?<x2>\d+),(?<y2>\d+),(?<z2>\d+)/#).first!.output
                return .init(
                    a: .init(x: Int(match.x1)!, y: Int(match.y1)!, z: Int(match.z1)!),
                    b: .init(x: Int(match.x2)!, y: Int(match.y2)!, z: Int(match.z2)!)
                )
            }
    }

    public func part01() -> String {
        var bricks = parse()
            .sorted(by: { $0.pos.z < $1.pos.z })

        let coords = bricks.map(\.maxPos)
        let (d, h, w) = (
            coords.map(\.z).max()! + 2,
            coords.map(\.y).max()! + 1,
            coords.map(\.x).max()! + 1
        )
        var map = [[[Int]]](
            repeating: [[Int]](
                repeating: [Int](
                    repeating: -1,
                    count: w
                ),
                count: h
            ),
            count: d
        )
        for (idx, brick) in bricks.enumerated() {
            brick.addTo(&map, tag: idx)
        }

        while true {
            var idx = 0
            var anyFall = false
            while idx < bricks.count {
                let brick = bricks[idx]
                if let down = brick.down, down.canAddTo(map, tag: idx) {
                    brick.removeFrom(&map)
                    down.addTo(&map, tag: idx)
                    bricks[idx] = down
                    anyFall = true
                } else {
                    idx += 1
                }
            }
            if anyFall == false { break }
        }

        var result = 0
        for idx in bricks.indices {
            let brick = bricks[idx]
            brick.removeFrom(&map)
            let sIdxs = Set(brick.up.cubes.map { map[$0.z][$0.y][$0.x] }.filter { $0 != -1 })
            var anyFall = false
            for nextIdx in sIdxs {
                guard let down = bricks[nextIdx].down else { break }
                if down.canAddTo(map, tag: nextIdx) {
                    anyFall = true
                    break
                }
            }
            if anyFall == false {
                result += 1
            }
            brick.addTo(&map, tag: idx)
        }

        return "\(result)"
    }

    public func part02() -> String {
        var bricks = parse()
            .sorted(by: { $0.pos.z < $1.pos.z })

        let coords = bricks.map(\.maxPos)
        let (d, h, w) = (
            coords.map(\.z).max()! + 2,
            coords.map(\.y).max()! + 1,
            coords.map(\.x).max()! + 1
        )
        var map = [[[Int]]](
            repeating: [[Int]](
                repeating: [Int](
                    repeating: -1,
                    count: w
                ),
                count: h
            ),
            count: d
        )
        for (idx, brick) in bricks.enumerated() {
            brick.addTo(&map, tag: idx)
        }

        while true {
            var idx = 0
            var anyFall = false
            while idx < bricks.count {
                let brick = bricks[idx]
                if let down = brick.down, down.canAddTo(map, tag: idx) {
                    brick.removeFrom(&map)
                    down.addTo(&map, tag: idx)
                    bricks[idx] = down
                    anyFall = true
                } else {
                    idx += 1
                }
            }
            if anyFall == false { break }
        }

        var result = 0
        for idx in bricks.indices {
            let brick = bricks[idx]
            brick.removeFrom(&map)
            var fallenBricks = Set<Int>()
            var mapCopy = map
            var bricksCopy = bricks
            var anyFall = true
            while anyFall {
                anyFall = false
                var nextIdx = idx + 1
                while nextIdx < bricksCopy.count {
                    let nextBrick = bricksCopy[nextIdx]
                    if let down = nextBrick.down, down.canAddTo(mapCopy, tag: nextIdx) {
                        nextBrick.removeFrom(&mapCopy)
                        down.addTo(&mapCopy, tag: nextIdx)
                        bricksCopy[nextIdx] = down
                        anyFall = true
                        fallenBricks.insert(nextIdx)
                    } else {
                        nextIdx += 1
                    }
                }
            }
            brick.addTo(&map, tag: idx)
            result += fallenBricks.count
        }

        return "\(result)"
    }
}

private extension Day22.Brick {
    var maxPos: Pos3 {
        switch type {
        case .x: return .init(x: pos.x + len, y: pos.y, z: pos.z)
        case .y: return .init(x: pos.x, y: pos.y + len, z: pos.z)
        case .z: return .init(x: pos.x, y: pos.y, z: pos.z + len)
        }
    }

    var cubes: [Pos3] {
        switch type {
        case .x: return (0..<len).map { .init(x: pos.x + $0, y: pos.y, z: pos.z) }
        case .y: return (0..<len).map { .init(x: pos.x, y: pos.y + $0, z: pos.z) }
        case .z: return (0..<len).map { .init(x: pos.x, y: pos.y, z: pos.z + $0) }
        }
    }

    var down: Self? {
        guard pos.z >= 2 else { return nil }
        return .init(pos: .init(x: pos.x, y: pos.y, z: pos.z - 1), type: type, len: len)
    }

    var up: Self {
        return .init(pos: .init(x: pos.x, y: pos.y, z: pos.z + 1), type: type, len: len)
    }

    func canAddTo(_ map: [[[Int]]], tag: Int) -> Bool {
        for cube in cubes {
            let t = map[cube.z][cube.y][cube.x]
            if t != -1 && t != tag {
                return false
            }
        }
        return true
    }

    func addTo(_ map: inout [[[Int]]], tag: Int) {
        for cube in cubes {
            map[cube.z][cube.y][cube.x] = tag
        }
    }

    func removeFrom(_ map: inout [[[Int]]]) {
        for cube in cubes {
            map[cube.z][cube.y][cube.x] = -1
        }
    }
}
