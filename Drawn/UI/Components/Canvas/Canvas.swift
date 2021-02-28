//
//  Canvas.swift
//  Drawn
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import SwiftUI

struct Canvas: UIViewRepresentable {
    @Binding var drawing: [[CGPoint]]

    func makeUIView(context: UIViewRepresentableContext<Canvas>) -> CanvasView {
        let canvasView = CanvasView()
        canvasView.backgroundColor = UIColor.systemBackground
        canvasView.delegate = context.coordinator
        
        return canvasView
    }

    func updateUIView(_ uiView: CanvasView, context: UIViewRepresentableContext<Canvas>) {
        if drawing.isEmpty {
            uiView.clean()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, CanvasViewDelegate {
        var parent: Canvas

        init(_ canvas: Canvas) {
            self.parent = canvas
        }

        func onDrawingChange(drawing: [[CGPoint]]) {
            parent.drawing = drawing
        }
    }
}
