//
//  CanvasView.swift
//  DrawerGame
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
    private var tempImageView = UIImageView()
    private var mainImageView = UIImageView()
    private var lastPoint = CGPoint.zero
    private var swiped = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(mainImageView)
        addSubview(tempImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("Init with coder is not implemented")
    }

    override var frame: CGRect {
        didSet {
            tempImageView.frame = frame
            mainImageView.frame = frame
        }
    }

    var drawing = [[CGPoint]]() {
        didSet {
            delegate?.onDrawingChange(drawing: drawing)
        }
    }

    func clean() {
        mainImageView.image = nil
        tempImageView.image = nil
        if !drawing.isEmpty {
            drawing = []
        }
    }

    func drawLine(from fromPoint: CGPoint, to toPoint: CGPoint) {
        UIGraphicsBeginImageContext(self.frame.size)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        tempImageView.image?.draw(in: self.bounds)

        context.move(to: fromPoint)
        context.addLine(to: toPoint)

        drawing.append([fromPoint, toPoint])

        context.setLineCap(.round)
        context.setBlendMode(.normal)
        context.setLineWidth(10)
        context.setStrokeColor(UIColor.systemBlue.cgColor)

        context.strokePath()

        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = 1

        UIGraphicsEndImageContext()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = false
        lastPoint = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        swiped = true
        let currentPoint = touch.location(in: self)
        drawLine(from: lastPoint, to: currentPoint)

        lastPoint = currentPoint
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
            drawLine(from: lastPoint, to: lastPoint)
        }

        UIGraphicsBeginImageContext(mainImageView.frame.size)
        mainImageView.image?.draw(in: self.bounds, blendMode: .normal, alpha: 1.0)
        tempImageView.image?.draw(in: self.bounds, blendMode: .normal, alpha: 1)
        mainImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        tempImageView.image = nil
    }
}
