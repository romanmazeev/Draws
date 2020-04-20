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
        ZStack {
            Canvas(drawing: $viewModel.drawing)
            VStack {
                Text(verbatim: "Try drawing: \(viewModel.drawingTask ?? "")")
                    .padding()
                    .font(.headline)
                if viewModel.prediction != "" {
                    Text(verbatim: "Now it`s look like \(viewModel.prediction)")
                        .foregroundColor(viewModel.isCompleted ? Color.green : Color.red)
                        .padding()
                        .font(.subheadline)
                }
                Spacer()
                HStack {
                    Button(
                        action: {
                            self.viewModel.clean()
                        },
                        label: {
                            Text(verbatim: "Clean")
                        }
                    )
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding()

                    Button(
                        action: {
                            self.viewModel.nextTask()
                        },
                        label: {
                            Text(verbatim: "Next")
                        }
                    )
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding()
                }

            }
        }
        .alert(isPresented: $viewModel.isCompleted) {
            Alert(
                title: Text(verbatim: "Good job"),
                message: Text(verbatim: "Try another one"),
                dismissButton: .cancel({
                    self.viewModel.nextTask()
                })
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ViewModel())
    }
}
