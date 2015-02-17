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
    enum State {
        case Pre
        case Insurance
        case Player
        case Dealer
        case Post
        case Surrender
    }
    
    enum Action {
        case Bet
        case Insurance
    }
    
    var cash = 100
    var bet = 0
    var insurance = 0
    private var showHole = false
    var doubled = false
    
    let dealer = Hands()
    let player = Hands()
    let deck = Deck()
    
    var state = State.Pre
    
    func start(bet: Int) {
        state = statePre(bet)
        
//        return state
    }
    
    //Setup the Decks.
    private func statePre(bet: Int) -> State {
        //Draw cards for each player
        player.addCard(0, c: deck.draw())
        player.addCard(0, c: deck.draw())
        dealer.addCard(0, c: deck.draw())
        dealer.addCard(0, c: deck.draw())
        
        //If the dealer has a score of 21, and has an Ace revealed, we can get insurance
        if dealer.score(0) == 21 && dealer.peek(0) == "A" {
            return State.Insurance
        }else {
            //Otherwise, they don't get it
            return stateInsurance(0)
        }
    }
    
    //Set insurance, and move onto the next state depending on scores
    private func stateInsurance(insurance: Int) -> State {
        showHole = true
        self.insurance = insurance
        
        //Check if someone has blackjack; if so, then we're all done
        if player.score(0) == 21 || dealer.score(0) == 21 {
            return State.Post
        }else {
            return State.Player
        }
    }
    
    private func statePlayerHit(hand: Int) -> State {
        player.addCard(hand, c: deck.draw())
        
        if(player.allHandsOut()) {
            return State.Dealer
        }else {
            return State.Player
        }
    }
    
    private func statePlayerDouble(hand: Int) -> State{
        doubled = true
        cash -= bet
        bet *= 2
        
        player.addCard(hand, c: deck.draw())
        
        if(player.allHandsOut()) {
            return State.Dealer
        }else {
            return State.Player
        }
    }
    
    private func statePlayerStand(hand: Int) -> State {
        player.activeHand[hand] = false
        
        if(player.allHandsOut()) {
            return State.Dealer
        }else {
            return State.Player
        }
    }
    
    private func statePlayerSplit(hand: Int) -> State {
        return State.Player
    }
    
    private func statePlayerSurrender() -> State {
        cash += bet/2
        return State.Post
    }
    
    private func statePost() -> State {
        doubled = false
        bet = 0
        insurance = 0
        showHole = false
        
        player.reset()
        dealer.reset()
        deck.reset()
        
        return State.Pre
    }
    
    
    
}



class Hands {
    private var cards:[[Character]] = [ [], [], [], [] ]
    
    //if true, that hand is active (i.e. we can do stuff to it)
    var activeHand: [Bool] = [true, false, false, false]
    
    //Return true if all hands have busted, or are otherwise disabled (i.e. Double, stand, etc.)
    func allHandsOut() ->Bool {
        if !activeHand[0] && !activeHand[1] && !activeHand[2] && !activeHand[3] {
            return true
        }else {
            return false
        }
    }
    
    //Add a given card c to a deck hand
    func addCard(hand: Int, c: Character) {
        switch c {
        case "A", "J", "Q", "K", "2", "3", "4", "5", "6", "7", "8", "9":
            cards[hand].append(c);
            
        default:
            break
        }
        
        if(score(hand) > 21) {
            activeHand[hand] = false
        }
    }
    
    //Return a string representation of the hand
    func string(hand: Int, dealer: Bool = false) -> String {
        if dealer {
            if let c = cards[hand].last {
                return [c] + " and \(cards[hand].count - 1) other card"
            }else {
                //This should never happen
                return "Empty hand???"
            }
            
        }else {
            return cards[hand].reduce("") {
                (retString: String, c: Character) -> String in
                retString + " " + [c]
            }
            
        }
    }
    
    //Peek at the top of a hand
    func peek(hand: Int) -> Character {
        return cards[hand][0]
    }
    
    func reset() {
        cards = [ [], [], [], [] ]
        activeHand = [true, false, false, false]
    }
    
    //Calculates the score of the hand and returns the highest possible, most advantageous score
    func score(hand: Int) -> Int {
        var numberAces = 0
        let score =  cards[hand].filter() {
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


class Deck {
    private var deck: [Character] = []
    
    //Draw from the top of the deck, returning the character
    func draw() -> Character {
        if deck.count == 0 {
            reset()
        }
        
        return self.deck.removeAtIndex(0)
    }
    
    //Generate a new, randomly shuffled deck
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
        //No built-in for this, so we're using an extension to Array from Nate Cook
        deck.shuffle()
    }
    
    init() {
        reset();
    }
}
