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
        uiDefaultState()
        
    }
    
    func uiPostRound() -> Void {
        self.bjGame.endRound()
        self.uiUpdateFields()
        self.uiDefaultState()
    }
    
    //Set the default state of the UI
    //(Only the Play button should be enabled)
    func uiDefaultState() {
        uiPlay.hidden = false
        uiHit.hidden = true
        uiStand.hidden = true
        uiDouble.hidden = true
        uiSplit.hidden = true
        uiSurrender.hidden = true
        
        uiHandDealer.text = ""
        uiHandPlayer1.text = ""
        uiScoreDealer.text = ""
        uiScorePlayer1.text = ""
        
    }
    
    func uiGameState() {
        uiHit.hidden = false
        uiStand.hidden = false
        uiDouble.hidden = true
        uiPlay.hidden = true
        uiSurrender.hidden = false
        
        uiUpdateFields()
    }
    
    func uiUpdateFields() {
        uiCash.text = String(bjGame.score)
        
        if !bjGame.doubled && bjGame.bet <= bjGame.score {
            uiDouble.hidden = false
        }
        
        if bjGame.player.cards.count == 2 {
            uiSurrender.hidden = false
        }else {
            uiSurrender.hidden = true
        }
        
        if bjGame.doubled {
            uiHit.hidden = true
            uiStand.hidden = true
            uiDouble.hidden = true
            uiSplit.hidden = true
            uiSurrender.hidden = true
        }
        
        uiHandDealer.text = bjGame.dealer.string(dealer: !bjGame.showHole)
        uiHandPlayer1.text = bjGame.player.string(dealer: false)
        
        if bjGame.showHole {
            uiScoreDealer.text = String(bjGame.dealer.score())
        }
        uiScorePlayer1.text = String(bjGame.player.score())
    }
    
    func uiCheckLose() {
        
        if bjGame.winState.player {
            let endGame = UIAlertController(title: "You Won!", message: "Well done!", preferredStyle: UIAlertControllerStyle.Alert)
            endGame.addAction(UIAlertAction(title: "Yay!", style:UIAlertActionStyle.Default){
                (UIAlertAction a) in
                self.uiPostRound()
                })
            self.presentViewController(endGame, animated: true, completion: nil)
            
        }else if bjGame.winState.dealer {
            let endGame = UIAlertController(title: "You Lost!", message: "Better luck next time", preferredStyle: UIAlertControllerStyle.Alert)
            endGame.addAction(UIAlertAction(title: ":(", style:UIAlertActionStyle.Default){
                (UIAlertAction a) in
                self.uiPostRound()
                })
            self.presentViewController(endGame, animated: true, completion: nil)
            
        }else if bjGame.winState.none {
            let endGame = UIAlertController(title: "Everyone Lost!", message: "Better than the dealer winning right?", preferredStyle: UIAlertControllerStyle.Alert)
            endGame.addAction(UIAlertAction(title: "...I guess so", style:UIAlertActionStyle.Default){
                (UIAlertAction a) in
                self.uiPostRound()
                })
            self.presentViewController(endGame, animated: true, completion: nil)
        }
    }
    
    func uiInsurance() {
        //Check if we need to offer insurance
        let index = advance(uiHandDealer.text!.startIndex, 0)
        if uiHandDealer.text![index] == "A" {
            let insurance = UIAlertController(title: "Insurance", message: "You may place an insurance wager up to $\(bjGame.bet/2). (Enter 0 for no insurance)", preferredStyle: UIAlertControllerStyle.Alert)
            
            var textField: UITextField?
            
            insurance.addTextFieldWithConfigurationHandler(){
            (UITextField money) in
                money.keyboardType = UIKeyboardType.NumberPad
                money.placeholder = "0"
                textField = money
            }
            
            insurance.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default) {
                (UIAlertAction a) in
                if let bet = textField!.text.toInt() {
                    if bet <= (self.bjGame.bet / 2)  {
                        self.bjGame.insurance(bet)
                    }else {
                        self.presentViewController(insurance, animated: true, completion: nil)
                    }
                }else {
                    self.presentViewController(insurance, animated: true, completion: nil)
                }
                
                })
            self.presentViewController(insurance, animated: true, completion: nil)
            
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions for when buttons are hit
    @IBAction func actionPlay(sender: AnyObject) {
        //Setup an invalid input prompt Just in case
        let error = UIAlertController(title: "Bad Bet!", message: "You may bet up to \(bjGame.score) in increments of $1. Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
        error.addAction(UIAlertAction(title: "Okay", style:UIAlertActionStyle.Default, nil))
        
        //Setup the betting prompt
        let alert = UIAlertController(title: "Enter Your Bet", message: "You may bet up to \(bjGame.score) in increments of $1", preferredStyle: UIAlertControllerStyle.Alert)
        var textField: UITextField?
        
        //Add a textfield to collect some input from the user
        alert.addTextFieldWithConfigurationHandler() {
        (UITextField money) in
            money.keyboardType = UIKeyboardType.NumberPad
            money.placeholder = String(self.bjGame.score)
            textField = money
        }
    
        //Now react to that input
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default) {
            (UIAlertAction a) in
            if let bet = textField!.text.toInt() {
                if bet <= self.bjGame.score && bet > 0 {
                    self.bjGame.start(bet)
                    self.uiGameState()
                    self.uiUpdateFields()
                    
                    self.uiInsurance()
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
                self.uiPostRound()
//                self.uiCheckLose()
            })
        alert.addAction(UIAlertAction(title: "No, I'll keep playing", style: UIAlertActionStyle.Default, nil) )
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionHit() {
        bjGame.hit()
        
        uiUpdateFields()
        
        uiCheckLose()
    }
    
    @IBAction func actionStand() {
        bjGame.showHole = true
        uiUpdateFields()
        bjGame.dealerActions()
        uiUpdateFields()
        uiCheckLose()
    }
    
    @IBAction func actionDouble() {
        bjGame.double()
        uiUpdateFields()
        uiCheckLose()
    }
    
    @IBAction func actionSplit() {
    }
    
    @IBOutlet var uiScoreDealer: UILabel!
    @IBOutlet var uiHandDealer: UILabel!
    @IBOutlet var uiScorePlayer1: UILabel!
    @IBOutlet var uiHandPlayer1: UILabel!
    @IBOutlet var uiHit: UIButton!
    @IBOutlet var uiStand: UIButton!
    @IBOutlet var uiDouble: UIButton!
    @IBOutlet var uiSplit: UIButton!
    @IBOutlet var uiPlay: UIButton!
    @IBOutlet var uiSurrender: UIButton!
    @IBOutlet var uiCash: UILabel!
}
