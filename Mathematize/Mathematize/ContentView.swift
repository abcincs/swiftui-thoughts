//
//  ContentView.swift
//  Mathematize
//
//  Created by Cédric Bahirwe on 30/05/2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameStore = GameStore()
    var body: some View {
        VStack {
            Text("MATHEMATIZE")
                .font(.system(.largeTitle, design: .rounded).bold())
                .padding(10)
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial, ignoresSafeAreaEdges: .top)

            Text("Can you guess it right!?")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.semibold)

            VStack {
                viewForCurrentLevel()
            }
            .frame(maxHeight: .infinity)
        }
        .alert(isPresented: $gameStore.alertItem.status, content: {
            Alert(title: Text("MATHEMATIZE"),
                  message: Text(gameStore.alertItem.message),
                  dismissButton: .default(Text("Got it!"), action: restartGame))
        })
    }

    private func restartGame() {
        withAnimation {
            gameStore.restartGame()
        }
    }

    @ViewBuilder
    private func viewForCurrentLevel() -> some View {
        switch gameStore.currentLevel {
        case .start:
            startView
        case .one:
            level1View
        case .two:
            level2View
        case .final:
            finalView
        }
    }

    private var startView: some View {
        VStack(spacing: 30) {
            Text("Choose the number of digits")
                .font(.system(.title, design: .rounded))

            HStack {
                ForEach(GameStore.suggestedDigitsChoice, id: \.self) { digit in
                    Text(String(digit))
                        .font(.system(.largeTitle, design: .rounded))
                        .frame(width: 60, height: 60)
                        .background(.regularMaterial)
                        .cornerRadius(10)
                        .scaleEffect(digit==gameStore.selectedDigitChoice ? 1 : 0.8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(digit==gameStore.selectedDigitChoice ? Color.green : Color.clear,
                                        lineWidth: 0.5)
                        )
                        .contentShape(Rectangle())
                        .animation(.linear, value: gameStore.selectedDigitChoice)
                        .onTapGesture {
                            gameStore.setGameDigit(digit)
                        }
                }
            }
            Button(action: gameStore.startGame) {
                Text("Start")
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    private var level1View: some View {
        VStack {
            Group {
                Text("The number to guess is")
                    .font(.system(.title, design: .rounded))
                Text(gameStore.selectedGameNumber.description)
                    .font(.system(.largeTitle, design: .rounded).weight(.black))
            }
            .foregroundColor(.green)

            Button(action:{
                gameStore.goToNextLevel()
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    private var level2View: some View {
        VStack(spacing: 25) {

            HStack {
                if !(gameStore.selectedGameNumber == -1) {
                    ForEach(0..<String(gameStore.selectedGameNumber).count, id:\.self) { i in
                        let guessString =  Array(String(gameStore.guessGameDigits))
                        let isContained = i < guessString.count
                        Text(isContained ? String(guessString[i]) : "")
                            .font(.system(.largeTitle, design: .rounded))
                            .frame(maxWidth: 60)
                            .frame(height: 60)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                        //                    .scaleEffect(digit==gameStore.selectedDigitChoice ? 1 : 0.8)
                        //                    .overlay(
                        //                        RoundedRectangle(cornerRadius: 10)
                        //                            .stroke(digit==gameStore.selectedDigitChoice ? Color.green : Color.clear,
                        //                                    lineWidth: 0.5)
                        //                    )
                            .contentShape(Rectangle())
                            .animation(.linear, value: gameStore.selectedGameNumber)
                    }

                    if !(gameStore.guessGameDigits.isEmpty) {
                        Text("X")
                            .font(.system(.largeTitle, design: .rounded))
                            .frame(maxWidth: 60)
                            .frame(height: 60)
                            .background(.regularMaterial)
                            .cornerRadius(10)
                            .foregroundColor(.red)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                gameStore.deleteLastDigit()
                            }
                    }
                }
            }

            PinView(inputNumber: gameStore.gameNumberBinding().animation())

            if gameStore.isReadyForSubmission() {
                Button(action: gameStore.submit) {
                    Text("Submit")
                        .foregroundColor(.white)
                        .frame(width: 120, height: 40)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal)

    }

    private var finalView: some View {
        VStack {
            Group {
                Text("Congrats, you got it right!!")
                    .font(.system(.title2, design: .rounded))
                Text("After \(gameStore.gameNumberGuesses.count) guesses.")
                    .font(.system(.title3, design: .serif))

            }

            Button(action: gameStore.restartGame) {
                Text("Restart")
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
