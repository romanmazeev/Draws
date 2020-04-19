//
//  MLService.swift
//  DrawerGame
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import Foundation
import Vision
import Combine

class MLService {
    private let drawerCalssifier = DrawnClassifier()

    func predict(drawing: Drawing) -> AnyPublisher<String, Error> {
        return Future { promise in
            do {
                let handler = VNImageRequestHandler(cgImage: drawing.rasterized)
                let request = VNCoreMLRequest(
                    model: try VNCoreMLModel(
                        for: self.drawerCalssifier.model
                    )
                ) { request, error in
                    guard let topResult = request.results?.first as? VNClassificationObservation else { return }
                    promise(.success(topResult.identifier))
                }
                try handler.perform([request])
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
