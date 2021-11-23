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

extension MockMeView {
    struct Property<T: Codable>: View {
        let name: String
        @Binding var property: T
        @State var json: Json = .value(.string("Loading"))
        @State var controller = UIHostingController(rootView: EmptyView())

        var body: some View {
            HStack {
                Text("\"\(name)\" \(json.label): ")
                Button("Edit") { controller.present(UIHostingController(rootView: editor), animated: true, completion: nil) }
            }
            .background(controller.toSwiftUI())
        }

        var editor: some View {
            NavigationView {
                VStack {
                    JsonEditor(json: $json)
                    let controller = UIHostingController(rootView: EmptyView())
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
                    .background(controller.toSwiftUI())
                }
                .navigationBarTitle(Text(name))
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
    }
}

extension String: Error {}

struct DynamicCodingKey: CodingKey {
    var stringValue = ""
    var intValue: Int?

    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue }
}
