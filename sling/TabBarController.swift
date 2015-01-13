//
//  TabBarController.swift
//  sling
//
//  Created by Nick De Heras on 1/12/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation

class CustomTabBarController : UIViewController {

    var currentViewController: UIViewController?
    @IBOutlet var placeholderView: UIView!
    @IBOutlet var tabBarButtons: Array <UIButton>!


    override func viewDidLoad() {
        super.viewDidLoad()
        if(tabBarButtons.count > 0) {
            performSegueWithIdentifier("Messages", sender: tabBarButtons[0])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let availableIdentifiers = ["Messages", "Friends", "Profile"]
        
        if(contains(availableIdentifiers, segue.identifier!)) {
            for btn in tabBarButtons {
                btn.selected = false
            }
            let senderBtn = sender as UIButton
            senderBtn.selected = true
        }
    }
}
