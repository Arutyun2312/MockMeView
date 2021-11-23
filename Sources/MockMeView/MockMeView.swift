//
//  MockMeScreen.swift
//  freebee
//
//  Created by Arutyun Enfendzhyan on 29.10.21.
//  Copyright © 2021 aaa - all about apps Gmbh. All rights reserved.
//

import SwiftUI

public struct MockMeView: View {
    let content: AnyView
    @State private var location: Location = .constant(.init(x: 100, y: 200))
    @State var targets: [Target] = []
    @State var mocking = false

    public var body: some View {
        ZStack {
            content
                .onPreferenceChange(TargetKey.self) { targets = $0 }
            let view = VStack(spacing: 10) {
                if !mocking {
                    Circle()
                        .frame(width: 25, height: 25)
                }
                Button { withAnimation { mocking.toggle() } } label: {
                    Text(mocking ? "Don't mock me!" : "Mock me!")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray)
                        .cornerRadius(15)
                }
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
            }
        }
    }

    var gesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
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

    private enum Location {
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
}

struct MockMeScreen_Previews: PreviewProvider, View {
    @State var data = Data()
    @State var text = ""
    @State var color = Color.red

    var body: some View {
        MockMeView {
            ZStack {
                color
                Text("Hi")
                    .mockTarget(name: "Data", property: $data)
                    .mockTarget(name: "Activate", property: $data.bool)
                    .mockTarget(name: "Color", property: $color, setTo: [.red, .gray, .black, .yellow, .green])
            }
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
