//
//  FriendParentViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/7/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendParentViewController : UIViewController, UISearchBarDelegate{
    
    //var convo : Conversation!
    var convos : NSMutableArray = NSMutableArray()
    var groupConvo : Conversation = Conversation(sender: PFUser.currentUser())
    var messageText : String = ""
    var groupSegmentedControl : UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sendButton = UIBarButtonItem(title: "send", style: .Plain, target: self, action: "send")
        self.navigationItem.setRightBarButtonItem(sendButton, animated: true)
        var backButton = UIBarButtonItem(title: "back", style: .Plain, target: self, action: "back")
        self.navigationItem.setLeftBarButtonItem(sendButton, animated: true)
        let items = ["blast", "group"]
        self.groupSegmentedControl = UISegmentedControl(items: items)
        self.navigationItem.titleView = self.groupSegmentedControl
        self.groupSegmentedControl.selectedSegmentIndex = 0
        //var child = self.childViewControllers[0] as FriendCollectionViewController
        //child.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("fddfdgfdd")
        super.viewDidAppear(animated)
        let widthConstraintChild = NSLayoutConstraint(item: self.childViewControllers[0].view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.view.addConstraint(widthConstraintChild)
        
    }
    
    func send(){
        if(self.groupSegmentedControl.selectedSegmentIndex == 0){
            for object in self.convos{
                let message:PFObject = PFObject(className: "Message")
                message["text"] = self.messageText
                let convo = object as! Conversation
                message["inConvo"] = convo.convo as PFObject
                message["sender"] = PFUser.currentUser()
                message.saveInBackgroundWithTarget(nil, selector: nil)
                convo.addRecipient(PFUser.currentUser(), isOwner: true)
                convo.save()
            }
        }
        else{
            let message:PFObject = PFObject(className: "Message")
            message["text"] = self.messageText
            message["inConvo"] = groupConvo.convo as PFObject
            message["sender"] = PFUser.currentUser()
            message.saveInBackgroundWithTarget(nil, selector: nil)
            groupConvo.addRecipient(PFUser.currentUser(), isOwner: true)
            groupConvo.save()
        }
    }
    
    func back(){
        if(self.groupSegmentedControl.selectedSegmentIndex == 0){
            print("blast back")
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else{
            print("group back")
            let count = self.navigationController?.viewControllers.count as Int!
            let messageVC = self.navigationController?.viewControllers[count - 2] as! MessagesViewController
            messageVC.convo = self.groupConvo
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        let child = self.childViewControllers[0] as! FriendTableViewController
        if searchBar.text!.isEmpty{
            child.isSearching = false
                child.tableView.reloadData()
        } else {
            child.isSearching = true
            child.filteredUsers.removeAllObjects()
            for var index = 0; index < child.users.count; index++
            {
                let currentUser = child.users.objectAtIndex(index) as! PFObject
                var currentString = currentUser.objectForKey("realName") as! String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    child.filteredUsers.addObject(currentUser)
                }
            }
            child.tableView.reloadData()
        }
    }

}