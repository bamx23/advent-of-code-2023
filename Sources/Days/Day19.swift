//
//  Day19.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 19/12/2023.
//

import Foundation
import Shared

public struct Day19: Day {
    static public let number = 19

    let input: String

    enum PartParam: CaseIterable {
        case x // Extremely cool looking
        case m // Musical (it makes a noise when you hit it)
        case a // Aerodynamic
        case s // Shiny
    }

    typealias Part = [PartParam: Int]
    typealias PartsDef = [PartParam: ClosedRange<Int>]

    enum Decision {
        case accept
        case reject
        case go(wf: String)
    }

    enum Condition {
        case gt(PartParam, Int)
        case lt(PartParam, Int)
    }

    struct Workflow {
        var checks: [(Condition, Decision)]
        var fallback: Decision
    }

    public init(input: String) {
        self.input = input
    }

    func parse() -> ([Part], [String: Workflow]) {
        let topPair = input.split(separator: "\n\n")
        let workflows = Dictionary(uniqueKeysWithValues: topPair.first!
            .split(separator: "\n")
            .map { line -> (String, Workflow) in
                let regex = #/(?<name>\w+)\{(?<conditions>.+),(?<fallback>\w+)\}/#
                let match = line.matches(of: regex).first!.output
                let checks = match.conditions
                    .split(separator: ",")
                    .map { cond -> (Condition, Decision) in
                        let cPair = cond.split(separator: ":")
                        return (.parse(cPair.first!), .parse(cPair.last!))
                    }
                return (String(match.name), .init(checks: checks, fallback: .parse(match.fallback)))
            }
        )
        let parts = topPair.last!
            .split(separator: "\n")
            .map { line -> Part in
                let regex = #/\{x=(?<x>\d+),m=(?<m>\d+),a=(?<a>\d+),s=(?<s>\d+)\}/#
                let match = line.matches(of: regex).first!.output
                return [.x: Int(match.x)!, .m: Int(match.m)!, .a: Int(match.a)!, .s: Int(match.s)!]
            }
        return (parts, workflows)
    }

    public func part01() -> String {
        let (parts, workflows) = parse()

        let acceptedParts = parts
            .filter { part in
                var wfName = "in"
                while true {
                    let wf = workflows[wfName]!
                    let decision = wf.checks.first(where: { $0.0.check(part) }).map(\.1) ?? wf.fallback
                    switch decision {
                    case .accept: return true
                    case .reject: return false
                    case .go(wf: let nextWfName):
                        wfName = nextWfName
                        break
                    }
                }
            }
        let result = acceptedParts
            .map { $0.values.reduce(0, +) }
            .reduce(0, +)
        return "\(result)"
    }

    public func part02() -> String {
        let (_, workflows) = parse()

        let defaultInterval = 1...4000
        let startDef: PartsDef = Dictionary(uniqueKeysWithValues: PartParam.allCases.map { ($0, defaultInterval) })

        var result = 0
        var stack = [("in", startDef)]
        while stack.isEmpty == false {
            let (wfName, def) = stack.removeFirst()
            let wf = workflows[wfName]!
            var curDef: PartsDef? = def
            for (check, decision) in wf.checks {
                guard let nCurDef = curDef else { break }
                let (passDef, fallDef) = check.filter(nCurDef)
                if let passDef {
                    switch decision {
                    case .accept:
                        result += passDef.power
                        break
                    case .reject:
                        break
                    case .go(wf: let nextWf):
                        stack.append((nextWf, passDef))
                        break
                    }
                }
                curDef = fallDef
            }
            if let curDef {
                switch wf.fallback {
                case .accept:
                    result += curDef.power
                    break
                case .reject:
                    break
                case .go(wf: let nextWf):
                    stack.append((nextWf, curDef))
                    break
                }
            }
        }

        return "\(result)"
    }
}

extension Day19.Decision {
    static func parse(_ str: Substring) -> Self {
        switch str {
        case "A": return .accept
        case "R": return .reject
        default: return .go(wf: String(str))
        }
    }
}

extension Day19.Condition {
    private static func parseParam(_ str: Substring) -> Day19.PartParam {
        switch str {
        case "x": return .x
        case "m": return .m
        case "a": return .a
        case "s": return .s
        default: fatalError("Unknown: \(str)")
        }
    }

    static func parse(_ str: Substring) -> Self {
        let ltPair = str.split(separator: "<")
        if ltPair.count == 2 {
            return .lt(parseParam(ltPair.first!), Int(ltPair.last!)!)
        }
        let gtPair = str.split(separator: ">")
        if gtPair.count == 2 {
            return .gt(parseParam(gtPair.first!), Int(gtPair.last!)!)
        }
        fatalError("Unknown: \(str)")
    }

    func check(_ part: Day19.Part) -> Bool {
        switch self {
        case let .lt(param, val): return part[param]! < val
        case let .gt(param, val): return part[param]! > val
        }
    }

    func filter(_ partDef: Day19.PartsDef) -> (Day19.PartsDef?, Day19.PartsDef?) {
        switch self {
        case let .lt(param, val):
            let cur = partDef[param]!
            guard cur.lowerBound < val else { return (nil, partDef) }
            guard cur.upperBound >= val else { return (partDef, nil) }
            var (a, b) = (partDef, partDef)
            a[param] = cur.lowerBound...(val - 1)
            b[param] = val...cur.upperBound
            return (a, b)
        case let .gt(param, val):
            let cur = partDef[param]!
            guard cur.upperBound > val else { return (nil, partDef) }
            guard cur.lowerBound <= val else { return (partDef, nil) }
            var (a, b) = (partDef, partDef)
            a[param] = (val + 1)...cur.upperBound
            b[param] = cur.lowerBound...val
            return (a, b)
        }
    }
}

extension Day19.PartsDef {
    var power: Int { values.map(\.count).reduce(1, *) }
}
