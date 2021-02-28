//
//  CanvasView.swift
//  Drawn
//
//  Created by Roman Mazeev on 19.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import UIKit

protocol CanvasViewDelegate: class {
    func onDrawingChange(drawing: [[CGPoint]])
}

class CanvasView: UIView {
    weak var delegate: CanvasViewDelegate?
    private var imageView = UIImageView()
    private var lastPoint = CGPoint.zero

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("Init with coder is not implemented")
    }

    override var frame: CGRect {
        didSet {
            imageView.frame = frame
        }
    }

    var drawing = [[CGPoint]]() {
        didSet {
            delegate?.onDrawingChange(drawing: drawing)
        }
    }

    func clean() {
        imageView.image = nil
        if !drawing.isEmpty {
            drawing = []
        }
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        imageView.image?.draw(in: self.bounds)

        context.move(to: fromPoint)
        context.addLine(to: toPoint)

        drawing.append([fromPoint, toPoint])

        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(10)
        context.setStrokeColor(UIColor.systemBlue.cgColor)

        context.strokePath()

        imageView.image = UIGraphicsGetImageFromCurrentImageContext()
        imageView.alpha = 1

        UIGraphicsEndImageContext()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        lastPoint = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentPoint = touch.location(in: self)
        drawLine(from: lastPoint, to: currentPoint)

        lastPoint = currentPoint
    }
}
