//
//  Blackjack.swift
//  HW1
//
//  Created by Richard Samuels on 15/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

//Array shuffling extension courtesy of:
// https://gist.github.com/natecook1000/0ac03efe07f647b46dae
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}
//End code from Nate Cook

class Blackjack {
    enum State {
        case Pre
        case Insurance
        case Player
        case Dealer
        case Post
        case Surrender
    }
    
    enum Result {
        case Win
        case Lose
        case Tie
        case Mad
    }
    
    var cash = 100
    var bet = 0
    var insurance = 0
    var round = 0
    private var showHole = false
    var doubled = false
    
    let dealer = Hands()
    let player = Hands()
    let deck = Deck()
    
    var state = State.Pre
    var endgame: [Result?] = [nil, nil, nil, nil]
    
    func start(bet: Int) -> State {
        state = statePre(bet)
        
        return state
    }
    
    //Return true if the a double can be made
    func canDouble() -> Bool {
        if state != State.Player {
            return false
        }
        
        if cash < 2 * bet {
            return false
        }
        
        return !player.allHandsOut()
    }
    
    func canSurrender() -> Bool {
        if state != State.Player {
            return false
        }
        
        if player.cards[0].count != 2 {
            return false
        }
        
        if player.activeHand[1] || player.activeHand[2] || player.activeHand[3] {
            return false
        }
        
        return player.activeHand[0]
    }
    func canSplit() -> Bool {
        if state != State.Player {
            return false
        }
        
        for index in 0..<player.cards.count {
            let hand = player.cards[index]
            
            if hand.count == 2 {
                //If the cards are the same
                if (hand[0] == hand[1]) ||
                    //Or if the cards are both face cards, we can split
                    ( (hand[0] == "J" || hand[0] == "K" || hand[0] == "Q")
                    && (hand[1] == "J" || hand[1] == "K" || hand[1] == "Q") ){
                    
                    //If the hand is inactive, we can split!
                    return !player.activeHand[index]
                }
            }
        }
        
        return false
    }
    
    func hit(hand: Int) {
        if state == State.Player && player.activeHand[hand] {
            state = statePlayerHit(hand)
        
            if state == State.Dealer {
                stateDealer()
            }
        }
    }
    
    func stand(hand: Int) {
        if state == State.Player && player.activeHand[hand] {
            state = statePlayerStand(hand)
            
            if state == State.Dealer {
                stateDealer()
            }
        }
        
    }
    
    func double(hand: Int) {
        if state == State.Player && player.activeHand[hand] {
            state = statePlayerDouble(hand)
            
            if state == State.Dealer {
                stateDealer()
            }
        }
    }
    
    func surrender() {
        if state == State.Player && canSurrender() {
            cash += bet/2
            
            state = statePost()
        }
    }
    
    func insurance(insurance: Int) {
        state = stateInsurance(insurance)
    }
    
    func post() {
        state = State.Pre
        statePost()
    }
    
    //Setup the Decks.
    private func statePre(bet: Int) -> State {
        cash -= bet
        self.bet = bet
        
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
            return State.Dealer
            
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
        player.activeHand[hand] = false
        
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
        let newDeck = hand + 1
        
        player.activeHand[newDeck] = true
        player.cards[newDeck].append(player.cards[hand][1])
        player.cards[hand].removeAtIndex(1)
        player.addCard(newDeck, c: deck.draw())
        
        if(player.allHandsOut()) {
            return State.Dealer
        }else {
            return State.Player
        }
    }
    
    private func stateDealer() -> State {
        while dealer.score(0) <= 16 {
            dealer.addCard(0, c: deck.draw())
        }
        
        for x in 0..<player.cards.count {
            endgame[x] = stateDealerCheckHand(x)
        }
        
        
        state = State.Post
        return state
    }
    
    //Do the dealer's work, and evaluate if the hand won
    private func stateDealerCheckHand(h: Int) -> Result? {
        if player.cards[h].count == 0 {
            return nil
        }
        let playerScore = player.score(h)
        let dealerScore = dealer.score(0)
        
        if playerScore == 21 && dealerScore == 21 {
            //Possible tie, who has blackjack?
            if player.hasBlackjack() && dealer.hasBlackjack()  {
                cash += bet
                return Result.Tie
            }else if player.hasBlackjack() {
                //Player winsT
                cash += (bet / 2) * 3
                return Result.Win
            }else {
                //Dealer wins, but maybe insurance?
                cash += 2 * insurance
                return Result.Lose
            }
        }else if playerScore > 21 || dealerScore > 21 {
            if dealerScore > 21 && playerScore > 21 {
                //Everyone loses
                return Result.Mad
            }else if playerScore > 21 {
                //Dealer wins
                return Result.Lose
            }else {
                //Player wins
                return Result.Win
            }
        }else  {
            if playerScore > dealerScore || playerScore == dealerScore {
                //Player wins or ties
                cash += bet
                return playerScore == dealerScore ? Result.Tie : Result.Win
            }else {
                //Dealer wins
                return Result.Lose
            }
        }
    }
    
    private func statePost() -> State {
        doubled = false
        bet = 0
        insurance = 0
        showHole = false
        endgame = [nil, nil, nil, nil]
        round += 1
        
        if(round % 5 == 0) {
            deck.reset()
        }else {
            deck.pushback(player.reset())
            deck.pushback(dealer.reset())
        }
        
        state = State.Pre
        return State.Pre
    }
    
    
    init() {}
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
    
    func reset() -> [Character] {
        let temp = cards.reduce([]) {
            (combine: [Character], next: [Character]) -> [Character] in
            combine + next
        }
        cards = [ [], [], [], [] ]
        activeHand = [true, false, false, false]
        return temp
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
            if (candidate + score) > 21 {
                candidate -= 10
            }else {
                break
            }
        }
        
        return score + candidate
    }
    
    func handsCanSplit() -> [Bool] {
        return cards.map() {
            (hand: [Character]) -> Bool in
            
            if hand.count == 2 {
                if (hand[0] == hand[1]) ||
                    //Or if the cards are both face cards, we can split
                    ( (hand[0] == "J" || hand[0] == "K" || hand[0] == "Q")
                        && (hand[0] == "J" || hand[0] == "K" || hand[0] == "Q") ){
                        return true
                }
            }
            return false
        }
        
    }
    
    func hasBlackjack() -> Bool {
        if activeHand[1] || activeHand[2] || activeHand[3] {
            return false
        }
        
        if cards[0].count != 2 || score(0) != 21 {
            return false
        }
        
       return true
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
    
    func pushback(c: [Character]) {
        deck += c
    }
    
    init() {
        reset();
    }
}
