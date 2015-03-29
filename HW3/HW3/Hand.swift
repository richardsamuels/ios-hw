//
//  Hand.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import Foundation

class Hand {
    private var cards:[Character] = []
    var numCards: Int {
        get {
            return cards.count
        }
    }
    
    var cardScore: Int {
        get {
            return score()
        }
    }
    
    //Add a given card c to a deck hand
    func addCard(c: Character) {
        switch c {
        case "A", "J", "Q", "K", "2", "3", "4", "5", "6", "7", "8", "9":
            cards.append(c);
            
        default:
            break
        }
    }
    
    //Return a string representation of the hand
    //When hideHole is true, only one card will be shown
    //This is used during the insurance bet phase
    func string(hideHole: Bool = false) -> String? {
        if hideHole {
            if let c = cards.last {
                return "\(c) and \(cards.count - 1) other card"
            }else {
                //This should never happen
                return nil
            }
            
        }else {
            return cards.reduce("") {
                (retString: String, c: Character) -> String in
                retString + " " + [c]
            }
            
        }
    }
    
    //Peek at the top of a hand
    func peek() -> Character {
        return cards[0]
    }
    
    //Clean up the hand and return the card set
    func reset() -> [Character] {
        let temp = cards;
        cards = []
        return temp
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
            if (candidate + score) > 21 {
                candidate -= 10
            }else {
                break
            }
        }
        
        return score + candidate
    }
    
    //true if the hand satisfies the rule for blackjack
    func hasBlackjack() -> Bool {
        if cards.count != 2 || score() != 21 {
            return false
        }
        
        return true
    }
    
    init() {}
}
