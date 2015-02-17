//
//  Blackjack.swift
//  HW1
//
//  Created by Richard Samuels on 15/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

//Array shuffling extension courtesy of:
// http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}

class Blackjack {
    var score = 100
    var bet = 0;
    var round = 0
    var isDealer = false
    var doubled = false
    
    let dealer = Hand()
    let player = Hand()
    let deck = Deck()
    
    func hit() {
        let h = isDealer ? dealer : player
        
        h.addCard(deck.draw())
    }
    
    func double() {
        doubled = true
        score -= bet
        bet *= 2
        hit()
    }
    
    func start(bet: Int) {
        self.bet = bet
        self.score -= bet
        
        player.addCard(deck.draw())
        player.addCard(deck.draw())
        dealer.addCard(deck.draw())
        dealer.addCard(deck.draw())
    }
    
    func endRound() {
        round += 1
        isDealer = false
        doubled = false
        dealer.cards.removeAll()
        player.cards.removeAll()
        deck.reset()
    }
    
    //Called when the player wishes to surrender. ends the round, and updates their score
    func surrender() {
        score += bet/2
        
        endRound()
    }
    
}

class Deck {
    var deck: [Character] = []
    
    func draw() -> Character {
        if deck.count == 0 {
            reset()
        }
        
        return self.deck.removeAtIndex(0)
    }
    
    func reset() {
        deck.removeAll(keepCapacity: true)
        
        //Now do the same with the face cards
        let set: [Character] = ["A", "J", "Q", "K", "2", "3", "4", "5", "6", "7", "8", "9"]
        for c in set {
            for _ in 1...4 {
                deck.append(c)
            }
        }
        
        //Now shuffle the array
        //No built-in for this, so we're using the Fisher-Yates shuffle for this
//        deck.shuffle()
    }
    
    init() {
        reset();
    }
}

class Hand {
    private var cards:[Character] = []
    
    func addCard(c: Character) {
        switch c {
        case "A", "J", "Q", "K", "2", "3", "4", "5", "6", "7", "8", "9":
            cards.append(c);
            
        default:
            break
        }
    }
    
    //Return a string representation of the hand
    func string(dealer: Bool = false) -> String {
        if dealer {
            if let c = cards.last {
                return [c] + " and \(cards.count - 1) other cards"
            }else {
                //This should never happen
                return "Empty hand???"
            }
            
        }else {
            return cards.reduce("") {
                (retString: String, c: Character) -> String in
                retString + " " + [c]
            }
            
        }
    }
    
    //Calculates the score of the hand and returns the highest possible, most advantageous score
    func score() -> Int {
        var numberAces = 0
        let score =  cards.filter() {
            (c: Character) -> Bool in
            if c == "A" {
                numberAces += 1
                return false
            }else {
                return true
            }
            }.map(){
            //Map the card character to a point value
            (c:Character) -> Int in
            switch c {
   
            case "J", "Q", "K":
                return 10
                
            case "2", "3", "4", "5", "6", "7", "8", "9":
                //Explicitly specifying the numbers instead of using _
                //This way it's safe to forcibly unwrap the optional
                return String(c).toInt()!
            default:
                //Something wacky, just play nice
                return 0
            }
            }.reduce(0) { $0 + $1 }
        
        //Now deal with the aces
        var candidate = numberAces * 11
        while candidate != numberAces {
            if candidate + score > 21 {
                candidate -= 10
            }else {
                break
            }
        }
        
        return score + candidate
        
    }
    
    init() {
        
    }
}
