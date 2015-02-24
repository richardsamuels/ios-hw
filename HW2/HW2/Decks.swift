//
//  Decks.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import Foundation

//Array shuffling extension courtesy of:
// https://gist.github.com/natecook1000/0ac03efe07f647b46dae
// (Fisher-Yates shuffling algorithm)
// Start code from Nate Cook
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&self[i], &self[j])
        }
    }
}
// End code from Nate Cook

class Deck {
    private var deck: [Character] = []
    let numberOfDecks: Int;
    
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
        for _ in 1...numberOfDecks {
            let set: [Character] = ["A", "J", "Q", "K", "2", "3", "4", "5", "6", "7", "8", "9"]
            
            for c in set {
                for _ in 1...4 {
                    deck.append(c)
                }
            }
        }
        
        //Now shuffle the array
        //No built-in for this, so we're using an extension to Array from Nate Cook
        deck.shuffle()
    }
    
    //Add to back of array
    func pushback(c: [Character]) {
        deck += c
    }
    
    init(numberOfDecks: Int) {
        if(numberOfDecks < 1) {
            self.numberOfDecks = 3
        }else {
            self.numberOfDecks = numberOfDecks
        }
        
        reset();
    }
}