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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 0
        return game.players.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        return UITableViewCell()
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        if indexPath.row == 0 {
            cell.textLabel?.text = game.playerDealer.hand.string(hideHole: false);
        }else {
            cell.textLabel?.text = game.players[indexPath.row - 1].hand.string(hideHole: false);
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.uiTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.game.gameAdvanceState()
        
        betChain(player: 0, action: {
            let postBetState = self.game.gameAdvanceState(bets: self.bets)
            
            if postBetState == Blackjack.State.Insurance {
                self.bets.removeAll(keepCapacity: true)
                
                self.insuranceChain(player: 0, action: {
                    let x = self.game.gameAdvanceState(bets: self.bets)
                })
            }
            
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var uiSurrender: UIButton!
    @IBOutlet weak var uiTable: UITableView!
    @IBAction func actionSurrender(sender: UIButton) {
    }
    @IBAction func actionStand(sender: UIButton) {
    }
    @IBAction func actionHit() {
    }
    
    
    func playerPrompt(player: Int?, action: (Int) -> Void) {
        var playerNum: Int
        if player == nil {
            playerNum = game.currentPlayer
        }else {
            playerNum = player!
        }
        
        let prompt = UIAlertController(title: "Player \(playerNum + 1)", message: "It is now your turn", preferredStyle: UIAlertControllerStyle.Alert)
        
        prompt.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, { (UIAlertAction) -> Void in action(playerNum)}))
        
        self.presentViewController(prompt, animated: true, completion: nil)
    }
    
    
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
            
            prompt.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
                (UIAlertAction a) in
                if let bet = textField!.text.toInt() {
                    if bet <= (self.game.players[player].bet/2)  {
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
        
}


