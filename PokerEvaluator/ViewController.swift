//
//  ViewController.swift
//  PokerEvaluator
//
//  Created by Joao Paulo Aquino on 25/08/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.
//

import UIKit
import SwiftMessages
import Combinatorics

class ViewController: UIViewController, ChooseCardViewControllerDelegate {
    
    @IBOutlet weak var p1c1Button: UIButton!
    @IBOutlet weak var p1c2Button: UIButton!
    @IBOutlet weak var p2c1Button: UIButton!
    @IBOutlet weak var p2c2Button: UIButton!
    
    @IBOutlet weak var b1Button: UIButton!
    @IBOutlet weak var b2Button: UIButton!
    @IBOutlet weak var b3Button: UIButton!
    @IBOutlet weak var b4Button: UIButton!
    @IBOutlet weak var b5Button: UIButton!
    
    
    var selectedCard: Int?
    
    var hand1 = [Card]()
    var hand2 = [Card]()
    var board = [Card]()
    
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        populateCardsWithImages()
    }
    
    @IBAction func simulateAction(_ sender: Any) {
        
        simulate(board: board, hands: [hand1,hand2] )
    }
    
    func selectedCard(_ card: Card) {
        
        switch selectedCard {
        case 11:
            if hand1.count >= 1 {
             hand1[0] = card
            } else {
            hand1.insert(card, at: 0)
            }
        case 12:
            
            if hand1.count >= 2 {
             hand1[1] = card
            } else {
            hand1.insert(card, at: 1)
            }
        case 21:
            
            if hand2.count >= 1 {
             hand2[0] = card
            } else {
            hand2.insert(card, at: 0)
            }
        case 22:
            
            if hand2.count >= 2 {
             hand2[1] = card
            } else {
            hand2.insert(card, at: 1)
            }
            
        case 31:
            
            if board.count >= 1 {
                board[0] = card
            } else {
                board.insert(card, at: 0)
            }
        case 32:
            
            if board.count >= 2 {
                board[1] = card
            } else {
                board.insert(card, at: 1)
            }
        case 33:
            
            if board.count >= 3 {
                board[2] = card
            } else {
                board.insert(card, at: 2)
            }
        case 34:
            
            if board.count >= 4 {
                board[3] = card
            } else {
                board.insert(card, at: 3)
            }
        case 35:
            
            if board.count >= 5 {
                board[4] = card
            } else {
                board.insert(card, at: 4)
            }
            
        default:
            print("No card selected")
        }
        populateCardsWithImages()

    }
    
    func populateCardsWithImages() {
        p1c1Button.setImage(hand1[safe: 0]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p1c2Button.setImage(hand1[safe: 1]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p2c1Button.setImage(hand2[safe: 0]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p2c2Button.setImage(hand2[safe: 1]?.image ?? UIImage(named: "gray_back"), for: .normal)
        b1Button.setImage(board[safe: 0]?.image ?? UIImage(named: "gray_back"), for: .normal)
        b2Button.setImage(board[safe: 1]?.image ?? UIImage(named: "gray_back"), for: .normal)
        b3Button.setImage(board[safe: 2]?.image ?? UIImage(named: "gray_back"), for: .normal)
        b4Button.setImage(board[safe: 3]?.image ?? UIImage(named: "gray_back"), for: .normal)
        b5Button.setImage(board[safe: 4]?.image ?? UIImage(named: "gray_back"), for: .normal)
    }
    
    @IBAction func cardAction(_ sender: UIButton) {
        selectedCard = sender.tag
        self.performSegue(withIdentifier: "ChooseCardsViewController", sender: sender)
    }
    
    func simulate(board:[Card], hands:[[Card]]) {
        
        switch board.count {
        case 0,1,2:
            self.simulateHoldem(numberOfSims: 1000, board: board, hands: hands)
        case 3,4:
            self.calculateHoldem(board: board, hands: hands)
        default:
            print("Illegal number of cards")
        }
        
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let vc = segue.destination as? ChooseCardsViewController {
                
                vc.cards = Cards.all.map {
                    if hand1.contains($0) || hand2.contains($0) || board.contains($0) {
                        return nil
                    }
                    return($0)
                }

                vc.delegate = self
            }
        }

    
    private func calculateMaxCards(tag: Int) -> Int {
        switch tag {
        case 1 ... 7:
            return 8 - tag
        default:
            return 15 - tag
        }
    }
    
    func simulateHoldem(numberOfSims: Int, board: [Card], hands: [[Card]]) {
        
        //Count number of wins for each player
        var arrayOfWins:[Int] = Array(repeating: 0, count: hands.count)
        //Start time to compute elapsed time
        let start = Date()
        //Exclude cards from players' hand and from board
        let excluding = (hands.flatMap {$0}) + board

        //For every simulation
        for _ in 1 ... numberOfSims {
                                    
            //best seat position in current simulation
            var bestIndex = 0
            //Best hand value for current simulation
            var bestValue: Int?
            
            //Excluded cards = existing cards in players hands
            var newExcluding = excluding
            var newBoard = board
            
            //Simulate remaining cards in board
            while newBoard.count < 5 {
                let newCard = Shuffler.getRandomCard(excludingCards: newExcluding)
                newBoard.append(newCard)
                newExcluding.append(newCard)
            }
            
            
            // for each players hands
            for (index, newHand) in hands.enumerated() {
                
                //Hand value for player
                let newHandValue = Evaluator().evaluate7CardHand(cards: newHand + newBoard)
                print("Thread \(Thread.current)")
                
                if(bestValue == nil) {
                    bestValue = newHandValue.rank
                    bestIndex = index
                } else {
                    if(newHandValue.rank < bestValue!) {
                        bestValue = newHandValue.rank
                        bestIndex = index
                    }
                }
                
            }
                    
            arrayOfWins[bestIndex] += 1
            
        }
             
        let elapsedTime = Date().timeIntervalSince(start)
            
        var result = "elapsedTime \(elapsedTime)"
             
             for (index, value) in arrayOfWins.enumerated() {
                result.append(" Seat \(index) wins \(value) times")
             }
        DispatchQueue.main.async {
            self.resultLabel.text = result
        }

    }
    
    func calculateHoldem(board: [Card], hands: [[Card]]) {
         //Count number of wins for each player
         var arrayOfWins:[Int] = Array(repeating: 0, count: hands.count)
         //Start time to compute elapsed time
         let start = Date()
         //Exclude cards from players' hand and from board
         let excluding = (hands.flatMap {$0}) + board

         //For every simulation
        
        var availableCards = Cards.all
        
        for card in excluding {
            availableCards.remove(object: card)
        }
             
        let combos = Combinatorics.combinationsWithoutRepetitionFrom(availableCards, taking: 5 - board.count)
             // for each players hands
                
                for combo in combos {
                    
                    //best seat position in current simulation
                    var bestIndex = 0
                    //Best hand value for current simulation
                    var bestValue: Int?
                    
                    for (index, newHand) in hands.enumerated() {

                    //Hand value for player
                    let newHandValue = Evaluator().evaluate7CardHand(cards: newHand + board + combo)
                    
                    if(bestValue == nil) {
                        bestValue = newHandValue.rank
                        bestIndex = index
                    } else {
                        if(newHandValue.rank < bestValue!) {
                            bestValue = newHandValue.rank
                            bestIndex = index
                        } 
                    }

                }
                    arrayOfWins[bestIndex] += 1
        }
                      
         let elapsedTime = Date().timeIntervalSince(start)
             
         var result = "elapsedTime \(elapsedTime)"
              
              for (index, value) in arrayOfWins.enumerated() {
                 result.append(" Seat \(index) wins \(value) times")
              }
         DispatchQueue.main.async {
             self.resultLabel.text = result
         }
     }
    
    func simulate5CardDraw(numberOfSims: Int, hands: [[Card]]) {
        var arrayOfWins:[Int] = Array(repeating: 0, count: hands.count)
        let start = Date()
        let excluding = hands.flatMap {$0}

        //For every simulation
        for _ in 1 ... numberOfSims {
         
            //best value in simulation
            var bestIndex = 0
             var bestValue: Int?

        //Excluded cards = existing cards in players hands
        var newExcluding = excluding
            
            // for each players hands
            for (index, var newHand) in hands.enumerated() {
             
         //Simulate remaining cards in player's hands
        while newHand.count < 5 {
            let newCard = Shuffler.getRandomCard(excludingCards: newExcluding)
            newHand.append(newCard)
            newExcluding.append(newCard)
        }
         
        //Hand value for player
        let newHandValue = Evaluator().evaluate(cards: newHand)
                
                if(bestValue == nil) {
                    bestValue = newHandValue.rank
                    bestIndex = index
                } else {
                    if(newHandValue.rank < bestValue!) {
                      bestValue = newHandValue.rank
                        bestIndex = index
                    }
                }

        }
            
            arrayOfWins[bestIndex] += 1
            
        }
        
        let elapsedTime = Date().timeIntervalSince(start)
        print("elapsedTime \(elapsedTime)")
        
        for (index, value) in arrayOfWins.enumerated() {
            print("Seat \(index) wins \(value) times")
        }
    }
    }


extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
