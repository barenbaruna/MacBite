//
//  View+Extensions.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

extension View {
    /// Centers the view horizontally within an infinite maximum width.
    func hCentered() -> some View {
        frame(maxWidth: .infinity, alignment: .center)
    }
}
