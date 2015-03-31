//
//  Blackjack.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import Foundation

class Blackjack {
    enum State {
        case Setup
        case Betting
        case Insurance
        case Player
        case NextPlayer
        case AI
        case Dealer
        case Scoring
        case Post
    }
    
    var players: [BlackjackPlayer] = []
    var aiPlayers: [BlackjackPlayer] = []
    var playerDealer = BlackjackPlayer()
    var shoe: Shoe
    var state: State = State.Setup
    var currentPlayer = 0
    var round = 0
    var gameResults: [BlackjackPlayer.State]?
    
    func gameAdvanceState(bets: [Int]? = nil) -> State {
        switch state {
        case State.Post:
            state = post()
        case State.Setup:
            state = State.Betting
        case State.Betting:
            if let bets_unwrapped = bets? {
                state = betting(bets_unwrapped)
            }
        case State.Insurance:
            if let bets_unwrapped = bets? {
                state = insurance(bets_unwrapped);
            }
            
        case State.Player:
            break
        case State.NextPlayer:
            state = playerNext()
        case State.AI:
            state = playerNext()
            //state = ai()
        case State.Dealer:
            state = dealer()
        case State.Scoring:
            state = score()
        }
        
        return state
    }
    
    private func betting(bets: [Int]) -> State {
        if bets.count != players.count {
            return State.Betting
        }
        
        for (index, p) in enumerate(players) {
            //set the bet
            p.bet = bets[index]
            p.cash -= p.bet
            
            //And deal
            p.hand.addCard(shoe.draw())
            p.hand.addCard(shoe.draw())
        }
        
        for (index, p) in enumerate(aiPlayers) {
            //set the bet
            p.bet = 5
            p.cash -= p.bet
            
            //And deal
            p.hand.addCard(shoe.draw())
            p.hand.addCard(shoe.draw())
        }
        
        // Deal to the dealer as well
        playerDealer.hand.addCard(shoe.draw())
        playerDealer.hand.addCard(shoe.draw())
        
        if playerDealer.hand.peek().val == "A" {
            return State.Insurance
        }else {
            return State.Player
        }
    }
    
    private func insurance(bets: [Int]) -> State {
        if bets.count != players.count {
            return State.Insurance
        }
        
        for (index, p) in enumerate(players) {
            p.insurance = bets[index]
            p.cash -= p.insurance
        }
        
        for (index, p) in enumerate(aiPlayers) {
            p.insurance = 0
        }
        
        if playerDealer.hand.hasBlackjack() {
            return State.Scoring
        }
        
        return State.Player
    }
    
    private func playerNext() -> State {
        currentPlayer += 1;
        
        if currentPlayer >= players.count + aiPlayers.count {
            state = State.Dealer
            return state
        }else if currentPlayer >= players.count {
            state = State.AI
            return state
        }else {
            
            state = State.Player
            return State.Player
        }
    }
    
    func playerHit(player: Int, ai: Bool = false) -> State {
        var p: [BlackjackPlayer]
        if ai {
            p = aiPlayers
            aiPlayers[player].hand.addCard(shoe.draw());
        }else {
            p = self.players
            p[player].hand.addCard(shoe.draw());
        }
        
        
        if p[player].hand.score() > 21 {
            state = State.NextPlayer
            return state
        }else {
            return state
        }
    }
    
    func playerStand(player: Int, ai: Bool = false) -> State {
        state = State.NextPlayer
        return state
    }
    
    func playerSurrender(player: Int, ai: Bool = false) -> State {
        var players: [BlackjackPlayer]
        if ai {
            players = aiPlayers
        }else {
            players = self.players
        }
        
        players[player].cash += players[player].bet/2
        
        state = State.NextPlayer
        return state
    }
    
    func playerCanSurrender(player: Int) -> Bool {
        return players[player].hand.numCards == 2
    }
    
    func ai() -> State {
        var currentPlayer = self.currentPlayer - players.count
        
        let h = aiPlayers[currentPlayer].hand
        let playerScore = aiPlayers[currentPlayer].hand.score()
        let dealerPeek = players[0].hand.cards[0].val
        
        if h.cards.count == 2 && h.cards[0].val == h.cards[1].val {
            //Pairs
            while state != State.NextPlayer {
                switch dealerPeek {
                case "2", "3", "4", "5", "6":
                    switch h.cards[0].val {
                    case "2","3","4","5","6","7","8","9","A":
                        playerHit(currentPlayer, ai: true)
                    case "J", "Q", "K":
                        playerStand(currentPlayer, ai: true)
                    case _:
                        state = State.NextPlayer
                    }
                    
                case "7":
                    switch h.cards[0].val {
                    case "2","3","4","5","6","7","8","A":
                        playerHit(currentPlayer, ai: true)
                    case "J", "Q", "K", "9":
                        playerStand(currentPlayer, ai: true)
                    case _:
                        state = State.NextPlayer
                    }
                
                case "8", "J", "Q", "K":
                    switch h.cards[0].val {
                    case "2","3","4","5","6","8", "A":
                        playerHit(currentPlayer, ai: true)
                    case "J", "Q", "K", "9", "7":
                        playerStand(currentPlayer, ai: true)
                    case _:
                        state = State.NextPlayer
                    }
                
                case "9", "A":
                    switch h.cards[0].val {
                    case "2","3","4","5","6","7","8","A":
                        playerHit(currentPlayer, ai: true)
                    case "J", "Q", "K", "9":
                        playerStand(currentPlayer, ai: true)
                    case _:
                        state = State.NextPlayer
                    }
                case _:
                    state = State.NextPlayer
                }
            }
            return state;
            
        }
        
        var isHard = false;
        
        for card in h.cards {
            if card.val == "A" {
                isHard = true
                break
            }
        }
        
        if isHard {
            while state != State.NextPlayer {
                switch playerScore {
                case 17...21:
                    playerStand(currentPlayer)
                case 13...16:
                    if dealerPeek == "2" || dealerPeek == "3" || dealerPeek == "4" || dealerPeek == "5" || dealerPeek == "6" {
                        playerStand(currentPlayer, ai: true)
                    }else {
                        playerHit(currentPlayer, ai: true)
                    }
                case 12:
                    if dealerPeek == "4" || dealerPeek == "5" || dealerPeek == "6" {
                        playerStand(currentPlayer, ai: true)
                    }else {
                        playerHit(currentPlayer, ai: true)
                    }
                case 5...11:
                    playerHit(currentPlayer, ai: true)
                case _:
                    state = State.NextPlayer
                }
            }
            
        }else {
            
            while state != State.NextPlayer {
                switch playerScore {
                case 13...17:
                    playerHit(currentPlayer)
                case 18:
                    if dealerPeek == "9" || dealerPeek == "J" || dealerPeek == "Q" || dealerPeek == "K" {
                        playerHit(currentPlayer, ai: true)
                    }else {
                        playerStand(currentPlayer, ai: true)
                    }
                case 19...21:
                    playerStand(currentPlayer, ai: true)
                case _:
                    state = State.NextPlayer
                }
            }
        }
        
        
        return state
    }
    
    private func dealer() -> State {
        while playerDealer.hand.score() <= 16 {
            playerDealer.hand.addCard(shoe.draw())
        }
        state = State.Scoring
        gameAdvanceState();
        return state
    }
    
    private func score() -> State {
        gameResults = (players + aiPlayers).map() {
            (player: BlackjackPlayer) -> BlackjackPlayer.State in
            let playerScore = player.hand.score()
            let dealerScore = self.playerDealer.hand.score()
            
            let bjPlayer = player.hand.hasBlackjack()
            let bjDealer = self.playerDealer.hand.hasBlackjack()
            
            if(bjDealer) {
                player.cash += player.insurance * 2
            }
            
            // All possible tie conditions
            if bjPlayer && bjDealer
                || playerScore == dealerScore {
                    player.cash += player.bet
                    return BlackjackPlayer.State.Push
                    
                    // ALl possible lose conditions
            }else if dealerScore <= 21 && (bjDealer || playerScore > 21 || playerScore < dealerScore) {
                
                return BlackjackPlayer.State.Lose
                
                // Otherwise they win
            }else {
                player.cash += (player.bet * 3)/2
                return BlackjackPlayer.State.Win
            }
        }
        
        state = State.Post
        return state
    }
    
    func post() -> State {
        currentPlayer = 0
        round += 1
        
        //Take the cards from every one's hand, and throw it back into the deck
        for p in players {
            shoe.addToBottom(p.hand.reset())
            p.bet = 0
            p.insurance = 0
        }
        
        for p in aiPlayers {
            shoe.addToBottom(p.hand.reset())
            p.bet = 0
            p.insurance = 0
        }
        shoe.addToBottom(playerDealer.hand.reset())
        
        //Shuffle after 5 rounds
        if round % 5 == 0 {
            shoe.reset()
        }
        
        state =  State.Setup
        return state
    }
    
    init(playerCount: Int, aiCount: Int, numberOfDecks: Int) {
        for _ in 0..<playerCount {
            players.append(BlackjackPlayer())
        }
        for _ in 0..<aiCount {
            aiPlayers.append(BlackjackPlayer())
        }
        shoe = Shoe(numberOfDecks: numberOfDecks)
    }
}