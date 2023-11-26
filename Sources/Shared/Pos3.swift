//
//  File.swift
//  
//
//  Created by Nikolay Volosatov on 18/12/2022.
//

import Foundation

public struct Pos3: Hashable {
    public let x: Int
    public let y: Int
    public let z: Int
    
    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }
}

public func +(lhs: Pos3, rhs: Pos3) -> Pos3 {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}

public func -(lhs: Pos3, rhs: Pos3) -> Pos3 {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}
