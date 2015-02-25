//
//  ViewController.swift
//  HW2
//
//  Created by Richard Samuels on 24/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
    var game: Blackjack!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var uiSurrender: UIButton!
    @IBAction func actionSurrender(sender: UIButton) {
    }
    @IBAction func actionStand(sender: UIButton) {
    }
    @IBAction func actionHit() {
    }
}


