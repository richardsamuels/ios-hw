//
//  Player.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import Foundation

class BlackjackPlayer {
    var cash = 100
    let hand = Hand()
    
    var bet = 0
    var insurance = 0
 
    enum State {
        case Win
        case Lose
        case Push
    }
    
    init() {
        
    }
}