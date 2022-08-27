//
//  PinView.swift
//  Mathematize
//
//  Created by Cédric Bahirwe on 27/08/2022.
//

import SwiftUI

struct PinView: View {
    @Binding var inputNumber: String

    private let btnSize: CGFloat = 70
    private let buttons: [String] = ["1","2","3","4","5","6","7","8","9","","0"]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 10) {
            ForEach(buttons, id: \.self) { button in
                CircleButton(button, size: btnSize,
                             action: { setKeyStroke(button) })
                .foregroundColor(.primary)
                .opacity(button.isEmpty ? 0 : 1)

            }
        }
    }

    private func setKeyStroke(_ value: String) {
        inputNumber += value
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(inputNumber: .constant("0"))
    }
}
