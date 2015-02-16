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
        uiHit.hidden = true
        uiStand.hidden = true
        uiDouble.hidden = true
        uiSplit.hidden = true
        uiSurrender.hidden = true
//        uiSurrender.setTitleColor(color: UIColor.grayColor(), forState: <#UIControlState#>)
    }
    
    func uiGameState() {
        uiHit.hidden = false
        uiStand.hidden = false
        uiDouble.hidden = false
        uiPlay.hidden = true
        uiSurrender.hidden = false
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
                if bet <= self.bjGame.score {
                    self.bjGame.start(bet)
                    self.uiGameState()
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
    }
    
    @IBAction func actionHit() {
    }
    
    @IBAction func actionStand() {
    }
    
    @IBAction func actionDouble() {
    }
    
    @IBAction func actionSplit() {
    }
    
    @IBOutlet  var uiHit: UIButton!
    @IBOutlet  var uiStand: UIButton!
    @IBOutlet  var uiDouble: UIButton!
    @IBOutlet  var uiSplit: UIButton!
    @IBOutlet  var uiPlay: UIButton!
    @IBOutlet  var uiSurrender: UIButton!
    @IBOutlet  var uiCash: UILabel!
}
