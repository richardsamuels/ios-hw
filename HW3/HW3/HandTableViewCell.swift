//
//  HandCellController.swift
//  HW2
//
//  Created by Richard Samuels on 25/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

public class HandTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
  
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let h = self.hand {
            return h.cards.count
        }else {
            return 0
        }
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.uiCollection.dequeueReusableCellWithReuseIdentifier("card_cell", forIndexPath: indexPath) as CardCell
        
        if let h = self.hand {
            cell.uiImage.image = h.cards[indexPath.row].card_image
        }
        
        return cell
    }
    
    @IBOutlet weak var uiPlayer: UILabel!
    @IBOutlet weak var uiScore: UILabel!
    @IBOutlet weak var uiWager: UILabel!
    @IBOutlet var uiCollection: UICollectionView!
    var hand: Hand? = nil

    public func set(cash: Int, player: Int, hand: Hand?, wager: Int? = nil, insurance: Int? = nil, score: Int? = nil, ai: Bool = false, dealer: Bool = false, active: Bool = false) {
        self.hand = hand
        self.uiCollection.delegate = self
        self.uiCollection.dataSource = self
        
        self.uiCollection.reloadData()
        
        if ai {
            uiPlayer.text  = "Player \(player) (AI): $\(cash)"
            self.backgroundColor = UIColor.grayColor()
            self.uiCollection.backgroundColor = UIColor.grayColor()
        }else {
            if player == 0 {
                uiPlayer.text = "Dealer"
            }else {
                uiPlayer.text = "Player \(player): $\(cash)"
            }
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
        
        if active {
            self.uiCollection.backgroundColor = UIColor.greenColor()
            self.backgroundColor = UIColor.greenColor()
        }else {
            self.uiCollection.backgroundColor = UIColor.whiteColor()
            self.backgroundColor = UIColor.whiteColor()
        }
    }
}