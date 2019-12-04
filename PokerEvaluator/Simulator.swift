//
//  Simulator.swift
//  PokerEvaluator
//
//  Created by Joao Paulo Aquino on 03/12/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.
//

import Foundation
import Combinatorics

class Simulator {
    
    //Monte Carlo simulation, returns array of wins by position
    static func simulateHoldem(numberOfSims: Int, board: [Card], hands: [[Card]]) -> [Double] {
        
        //Count number of wins for each player
        var arrayOfWins:[Double] = Array(repeating: 0, count: hands.count)
        //Start time to compute elapsed time
        let start = Date()
        //Exclude cards from players' hand and from board
        let excluding = (hands.flatMap {$0}) + board
        
        //For every simulation
        for _ in 1 ... numberOfSims {
            
            //best seat position in current simulation
            var bestIndex:[Int] = [0]
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
                    bestIndex = [index]
                } else {
                    if(newHandValue.rank < bestValue!) {
                        bestValue = newHandValue.rank
                        bestIndex = [index]
                    } else if(newHandValue.rank == bestValue!) {
                        bestIndex.append(index)
                    }
                }
                
            }
            let winningHands: Double = Double(bestIndex.count)
            let winFraction: Double = 1/winningHands
            
            for index in bestIndex {
                arrayOfWins[index] += winFraction
            }
            
        }
        
        let elapsedTime = Date().timeIntervalSince(start)
        print("elapsedTime: \(elapsedTime)")
        
        return arrayOfWins
    }
    
    //Exhaustive calculation
    static func calculateHoldem(board: [Card], hands: [[Card]]) -> [Double] {
        //Count number of wins for each player
        var arrayOfWins:[Double] = Array(repeating: 0, count: hands.count)
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
            var bestIndex:[Int] = [0]
            //Best hand value for current simulation
            var bestValue: Int?
            
            for (index, newHand) in hands.enumerated() {
                
                //Hand value for player
                let newHandValue = Evaluator().evaluate7CardHand(cards: newHand + board + combo)
                
                if(bestValue == nil) {
                    bestValue = newHandValue.rank
                    bestIndex = [index]
                } else {
                    if(newHandValue.rank < bestValue!) {
                        bestValue = newHandValue.rank
                        bestIndex = [index]
                    } else if(newHandValue.rank == bestValue!) {
                        bestIndex.append(index)
                    }
                }
                
            }
            let winningHands: Double = Double(bestIndex.count)
            let winFraction: Double = 1/winningHands
            
            for index in bestIndex {
                arrayOfWins[index] += winFraction
            }
        }
        let elapsedTime = Date().timeIntervalSince(start)
        print("elapsedTime: \(elapsedTime)")
        return arrayOfWins
        
    }
    
    static func simulate5CardDraw(numberOfSims: Int, hands: [[Card]]) -> [Double] {
        var arrayOfWins:[Double] = Array(repeating: 0, count: hands.count)
        let start = Date()
        let excluding = hands.flatMap {$0}
        
        //For every simulation
        for _ in 1 ... numberOfSims {
            
            //best value in simulation
            var bestIndex = [0]
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
                        bestIndex = [index]
                    } else {
                        if(newHandValue.rank < bestValue!) {
                            bestValue = newHandValue.rank
                            bestIndex = [index]
                        } else if(newHandValue.rank == bestValue!) {
                            bestIndex.append(index)
                        }
                    }
                    
                }
                let winningHands: Double = Double(bestIndex.count)
                let winFraction: Double = 1/winningHands
                
                for index in bestIndex {
                    arrayOfWins[index] += winFraction
                }
            
        }
        
        let elapsedTime = Date().timeIntervalSince(start)
        print("elapsedTime \(elapsedTime)")
        
        for (index, value) in arrayOfWins.enumerated() {
            print("Seat \(index) wins \(value) times")
        }
        return arrayOfWins
    }
}


