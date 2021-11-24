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
                    value[i] = .init(name: new.name, body: .init(Group { value[i].body; new.body }))
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
    func mockView<Content: View>(viewName name: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        modifier(MockMeView.TargetScreen(name: name, refreshable: false, mockView: content))
    }
    func mockView(viewName name: String, refreshable: Bool) -> some View {
        modifier(MockMeView.TargetScreen(name: name, refreshable: refreshable) {})
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
