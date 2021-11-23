//
//  File.swift
//
//
//  Created by Arutyun Enfendzhyan on 23.11.21.
//

import Foundation

indirect enum Json: Codable, CustomStringConvertible {
    case value(Value), object([(String, Json)]), array([Json])

    init<Value: Encodable>(from value: Value) throws {
        self = try JSONDecoder().decode(Json.self, from: JSONEncoder().encode(value))
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: DynamicCodingKey.self) {
            self = try .object(container.allKeys.reduce(into: [:]) {
                $0[$1.stringValue] = try .init(from: try container.superDecoder(forKey: $1))
            }.map { ($0.0, $0.1) })
        } else if var container = try? decoder.unkeyedContainer() {
            var elements: [Json] = []
            while !container.isAtEnd {
                elements.append(try .init(from: container.superDecoder()))
            }
            self = .array(elements)
        } else {
            let value = try decoder.singleValueContainer()
            if let value = try? value.decode(Bool.self) {
                self = .value(.init(value))
            } else if let value = try? value.decode(Int.self) {
                self = .value(.init(value))
            } else if let value = try? value.decode(Double.self) {
                self = .value(.init(value))
            } else {
                guard let str = try? value.decode(String.self) else { throw "What is this?" }
                self = .value(.init(str))
            }
        }
    }

    var isValue: Bool {
        if case .value = self {
            return true
        } else {
            return false
        }
    }

    var isObject: Bool {
        if case .object = self {
            return true
        } else {
            return false
        }
    }

    var isArray: Bool {
        if case .array = self {
            return true
        } else {
            return false
        }
    }

    var label: String { Mirror(reflecting: self).children.first!.label! }

    func encode(to encoder: Encoder) throws { try description.encode(to: encoder) }
    func toObj<Value: Decodable>() throws -> Value {
        try JSONDecoder().decode(Value.self, from: description.data(using: .utf8)!)
    }

    var description: String {
        switch self {
        case .value(let value):
            return value.description
        case .object(let dictionary):
            return "{\(dictionary.map { "\"\($0.0)\": \($0.1.description)" }.joined(separator: ", "))}"
        case .array(let array):
            return array.description
        }
    }

    enum Value: CustomStringConvertible {
        case string(String), int(Int), double(Double), bool(Bool)

        init(_ value: String) { self = .string(value) }
        init(_ value: Int) { self = .int(value) }
        init(_ value: Double) { self = .double(value) }
        init(_ value: Bool) { self = .bool(value) }
        init?(_ value: Any) {
            if let value = value as? String {
                self = .init(value)
            } else if let value = value as? Int {
                self = .init(value)
            } else if let value = value as? Double {
                self = .init(value)
            } else if let value = value as? Bool {
                self = .init(value)
            } else {
                return nil
            }
        }

        var description: String {
            switch self {
            case .string(let value):
                return "\"\(value)\""
            case .int(let value):
                return value.description
            case .double(let value):
                return value.description
            case .bool(let value):
                return value.description
            }
        }
    }
}

extension Json: ExpressibleByStringLiteral {
    init(stringLiteral value: StringLiteralType) { self = .value(.string(value)) }
}
extension Json: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) { self = .value(.int(value)) }
}
extension Json: ExpressibleByFloatLiteral {
    init(floatLiteral value: FloatLiteralType) { self = .value(.double(value)) }
}
extension Json: ExpressibleByBooleanLiteral {
    init(booleanLiteral value: BooleanLiteralType) { self = .value(.bool(value)) }
}
