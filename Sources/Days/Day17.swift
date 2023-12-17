//
//  Day17.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 17/12/2023.
//

import Foundation
import Shared
import Collections

public struct Day17: Day {
    static public let number = 17

    let input: String

    struct State: Hashable {
        struct Key: Hashable {
            var pos: Pos
            var dir: Dir
            var dirMoves: Int
        }

        var key: Key
        var loss: Int
    }

    typealias DirMoveOption = (dir: Dir, dirMoves: Int)

    public init(input: String) {
        self.input = input
    }

    func parse() -> [[Int]] {
        input
            .split(separator: "\n")
            .map { $0.compactMap(\.wholeNumberValue) }
    }

    private func solve(dirSelector: (_ state: State) -> [DirMoveOption]) -> Int {
        let map = parse()
        let start = Pos(x: 0, y: 0)
        let target = Pos(x: map.first!.count - 1, y: map.count - 1)

        var visited = Set<State.Key>()
        var heap = Heap<State>([State(key: .init(pos: start, dir: .right, dirMoves: 0), loss: 0)])
        while heap.isEmpty == false {
            let state = heap.removeMin()
            if state.key.pos == target {
                return state.loss
            }

            for (dir, dirMoves) in dirSelector(state) {
                let pos = state.key.pos + dir.delta
                guard let loss = map.at(pos) else { continue }

                let nextState = State(
                    key: .init(
                        pos: pos,
                        dir: dir,
                        dirMoves: dirMoves
                    ),
                    loss: state.loss + loss
                )
                guard visited.contains(nextState.key) == false else { continue }

                visited.insert(nextState.key)
                heap.insert(nextState)
            }
        }

        fatalError("Can't reach target")
    }

    public func part01() -> String {
        let result = solve { state in
            var dirs: [(dir: Dir, dirMoves: Int)] = state.key.dir.rotationDirs.map { ($0, 1) }
            if state.key.dirMoves < 3 {
                dirs.append((state.key.dir, state.key.dirMoves + 1))
            }
            return dirs
        }
        return "\(result)"
    }

    public func part02() -> String {
        let result = solve { state in
            var dirs: [(dir: Dir, dirMoves: Int)] = []
            if state.key.dirMoves < 10 {
                dirs.append((state.key.dir, state.key.dirMoves + 1))
            }
            if state.key.dirMoves >= 4 {
                dirs.append(contentsOf: state.key.dir.rotationDirs.map { ($0, 1) })
            }
            return dirs
        }
        return "\(result)"
    }
}

extension Day17.State: Comparable {
    static func < (lhs: Day17.State, rhs: Day17.State) -> Bool {
        lhs.loss < rhs.loss
    }
}
