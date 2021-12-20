//
//  MockMeScreen.swift
//  freebee
//
//  Created by Arutyun Enfendzhyan on 29.10.21.
//  Copyright © 2021 aaa - all about apps Gmbh. All rights reserved.
//

import Combine
import SwiftUI

#if DEBUG
    public struct MockMeView: View {
        let content: AnyView
        @State private var location: Location = .constant(GlobalConfig.shared.lastPosition)
        @State var targets: [Target] = []
        @State var mocking = false
        @ObservedObject var globalConfig = GlobalConfig.shared

        public var body: some View {
            if globalConfig.isActive {
                ZStack {
                    content
                        .onPreferenceChange(TargetKey.self) { targets = $0 }
                    let view = VStack(spacing: 10) {
                        Text(mocking ? "Don't mock me!" : "Mock me!")
                            .foregroundColor(.white)
                            .padding(.all, 8)
                            .background(Color.gray)
                            .cornerRadius(10)
                            .onTapGesture { withAnimation { mocking.toggle() } }
                        if mocking {
                            VStack(alignment: .leading, spacing: 15) {
                                ForEach(targets) { $0 }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                        }
                    }
                    if mocking {
                        view
                            .padding(.horizontal, UIScreen.main.bounds.width * 0.1)
                            .padding(.vertical, UIScreen.main.bounds.height * 0.1)
                    } else {
                        view
                            .position(x: max(location.point.x, 0), y: max(location.point.y, 0))
                            .padding(.all, 30)
                            .gesture(gesture, including: mocking ? .subviews : .all)
                            .onReceive(Just(location)) { if globalConfig.lastPosition != $0.point { globalConfig.lastPosition = $0.point } }
                    }
                }
            } else {
                content
            }
        }

        var gesture: some Gesture {
            DragGesture(minimumDistance: 5, coordinateSpace: .global)
                .onChanged {
                    let initial: CGPoint = {
                        switch location {
                        case let .changing(value, _), let .constant(value):
                            return value
                        }
                    }()
                    location = .changing(initial, $0.translation)
                }
                .onEnded { _ in location = .constant(location.point) }
        }

        private enum Location: Equatable {
            case constant(CGPoint), changing(CGPoint, CGSize)

            var point: CGPoint {
                switch self {
                case let .constant(value):
                    return value
                case .changing(var p, let trans):
                    p.x += trans.width
                    p.y += trans.height
                    return p
                }
            }
        }

        public class GlobalConfig: ObservableObject {
            static let shared = GlobalConfig()
            private init() {
                _lastPosition = .init(key: "lastPosition", default: .init(x: 100, y: 100))
            }

            @Published var lastPosition: CGPoint

            @Published var isActive = true
        }
    }

    private var cancellable: Set<AnyCancellable> = []
    extension Published where Value: Codable {
        init(key: String, default value: Value) {
            var published = Published(wrappedValue: UserDefaults.standard.decode(key: key) ?? value)
            published.projectedValue
                .sink { UserDefaults.standard.encode($0, key: key) }
                .store(in: &cancellable)
            self = published
        }
    }

    extension UIViewController {
        func alert(title: String, message: String?) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    extension UserDefaults {
        func decode<T: Decodable>(_ t: T.Type = T.self, key: String) -> T? {
            guard let data = self.data(forKey: key),
                  let obj = try? JSONDecoder().decode(t, from: data)
            else { return nil }
            return obj
        }

        func encode<T: Encodable>(_ obj: T, key: String) {
            let data = try! JSONEncoder().encode(obj)
            set(data, forKey: key)
        }
    }

    public extension View {
        func mockMeView() -> some View {
            MockMeView { self }
        }
    }

    struct MockMeScreen_Previews: PreviewProvider, View {
        @State var data = Data()
        @State var text = ""
        @State var color = Color.black

        var body: some View {
            MockMeView {
                ZStack {
                    color
                    Text("Hi")
                    #if DEBUG
                        .mockView(viewName: "Main View") {
                            MockProperty.Simple(name: "Data2", property: $data.name)
                        }
                        .mockView(viewName: "Main View") {
                            MockProperty(name: "Data1", property: $data)
                        }
                    #endif
//                    .mock(name: "Activate", property: $data.bool)
//                    .mock(name: "Color", property: $color, setTo: [.red, .gray, .black, .yellow, .green])
                }
                #if DEBUG
                    .mockView(viewName: "Main View") {
                        Text("Hey")
                    }
                #endif
            }
        }

        struct Data: Codable {
            var name = "Name"
            var object = Data()
            var bool = false
            var array = [0, 4, 5]

            struct Data: Codable {
                var id = "ID"
            }
        }

        static var previews: some View {
            MockMeScreen_Previews()
        }
    }

#endif
