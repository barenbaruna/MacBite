//
//  CallBiteWidget.swift
//  CallBite
//
//  Created by Joshua Valentine Manik on 13/09/26.
//

import SwiftUI
import WidgetKit

@main
struct CallBiteWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: CallBiteWidgetConfiguration.kind,
            provider: CallBiteWidgetProvider()
        ) { entry in
            CallBiteWidgetView(entry: entry)
        }
        .configurationDisplayName("Nutrisi Hari Ini")
        .description("Lihat kalori dan makro, lalu catat makanan dari Layar Utama.")
        .supportedFamilies([.systemMedium])
    }
}
