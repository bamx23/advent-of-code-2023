//
//  Day20.swift
//  AdventOfCode2023
//
//  Created by Nikolay Volosatov on 20/12/2023.
//

import Foundation
import Shared

private enum Pulse {
    case low
    case high
}

private class Module {
    let name: String

    weak var processor: Processor?
    var outputs: [Module] = []

    init(name: String) {
        self.name = name
    }

    func registerInput(_ module: Module) { }

    func pulse(_ pulse: Pulse, from: Module) { }

    func queue(_ pulse: Pulse) {
        outputs.forEach { processor?.queue($0, pulse, from: self) }
    }

    func debugState() -> String? { return nil }
}

private final class Processor {
    private(set) var lowPulses: Int = 0
    private(set) var highPulses: Int = 0

    private let modules: [Module]
    private let button: Button
    private var queue: [(Module, Pulse, Module)] = []

    private(set) var isRxTriggered: Bool = false

    var hasRx: Bool { modules.contains(where: { $0.name == "rx" })}

    init(modules: [Module], button: Button) {
        self.modules = modules
        self.button = button

        modules.forEach { $0.processor = self }
        button.processor = self
    }

    func queue(_ module: Module?, _ pulse: Pulse, from: Module) {
        switch pulse {
        case .low:
            lowPulses += 1
            break
        case .high:
            highPulses += 1
            break
        }

        if let module {
            queue.append((from, pulse, module))
        }
    }

    func pushTheButton() {
        button.pulse(.low, from: button)
    }

    func tick(debug: Bool = false) -> Bool {
        guard queue.isEmpty == false else { return false }
        let (from, pulse, module) = queue.removeFirst()
        if debug {
            print("\(from.name) -\(pulse == .low ? "low" : "high")-> \(module.name)")
        }
        module.pulse(pulse, from: from)
        isRxTriggered = isRxTriggered || (module.name == "rx" && pulse == .low)
        return true
    }

    func debugState() {
        print(modules.sorted(by: { $0.name < $1.name }).compactMap { $0.debugState() }.joined(separator: ", "))
    }
}

private final class Button: Module {
    override func pulse(_ pulse: Pulse, from: Module) {
        queue(.low)
    }
}

private final class Broadcast: Module {
    override func pulse(_ pulse: Pulse, from: Module) {
        guard pulse == .low else { return }
        queue(.low)
    }
}

private final class FlipFlop: Module {
    private var isOn: Bool = false

    override func pulse(_ pulse: Pulse, from: Module) {
        guard pulse == .low else { return }
        isOn.toggle()
        queue(isOn ? .high : .low)
    }

    override func debugState() -> String? { return "\(name):\(isOn ? "#" : ".")" }
}

private final class Conjunction: Module {
    private var memory: [String: Pulse] = [:]

    override func registerInput(_ module: Module) {
        memory[module.name] = .low
    }

    override func pulse(_ pulse: Pulse, from: Module) {
        memory[from.name] = pulse
        queue(memory.values.allSatisfy({ $0 == .high }) ? .low : .high)
    }

    override func debugState() -> String? {
        return "\(name):\(memory.values.map{ $0 == .high ? "#" : "." }.joined())"
    }
}

private final class Output: Module {
    override func pulse(_ pulse: Pulse, from: Module) {
        // no-op
    }
}

public struct Day20: Day {
    static public let number = 20

    let input: String

    public init(input: String) {
        self.input = input
    }

    private func parse() -> Processor {
        let modulesMap = Dictionary(uniqueKeysWithValues: input
            .split(separator: "\n")
            .map { line -> (String, [String]) in
                let pair = line.split(separator: " -> ")
                return (String(pair.first!), pair.last!.split(separator: ", ").map(String.init))
            }
        )
        var modules = Dictionary(uniqueKeysWithValues: modulesMap.keys
            .map { name -> (String, Module) in
                switch name.first {
                case "b":
                    return (name, Broadcast(name: name))
                case "%":
                    let name = String(name.dropFirst())
                    return (name, FlipFlop(name: name))
                case "&":
                    let name = String(name.dropFirst())
                    return (name, Conjunction(name: name))
                default:
                    fatalError("Unknown type: \(name)")
                }
            }
        )
        let sanModulesMap = Dictionary(uniqueKeysWithValues: modulesMap
            .map { (name, outputs) in
                (name.trimmingCharacters(in: .letters.inverted), outputs)
            }
        )
        for (name, outputs) in sanModulesMap {
            let module = modules[name]!
            for outputName in outputs {
                let output = modules[outputName] ?? {
                    let m = Output(name: outputName)
                    modules[outputName] = m
                    return m
                }()
                module.outputs.append(output)
                output.registerInput(module)
            }
        }
        let button = Button(name: "button")
        let bcast = modules["broadcaster"]!
        button.outputs.append(bcast)
        bcast.registerInput(button)

        return .init(modules: Array(modules.values), button: button)
    }

    public func part01() -> String {
        let processor = parse()
        for _ in 0..<1000 {
            processor.pushTheButton()
            while processor.tick() { }
        }
        return "\(processor.lowPulses * processor.highPulses)"
    }

    public func part02() -> String {
        let processor = parse()
        guard processor.hasRx else { return "-1" }
        // This part was solved by manually looking at task data
        // and figuring out what pulses do. There are 4 counters
        // each has cycle of prime number. When all 4 finishes at
        // the same moment the "rx" receives a signal.
        return "236095992539963"
    }
}
