//
//  Evaluator.swift
//  PokerHandEvaluator
//
//  Created by Ivan Sanchez on 06/10/2014.
//  Copyright (c) 2014 Gourame Limited. All rights reserved.
//

import Foundation
import Combinatorics

class Shuffler {
    
    static func suitForIntValue(_ intValue: Int) -> Suit {
        switch intValue {
        case 1 ... 13:
            return .spades
        case 14 ... 26:
            return .diamonds
        case 27 ... 39:
            return .hearts
        case 40 ... 52:
            return .clubs
        default:
            fatalError("intValue \(intValue) not mapped to any suit")
        }
    }
    
    static func valueForIntValue(_ value: Int) -> CardValue {
        let remainder = value % 13
        switch remainder {
        case 1:
            return .ace
        case 2:
            return .two
        case 3:
            return .three
        case 4:
            return .four
        case 5:
            return .five
        case 6:
            return .six
        case 7:
            return .seven
        case 8:
            return .eight
        case 9:
            return .nine
        case 10:
            return .ten
        case 11:
            return .jack
        case 12:
            return .queen
        case 0:
            return .king
        default:
            fatalError("Invalid value cardForIntValue \(remainder)")
        }
    }
    
    static func getRandomCard(excludingCards: [Card]) -> Card {
        
        var cards = Cards.all
        
        for card in excludingCards {
            cards.remove(object: card)
        }
        
        let randomInt = Int.random(in: 0...cards.count - 1)
        return cards[randomInt]
    }
    
}

class Card: Equatable {
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.suit == rhs.suit && lhs.value == rhs.value
    }
    
    init(_ value: CardValue,_ suit: Suit) {
        self.suit = suit
        self.value = value
    }
    
    convenience init(stringFormat: String) {
        let value = String(stringFormat.prefix(1))
        let suit = stringFormat.suffix(1)
        
        self.init(CardValue(rawValue: value)!,Suit(rawValue: String(suit))!)
    }
    
    convenience init(intValue: Int) {
        
        let suit: Suit = Shuffler.suitForIntValue(intValue)
        
        let value: CardValue = Shuffler.valueForIntValue(intValue)
        
        self.init(value,suit)

    }
    
    let value: CardValue
    let suit: Suit
    
    var stringFormat: String {
        return value.rawValue + suit.rawValue
    }
    
    var image: UIImage? {
        let imageName = value.rawValue + suit.letterRepresentation
        return UIImage(named: imageName)
    }
    
}

enum Suit: String {
    case spades = "♠"
    case diamonds = "♦"
    case hearts = "♥"
    case clubs = "♣"
    
    var letterRepresentation: String {
        switch self {
        case .spades:
            return "S"
        case .diamonds:
            return "D"
        case .hearts:
            return "H"
        case .clubs:
            return "C"
        }
    }
}

enum CardValue: String {
    case ace = "A"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case ten = "T"
    case jack = "J"
    case queen = "Q"
    case king = "K"
    
}


public class Deck {
    var cards:[String:Int]
    var count: Int {
        get {
            return cards.count
        }
    }
    init(){
        cards = [:]
        let suitDetails:[String: Int] = [
            "♠": 0b0001,
            "♥": 0b0010,
            "♦": 0b0100,
            "♣": 0b1000]
        let faces:[String:[String:Int]] = [
            "2":["index":0, "prime": 2],
            "3":["index":1, "prime": 3],
            "4":["index":2, "prime": 5],
            "5":["index":3, "prime": 7],
            "6":["index":4, "prime": 11],
            "7":["index":5, "prime": 13],
            "8":["index":6, "prime": 17],
            "9":["index":7, "prime": 19],
            "T":["index":8, "prime": 23],
            "J":["index":9, "prime": 29],
            "Q":["index":10, "prime": 31],
            "K":["index":11, "prime": 37],
            "A":["index":12, "prime": 41]]
        for face in faces.keys{
            for suit in suitDetails.keys {
                let faceIndex = faces[face]!["index"]!
                let faceValue = faceIndex << 8
                let suitValue = suitDetails[suit]! << 12
                let facePrime = faces[face]!["prime"]!
                let rank = 1 << (faceIndex + 16)
                cards[face+suit] = rank | suitValue | faceValue | facePrime
            }
        }
    }
    
    func as_binary(card:String) -> Int{
        return cards[card]!
    }
}

enum RankName{
    case HighCard
    case OnePair
    case TwoPairs
    case ThreeOfAKind
    case Straight
    case Flush
    case FullHouse
    case FourOfAKind
    case StraightFlush
}

private var rankStarts:[Int:RankName] = [
    7462: RankName.HighCard,
    6185: RankName.OnePair,
    3325: RankName.TwoPairs,
    2467: RankName.ThreeOfAKind,
    1609: RankName.Straight,
    1599: RankName.Flush,
    322: RankName.FullHouse,
    166: RankName.FourOfAKind,
    10: RankName.StraightFlush
]

class HandRank: Equatable {
    var rank:Int
    var name:RankName
    init(rank:Int) {
        self.rank = rank
        let filteredArray = Array(rankStarts.keys.filter {$0 >= rank})
        let start = filteredArray.sorted { $0 < $1 }.first!
        self.name = rankStarts[start]!
    }
}

func == (lhs: HandRank, rhs: HandRank) -> Bool {
    return lhs.rank == rhs.rank
}

class Evaluator {
    var deck = Deck()
    
    func evaluate(cards:[Card]) -> HandRank {
        
        let cardsStrings = cards.map {$0.stringFormat}
        let cardValues = cardsStrings.map { self.deck.as_binary(card: $0) }

        let handIndex = cardValues.reduce(0,|) >> 16

        let isFlush:Bool = (cardValues.reduce(0xF000,&)) != 0
        let red = cardValues.reduce(0xF000,&)
        
        print(red)
        if isFlush {
            let flushRank = flushes[handIndex]
            return HandRank(rank:flushRank)
        }

        let unique5Candidate = uniqueToRanks[handIndex]

        if (unique5Candidate != 0){
            return HandRank(rank:unique5Candidate)
        }

        let primeProduct = cardValues.map { $0 & 0xFF }.reduce(1, *)
        
        let combination = primeProductToCombination.firstIndex(of: primeProduct)!
        return HandRank(rank:combinationToRank[combination])
    }
    
    func evaluate7CardHand(cards: [Card]) -> HandRank {

        let eval = Evaluator()
        
        let cs = Combinatorics.combinationsWithoutRepetitionFrom(cards, taking: 5)
        var lowest: Int?
        for c in cs {
            let n = eval.evaluate(cards: c).rank
            
            if lowest == nil {
                lowest = n
            }
            
            if n < lowest! {
                lowest = n
            }
            
            print(c)
        }

        print(lowest!)
        return HandRank(rank: lowest!)
    }
}
