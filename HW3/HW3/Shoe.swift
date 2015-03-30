//
//  Decks.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import Foundation


class Shoe {
    private let decks: [Deck]
    var cards: [Card] = []
    
    
    var numberOfDecks: Int {
        get {
            return decks.count
        }
    }
    
    func draw() -> Card {
        if cards.count == 0 {
            reset()
        }
        
        return self.cards.removeAtIndex(0)
    }
    
    func addToBottom(cards: [Card])  {
        for c in cards {
            self.cards.append(c);
        }
    }
    
    func reset() {
        cards.removeAll(keepCapacity: true)
        
        for deck in decks {
            deck.reset()
        }
        
        for deck in decks {
            for card in deck.deck {
                self.cards.append(card);
            }
            
            deck.deck.removeAll(keepCapacity: true)
        }
    }
    
    init(numberOfDecks: Int = 3) {
        decks = [Deck](count: numberOfDecks, repeatedValue: Deck())
        
        reset()
    }
}