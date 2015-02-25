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
    var numberOfDecks: Int {
        get {
            return decks.count
        }
    }
    
    func draw() -> Character {
        let randomlySelectDeck = Int(arc4random_uniform(UInt32(numberOfDecks)))
        return decks[randomlySelectDeck].draw()
    }
    
    init(numberOfDecks: Int = 3) {
        decks = [Deck](count: numberOfDecks, repeatedValue: Deck())
    }
}