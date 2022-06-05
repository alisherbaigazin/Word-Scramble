//
//  ContentView.swift
//  Word Scramble
//
//  Created by Alisher Baigazin on 05.06.2022.
//

import SwiftUI

struct ContentView: View {
    @State var newWord = ""
    @State var words: [String] = []
    @State var rootWord = ""
    
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var isAlertVisible = false
    
    @State var score = 0
    @FocusState var isKeyboardOnFocus: Bool
    
    var body: some View {
        NavigationView {
            List {
                TextField("Enter a word", text: $newWord)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .focused($isKeyboardOnFocus)
                
                Section {
                    ForEach(words, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                } header: {
                    Text("Words")
                }
            }
            .onAppear(perform: startGame)
            .navigationTitle("\(rootWord)")
//            .navigationBarTitleDisplayMode(.inline)
            .onSubmit {
                addWord()
            }
            .alert(alertTitle, isPresented: $isAlertVisible) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Image(systemName: "\(score).circle.fill")
                        .font(.title)
                        .foregroundColor(.accentColor)
                    Button("New Game") {
                        newGame()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isKeyboardOnFocus.toggle()
                    }
                }
            }
        }
    }
    
    func newGame() {
        startGame()
        words = []
        score = 0
        newWord = ""
    }
    
    func startGame() {
        if let fileUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let fileToString = try? String(contentsOf: fileUrl) {
                let array = fileToString.components(separatedBy: "\n")
                rootWord = array.randomElement() ?? "default!"
                return
            }
        }
        fatalError("There is some kind of a problem, sorry bro")
    }
    
    func addWord() {
        let word = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard word.count > 2 && word != rootWord else {
            callAlert(alertTitle: "Too short", alertMessage: "Word must contain at least 3 character")
            return
        }
        
        guard isOriginal(for: word) else {
            callAlert(alertTitle: "Not original word", alertMessage: "You already used this word")
            return
        }
        guard isPossible(for: word) else {
            callAlert(alertTitle: "Not possible word", alertMessage: "Rootword does not contain this characters")
            return
        }
        guard isMisspeled(for: word) else {
            callAlert(alertTitle: "Misspeled", alertMessage: "You can not come up with this word")
            return
        }
        newWord = ""
        
        withAnimation {
            words.insert(word, at: 0)
        }
        
        score += word.count
    }
    
    func callAlert(alertTitle: String, alertMessage: String) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        newWord = ""
        isAlertVisible.toggle()
    }
    
    func isOriginal(for word: String) -> Bool {
        !words.contains(word)
    }
    
    func isPossible(for word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let index = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: index)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isMisspeled(for word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspeledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        let allGood = misspeledRange.location == NSNotFound
        
        return allGood
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
