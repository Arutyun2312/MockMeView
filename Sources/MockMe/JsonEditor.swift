//
//  File.swift
//
//
//  Created by Arutyun Enfendzhyan on 23.11.21.
//

import Foundation
import SwiftUI

//struct JsonEditor: View, Equatable {
//    static func == (lhs: JsonEditor, rhs: JsonEditor) -> Bool { lhs.json == rhs.json }
//
//    @Binding var json: Json
//    @State var initial: Json
//    var name: String? = nil
//    var isProperty = true
//    @State var paths: [String] = []
//
//    var body: some View {
//        VStack {
//            if !isProperty {
//                HStack(spacing: 0) {
//                    Button("self") { paths.removeAll() }
//                    if !paths.isEmpty {
//                        Text(".")
//                        ForEach(paths.enumerated().map { $0 }, id: \.0) {
//                            let (i, path) = $0
//                            Button(path) { paths = .init(paths.prefix(i + 1)) }
//                            if i + 1 != paths.count {
//                                Text(".")
//                            }
//                        }
//                    }
//                    Text(": ")
//                    TypeSelector(json: .init { json[paths] ?? "" } set: { json[paths] = $0 })
//                    Button { json = initial } label: {
//                        Image(systemName: "arrow.clockwise")
//                    }
//                    .padding(.leading)
//                }
//            }
//            editor
//        }
//    }
//
//    struct TypeSelector: View {
//        @Binding var json: Json
//
//        var body: some View {
//            let types = ["object", "array", "string", "int", "double", "bool", "null"]
//            let binding = Binding<String> {
//                if case .value(let value) = json {
//                    return value?.label ?? "null"
//                } else {
//                    return json.label
//                }
//            } set: { type in
//                json = {
//                    switch type {
//                    case types[0]:
//                        return .object([])
//                    case types[1]:
//                        return .array([])
//                    case types[2]:
//                        return ""
//                    case types[3]:
//                        return 0
//                    case types[4]:
//                        return 0.0
//                    case types[5]:
//                        return false
//                    case types[6]:
//                        return .value(nil)
//                    default:
//                        fatalError()
//                    }
//                }()
//            }
//            Picker("", selection: binding) {
//                ForEach(types, id: \.self) { Text($0) }
//            }
//        }
//    }
//
//    @ViewBuilder var editor: some View {
//        HStack {
//            switch json[paths] {
//            case .value(let value):
//                ValueEditor(value: .init { value } set: { json[paths] = .value($0) })
//            case .object(let dictionary):
//                DicEditor(dic: .init { dictionary } set: { json[paths] = .object($0) }, goToPath: goToPath)
//            case .array(let array):
//                ArrayEditor(array: .init { array } set: { json[paths] = .array($0) }, goToPath: goToPath)
//            case .none:
//                Text("Invalid paths: \(paths.joined(separator: "."))")
//            }
//        }
//    }
//
//    func goToPath(path: String) {
//        withAnimation {
//            paths.append(path)
//        }
//    }
//
//    struct ValueEditor: View {
//        @Binding var value: Json.Value?
//
//        var body: some View {
//            switch value {
//            case .string(let string):
//                TextField("enter string pls", text: .init { string } set: { value = .init($0) })
//            case .int(let int):
//                TextField("enter int pls", text: .init { int.description } set: { value = .init(Int($0) ?? 0) })
//                    .keyboardType(.numberPad)
//            case .double(let double):
//                TextField("enter double pls", text: .init { double.description } set: { value = .init(Double($0) ?? 0) })
//                    .keyboardType(.numbersAndPunctuation)
//            case .bool(let bool):
//                Toggle("", isOn: .init { bool } set: { value = .init($0) })
//                    .frame(width: 50, height: 35)
//            case .none:
//                Text("null")
//            }
//        }
//    }
//
//    struct DicEditor: View {
//        @Binding var dic: [(String, Json)]
//        let goToPath: (String) -> ()
//        @State var editing: Int?
//
//        var body: some View {
//            VStack(alignment: .leading) {
//                ForEach(dic.enumerated().map { $0 }, id: \.0) {
//                    let (i, _) = $0
//                    Item(keyAndValue: $dic[i], goToPath: goToPath) { dic.remove(at: i) }
//                    Divider()
//                }
//                HStack {
//                    Button("Clear") { dic.removeAll() }
//                    Button("Add") {
//                        dic.append(("", ""))
//                    }
//                }
//            }
//        }
//
//        struct Item: View {
//            @Binding var keyAndValue: (String, Json)
//            let goToPath: (String) -> ()
//            let delete: () -> ()
//            @State var editing = false
//            let font = UIFont(name: "Helvetica", size: 16)!
//            var width: CGFloat {
//                let fontAttributes = [NSAttributedString.Key.font: font]
//                let size = (keyAndValue.0 as NSString).size(withAttributes: fontAttributes)
//                return max(50, size.width)
//            }
//
//            var body: some View {
//                let (key, el) = keyAndValue
//                HStack(alignment: .center, spacing: 0) {
//                    if editing {
//                        Button(action: delete) {
//                            Image(systemName: "multiply")
//                                .resizable()
//                                .frame(width: 7, height: 7)
//                                .padding(.all, 7)
//                                .background(
//                                    Color.red
//                                        .clipShape(Circle())
//                                )
//                                .padding(.trailing, 5)
//                        }
//                    }
//                    TextField("key", text: .init { keyAndValue.0 } set: { keyAndValue = ($0, el) }) { editing = $0 }
//                        .frame(maxWidth: editing ? .infinity : width)
//                        .font(.init(font))
//                    Text(" : ")
//                    let binding = Binding { el } set: { keyAndValue = (key, $0) }
//                    if !editing {
//                        Button { goToPath(key) } label: {
//                            Image(systemName: "square.and.arrow.down")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                        }
//                        .padding(.trailing)
//                        if el.isValue {
//                            JsonEditor(json: binding, initial: el, isProperty: true)
//                        } else {
//                            Text(el.description) // JsonEditor(json: binding, isProperty: true)
//                                .lineLimit(3)
//                        }
//                    }
//                    Spacer()
//                }
//            }
//        }
//    }
//
//    struct ArrayEditor: View {
//        @Binding var array: [Json]
//        let goToPath: (String) -> ()
//        @State var i1 = 0
//        @State var i2 = 0
//
//        var body: some View {
//            VStack(alignment: .leading) {
//                ForEach(array.enumerated().map { $0 }, id: \.0) {
//                    let (i, el) = $0
//                    HStack(spacing: 0) {
//                        Text("\(i): ")
//                            .padding()
//                            .contentShape(Rectangle())
//                            .contextMenu {
//                                Button("Delete") { array.remove(at: i) }
//                            }
//                        let binding = Binding { el } set: { array[i] = $0 }
//                        Button { goToPath("\(i)") } label: {
//                            Image(systemName: "square.and.arrow.down")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                        }
//                        .padding(.trailing)
//                        if el.isValue {
//                            JsonEditor(json: binding, initial: el)
//                        } else {
//                            Text(el.description)
//                                .lineLimit(3)
//                        }
//                    }
//                    Divider()
//                }
//                HStack {
//                    HStack(alignment: .center, spacing: 1) {
//                        Spacer()
//                        Button("Swap") { array.swapAt(i1, i2) }
//                            .disabled(!array.indices.contains(i1) || !array.indices.contains(i2))
//                        TextField("i1", text: .init { "\(i1)" } set: { i1 = .init($0) ?? 0 })
//                            .frame(width: 25)
//                        Text(" with ")
//                        TextField("i2", text: .init { "\(i2)" } set: { i2 = .init($0) ?? 0 })
//                            .frame(width: 25)
//                        Spacer()
//                        Button("Clear") { array.removeAll() }
//                        Spacer()
//                    }
//                    Button("Add") { array.append("") }
//                }
//            }
//        }
//    }
//}
