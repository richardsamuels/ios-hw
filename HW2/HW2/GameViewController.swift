//
//  ViewController.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var game: Blackjack!
    var bets: [Int] = []
    
    //Table view Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.players.count + 1
    }
    
    //Builds each cell of the table view
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HandCell") as HandTableViewCell
        
        if indexPath.row == 0 {
            if game.state == Blackjack.State.Player {
                cell.set(indexPath.row, hand: game.playerDealer.hand.string(),
                    score: game.playerDealer.hand.score())
            }else {
                cell.set(indexPath.row, hand: game.playerDealer.hand.string(hideHole: true),
                    score: nil)
            }
        }else {
            let player: BlackjackPlayer = game.players [(indexPath.row - 1)]
            
            cell.set(indexPath.row,
                hand: player.hand.string(),
                wager: player.bet,
                insurance: player.insurance,
                score: player.hand.score())
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.uiTable.registerClass(HandTableViewCell.self, forCellReuseIdentifier: "HandCell")
    }
    
    //Starts the game once the view has loaded
    override func viewDidAppear(animated: Bool) {
        self.game.gameAdvanceState()
        
        betChain(player: 0, action: {
            //Advance the game state
            let postBetState = self.game.gameAdvanceState(bets: self.bets)
            
            //update the table
            self.uiTable.reloadData()
            
            //Check if we need to ask users for insurance
            if postBetState == Blackjack.State.Insurance {
                self.bets.removeAll(keepCapacity: true)
                
                //if so, get the bets,
                self.insuranceChain(player: 0, action: {
                    //Then advance the game state
                    let x = self.game.gameAdvanceState(bets: self.bets)
                    if x == Blackjack.State.Scoring {
                        self.scoring()
                    }
                })
            }else if postBetState == Blackjack.State.Scoring {
                self.scoring()
            }
            
            self.uiTable.reloadData()
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var uiSurrender: UIButton!
    @IBOutlet weak var uiTable: UITableView!
    
    //Surrender Button
    @IBAction func actionSurrender(sender: UIButton) {
        if game.state == Blackjack.State.Player {
            game.playerSurrender(game.currentPlayer)
            let s = game.gameAdvanceState()
            
            if s == Blackjack.State.Player {
                playerPrompt(game.currentPlayer, nil)
            }else {
                scoring()
            }
            
        }
    }
    
    //Stand button
    @IBAction func actionStand(sender: UIButton) {
        if game.state == Blackjack.State.Player {
            game.playerStand(game.currentPlayer)
            let s = game.gameAdvanceState()
            
            if s == Blackjack.State.Player {
                playerPrompt(game.currentPlayer, nil)
            }else {
                scoring()
            }
            
        }
    }
    @IBAction func actionHit() {
        uiSurrender.hidden = true
        
        if game.state == Blackjack.State.Player {
            let s = game.playerHit(game.currentPlayer)
            uiTable.reloadData()
            
            if s == Blackjack.State.NextPlayer {
                let s2 = game.gameAdvanceState()
                
                if s2 == Blackjack.State.Player {
                    playerPrompt(game.currentPlayer, nil)
                }else {
                    scoring()
                }
            }
            
        }
    }
    
    func scoring() {
        game.gameAdvanceState()
        
    }
    
    //Notify the player it's their turn, then execute action
    func playerPrompt(player: Int?, action: ((Int) -> Void)? ) {
        self.uiSurrender.hidden = false
        
        //Work with the optional
        var playerNum: Int
        if player == nil {
            playerNum = game.currentPlayer
        }else {
            playerNum = player!
        }
        
        //Let the user know whose turn it is
        let prompt = UIAlertController(title: "Player \(playerNum + 1)", message: "It is now your turn", preferredStyle: UIAlertControllerStyle.Alert)
        
        prompt.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, { (UIAlertAction) -> Void in if action != nil { action!(playerNum)}}) )
        
        self.presentViewController(prompt, animated: true, completion: nil)
    }
    
    //Request a bet from all the players, then execute action
    func betChain(player: Int = 0, action: () -> Void) {
        playerPrompt(player, action: {
            (Int) -> Void in
            let prompt = UIAlertController(title: "Wager", message: "You may place an wager up to $\(self.game.players[player].cash) in $1 increments.", preferredStyle: UIAlertControllerStyle.Alert)
            
            var textField: UITextField?
            
            //Add a text field
            prompt.addTextFieldWithConfigurationHandler(){
                (UITextField money) in
                money.keyboardType = UIKeyboardType.NumberPad
                money.placeholder = "1"
                money.text = "1"
                textField = money
            }
            
            prompt.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
                (UIAlertAction a) in
                if let bet = textField!.text.toInt() {
                    if bet <= (self.game.players[player].cash)  {
                        self.bets.append(bet)
                        
                        if (player + 1) < self.game.players.count {
                            self.betChain(player: (player + 1), action: action)
                        }else {
                            action()
                        }
                    }else {
                        //if failed, reprompt the user
                        self.presentViewController(prompt, animated: true, completion: nil)
                    }
                }else {
                    //if failed, reprompt the user
                    self.presentViewController(prompt, animated: true, completion: nil)
                }
                
                })
            self.presentViewController(prompt, animated: true, completion: nil)
        })
    }
    
    //Request an insurance bet from all players, then execute action
    func insuranceChain(player: Int = 0, action: () -> Void) {
        playerPrompt(player, action: {
            (Int) -> Void in
            let prompt = UIAlertController(title: "Insurance", message: "You may place an insurance wager up to $\(self.game.players[player].bet/2) in $1 increments. For no wager, enter 0", preferredStyle: UIAlertControllerStyle.Alert)
            
            var textField: UITextField?
            
            //Add a text field
            prompt.addTextFieldWithConfigurationHandler(){
                (UITextField money) in
                money.keyboardType = UIKeyboardType.NumberPad
                money.placeholder = "0"
                money.text = "0"
                textField = money
            }
            
            //Add a button to close the modal
            prompt.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
                (UIAlertAction a) in
                if let bet = textField!.text.toInt() {
                    //Check if valid insurance bet
                    if bet <= (self.game.players[player].bet/2)  {
                        
                        //If so, accept it
                        self.bets.append(bet)
                        
                        //and move on to the next player
                        if (player + 1) < self.game.players.count {
                            self.betChain(player: (player + 1), action: action)
                        }else {
                            action()
                        }
                    }else {
                        //if failed, reprompt the user
                        self.presentViewController(prompt, animated: true, completion: nil)
                    }
                }else {
                    //if failed, reprompt the user
                    self.presentViewController(prompt, animated: true, completion: nil)
                }
                
                })
            self.presentViewController(prompt, animated: true, completion: nil)
        })
    }
        
}


