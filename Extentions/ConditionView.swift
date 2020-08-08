//
//  ConditionView.swift
//  EmojiArt
//
//  Created by Lucas Claro on 02/07/20.
//  Copyright © 2020 Lucas Claro. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        }
        else {
            self
        }
    }
}
