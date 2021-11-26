//
//  File.swift
//
//
//  Created by Arutyun Enfendzhyan on 23.11.21.
//

import Foundation
import SwiftUI

struct JsonEditor: View {
    @Binding var json: Json
    var name: String? = nil
    var forSheet = true
    var isProperty = true

    var body: some View {
        if isProperty {
            let view = HStack {
                typePicker
                editor
            }
            if forSheet {
                ScrollView {
                    view
                        .padding()
                }
            } else {
                view
            }
        } else {
            let view = VStack {
                editor
            }
            .navigationBarTitle("\(name ?? "")")
            .navigationBarItems(trailing: typePicker)
            if forSheet {
                ScrollView {
                    view
                        .padding()
                }
            } else {
                view
            }
        }
    }

    @ViewBuilder var editor: some View {
        switch json {
        case .value(let value):
            ValueEditor(value: .init { value } set: { json = .value($0) })
        case .object(let dictionary):
            DicEditor(dic: .init { dictionary } set: { json = .object($0) })
        case .array(let array):
            ArrayEditor(array: .init { array } set: { json = .array($0) })
        }
    }

    @ViewBuilder var typePicker: some View {
        let types = ["string", "int", "double", "bool", "object", "array"]
        Picker("", selection: .init { () -> String in
            if case .value(let json) = json {
                return json.label
            } else {
                return json.label
            }
        } set: {
            switch $0 {
            case types[0]:
                json = ""
            case types[1]:
                json = 0
            case types[2]:
                json = 0.0
            case types[3]:
                json = false
            case types[4]:
                json = .object([])
            case types[5]:
                json = []
            default:
                fatalError()
            }
        }) {
            ForEach(types.indices) {
                let type = types[$0]
                Text(name == nil ? type : "data type: \(type)")
                    .tag(type)
            }
        }
    }

    struct ValueEditor: View {
        @Binding var value: Json.Value

        var body: some View {
            switch value {
            case .string(let string):
                TextField("enter string pls", text: .init { string } set: { value = .init($0) })
            case .int(let int):
                TextField("enter int pls", text: .init { int.description } set: { value = .init(Int($0) ?? 0) })
                    .keyboardType(.numberPad)
            case .double(let double):
                TextField("enter double pls", text: .init { double.description } set: { value = .init(Double($0) ?? 0) })
                    .keyboardType(.numbersAndPunctuation)
            case .bool(let bool):
                Toggle("", isOn: .init { bool } set: { value = .init($0) })
                    .frame(width: 80, height: 35)
            }
        }
    }

    struct DicEditor: View {
        @Binding var dic: [(String, Json)]
        @State var editing: Int?

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Button("Clear") { dic.removeAll() }
                    Spacer()
                }
                ForEach(dic.enumerated().map { $0 }, id: \.0) {
                    let (i, _) = $0
                    Item(keyAndValue: $dic[i]) { dic.remove(at: i) }
                }
                Button("Add") {
                    dic.append(("", ""))
                }
            }
        }

        struct Item: View {
            @Binding var keyAndValue: (String, Json)
            let delete: () -> ()
            @State var editing = false
            let font = UIFont(name: "Helvetica", size: 16)!
            var width: CGFloat {
                let fontAttributes = [NSAttributedString.Key.font: font]
                let size = (keyAndValue.0 as NSString).size(withAttributes: fontAttributes)
                return max(50, size.width)
            }

            var body: some View {
                let (key, el) = keyAndValue
                HStack(alignment: .center, spacing: 0) {
                    if editing {
                        Button(action: delete) {
                            Image(systemName: "multiply")
                                .resizable()
                                .frame(width: 7, height: 7)
                                .padding(.all, 7)
                                .background(
                                    Color.red
                                        .clipShape(Circle())
                                )
                                .padding(.trailing, 5)
                        }
                    }
                    TextField("key", text: .init { keyAndValue.0 } set: { keyAndValue = ($0, el) }) { editing = $0 }
                        .frame(maxWidth: editing ? .infinity : width)
                        .font(.init(font))
                    Text(" : ")
                    let binding = Binding { el } set: { keyAndValue = (key, $0) }
                    if el.isValue {
                        if !editing {
                            JsonEditor(json: binding, isProperty: true)
                        }
                    } else {
                        NavigationLink("Edit", destination: JsonEditor(json: binding, name: key, isProperty: false))
                    }
                    Spacer()
                }
            }
        }
    }

    struct ArrayEditor: View {
        @Binding var array: [Json]
        @State var i1 = 0
        @State var i2 = 0

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 1) {
                    Spacer()
                    Button("Swap") { array.swapAt(i1, i2) }
                        .disabled(!array.indices.contains(i1) || !array.indices.contains(i2))
                    TextField("i1", text: .init { "\(i1)" } set: { i1 = .init($0) ?? 0 })
                        .frame(width: 25)
                    Text(" with ")
                    TextField("i2", text: .init { "\(i2)" } set: { i2 = .init($0) ?? 0 })
                        .frame(width: 25)
                    Spacer()
                    Button("Clear") { array.removeAll() }
                    Spacer()
                }
                ForEach(array.enumerated().map { $0 }, id: \.0) {
                    let (i, el) = $0
                    HStack(spacing: 0) {
                        Text("\(i): ")
                            .padding()
                            .contentShape(Rectangle())
                            .contextMenu {
                                Button("Delete") { array.remove(at: i) }
                            }
                        let binding = Binding  { el } set: { array[i] = $0 }
                        if el.isValue {
                            JsonEditor(json: binding)
                        } else {
                            NavigationLink("Edit", destination: JsonEditor(json: binding, name: "\(i)", isProperty: false))
                        }
                    }
                }
                Button("Add") {
                    array.append(.value(.string("")))
                }
            }
        }
    }
}
