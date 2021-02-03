//
//  ViewController.swift
//  7Sözcük
//
//  Created by Onur Mavitas on 22.01.2021.
//

import UIKit

class ViewController: UIViewController {
    //5 properties to hold the important ui elements
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons: [UIButton] = []
    
    var activatedButtons: [UIButton] = []
    var solutions: [String] = []
    var score = 0 {
        didSet { //property observers: whenever score is changed in the code this is executed
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func loadView() {
        //create an empty UIView with white background, assign it to view controller and the view property
        view = UIView() //UIView is the parent class of all UIKit view types
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)
        
        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 24) //get the standard system font
        cluesLabel.text = "İPUÇLARI"
        cluesLabel.numberOfLines = 0 //wraps its clues across as many lines as it takes
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) //this makes it strecth easily
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 24)
        answersLabel.text = "CEVAPLAR"
        answersLabel.textAlignment = .right
        answersLabel.numberOfLines = 0
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)//this makes it strecth easily
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tahmin etmek için heceleri seçin"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false //user cannot activate the textbox
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("CEVAPLA", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside) //calls submitTapped when the button is triggered
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("SİL", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        //a container view to host the buttons (heceler)
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonsView)
        
        //activate all constraints at once with this method
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            //scoreLabel will appear at the top right after pinning it to trailing and top margin
            
            //pin top of the cluesLabel to the bottom of scoreLabel
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            //pin the leading edge of the cluesLabel to the leading edge of the layoutMargins and add 100
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            //multiplier taken into account first, then constant is taken away
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            //this takes up 40% of the available space, -100
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            //center horiontally
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            //put currentAnswer 20 points below the cluesLabel
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            //centerX - 100 to not overlap with the clear button
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            //make it 44 points high
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            //keep the clear and submit buttons aligned
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //this one is 20 points below the submit button
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            
        ])
        
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.layer.borderWidth = 1.0
                letterButton.layer.borderColor = UIColor.systemTeal.cgColor
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLevel()
    }
    
    @objc func letterTapped(_ sender: UIButton) {
        //read the title label from the tapped button
        guard let buttonTitle = sender.titleLabel?.text else { return } //exit if there is no title
        
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle) //add that button title to the current ans text
        activatedButtons.append(sender) //add to this array to know that it is tapped. to reshow when clear is tapped
        sender.isHidden = true //hide the button
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        
        guard let answerText = currentAnswer.text else { return }
        
        if let solutionPosition = solutions.firstIndex(of: answerText) { //if the answer is correct
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n")
            splitAnswers?[solutionPosition] = answerText //replace "7 letters" with the actual answer
            answersLabel.text = splitAnswers?.joined(separator: "\n")
            
            currentAnswer.text = ""
            score += 1
            
            var allAnswered: Bool = true
            for ans in splitAnswers! {
                if ans.contains("letters") {
                    allAnswered = false
                }
            }
            
            if allAnswered {
                let ac = UIAlertController(title: "Bravo!", message: "Bu seviyeyi tamamladın", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Sonraki seviyeye geç", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        } else {
            if score>0 {
                score -= 1
            }
            let ac = UIAlertController(title: "Yanlış cevap", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Tekrar dene", style: .default, handler: nil))
            present(ac, animated: true)
        }
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        
        solutions.removeAll(keepingCapacity: true)
        loadLevel()
        
        for button in letterButtons {
            button.isHidden = false
        }
    }
    
    @objc func clearTapped(_ sender: UIButton) {
        currentAnswer.text = ""
        
        for button in activatedButtons {
            button.isHidden = false
        }
        
        activatedButtons.removeAll()
    }
    
    func loadLevel() {
        var clueString = ""
        var solutionsString = "" //this holds all text we show in the answers label
        var syllables: [String] = []
        
        if let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") {
            if let levelContents = try? String(contentsOf: levelFileURL) {
                var lines = levelContents.components(separatedBy: "\n") //separate clues into individual lines
                lines.shuffle() //each player plays in a different order
                
                for (index, line) in lines.enumerated() {
                    let parts = line.components(separatedBy: ": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index + 1). \(clue)\n"
                    
                    let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                    solutionsString += "\(solutionWord.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let syls = answer.components(separatedBy: "|")
                    syllables += syls
                }
            }
        }
        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines) //remove newlines before adding to labels
        answersLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        letterButtons.shuffle()
        
        if letterButtons.count == syllables.count { //this should always be the case but just to be sure
            let buttonNum = letterButtons.count
            for i in 0..<buttonNum {
                letterButtons[i].setTitle(syllables[i], for: .normal)
            }
        }
    }
}

