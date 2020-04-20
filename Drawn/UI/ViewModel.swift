//
//  ViewModel.swift
//  DrawerGame
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var drawing = [[CGPoint]]()

    @Published private(set) var prediction = ""
    @Published private(set) var drawingTask = TaskDataSource.tasks.randomElement()
    @Published var isCompleted = false

    private var cancellables: Set<AnyCancellable> = .init()
    private var predictionCancellables: Set<AnyCancellable> = .init()

    private let mlService = MLService()

    init() {
        $drawing
            .filter { $0 != [] }
            .throttle(for: 1, scheduler: DispatchQueue.global(), latest: true)
            .sink { drawing in
                self.predict(using: drawing)
            }
            .store(in: &cancellables)

        $prediction
            .map { $0 == self.drawingTask }
            .sink { isCompleted in
                self.isCompleted = isCompleted
            }
            .store(in: &cancellables)
    }

    func clean() {
        drawing = []
        prediction = ""
        predictionCancellables.forEach { $0.cancel() }
    }

    func nextTask() {
        clean()
        drawingTask = TaskDataSource.tasks.randomElement()
    }

    private func predict(using drawing: [[CGPoint]]) {
        mlService.predict(drawing: Drawing(drawing: drawing))
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { prediction in
                    self.prediction = prediction
                }
            )
            .store(in: &predictionCancellables)
    }
}
