//
//  ContentView.swift
//  CallBite
//
//  Created by Baren Baruna Harahap on 31/08/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        DashboardFactory.makeView()
    }
}

#Preview {
    DashboardFactory.makeView()
}
