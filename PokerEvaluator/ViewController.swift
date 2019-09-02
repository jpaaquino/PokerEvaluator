//
//  ViewController.swift
//  PokerEvaluator
//
//  Created by Joao Paulo Aquino on 25/08/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.
//

import UIKit
import SwiftMessages


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hand1 = [
            Card(.ten, .diamonds),
            Card(.ten, .clubs),

        ]
        
        let hand2 = [
            Card(.ace, .clubs),
            Card(.ace, .spades)
        ]
        

        simulate5CardDraw(numberOfSims: 1000, hands: [hand1,hand2])

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
    
    @IBAction func showCards(_ sender: Any) {
        
        let myCustomView: CardsView = UIView.fromNib()
        SwiftMessages.show(view: myCustomView)
        
    }
    
}

func addConstraints() {
    
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
