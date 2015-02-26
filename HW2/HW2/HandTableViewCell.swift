//
//  HandCellController.swift
//  HW2
//
//  Created by Richard Samuels on 25/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

public class HandTableViewCell: UITableViewCell {
    
    @IBOutlet weak var uiHand: UILabel!
    @IBOutlet weak var uiPlayer: UILabel!
    @IBOutlet weak var uiScore: UILabel!
    @IBOutlet weak var uiWager: UILabel!
    
    public func set(player: Int, hand: String, wager: Int? = nil, insurance: Int? = nil, score: Int? = nil) {
        uiHand.text = hand
        
        if player == 0 {
            uiPlayer.text = "Dealer"
        }else {
            uiPlayer.text = "Player \(player)"
        }
        
        if wager != nil {
            if insurance != nil {
                uiWager.text = "$\(wager) + $\(insurance)"
            }else {
                uiWager.text = "$\(wager)"
            }
        }else {
            uiWager.text = ""
        }
        
        if score != nil && score != 0 {
            uiScore.text = String(score!)
        }else {
            uiScore.text = ""
        }
    }
}