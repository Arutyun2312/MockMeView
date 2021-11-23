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
    var forSheet = true

    var body: some View {
        let view = Group {
            switch json {
            case .value(let value):
                ValueEditor(value: .init { value } set: { json = .value($0) })
            case .object(let dictionary):
                DicEditor(dic: .init { dictionary } set: { json = .object($0) })
            case .array(let array):
                ArrayEditor(array: .init { array } set: { json = .array($0) })
            }
        }
        if forSheet {
            ScrollView {
                view
                    .padding()
            }
        } else {
            view
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
            case .double(let double):
                TextField("enter double pls", text: .init { double.description } set: { value = .init(Double($0) ?? 0) })
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
                ForEach(dic.enumerated().map { $0 }, id: \.0) {
                    let (i, _) = $0
                    Item(keyAndValue: $dic[i]) { dic.remove(at: i) }
                }
                Button("Add") {
                    dic.append(("", .value(.string(""))))
                }
            }
        }

        struct Item: View {
            @Binding var keyAndValue: (String, Json)
            let delete: () -> ()
            @State var editing = false
            var width: CGFloat {
                let font = UIFont(name: "Helvetica", size: 24)!
                let fontAttributes = [NSAttributedString.Key.font: font]
                let size = (keyAndValue.0 as NSString).size(withAttributes: fontAttributes)
                return max(50, size.width)
            }

            var body: some View {
                let (key, el) = keyAndValue
                HStack(spacing: 0) {
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
                        }
                    }
                    TextField("key", text: .init { keyAndValue.0 } set: { keyAndValue = ($0, el) }) { editing = $0 }
                        .frame(maxWidth: editing ? .infinity : width)
                    Text(" : ")
                    let editor = JsonEditor(json: .init { el } set: { keyAndValue = (key, $0) })
                    if el.isValue {
                        editor
                    } else {
                        NavigationLink("Edit", destination: editor)
                    }
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
                HStack {
                    Spacer()
                    Button("Swap") { array.swapAt(i1, i2) }
                        .disabled(!array.indices.contains(i1) || !array.indices.contains(i2))
                    TextField("i1", text: .init { "\(i1)" } set: { i1 = .init($0) ?? 0 })
                        .frame(width: 50)
                    Text(" with ")
                    TextField("i2", text: .init { "\(i2)" } set: { i2 = .init($0) ?? 0 })
                        .frame(width: 50)
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
                        let editor = JsonEditor(json: .init { el } set: { array[i] = $0 })
                        if el.isValue {
                            editor
                        } else {
                            NavigationLink("Edit", destination: editor)
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
