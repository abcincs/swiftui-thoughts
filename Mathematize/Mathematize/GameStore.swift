//
//  GameStore.swift
//  Mathematize
//
//  Created by Cédric Bahirwe on 27/08/2022.
//

import Combine

final class GameStore: ObservableObject {
    private let maxGameDigitsRange: ClosedRange<Int> = (4...10)
    static var suggestedDigitsChoice: [Int] = [4, 5, 6, 7, 8]

    @Published private(set) var currentLevel = GameLevel.start
    @Published private(set) var selectedDigitChoice: Int = suggestedDigitsChoice[0]
    @Published private(set) var guessGameDigits: String = ""

    @Published private(set) var selectedGameNumber: Int = -1
    @Published private(set) var gameNumberGuesses: [String] = []
    @Published var alertItem: (status: Bool, message: String) = (false, "")


    // MARK: - Private Methods
    private func setGameLevel(_ newLevel: GameLevel) {
        self.currentLevel = newLevel
    }

    private func setGameNumber() {
        let gameNumberRange = generateGameNumberRange()
        selectedGameNumber = gameNumberRange.randomElement()!
    }

    // We can also throw if selected digit is not supported
    private func generateGameNumberRange() -> ClosedRange<Int> {
        let lowerBound: Int = Int(pow(Double(10), Double(selectedDigitChoice)))
        let upperBound: Int = Int(pow(Double(10), Double(selectedDigitChoice+1))) - 1

        return lowerBound...upperBound
    }

    private func getAnswerValidation() -> (success: Bool, message: String) {
        guard guessGameDigits.count == String(selectedGameNumber).count else {
            return (true, "You have not finished the game yet!.")
        }

        guard guessGameDigits == String(selectedGameNumber) else {
            return (true, "You guessed it wrong dear, the correct one was \(selectedGameNumber)!.")
        }

        return (true, "Congrats!, You guessed it right!.")
    }

    // MARK: - Public Methods
    public func gameNumberBinding() -> Binding<String> {
        Binding {
            self.guessGameDigits
        } set: { value in
            guard value.count <=  String(self.selectedGameNumber).count else { return }
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
    public func startGame() {
        setGameNumber()
        setGameLevel(.one)
    }

    public func restartGame() {
        selectedDigitChoice = Self.suggestedDigitsChoice[0]
        guessGameDigits = ""
        selectedGameNumber = -1
        gameNumberGuesses = []
        currentLevel = .start
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

    public func isReadyForSubmission() -> Bool {
        guessGameDigits.count == String(selectedGameNumber).count
    }

    public func submit() {
        gameNumberGuesses.append(guessGameDigits)

        let validation = getAnswerValidation()

        alertItem = (validation.success, validation.message)
    }
}
