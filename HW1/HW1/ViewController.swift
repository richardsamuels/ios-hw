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
        
        if bjGame.doubled {
            uiHit.hidden = true
            uiStand.hidden = true
            uiDouble.hidden = true
            uiSplit.hidden = true
            uiSurrender.hidden = true
        }
        
        uiHandDealer.text = bjGame.dealer.string(dealer: true)
        uiHandPlayer1.text = bjGame.player.string(dealer: false)
        
        uiScoreDealer.text = String(bjGame.dealer.score())
        uiScorePlayer1.text = String(bjGame.player.score())
    }
    
    func uiCheckLose() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions for when buttons are hit
    @IBAction func actionPlay(sender: AnyObject) {
        //Setup an invalid input prompt Just in case
        var error = UIAlertController(title: "Bad Bet!", message: "You may bet up to \(bjGame.score) in increments of $1. Please try again!", preferredStyle: UIAlertControllerStyle.Alert)
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
                self.uiUpdateFields()
                self.uiDefaultState()
            })
        alert.addAction(UIAlertAction(title: "No, I'll keep playing", style: UIAlertActionStyle.Default, nil) )
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func actionHit() {
    }
    
    @IBAction func actionStand() {
    }
    
    @IBAction func actionDouble() {
        bjGame.double()
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
