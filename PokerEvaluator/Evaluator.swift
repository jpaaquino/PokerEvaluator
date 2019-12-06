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
    
    var numberValue: Int {
        switch value {
        case .ace:
            return 1
        case .two, .three, .four,.five,.six,.seven,.eight,.nine:
            return Int(value.rawValue)!
        case .ten:
             return 10
        case .jack:
            return 11
        case .queen:
            return 12
        case .king:
            return 13
        }
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

enum RankName: Int{
    case HighCard = 0
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
        
        //let cardsStrings = cards.map {$0.stringFormat}
        let cardValues = cards.map { self.deck.as_binary(card: $0.stringFormat) }

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

        let combos = Combinatorics.combinationsWithoutRepetitionFrom(cards, taking: 5)

        var lowest: Int?
        for combo in combos {
            
            let n = eval.evaluate(cards: combo).rank
            //let n = eval.eval(cards: combo).rawValue

            
            if lowest == nil {
                lowest = n
            }
            
            if n < lowest! {
                lowest = n
            }
            
        }

        return HandRank(rank: lowest!)
    }
    
    func getHandRank(cards: [Card]) -> RankName {

         let eval = Evaluator()

         let combos = Combinatorics.combinationsWithoutRepetitionFrom(cards, taking: 5)

        var highest: RankName = .HighCard
         for combo in combos {
             
            let rankName = eval.eval(cards: combo)
             
            if rankName.rawValue > highest.rawValue {
                 highest = rankName
             }
         }

         return highest
     }
    
}

extension Evaluator {
    func isFlush(cards: [Card]) -> Bool {
        return cards.filter{$0.suit == cards[0].suit}.count >= 5
    }
    
    func retrieveSetOfCards(cards: [Card]) -> Set<Int> {
        var set = Set<Int>()
        for card in cards {
            set.insert(card.numberValue)
        }
        return set
    }
    
    private func isItAStraight(set: Set<Int>) -> Bool {
        if(set.count != 5){return false}
        
        if(set.max()! - set.min()! == 4){
            return true
        } else if(set.contains(14)){
            if(set == [14,5,4,3,2]){return true}
        }
        return false
    }
    
    
    func eval(cards: [Card]) -> RankName {
        let set = retrieveSetOfCards(cards: cards)
        
        var arrayOfValues:[Int] = []
        
        for card in cards{
            arrayOfValues.append(card.numberValue)
        }
        
        var counts = [Int: Int]()
        arrayOfValues.forEach { counts[$0] = (counts[$0] ?? 0) + 1 }
        let (_, mostRepeatedCount) = counts.max(by: {$0.1 < $1.1})!
        
        let flush = isFlush(cards: cards)
        
        switch set.count {
        case 5:
            let isStraight = self.isItAStraight(set: set)
            if(flush && isStraight){return .StraightFlush}
            else if(flush && !isStraight){return .Flush}
            else if(!flush && isStraight){return .Straight}
            else if(!flush && !isStraight){return .HighCard}
        case 4:
            return .OnePair
        case 3:
            if(mostRepeatedCount == 3){return .ThreeOfAKind}
            else if(mostRepeatedCount == 2){return .TwoPairs}
        case 2:
            if(mostRepeatedCount == 3){return .FullHouse}
            else if(mostRepeatedCount == 4){return .FourOfAKind}
        default:
            print("Error hand not recognized")

            return .HighCard
        }
        return .HighCard

    }
    
    func eval7Cards(cards: [Card]) -> RankName {
        let flush = isFlush(cards: cards)
        let straight = isStraight7Card(cards: cards)
        let mostRepeated = twoMostRepeated(cards: cards)
        
        if straight && flush {
            if isStraightFlush7Card(cards: cards) {
                return .StraightFlush
            }
        }
        
        switch mostRepeated {
        case (4, 1...3):
            return .FourOfAKind
        case (3, 2...3):
            return .FullHouse
        case (3, 1):
            if flush {return .Flush}
            if straight {return .Straight}
            return .ThreeOfAKind
        case (2, 2):
            if flush {return .Flush}
            if straight {return .Straight}
            return .TwoPairs
        case (2, 1):
            if flush {return .Flush}
            if straight {return .Straight}
            return .OnePair
        case (1, 1):
            if flush {return .Flush}
            if straight {return .Straight}
            return .HighCard
        default:
            if flush {return .Flush}
            if straight {return .Straight}
            print("Default")
            return .HighCard

        }
        
        
    }
    
    func isStraight7Card(cards: [Card]) -> Bool {
        var previous:Int?
        let newCards = cards.sorted(by: { $0.numberValue < $1.numberValue })
        var count = 0
        for card in newCards {
            if (card.numberValue == 13 && newCards.first!.numberValue == 1) {
            count += 2
            if count >= 5 { return true }
            }
            else if previous == nil || previous == card.numberValue - 1 {
            count += 1
            previous = card.numberValue
                if count >= 5 { return true }
            } else {
                count = 1
                previous = card.numberValue
            }
            
        }
        return false
    }
    
    func isStraightFlush7Card(cards: [Card]) -> Bool {
        var previous:Card?
        let newCards = cards.sorted(by: { $0.numberValue < $1.numberValue })
        var count = 0
        for card in newCards {
            if (card.numberValue == 13 && newCards.first!.numberValue == 1 && card.suit == newCards.first!.suit) {
                       count += 2
                       if count >= 5 { return true }
            }
            else if previous == nil || (previous!.numberValue == card.numberValue - 1 && previous!.suit == card.suit) {
             count += 1
            previous = card
                if count >= 5 {return true}
            } else {
                count = 1
                previous = card
            }
            
        }
        return false
    }
    
    func twoMostRepeated(cards: [Card]) -> (Int, Int) {
        var dict: [Int: Int] = [:]
        for card in cards {
            if let current = dict[card.numberValue] {
                dict[card.numberValue] = current + 1
            } else {
              dict[card.numberValue] =  1
            }
        }
        
        var arr = [Int](dict.values)
        arr = arr.sorted(by: { $0 > $1 })
        return (arr[0], arr[1])
        
    }
}
