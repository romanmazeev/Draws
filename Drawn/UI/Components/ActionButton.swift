//
//  ActionButton.swift
//  Drawn
//
//  Created by Roman Mazeev on 01.05.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import SwiftUI

struct ActionButton: View {
    enum ButtonType {
        case clean
        case next
        case remember
        case resetPredictor

        var backgroundColor: Color {
            switch self {
                case .clean:
                    return .gray
                case .next:
                    return .green
                case .remember:
                    return .orange
                case .resetPredictor:
                    return .red
            }
        }

        var title: String {
            switch self {
                case .clean:
                    return "Clean"
                case .next:
                    return "Next"
                case .remember:
                    return "Remember"
                case .resetPredictor :
                    return "Reset predictor"
            }
        }
    }

    let type: ButtonType
    let action: () -> Void

    var body: some View {
        Button(
            action: {
                self.action()
            },
            label: {
                Text(verbatim: type.title)
            }
        )
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding()
        .foregroundColor(.white)
        .background(type.backgroundColor)
        .cornerRadius(12)
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        ActionButton(type: .clean, action: {})
    }
}
