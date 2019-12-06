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
        outerloop: for _ in 1 ... numberOfSims {
            
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
            
            //MARK: Evaluate for hand rank only
            var bestHandRank: RankName?

            for (index, newHand) in hands.enumerated() {
                //let newRank = Evaluator().getHandRank(cards: newHand + newBoard)
                let newRank = Evaluator().eval7Cards(cards: newHand + newBoard)

                if(bestHandRank == nil) {
                    bestHandRank = newRank
                    bestIndex = [index]
                }
                 else if newRank.rawValue > bestHandRank!.rawValue {
                     bestHandRank = newRank
                     bestIndex = [index]
                 } else if newRank.rawValue == bestHandRank!.rawValue {
                    bestIndex.append(index)
                }

            }
            if bestIndex.count == 1 {
                arrayOfWins[bestIndex.first!] += 1
                continue outerloop
            }
            
            //MARK: Get Detailed hand value if hand rank is the same

            // for each players hands
            for (index, newHand) in hands.enumerated() {
                
                //Evaluates the 21 combos for current player and returns best value
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
    
//      //Monte Carlo simulation, returns array of wins by position
//      static func simulateHoldem2(numberOfSims: Int, board: [Card], hands: [[Card]]) -> [Double] {
//
//          //Count number of wins for each player
//          var arrayOfWins:[Double] = Array(repeating: 0, count: hands.count)
//          //Start time to compute elapsed time
//          let start = Date()
//          //Exclude cards from players' hand and from board
//          let excluding = (hands.flatMap {$0}) + board
//
//          //For every simulation
//          for _ in 1 ... numberOfSims {
//
//              //best seat position in current simulation
//              var bestIndex:[Int] = [0]
//              //Best hand value for current simulation
//              var bestValue: Int?
//
//              //Excluded cards = existing cards in players hands
//              var newExcluding = excluding
//              var newBoard = board
//
//              //Simulate remaining cards in board
//              while newBoard.count < 5 {
//                  let newCard = Shuffler.getRandomCard(excludingCards: newExcluding)
//                  newBoard.append(newCard)
//                  newExcluding.append(newCard)
//              }
//
//            var bestHandRank: RankName = .HighCard
//              // for each players hands
//              for (index, newHand) in hands.enumerated() {
//
//                  //Evaluates the 21 combos for current player and returns best hand rank
//                let newRank = Evaluator().getHandRank(cards: newHand + newBoard)
//
//                if newRank.rawValue > bestHandRank.rawValue {
//                    bestHandRank = newRank
//                    bestIndex = [index]
//                }
//
//
////                  print("Thread \(Thread.current)")
////
////                  if(bestValue == nil) {
////                      bestValue = newHandValue.rank
////                      bestIndex = [index]
////                  } else {
////                      if(newHandValue.rank < bestValue!) {
////                          bestValue = newHandValue.rank
////                          bestIndex = [index]
////                      } else if(newHandValue.rank == bestValue!) {
////                          bestIndex.append(index)
////                      }
////                  }
//
//              }
//              let winningHands: Double = Double(bestIndex.count)
//              let winFraction: Double = 1/winningHands
//
//              for index in bestIndex {
//                  arrayOfWins[index] += winFraction
//              }
//
//          }
//
//          let elapsedTime = Date().timeIntervalSince(start)
//          print("elapsedTime: \(elapsedTime)")
//
//          return arrayOfWins
//      }
//
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
        
        outerloop: for combo in combos {
            
            //best seat position in current simulation
            var bestIndex:[Int] = [0]
            //Best hand value for current simulation
            var bestValue: Int?

            //MARK: Evaluate for hand rank only

            var bestHandRank: RankName?

            for (index, newHand) in hands.enumerated() {
                var allCards = newHand + board + combo

                let newRank = Evaluator().eval7Cards(cards: newHand + board + combo)
                for allC in allCards {
                    print(allC.stringFormat)
                }
                print(newRank)
                
                if(bestHandRank == nil) {
                    bestHandRank = newRank
                    bestIndex = [index]
                }
                 else if newRank.rawValue > bestHandRank!.rawValue {
                     bestHandRank = newRank
                     bestIndex = [index]
                 } else if newRank.rawValue == bestHandRank!.rawValue {
                    bestIndex.append(index)
                }

            }
            if bestIndex.count == 1 {
                arrayOfWins[bestIndex.first!] += 1
                continue outerloop
            }
            
            //MARK: Get Detailed hand value if hand rank is the same
            bestIndex = [0]

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
    
    static func calculatePreflop(cards: [Card]) {
        let combos = Combinatorics.permutationsWithoutRepetitionFrom(cards, taking: 4)
        var newArray = [[Card]]()
        for combo in combos.prefix(10) {
        var array1 = [Card](combo.prefix(2))
        array1 = array1.sorted(by: { $0.numberValue > $1.numberValue })
        var array2 = [Card](combo.suffix(2))
        array2 = array2.sorted(by: { $0.numberValue > $1.numberValue })
            var finalArray = array1 + array2

            if array2.first!.numberValue > array1.first!.numberValue || (array2.first!.numberValue == array1.first!.numberValue && array2.last!.numberValue > array1.last!.numberValue) {
             finalArray = array2 + array1
            }
            newArray.append(finalArray)
            let result = Simulator.simulateHoldem(numberOfSims: 100, board: [], hands: [[Card](finalArray.prefix(2)), [Card](finalArray.suffix(2))])
            var dict = [String: Double]()
            dict[(finalArray.first!.stringFormat + finalArray[1].stringFormat + finalArray[2].stringFormat + finalArray[3].stringFormat)] = result[0]

            print(dict)
        }
        
        let set = Set(newArray)
        
        print("combos count \(set.count)")
    }
    
}

extension Card: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.stringFormat)
       }
}

