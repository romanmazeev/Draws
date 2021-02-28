//
//  MLService.swift
//  Drawn
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import Combine
import CoreML
import CoreImage

class MLService {
    private var updatedDrawingClassifier: QuickDrawUpdatable?
    private let defaultDrawingClassifier = try! QuickDrawUpdatable(configuration: .init())

    private var currentModel: QuickDrawUpdatable {
        updatedDrawingClassifier ?? defaultDrawingClassifier
    }

    private let defaultModelURL: URL
    private let updatedModelURL: URL
    private let tempUpdatedModelURL: URL

    init() {
        let appDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!

        defaultModelURL = QuickDrawUpdatable.urlOfModelInThisBundle

        updatedModelURL = appDirectory.appendingPathComponent("personalized.mlmodelc")
        tempUpdatedModelURL = appDirectory.appendingPathComponent("personalized_tmp.mlmodelc")

        loadUpdatedModel()
    }

    func predict(image: CGImage) -> AnyPublisher<String, Error> {
        return Future { promise in
            do {
                let featureValue = try MLFeatureValue(
                    cgImage: image,
                    constraint: self.currentModel.imageConstraint,
                    options: nil
                )
                
                let prediction = try self.currentModel.prediction(
                    input: QuickDrawUpdatableInput(
                        image: featureValue.imageBufferValue!
                    )
                )

                promise(.success(prediction.classLabel))
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func updateModel(image: CGImage, classLabel: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                let featureValue = try MLFeatureValue(
                    cgImage: image,
                    constraint: self.currentModel.imageConstraint,
                    options: nil
                )
                let featureProvider = QuickDrawUpdatableTrainingInput(
                    image: featureValue.imageBufferValue!,
                    classLabel: classLabel
                )
                let banchProvider = MLArrayBatchProvider(array: [featureProvider])

                let usingUpdatedModel = self.updatedDrawingClassifier != nil
                let currentModelURL = usingUpdatedModel ? self.updatedModelURL : self.defaultModelURL

                try MLUpdateTask(
                    forModelAt: currentModelURL,
                    trainingData: banchProvider,
                    configuration: nil,
                    completionHandler: {
                        self.saveUpdatedModel($0)
                        self.loadUpdatedModel()
                        promise(.success(()))
                    }
                ).resume()
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }

    func resetDrawingClassifier() {
        updatedDrawingClassifier = nil

        if FileManager.default.fileExists(atPath: updatedModelURL.path) {
            try? FileManager.default.removeItem(at: updatedModelURL)
        }
    }

    private func loadUpdatedModel()  {
        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else { return }
        let model = try? QuickDrawUpdatable(contentsOf: updatedModelURL)
        updatedDrawingClassifier = model
    }

    private func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        let fileManager = FileManager.default
        try? fileManager.createDirectory(at: tempUpdatedModelURL,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        try? updatedModel.write(to: tempUpdatedModelURL)
        _ = try? fileManager.replaceItemAt(updatedModelURL,
                                           withItemAt: tempUpdatedModelURL)
    }
}

extension QuickDrawUpdatable {
    var imageConstraint: MLImageConstraint {
        model.modelDescription.inputDescriptionsByName["image"]!.imageConstraint!
    }
}
