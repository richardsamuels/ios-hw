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

//class Blackjack: UITextViewDelegate {
class Blackjack {
    //    UITextView text;
    
    var score = 100
    var bet = 0;
    var round = 0
    var isDealer = false
    
    let dealer = Hand()
    let player = Hand()
    let deck = Deck()
    
    func hit() {
        let h = isDealer ? dealer : player
        
        h.addCard(deck.draw())
    }
    
    func double() {
        let h = isDealer ? dealer : player
    }
    
    func start(bet: Int) {
        self.bet = bet
        
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
        
        //Fill the deck with the numerical cards
        for i in 2...10 {
            for _ in 1...4 {
                deck.append(Character(UnicodeScalar(i)))
            }
        }
        
        //Now do the same with the face cards
        let set: [Character] = ["A", "J", "Q", "K"]
        for c in set {
            for _ in 1...4 {
                deck.append(c)
            }
        }
        
        //Now shuffle the array
        //No built-in for this, so we're using the Fisher-Yates shuffle for this
        deck.shuffle()
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
    
    //Calculates the score of the hand and returns a tuple, with the score
    //where aces are treated as 1's and 11's respectively
    func score() -> (score1: Int, score11: Int) {
        return cards.map(){
            //Map the card character to a point value
            (c:Character) -> (Int, Int) in
            switch c {
            case "A":
                return (1,11)
                
            case "J", "Q", "K":
                return (10,10)
                
            case "2", "3", "4", "5", "6", "7", "8", "9":
                //Explicitly specifying the numbers instead of using _
                //This way it's safe to forcibly unwrap the optional
                let c_i: Int = String(c).toInt()!
                return (c_i, c_i)
            default:
                //Something wacky, just play nice
                return (0,0)
            }
            }.reduce((0,0)) {
                //Now combine the score tuples, and return it
                (total: (Int, Int), ele: (Int, Int)) -> (Int, Int) in
                (total.0 + ele.0, total.1 + ele.1)
        }
        
    }
    
    init() {
        
    }
}
