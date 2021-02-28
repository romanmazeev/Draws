//
//  Drawing.swift
//  Drawn
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import Foundation
import CoreGraphics

struct Drawing {
    private var drawing = [[CGPoint]]()
    private var stroke = [CGPoint]()
    private var minX: CGFloat = CGFloat.greatestFiniteMagnitude
    private var minY: CGFloat = CGFloat.greatestFiniteMagnitude
    private var maxX: CGFloat = 0.0
    private var maxY: CGFloat = 0.0


    init(_ strokes: [[CGPoint]]) {
        for stroke in strokes {
            for point in stroke {
                addPoint(point)
            }
            endStroke()
        }
    }

    mutating private func addPoint(_ point: CGPoint) {
        minX = min(point.x, minX)
        maxX = max(point.x, maxX)
        minY = min(point.y, minY)
        maxY = max(point.y, maxY)
        stroke.append(point)
    }

    mutating private func endStroke() {
        drawing.append(stroke)
        stroke = []
    }

    var rasterized: CGImage {
        let grayscale = CGColorSpaceCreateDeviceGray()
        let intermediateBitmapContext = CGContext(
            data: nil,
            width: 256,
            height: 256,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: grayscale,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        intermediateBitmapContext?.setStrokeColor(
            red: 1.0,
            green: 1.0,
            blue: 1.0,
            alpha: 1.0
        )
        let transform = CGAffineTransform.identity

        let path = CGMutablePath()
        for stroke in normalized {
            guard let startPoint = stroke.first else { break }
            path.move(to: startPoint, transform: transform)
            for point in stroke {
                path.addLine(to: point, transform: transform)
            }
        }

        intermediateBitmapContext?.setLineWidth(20.0)
        intermediateBitmapContext?.beginPath()
        intermediateBitmapContext?.addPath(path)
        intermediateBitmapContext?.strokePath()
        let intermediateImage = intermediateBitmapContext?.makeImage()

        let finalBitmapContext = CGContext(
            data: nil,
            width: 28,
            height: 28,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: grayscale,
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )
        let finalRect = CGRect(x: 0.0, y: 0.0, width: 28.0, height: 28.0)
        finalBitmapContext?.draw(intermediateImage!, in: finalRect)
        return (finalBitmapContext?.makeImage())!
    }

    private var normalized: [[CGPoint]] {
        return drawing.map { stroke in
            stroke.map { point in
                let newX = maxX == minX ? minX : (point.x - minX) * 255.0 / (maxX - minX)
                let newY = maxY == minY ? minY : (point.y - maxY) * 255.0 / (minY - maxY)
                return CGPoint(x: newX, y: newY)
            }
        }
    }
}
