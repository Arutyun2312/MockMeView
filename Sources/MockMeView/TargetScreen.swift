//
//  TargetScreen.swift
//  freebee
//
//  Created by Arutyun Enfendzhyan on 30.10.21.
//  Copyright © 2021 aaa - all about apps Gmbh. All rights reserved.
//

import Combine
import SwiftUI

public extension MockMeView {
    struct TargetKey: PreferenceKey {
        public typealias Value = [Target]
        public static var defaultValue: Value = []

        public static func reduce(value: inout Value, nextValue: () -> Value) {
            for new in nextValue().reversed() {
                if let i = value.firstIndex(where: { $0.id == new.id }) {
                    value[i] = new
                } else {
                    value.append(new)
                }
            }
        }
    }

    struct Target: View {
        public let id = UUID()
        let name: String
        public let body: AnyView
    }

    fileprivate struct TargetScreen<MockContent: View>: ViewModifier {
        let name: String
        let refreshable: Bool
        @ViewBuilder let mockView: MockContent
        @State var idForRefresh = UUID()

        var target: MockMeView.Target {
            .init(name: name, body: .init(
                VStack(alignment: .leading) {
                    HStack {
                        Text(name)
                            .bold()
                        if refreshable {
                            Button { idForRefresh = .init() } label: {
                                Image(systemName: "arrow.triangle.2.circlepath")
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    mockView
                }
                .overlay(
                    VStack {
                        Divider()
                        Spacer()
                        Divider()
                    }
                )
            ))
        }

        func body(content: Content) -> some View {
            content
                .id(idForRefresh)
                .background( // due to how preferences work, it's best to use background
                    EmptyView()
                        .preference(key: MockMeView.TargetKey.self, value: [target])
                )
        }
    }
}

public extension View {
    func mockTarget<Content: View>(name: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(MockMeView.TargetScreen(name: name, refreshable: false, mockView: content))
    }
    func mockTarget<Content: View>(name: String, refreshable: Bool) -> some View {
        modifier(MockMeView.TargetScreen(name: name, refreshable: refreshable) {})
    }

    func mockTarget<Value: Codable>(name: String, property: Binding<Value>) -> some View {
        mockTarget(name: name) {
            if Json.Value(property.wrappedValue) == nil {
                MockMeView.Property(name: name, property: property)
            } else {
                SimpleProperty(value: property)
            }
        }
    }

    func mockTarget<Value: Codable>(name: String, complexProperty property: Binding<Value>) -> some View {
        mockTarget(name: name) {
            MockMeView.Property(name: name, property: property)
        }
    }
    
    func mockTarget<Value>(name: String, property: Binding<Value>, setTo values: [Value], description: @escaping (Value) -> String) -> some View {
        mockTarget(name: name) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(values.enumerated().map { $0 }, id: \.0) {
                        let (i, el) = $0
                        Button(description(el)) { property.wrappedValue = el }
                    }
                }
            }
        }
    }
    func mockTarget<Value: CustomStringConvertible>(name: String, property: Binding<Value>, setTo values: [Value]) -> some View {
        mockTarget(name: name, property: property, setTo: values, description: { $0.description })
    }
}

private struct SimpleProperty<Value: Codable>: View {
    @State var json: Json = "Loading"
    @Binding var value: Value

    var body: some View {
        JsonEditor(json: $json, forSheet: false)
            .onReceive(Just(json)) { json in
                guard let value: Value = try? json.toObj() else { return }
                self.value = value
            }
            .onAppear { json = (try? Json(from: value)) ?? "Error" }
    }
}
