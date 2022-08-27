//
//  CircleButton.swift
//  Mathematize
//
//  Created by Cédric Bahirwe on 27/08/2022.
//

import SwiftUI

struct CircleButton: View {
    let title: String
    let size: CGFloat
    let action: () -> Void

    init(_ title: String, size: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title2, design: .monospaced))
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct CircleButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleButton("0", size: 29, action: {})
    }
}
