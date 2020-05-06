//
//  ContentView.swift
//  DrawerGame
//
//  Created by Roman Mazeev on 18.04.2020.
//  Copyright © 2020 Roman Mazeev. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack {
            VStack {
                Text(verbatim: "Try drawing: \(viewModel.drawingTask)")
                    .font(.headline)
                    .padding(.bottom)

                Text(verbatim: viewModel.prediction != "" ? "Now it`s look like \(viewModel.prediction)" : " ")
                    .foregroundColor(viewModel.isCompleted ? Color.green : Color.red)
                    .font(.subheadline)
            }
            .padding()

            Canvas(drawing: $viewModel.drawing)

            VStack {
                HStack {
                    ActionButton(
                        action: self.viewModel.clean,
                        backgroundColor: .gray,
                        title: "Clean"
                    )

                    ActionButton(
                        action: self.viewModel.nextTask,
                        backgroundColor: .blue,
                        title: "Next"
                    )
                }
                .padding(.bottom)

                HStack {
                    ActionButton(
                        action: self.viewModel.rememberDrawing,
                        backgroundColor: .green,
                        title: "Remember"
                    )

                    ActionButton(
                        action: self.viewModel.resetPredictor,
                        backgroundColor: .red,
                        title: "Reset predictor"
                    )
                }
            }
            .padding()
        }
        .alert(isPresented: $viewModel.isCompleted) {
            Alert(
                title: Text(verbatim: "Good job"),
                message: Text(verbatim: "Try another one"),
                dismissButton: .cancel(self.viewModel.nextTask)
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewModel())
    }
}
