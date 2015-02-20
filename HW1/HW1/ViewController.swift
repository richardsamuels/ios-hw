//
//  ViewController.swift
//  HW1
//
//  Created by Richard Samuels on 16/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIAlertViewDelegate {
    
    let bjGame = Blackjack()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Now lets setup the initial interface.
        //Only the play button should be enabled.
        uiUpdate()
    }
    
    //Prompt the user to select a hand to perform the action on
    //When there is only one option, it'll still prompt the user,
    private func uiSelectHandAnd(action: String, hands: [Bool], callback: (Int) -> Void)  {
        let select = UIAlertController(title: "Select a hand", message: "You can \(action) on the following hands", preferredStyle: UIAlertControllerStyle.Alert)
        
        for (i,x) in enumerate(hands) {
            if x {
                select.addAction(UIAlertAction(title: "Hand \(i + 1)", style:UIAlertActionStyle.Default) {
                    (UIAlertAction a) in
                    callback(i)
                    })
            }
            
        }
        self.presentViewController(select, animated: true, completion: nil)
    }
    
    //Set up UI based on the state of the Blackjack game
    func uiUpdate() {
        //Debug button
//        uiUpdateButton.hidden = true
        
        //State before a round has been started. Just show the Start button
        if bjGame.state == Blackjack.State.Pre || bjGame.state == Blackjack.State.Dealer {
            uiHit.hidden = true
            uiStand.hidden = true
            uiDouble.hidden = true
            uiSplit.hidden = true
            uiSurrender.hidden = true
            
            if bjGame.state != Blackjack.State.Dealer {
                uiPlay.hidden = false
                uiHandDealer.text = ""
                uiScoreDealer.text = ""
                uiHandPlayer1.text = ""
                uiScorePlayer1.text = ""
                uiHandPlayer2.text = ""
                uiScorePlayer2.text = ""
                uiHandPlayer3.text = ""
                uiScorePlayer3.text = ""
                uiHandPlayer4.text = ""
                uiScorePlayer4.text = ""
            }else {
                uiPlay.hidden = true
            }
            
        //State after a game has been started
        }else if bjGame.state == Blackjack.State.Post {
            uiPlay.hidden = false
            uiHit.hidden = true
            uiStand.hidden = true
            uiDouble.hidden = true
            uiSplit.hidden = true
            uiSurrender.hidden = true
            
            uiHandDealer.text = bjGame.dealer.string(0, dealer: false)
            uiScoreDealer.text = String(bjGame.dealer.score(0))
            uiHandPlayer1.text = bjGame.player.string(0, dealer: false)
            uiScorePlayer1.text = String(bjGame.player.score(0))
            
            if self.bjGame.player.activatedHand(1) {
                uiHandPlayer2.text = bjGame.player.string(1, dealer: false)
                uiScorePlayer2.text = String(bjGame.player.score(1))
                
                if self.bjGame.player.activatedHand(2) {
                    uiHandPlayer3.text = bjGame.player.string(2, dealer: false)
                    uiScorePlayer3.text = String(bjGame.player.score(2))
                    
                    if self.bjGame.player.activatedHand(3) {
                        uiHandPlayer4.text = bjGame.player.string(3, dealer: false)
                        uiScorePlayer4.text = String(bjGame.player.score(3))
                    }
                    
                }
                
            }
            
        }else {
            uiHit.hidden = false
            uiStand.hidden = false
            uiDouble.hidden = true
            uiPlay.hidden = true
        
            if bjGame.state == Blackjack.State.Insurance {
                uiHandDealer.text = bjGame.dealer.string(0, dealer: true)
                
            }else {
                uiHandDealer.text = bjGame.dealer.string(0, dealer: false)
                uiScoreDealer.text = String(bjGame.dealer.score(0))
            }
            uiHandPlayer1.text = bjGame.player.string(0, dealer: false)
            
            uiScorePlayer1.text = String(bjGame.player.score(0))
        }
        
        if self.bjGame.player.activatedHand(1) {
            uiHandPlayer2.text = bjGame.player.string(1, dealer: false)
            uiScorePlayer2.text = String(bjGame.player.score(1))
            
            if self.bjGame.player.activatedHand(2) {
                uiHandPlayer3.text = bjGame.player.string(2, dealer: false)
                uiScorePlayer3.text = String(bjGame.player.score(2))
                
                if self.bjGame.player.activatedHand(3) {
                    uiHandPlayer4.text = bjGame.player.string(3, dealer: false)
                    uiScorePlayer4.text = String(bjGame.player.score(3))
                }
                
            }
            
        }
        uiCash.text = String(bjGame.cash)
        uiDouble.hidden = !bjGame.canDouble()
        uiSplit.hidden = !bjGame.canSplit()
        uiSurrender.hidden = !bjGame.canSurrender()
        
    }
    
    //Check if the game is over, if so prompt the player with the game information
    func uiCheckLose() {
        self.uiUpdate()
        
        if self.bjGame.state == Blackjack.State.Post {
        
            var messages:[String] = []
            
            for (index, x) in enumerate(bjGame.endgame) {
                if x == Blackjack.Result.Win {
                    messages.append("Hand \(index + 1): Win")
                    
                }else if x == Blackjack.Result.Lose {
                    messages.append("Hand \(index + 1): Lose ")
                    
                }else if x == Blackjack.Result.Tie {
                    messages.append("Hand \(index + 1): No winner")
                }
            }
            
            //Display the message
            //Has a trailing newline on it
            let endGame = UIAlertController(title: "Game over", message: messages.reduce("", {$0! + $1 + "\n"}), preferredStyle: UIAlertControllerStyle.Alert)
            endGame.addAction(UIAlertAction(title: "Okay", style:UIAlertActionStyle.Default){
                (UIAlertAction a) in
                self.bjGame.post()
                })
            self.presentViewController(endGame, animated: true, completion: nil)
        }
    }
    
    //Prompt the user for an insurance bet
    func uiInsurance() {
        let insurance = UIAlertController(title: "Insurance", message: "You may place an insurance wager up to $\(bjGame.bet/2). (Enter 0 for no insurance)", preferredStyle: UIAlertControllerStyle.Alert)
        
        var textField: UITextField?
        
        //Add a text field
        insurance.addTextFieldWithConfigurationHandler(){
        (UITextField money) in
            money.keyboardType = UIKeyboardType.NumberPad
            money.placeholder = "0"
            money.text = "0"
            textField = money
        }
        
        insurance.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
            (UIAlertAction a) in
            if let bet = textField!.text.toInt() {
                if bet <= (self.bjGame.bet / 2)  {
                    self.bjGame.insurance(bet)
                    self.uiUpdate()
                }else {
                    //if failed, reprompt the user
                    self.presentViewController(insurance, animated: true, completion: nil)
                }
            }else {
                //if failed, reprompt the user
                self.presentViewController(insurance, animated: true, completion: nil)
            }
            
            })
        self.presentViewController(insurance, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions for when buttons are hit
    @IBAction func actionPlay(sender: AnyObject) {
        //Setup an invalid input prompt Just in case
        let error = UIAlertController(title: "Bad Bet!", message: "You may bet up to \(bjGame.cash) in increments of $1. Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
        error.addAction(UIAlertAction(title: "Okay", style:UIAlertActionStyle.Default, nil))
        
        //Setup the betting prompt
        let alert = UIAlertController(title: "Enter Your Bet", message: "You may bet up to \(bjGame.cash) in increments of $1", preferredStyle: UIAlertControllerStyle.Alert)
        var textField: UITextField?
        
        //Add a textfield to collect some input from the user
        alert.addTextFieldWithConfigurationHandler() {
        (UITextField money) in
            money.keyboardType = UIKeyboardType.NumberPad
            money.placeholder = String(self.bjGame.cash)
            textField = money
        }
    
        //Now react to that input
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) {
            (UIAlertAction a) in
            if let bet = textField!.text.toInt() {
                if bet <= self.bjGame.cash && bet > 0 {
                    let state = self.bjGame.start(bet)
                    
                    if state == Blackjack.State.Insurance {
                        self.uiInsurance()
                    }
                    
                    self.uiUpdate()
                    
                }else {
                    self.presentViewController(error, animated: true, completion: nil)
                }
            }else {
                self.presentViewController(error, animated: true, completion: nil)
            }
            
            })
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionSurrender() {
        //Setup the surrender prompt
        let alert = UIAlertController(title: "Are you sure you wish to surrender?", message: "You'll get $\(bjGame.bet/2) back, and the round will end. This cannot be undone", preferredStyle: UIAlertControllerStyle.Alert)
        var textField: UITextField?
        
        //Now react to that input
        alert.addAction(UIAlertAction(title: "Yes, I give up", style: UIAlertActionStyle.Destructive) {
            (UIAlertAction a) in
                self.bjGame.surrender()
                self.uiUpdate()
            })
        alert.addAction(UIAlertAction(title: "No, I'll keep playing", style: UIAlertActionStyle.Default, nil) )
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionHit() {
        uiSelectHandAnd("hit", hands: self.bjGame.player.activeHand ) {
            (h: Int) -> Void in
            self.bjGame.hit(h)
            self.uiUpdate()
            self.uiCheckLose()
        }
    }
    
    @IBAction func actionStand() {
        uiSelectHandAnd("stand", hands: self.bjGame.player.activeHand) {
            (h: Int) -> Void in
            self.bjGame.stand(h)
            self.uiUpdate()
            self.uiCheckLose()
        }

    }
    
    @IBAction func actionDouble() {
        uiSelectHandAnd("double", hands: self.bjGame.player.activeHand) {
            (h: Int) -> Void in
            self.bjGame.double(h)
            self.uiUpdate()
            self.uiCheckLose()
        }
    }
    
    @IBAction func actionSplit() {
        uiSelectHandAnd("split", hands: self.bjGame.player.handsCanSplit()) {
            (h: Int) -> Void in
            self.bjGame.split(h)
            self.uiUpdate()
            self.uiCheckLose()
        }
    }
    
    @IBAction func ui() {
        self.uiUpdate()
    }
    
    //Outlets
    @IBOutlet var uiUpdateButton: UIButton!
    @IBOutlet var uiScoreDealer: UILabel!
    @IBOutlet var uiHandDealer: UILabel!
    @IBOutlet var uiScorePlayer1: UILabel!
    @IBOutlet var uiHandPlayer1: UILabel!
    @IBOutlet var uiScorePlayer2: UILabel!
    @IBOutlet var uiHandPlayer2: UILabel!
    @IBOutlet var uiScorePlayer3: UILabel!
    @IBOutlet var uiHandPlayer3: UILabel!
    @IBOutlet var uiScorePlayer4: UILabel!
    @IBOutlet var uiHandPlayer4: UILabel!
    @IBOutlet var uiHit: UIButton!
    @IBOutlet var uiStand: UIButton!
    @IBOutlet var uiDouble: UIButton!
    @IBOutlet var uiSplit: UIButton!
    @IBOutlet var uiPlay: UIButton!
    @IBOutlet var uiSurrender: UIButton!
    @IBOutlet var uiCash: UILabel!
}
