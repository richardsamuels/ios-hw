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
    
    public func set(cash: Int, player: Int, hand: String?, wager: Int? = nil, insurance: Int? = nil, score: Int? = nil) {
        if hand != nil {
            uiHand.text = hand
        }else {
            uiHand.text = ""
        }
        
        if player == 0 {
            uiPlayer.text = "Dealer"
        }else {
            uiPlayer.text = "Player \(player): $\(cash)"
        }
        
        if wager != nil && wager != 0 {
            if insurance != nil && insurance != 0 {
                uiWager.text = "$\(wager!) + $\(insurance!)"
            }else {
                uiWager.text = "$\(wager!)"
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