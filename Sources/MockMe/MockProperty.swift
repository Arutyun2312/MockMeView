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

public struct MockProperty<Value: Codable>: View {
    let name: String
    @Binding var property: Value
    @State var json: Json = "Loading"
    let controller = UIHostingController(rootView: EmptyView())

    public var body: some View {
        HStack {
            Text("\"\(name)\" \(json.label): ")
            Button("Edit") { controller.present(UIHostingController(rootView: editor), animated: true, completion: nil) }
        }
        .background(controller.toSwiftUI())
    }

    var editor: some View {
        NavigationView {
            VStack {
                JsonEditor(json: $json, name: name, isProperty: false)
                Button {
                    do {
                        property = try json.toObj()
                        controller.dismiss(animated: true, completion: nil)
                    } catch {
                        let alert = UIAlertController(title: "Couldn't decode", message: "\(error)", preferredStyle: .alert)
                        alert.addAction(.init(title: "OK", style: .default, handler: nil))
                        controller.present(alert, animated: true, completion: nil)
                    }
                } label: {
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
            .background(controller.toSwiftUI())
        }
        .onAppear {
            do {
                json = try Json(from: property)
            } catch {
                let alert = UIAlertController(title: "Couldn't encode", message: "\(error)", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                controller.present(alert, animated: true, completion: nil)
            }
        }
    }

    public struct Simple: View {
        public init(name: String, property: Binding<Value>) {
            _property = property
            do {
                _json = try .init(wrappedValue: Json(from: property.wrappedValue))
            } catch {
                let alert = UIAlertController(title: "Couldn't encode", message: "\(error)", preferredStyle: .alert)
                alert.addAction(.init(title: "OK", style: .default, handler: nil))
                controller.present(alert, animated: true, completion: nil)
            }
        }

        @Binding var property: Value
        @State var json: Json = "Loading"
        @State var controller = UIHostingController(rootView: EmptyView())

        public var body: some View {
            VStack { JsonEditor(json: $json, forSheet: false, isProperty: false) }
                .onReceive(Just(json)) { json in
                    do {
                        property = try json.toObj()
                        controller.dismiss(animated: true, completion: nil)
                    } catch {
                        let alert = UIAlertController(title: "Couldn't decode", message: "\(error)", preferredStyle: .alert)
                        alert.addAction(.init(title: "OK", style: .default, handler: nil))
                        controller.present(alert, animated: true, completion: nil)
                    }
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
