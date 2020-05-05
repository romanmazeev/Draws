//
//  ActionButton.swift
//  Drawn
//
//  Created by Roman Mazeev on 01.05.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    let action: () -> Void
    let backgroundColor: Color
    let title: String
    
    var body: some View {
        Button(
            action: {
                self.action()
            },
            label: {
                Text(verbatim: title)
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
            }
        )
        .foregroundColor(.white)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(action: {}, backgroundColor: .red, title: "123")
    }
}
