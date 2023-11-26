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
