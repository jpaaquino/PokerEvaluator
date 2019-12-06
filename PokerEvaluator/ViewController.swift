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
    
    enum GameType {
        case noLimitHoldem
        case fiveCardDraw
    }
    
    @IBOutlet weak var p1c1Button: UIButton!
    @IBOutlet weak var p1c2Button: UIButton!
    @IBOutlet weak var p1c3Button: UIButton!
    @IBOutlet weak var p1c4Button: UIButton!
    @IBOutlet weak var p1c5Button: UIButton!
    @IBOutlet weak var p2c1Button: UIButton!
    @IBOutlet weak var p2c2Button: UIButton!
    @IBOutlet weak var p2c3Button: UIButton!
    @IBOutlet weak var p2c4Button: UIButton!
    @IBOutlet weak var p2c5Button: UIButton!
   
    @IBOutlet weak var b1Button: UIButton!
    @IBOutlet weak var b2Button: UIButton!
    @IBOutlet weak var b3Button: UIButton!
    @IBOutlet weak var b4Button: UIButton!
    @IBOutlet weak var b5Button: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var boardLabel: UILabel!
    
    var selectedCard: Int?
    
    var game: GameType {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            return .noLimitHoldem
        default:
            return .fiveCardDraw
        }
    }
    
    var hand1: [Card] = [Card(.ace, .spades), Card(.king, .spades)]
    var hand2: [Card] = [Card(.five, .spades), Card(.five, .diamonds)]
    var board = [Card(.ten, .spades), Card(.jack, .spades), Card(.two, .diamonds) ]
    
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        populateCardsWithImages()
    }
    @IBAction func didChangeValue(_ sender: UISegmentedControl) {
        clear()
        setupGame()
    }
    
    @IBAction func simulateAction(_ sender: Any) {
        
        simulate(board: board, hands: [hand1,hand2] )
    }
    
    @IBAction func claerAction(_ sender: Any) {
        clear()
    }
    
    func clear() {
        hand1 = []
        hand2 = []
        board = []
        populateCardsWithImages()
    }
    
    func setupGame() {
        p1c3Button.isHidden = game == .noLimitHoldem
        p1c4Button.isHidden = game == .noLimitHoldem
        p1c5Button.isHidden = game == .noLimitHoldem
        p2c3Button.isHidden = game == .noLimitHoldem
        p2c4Button.isHidden = game == .noLimitHoldem
        p2c5Button.isHidden = game == .noLimitHoldem
        b1Button.isHidden = game == .fiveCardDraw
        b2Button.isHidden = game == .fiveCardDraw
        b3Button.isHidden = game == .fiveCardDraw
        b4Button.isHidden = game == .fiveCardDraw
        b5Button.isHidden = game == .fiveCardDraw
        boardLabel.isHidden = game == .fiveCardDraw
        
    }
    
    func selectedCard(_ card: Card) {
        guard let selectedCard = selectedCard else {return}
        
        let minCard = selectedCard % 10
        let cardPosition = minCard - 1
        
        if selectedCard < 20 {
            
            if hand1.count >= minCard {
                hand1[cardPosition] = card
            } else {
                hand1.insert(card, at: cardPosition)
            }
        } else if selectedCard < 30 {
            
            if hand2.count >= minCard {
                hand2[cardPosition] = card
            } else {
                hand2.insert(card, at: cardPosition)
            }
            
        } else {
            if board.count >= minCard {
                board[cardPosition] = card
            } else {
                board.insert(card, at: cardPosition)
            }
        }
        
        populateCardsWithImages()
    }
    
    func populateCardsWithImages() {
        p1c1Button.setImage(hand1[safe: 0]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p1c2Button.setImage(hand1[safe: 1]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p1c3Button.setImage(hand1[safe: 2]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p1c4Button.setImage(hand1[safe: 3]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p1c5Button.setImage(hand1[safe: 4]?.image ?? UIImage(named: "gray_back"), for: .normal)

        p2c1Button.setImage(hand2[safe: 0]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p2c2Button.setImage(hand2[safe: 1]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p2c3Button.setImage(hand2[safe: 2]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p2c4Button.setImage(hand2[safe: 3]?.image ?? UIImage(named: "gray_back"), for: .normal)
        p2c5Button.setImage(hand2[safe: 4]?.image ?? UIImage(named: "gray_back"), for: .normal)

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

        if game == .fiveCardDraw {
        let result = Simulator.simulate5CardDraw(numberOfSims: 1000, hands: hands)
        printResult(wins: result)

        } else {
        
        switch board.count {
        case 0:
            let result = Simulator.simulateHoldem(numberOfSims: 1000, board: board, hands: hands)

            printResult(wins: result)
        case 3,4:
            let result = Simulator.calculateHoldem(board: board, hands: hands)
            printResult(wins: result)
        default:
            print("Illegal number of cards")
        }
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

    private func printResult(wins: [Double]) {
        
        let heroWins: Double = Double(wins[0])
        let villainWins = Double(wins[1])
        let total = heroWins + villainWins
        
        let text = "Hero wins \(heroWins) times - \(100*heroWins/total)%\nVillain wins \(villainWins) times - \(100*villainWins/total)%"
        
        DispatchQueue.main.async {
            self.resultLabel.text = text
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
