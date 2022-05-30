//
//  ContentView.swift
//  Mathematize
//
//  Created by Cédric Bahirwe on 30/05/2022.
//

import SwiftUI

enum GameLevel: Int {
    case start = 0
    case one, two, three
    case final
}

class GameStore: ObservableObject {
    private let maxGameDigitsRange: ClosedRange<Int> = (4...10)
    static var suggestedDigitsChoice: [Int] = [4, 5, 6, 7, 8]

    @Published private(set) var currentLevel = GameLevel.start
    @Published private(set) var selectedDigitChoice: Int = suggestedDigitsChoice[0]

    @Published private(set) var selectedGameNumber: Int = -1
    @Published private(set) var gameNumberGuesses: [Int] = []


    public func gameNumberBinding() -> Binding<Int> {
        Binding {
            self.selectedGameNumber
        } set: { value in
            self.selectedGameNumber = value
        }
    }

    // We can also throw if selected digit is not supported
    public func setGameDigit(_ digit: Int) {
        guard maxGameDigitsRange.contains(digit) else { return }
        self.selectedDigitChoice = digit
    }


    private func setGameLevel(_ newLevel: GameLevel) {
        self.currentLevel = newLevel
    }

    public func startGame() {
        generateGameNumber()
        setGameLevel(.one)
    }

    public func restartGame() {
        selectedDigitChoice = Self.suggestedDigitsChoice[0]
        selectedGameNumber = -1
        gameNumberGuesses = []
        currentLevel = .start
    }

    // We can also throw if selected digit is not supported
    private func generateGameNumberRange() -> ClosedRange<Int> {
        switch selectedDigitChoice {
        case 4: return (10_000...99_999)
        case 5: return (100_000...999_999)
        case 6: return (1_000_000...9_99_999)
        case 7: return (10_000_000...99_999_999)
        case 8: return (100_000_000...9_999_999)
        default: fatalError("Invalid Choice")
        }
    }


    func generateGameNumber() {
        let gameNumberRange = generateGameNumberRange()
        selectedGameNumber = gameNumberRange.randomElement()!
    }

    // We can also throw if next level is not supported
    func goToNextLevel() {
        let thisLevel = currentLevel.rawValue

        if let nextLevel = GameLevel(rawValue: thisLevel) {
            self.currentLevel = nextLevel
        } else {
            print("There is no next level at the moment, You are done with the game\nStart a new one.")
        }
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
        case .three:
            level3View
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

            Button(action: gameStore.startGame) {
                Text("Start")
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }

    private var level2View: some View {
        HStack {
            if !(gameStore.selectedGameNumber == -1) {
                ForEach(String(gameStore.selectedGameNumber).map({ $0 }), id:\.self) { digit in
                    Text(String(digit))
                        .font(.system(.largeTitle, design: .rounded))
                        .frame(width: 60, height: 60)
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
            }
        }
    }

    private var level3View: some View {
        PinView(inputNumber: gameStore.gameNumberBinding())
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
    @Binding var inputNumber: Int
    @State private var inputString: String = ""

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
        .padding(.horizontal)
        .onAppear() {
            inputString = String(inputNumber)
        }
    }

    private func addKey(_ value: String) {
        if value == "X" {
            if !(inputNumber == -1) {
                var numberString = String(inputNumber)
                numberString.removeLast()
                let numberInt = Int(numberString) ?? -1
                inputNumber = numberInt
            }
        } else {
            let numberString = String(inputNumber) + value
            let numberInt = Int(numberString) ?? -1
            inputNumber = numberInt
            inputString = String(numberString)
        }
    }
}

extension Int {
    var stringBind: String {
        get { String(self) }
        set(value) { self = Int(value) ?? 0 }
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
