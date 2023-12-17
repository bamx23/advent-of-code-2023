//
//  Pos.swift
//  
//
//  Created by Nikolay Volosatov on 15/12/2022.
//

import Foundation

public struct Pos: Hashable {
    public let x: Int
    public let y: Int
    
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

public extension Pos {
    func manhDist(_ other: Pos) -> Int {
        return abs(other.x - x) + abs(other.y - y)
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
