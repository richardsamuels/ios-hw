//
//  Card.swift
//  HW3
//
//  Created by Richard Samuels on 27/03/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

class Card {
    let card_image: UIImage;
    let val: Character
    let suit: Character
    
    init (val: Character, suit: Character) {
        let card_string = "\(val)_of_\(suit)"
        self.card_image = UIImage(named: card_string)!;
        self.val = val
        self.suit = suit
    }
    
}