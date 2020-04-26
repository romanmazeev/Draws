//
//  MLService.swift
//  DrawerGame
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import Combine
import CoreML
import CoreImage

class MLService {
    private var updatedDrawingClassifier: QuickDrawUpdatable?
    private let defaultDrawingClassifier = QuickDrawUpdatable()

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

    func updateModel(image: CGImage, classLabel: String) {
        let featureValue = try! MLFeatureValue(cgImage: image, constraint: currentModel.imageConstraint, options: nil)
        let featureProvider = QuickDrawUpdatableTrainingInput(
            image: featureValue.imageBufferValue!,
            classLabel: classLabel
        )
        let banchProvider = MLArrayBatchProvider(array: [featureProvider])

        let usingUpdatedModel = updatedDrawingClassifier != nil
        let currentModelURL = usingUpdatedModel ? updatedModelURL : defaultModelURL

        func updateModelCompletionHandler(updateContext: MLUpdateContext) {
            saveUpdatedModel(updateContext)

            loadUpdatedModel()
        }

        updateModel(at: currentModelURL,
                    with: banchProvider,
                    completionHandler: updateModelCompletionHandler)
    }

    func resetDrawingClassifier() {
        updatedDrawingClassifier = nil

        if FileManager.default.fileExists(atPath: updatedModelURL.path) {
            try? FileManager.default.removeItem(at: updatedModelURL)
        }
    }

    private func updateModel(at url: URL,
                             with trainingData: MLBatchProvider,
                             completionHandler: @escaping (MLUpdateContext) -> Void) {
        
        guard let updateTask = try? MLUpdateTask(
            forModelAt: url,
            trainingData: trainingData,
            configuration: nil,
            completionHandler: completionHandler
        )
            else {
                print("Could't create an MLUpdateTask.")
                return
        }

        updateTask.resume()
    }

    private func loadUpdatedModel() {
        guard FileManager.default.fileExists(atPath: updatedModelURL.path) else {
            return
        }

        guard let model = try? QuickDrawUpdatable(contentsOf: updatedModelURL) else {
            return
        }

        updatedDrawingClassifier = model
    }

    private func saveUpdatedModel(_ updateContext: MLUpdateContext) {
        let updatedModel = updateContext.model
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(at: tempUpdatedModelURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            try updatedModel.write(to: tempUpdatedModelURL)
            _ = try fileManager.replaceItemAt(updatedModelURL,
                                              withItemAt: tempUpdatedModelURL)
        } catch let error {
            print("Could not save updated model to the file system: \(error)")
            return
        }
    }
}

extension QuickDrawUpdatable {
    var imageConstraint: MLImageConstraint {
        let description = model.modelDescription

        let inputName = "image"
        let imageInputDescription = description.inputDescriptionsByName[inputName]!

        return imageInputDescription.imageConstraint!
    }
}
