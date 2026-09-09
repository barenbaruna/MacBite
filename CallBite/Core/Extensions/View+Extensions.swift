//
//  View+Extensions.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 09/09/26.
//

import SwiftUI

extension View {
    /// Menerapkan alignment center secara horizontal dalam lebar maksimum
    func hCentered() -> some View {
        frame(maxWidth: .infinity, alignment: .center)
    }
}
