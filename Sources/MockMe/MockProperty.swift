//
//  MockProperty.swift
//  freebee
//
//  Created by Arutyun Enfendzhyan on 30.10.21.
//  Copyright © 2021 aaa - all about apps Gmbh. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

#if DEBUG
public struct MockProperty<Value: Codable>: View {
    public init(name: String, property: Binding<Value>) {
        self.name = name
        _property = property
    }

    let name: String
    @Binding var property: Value
    @State var json: Json = "Loading"
    @State var showSheet = false
    @State var alert: Alert?

    public var body: some View {
        HStack {
            Text("\(name): ")
            Button { showSheet.toggle() } label: {
                Image(systemName: "square.and.arrow.down")
                    .resizable()
                    .frame(width: 25, height: 25)
            }
            .padding(.trailing)
            Text(json.description)
        }
        .alert(isPresented: .init { alert != nil } set: { _ in alert = nil }) { alert! }
        .sheet(isPresented: $showSheet) { sheet }
        .onAppear {
            do {
                json = try Json(from: property)
            } catch {
                alert = .init(title: .init("Couldn't encode"), message: .init("\(error)" as String))
            }
        }
    }

    var sheet: some View {
        VStack {
            ScrollView {
                JsonEditor(json: $json, initial: json, name: name, isProperty: false)
                    .equatable()
                    .padding(.horizontal)
            }
            Spacer()
            Button(action: save) {
                Text("Save")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray)
                    )
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }

    func save() {
        do {
            property = try json.toObj()
            showSheet.toggle()
        } catch {
            alert = .init(title: .init("Couldn't decode"), message: .init("\(error)" as String))
        }
    }

    public struct Simple: View {
        public init(name: String, property: Binding<Value>) {
            self.name = name
            _property = property
            do {
                _json = try .init(wrappedValue: Json(from: property.wrappedValue))
            } catch {
                controller.alert(title: "Couldn't encode", message: "\(error)")
            }
        }

        let name: String
        @Binding var property: Value
        @State var json: Json = "Loading"
        @State var controller = UIHostingController(rootView: EmptyView())

        public var body: some View {
            HStack {
                Text("\(name): ")
                JsonEditor(json: $json, initial: json, isProperty: true)
                    .equatable()
                Button(action: save) {
                    Image(systemName: "checkmark")
                        .padding(.all, 6)
                }
            }
        }

        func save() {
            do {
                property = try json.toObj()
                controller.dismiss(animated: true, completion: nil)
            } catch {
                controller.alert(title: "Couldn't decode", message: "\(error)")
            }
        }
    }
}

extension String: Error {}

struct DynamicCodingKey: CodingKey {
    var stringValue = ""
    var intValue: Int?

    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue }
}
#endif
