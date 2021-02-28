//
//  ContentView.swift
//  Drawn
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            Canvas(drawing: $viewModel.drawing)
                .ignoresSafeArea()

            VStack {
                Text(verbatim: "Try to draw: \(viewModel.drawingTask)")
                    .padding()
                    .font(.title)

                if !viewModel.prediction.isEmpty {
                    Text(verbatim: "It seems to be \(viewModel.prediction)")
                        .foregroundColor(viewModel.isCompleted ? Color.green : Color.red)
                        .font(.subheadline)
                }

                Spacer()

                VStack {
                    HStack {
                        ActionButton(type: .clean) {
                            self.viewModel.clean()
                        }

                        ActionButton(type: .next) {
                            self.viewModel.nextTask()
                        }
                    }

                    HStack {
                        ActionButton(type: .remember) {
                            self.viewModel.rememberDrawing()
                        }

                        ActionButton(type: .resetPredictor) {
                            self.viewModel.resetPredictor()
                        }
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $viewModel.isCompleted) {
            Alert(
                title: Text(verbatim: "Good job"),
                message: Text(verbatim: "Try another one"),
                dismissButton: .cancel {
                    self.viewModel.nextTask()
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewModel())
    }
}
