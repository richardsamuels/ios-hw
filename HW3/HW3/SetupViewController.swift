//
//  ViewController.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

class SetupViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiDeckStepper.minimumValue = 1
        uiDeckStepper.maximumValue = 10
        uiDeckStepper.value = 3.0
        uiPlayerStepper.minimumValue = 1
        uiPlayerStepper.maximumValue = 10
        uiPlayerStepper.value = 1.0
        uiDeckNum.text = "3"
        uiPlayerNum.text = "1"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gameToSetup" {
            
            var svc = segue.destinationViewController as GameViewController;
            svc.game = Blackjack(playerCount: Int(uiPlayerStepper.value), aiCount: 1, numberOfDecks: Int(uiDeckStepper.value))
        }
    }
    
    @IBAction func uiPlayerStepperChanged() {
        uiPlayerNum.text = "\(Int(uiPlayerStepper.value))"
    }
    
    @IBAction func uiDeckStepperChanged() {
        uiDeckNum.text = "\(Int(uiDeckStepper.value))"
    }
    @IBOutlet weak var uiDeckNum: UILabel!
    @IBOutlet weak var uiPlayerNum: UILabel!
    @IBOutlet weak var uiDeckStepper: UIStepper!
    @IBOutlet weak var uiPlayerStepper: UIStepper!
    @IBOutlet weak var uiStartGame: UIButton!
}

