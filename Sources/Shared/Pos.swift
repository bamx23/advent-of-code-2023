//
//  Pos.swift
//  
//
//  Created by Nikolay Volosatov on 15/12/2022.
//

import Foundation

public struct Pos: Hashable, CustomStringConvertible {
    public let x: Int
    public let y: Int

    public var description: String { "(\(x),\(y))" }

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public func +(lhs: Pos, rhs: Pos) -> Pos {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

public func -(lhs: Pos, rhs: Pos) -> Pos {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

public func *(lhs: Pos, rhs: Int) -> Pos {
    .init(x: lhs.x * rhs, y: lhs.y * rhs)
}

public extension Pos {
    func manhDist(_ other: Pos) -> Int {
        return abs(other.x - x) + abs(other.y - y)
    }

    func wrap(w: Int, h: Int) -> Pos {
        let x = x < 0
        ? (w - ((-x) % w)) % w
        : (x % w)
        let y = y < 0
        ? (h - ((-y) % h)) % h
        : (y % h)
        return .init(x: x, y: y)
    }
}

public extension Array {
    func at<T>(_ pos: Pos) -> Optional<T> where Element == Array<T> {
        guard 0 <= pos.y && pos.y < count else { return nil }
        let row = self[pos.y]
        guard 0 <= pos.x && pos.x < row.count else { return nil }
        return row[pos.x]
    }
}
