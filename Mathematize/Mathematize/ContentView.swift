//
//  ContentView.swift
//  Mathematize
//
//  Created by Cédric Bahirwe on 30/05/2022.
//

import SwiftUI

enum GameLevel: Int {
    case start = 0
    case one, two
    case final
}

class GameStore: ObservableObject {
    private let maxGameDigitsRange: ClosedRange<Int> = (4...10)
    static var suggestedDigitsChoice: [Int] = [4, 5, 6, 7, 8]

    @Published private(set) var currentLevel = GameLevel.start
    @Published private(set) var selectedDigitChoice: Int = suggestedDigitsChoice[0]
    @Published private(set) var guessGameDigits: String = ""

    @Published private(set) var selectedGameNumber: Int = -1
    @Published private(set) var gameNumberGuesses: [String] = []
    @Published var alertItem: (status: Bool, message: String) = (false, "")

    public func gameNumberBinding() -> Binding<String> {
        Binding {
            self.guessGameDigits
        } set: { value in
            self.guessGameDigits = value
        }
    }

    // We can also throw if selected digit is not supported
    public func setGameDigit(_ digit: Int) {
        guard maxGameDigitsRange.contains(digit) else { return }
        self.selectedDigitChoice = digit
    }

    public func deleteLastDigit() {
        self.guessGameDigits.removeLast()
    }


    private func setGameLevel(_ newLevel: GameLevel) {
        self.currentLevel = newLevel
    }

    public func startGame() {
        setGameNumber()
        setGameLevel(.one)
    }

    public func restartGame() {
        withAnimation {
            selectedDigitChoice = Self.suggestedDigitsChoice[0]
            guessGameDigits = ""
            selectedGameNumber = -1
            gameNumberGuesses = []
            currentLevel = .start
        }
    }

    // We can also throw if selected digit is not supported
    func generateGameNumberRange() -> ClosedRange<Int> {
        let lowerBound: Int = Int(pow(Double(10), Double(selectedDigitChoice)))
        let upperBound: Int = Int(pow(Double(10), Double(selectedDigitChoice+1))) - 1

        return lowerBound...upperBound
    }


    private func setGameNumber() {
        let gameNumberRange = generateGameNumberRange()
        selectedGameNumber = gameNumberRange.randomElement()!
    }

    // We can also throw if next level is not supported
    func goToNextLevel() {
        let thisLevel = currentLevel.rawValue

        if let nextLevel = GameLevel(rawValue: thisLevel+1) {
            self.currentLevel = nextLevel
        } else {
            print("There is no next level at the moment, You are done with the game\nStart a new one.")
        }
    }

    func isReadyForSubmission() -> Bool {
        guessGameDigits.count == String(selectedGameNumber).count
    }

    func submit() {
        gameNumberGuesses.append(guessGameDigits)

        let result = validateAnswer()

        alertItem = (result.success, result.message)
    }

    private func validateAnswer() -> (success: Bool, message: String) {
        guard guessGameDigits.count == String(selectedGameNumber).count else {
            return (true, "You have not finished the game yet!.")
        }

        guard guessGameDigits == String(selectedGameNumber) else {
            return (true, "You guessed it wrong dear, the correct one was \(selectedGameNumber)!.")
        }

        return (true, "Congrats!, You guessed it right!.")
    }

}

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
                  dismissButton: .default(Text("Got it!"), action: gameStore.restartGame))
        })
        .onAppear(perform: logic)

    }


    func logic() {
        // 3. and a input for collecting user value (need screen key board
        // 4. Finally collect user guess and compare to initial guess

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
        VStack {
            Text("Choose the number of digits")
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
            Text("Your number is \(gameStore.selectedGameNumber.description)")
                .font(.system(.title, design: .rounded))
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

struct PinView: View {
    @Binding var inputNumber: String

    private let btnSize: CGFloat = 70
    private let buttons: [String] = ["1","2","3","4","5","6","7","8","9","","0"]

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 10) {
            ForEach(buttons, id: \.self) { button in
                CircleButton(button, size: btnSize,
                             action: { addKey(button)})
                .foregroundColor(.primary)
                .opacity(button.isEmpty ? 0 : 1)

            }
        }
    }

    private func addKey(_ value: String) {
        inputNumber += value
    }
}

struct CircleButton: View {

    let title: String
    let size: CGFloat
    let action: () -> Void


    init(_ title: String, size: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title2, design: .monospaced))
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}
