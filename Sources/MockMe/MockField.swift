//
//  File.swift
//
//
//  Created by Arutyun Enfendzhyan on 01.05.22.
//

import Foundation
import SwiftUI

public struct MockField<Value: Codable & Equatable>: View {
    public init(label: String, value: Value, save: @escaping (Value) -> Void) {
        self.label = label
        self.save = save
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        let json = (try? encoder.encode(value)).map { String(data: $0, encoding: .utf8) ?? "" } ?? "Invalid encode"
        self.json = json
        self.originalJson = json
    }

    let label: String
    @State var originalJson: String
    @State var json: String
    @State var openSheet = false
    let save: (Value) -> Void
    var decodedValue: Value? {
        let json = String(json.map { // filter out bad quotes
            let leftQuote = [226, 128, 156]
            let rightQuote = [226, 128, 157]
            if [leftQuote, rightQuote].contains($0.utf8.map { Int($0) }) {
                return "\""
            }
            return $0
        })
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    var decodedOriginal: Value? {
        let json = String(originalJson.map { // filter out bad quotes
            let leftQuote = [226, 128, 156]
            let rightQuote = [226, 128, 157]
            if [leftQuote, rightQuote].contains($0.utf8.map { Int($0) }) {
                return "\""
            }
            return $0
        })
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Value.self, from: data)
    }

    public var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Button("↗️") {
                    openSheet.toggle()
                }
            }
            HStack {
                TextField("Value", text: $json)
                saveButton
            }
            Divider()
        }
        .sheet(isPresented: $openSheet) {
            VStack(alignment: .trailing) {
                saveButton
                if #available(iOS 14.0, *) {
                    TextEditor(text: $json)
                } else {
                    Text("Cannot edit")
                    Text(json)
                }
            }
        }
    }

    @ViewBuilder var saveButton: some View {
        if let value = decodedValue, value != decodedOriginal {
            Button {
                save(value)
                originalJson = json
                openSheet = false
            } label: {
                Text("✓")
                    .padding()
            }
        }
    }
}

public extension MockField {
    init(label: String, value: Binding<Value>) {
        self.init(label: label, value: value.wrappedValue) { value.wrappedValue = $0 }
    }
}

struct Previews_MockField_Previews: PreviewProvider, View {
    @State var j = ["Hi": "0", "Bu": "1"]

    var body: some View {
        VStack {
            MockField(label: "Label", value: $j)
            MockField(label: "Label", value: "Hi", save: { _ in })
        }
    }

    static var previews: some View { Previews_MockField_Previews() }
}
