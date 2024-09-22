//
//  ContentView.swift
//  WordGarden
//
//  Created by Theodore Utomo on 9/19/24.
//

import SwiftUI
import AVFAudio

struct ContentView: View {
    @State private var wordsGuessed = 0
    @State private var wordsMissed = 0
    @State private var currentWordIndex = 0
    @State private var wordToGuess = ""
    @State private var revealedWord = ""
    @State private var lettersGuessed = ""
    @State private var guessesRemaining = 8
    @State private var gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
    @State private var guessedLetter = ""
    @State private var imageName = "flower8"
    @State private var playAgainHidden = true
    @State private var playAgainButtonLabel = "Another Word?"
    @State private var audioPlayer: AVAudioPlayer!

    @FocusState private var textFieldIsFocused: Bool

    
    private let wordsToGuess = ["SWIFT", "DOG", "CAT"]
    private let maximumGuesses = 8
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Words Guessed : \(wordsGuessed)")
                    Text("Words Missed: \(wordsMissed)")
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Words to Guess: \(wordsToGuess.count - (wordsGuessed + wordsMissed))")
                    Text("Words in Game: \(wordsToGuess.count)")
                }
            }
            .padding(.horizontal)
            Spacer()
            Text(gameStatusMessage)
                .font(.title)
                .multilineTextAlignment(.center)
                .frame(height: 80)
                .minimumScaleFactor(0.5)
                .padding()
            Spacer()
            //TODO: Switch to wordsToGuess[currenWord]
            Text(revealedWord)
                .font(.title)
            if playAgainHidden {
                HStack {
                    TextField("", text: $guessedLetter)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 30)
                        .overlay {
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(.gray, lineWidth: 2)
                        }
                        .keyboardType(.asciiCapable)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                        .onChange(of: guessedLetter) {
                            guessedLetter = guessedLetter.trimmingCharacters(in: .letters.inverted)
                            guard let lastChar = guessedLetter.last else {
                                return
                            }
                            guessedLetter = String(lastChar).uppercased()
                        }
                        .onSubmit {
                            guard guessedLetter != "" else {
                                return
                            }
                            guessALetter()
                            updateGameplay()
                        }
                        .focused($textFieldIsFocused)
                    
                    
                    Button("Guess a letter") {
                        guessALetter()
                        updateGameplay()
                    }
                    .buttonStyle(.bordered)
                    .tint(.mint)
                    .disabled(guessedLetter.isEmpty)
                }
            } else {
                Button(playAgainButtonLabel) {
                    //If all words have been guessed...
                    if currentWordIndex == wordsToGuess.count {
                        currentWordIndex = 0
                        wordsGuessed = 0
                        wordsMissed = 0
                        playAgainButtonLabel = "Another Word?"
                    }
                    //Reset after a word was guessed or missed
                    wordToGuess = wordsToGuess[currentWordIndex]
                    revealedWord = "_" + String(repeating: " _", count: wordToGuess.count - 1)
                    lettersGuessed = ""
                    guessesRemaining = maximumGuesses
                    imageName = "flower\(guessesRemaining)"
                    gameStatusMessage = "How Many Guesses to Uncover the Hidden Word?"
                    playAgainHidden = true
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.mint)
                
            }
            Spacer()
            Image(imageName)
                .resizable()
                .scaledToFit()
                .animation(.easeIn(duration: 0.75), value: imageName)
        }
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            wordToGuess = wordsToGuess[currentWordIndex]
            revealedWord = "_" + String(repeating: " _", count: wordToGuess.count - 1)
            guessesRemaining = maximumGuesses
        }
    }
    
    func guessALetter() {
        textFieldIsFocused = false
        lettersGuessed += guessedLetter
        revealedWord = ""
        for letter in wordToGuess {
            if lettersGuessed.contains(String(letter)) {
                revealedWord = revealedWord + "\(letter) "
            } else {
                revealedWord = revealedWord + "_ "
            }
        }
        
        revealedWord.removeLast()
    }
    
    func updateGameplay() {
        if !wordToGuess.contains(guessedLetter) {
            guessesRemaining -= 1
            //Animate crubmbling leaf and play "incorrect" sound
            imageName = "wilt\(guessesRemaining)"
            playSound(soundName: "incorrect")
            //Delays change to flower image until after wilt animation is done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                imageName = "flower\(guessesRemaining)"
            }
        } else {
            playSound(soundName: "correct")
        }
        //When we play another word?
        if !revealedWord.contains("_") {
            gameStatusMessage = "You've Guesses It! It Took You \(lettersGuessed.count) Guesses to Guess the Word"
            wordsGuessed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-guessed")
        } else if guessesRemaining == 0 {
            gameStatusMessage = "So Sorry. You're All Out of Guesses"
            wordsMissed += 1
            currentWordIndex += 1
            playAgainHidden = false
            playSound(soundName: "word-not-guessed")
        } else {
            gameStatusMessage = "You've Made \(lettersGuessed.count) Guess\(lettersGuessed.count == 1 ? "" : "es")"
            
        }
        guessedLetter = ""
        if currentWordIndex == wordsToGuess.count {
            playAgainButtonLabel = "Restart Game?"
            gameStatusMessage = gameStatusMessage + "\nYou've Tried All Of the Words. Restart From the Beginning?"
        }
    }
    
    func playSound(soundName: String) {
        guard let soundFile = NSDataAsset(name: soundName) else {
            print("Could not read file named \(soundName)")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(data: soundFile.data)
            audioPlayer.play()
        } catch {
            print("ERROR: \(error.localizedDescription) creating audioPlayer.")
        }
    }
}

#Preview {
    ContentView()
}
