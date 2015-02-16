//
//  ViewController.swift
//  HW1
//
//  Created by Richard Samuels on 16/02/15.
//  Copyright (c) 2015 Richard Samuels. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let bjGame = Blackjack()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Actions for when buttons are hit
    @IBAction func actionPlay() {
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
    
    @IBOutlet weak var uiHit: UIButton!
    @IBOutlet weak var uiStand: UIButton!
    @IBOutlet weak var uiDouble: UIButton!
    @IBOutlet weak var uiSplit: UIButton!
    @IBOutlet weak var uiPlay: UIButton!
    @IBOutlet weak var uiSurrender: UIButton!
    @IBOutlet weak var uiCash: UILabel!
}
