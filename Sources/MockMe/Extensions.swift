//
//  Extensions.swift
//  freebee
//
//  Created by Arutyun Enfendzhyan on 30.10.21.
//  Copyright © 2021 aaa - all about apps Gmbh. All rights reserved.
//

import SwiftUI
import UIKit

#if DEBUG
extension MockMeView.Target: Hashable, Identifiable {
    public static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    public func hash(into hasher: inout Hasher) { id.hash(into: &hasher) }
}

public extension MockMeView {
    init<Content: View>(@ViewBuilder content: () -> Content) {
        self.init(content: .init(content()))
    }
}
#endif
