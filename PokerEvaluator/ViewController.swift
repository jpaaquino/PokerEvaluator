//
//  ViewController.swift
//  PokerEvaluator
//
//  Created by Joao Paulo Aquino on 25/08/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let hand = Evaluator().evaluate(cards: ["T♣", "J♣", "Q♣", "K♣", "A♦"])
        let newHand = Evaluator().evaluate7CardHand(cards: ["4♣", "5♦","T♣", "J♦", "A♣", "K♣", "A♦"])

        print("\(newHand.name) \(newHand.rank)")

        print("\(hand.name) \(hand.rank)")
    }

}


//"♠": 0b0001,
//"♥": 0b0010,
//"♦": 0b0100,
//"♣": 0b1000]
