//
//  Decks.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import Foundation


class Shoe {
    private let decks: [Deck];
    
    var numCards: Int {
        get {
            return decks.map() {
                (d: Deck) -> Int in
                return d.numCards
            }.reduce(0){ $0 + $1}
        }
    }
    
    var numberOfDecks: Int {
        get {
            return decks.count
        }
    }
    
    func draw() -> Character {
        let randomlySelectDeck = Int(arc4random_uniform(UInt32(numberOfDecks)))
        return decks[randomlySelectDeck].draw()
    }
    
    func addToBottom(characters: [Character])  {
        for c in characters {
            for d in decks {
                if d.numCards < 52 {
                    d.pushback([c]);
                }
            }
        }
    }
    
    func reset() {
        for d in decks {
            d.reset()
        }
    }
    
    init(numberOfDecks: Int = 3) {
        decks = [Deck](count: numberOfDecks, repeatedValue: Deck())
    }
}