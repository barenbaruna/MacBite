//
//  CameraSafeAreaView.swift
//  CallBite
//
//  Created by Codex on 12/09/26.
//

import SwiftUI

struct CameraSafeAreaView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: AppSize.cameraSafeAreaCornerRadius)
            .strokeBorder(
                AppColor.white,
                lineWidth: AppSize.cameraSafeAreaStroke
            )
            .accessibilityHidden(true)
    }
}
