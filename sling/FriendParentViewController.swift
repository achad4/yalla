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
    var messageText : String = ""
    var groupSegmentedControl : UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var sendButton = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: "send")
        self.navigationItem.setRightBarButtonItem(sendButton, animated: true)
        var items = ["blast", "group"]
        self.groupSegmentedControl = UISegmentedControl(items: items)
        self.navigationItem.titleView = self.groupSegmentedControl
        self.groupSegmentedControl.selectedSegmentIndex = 0
        //var child = self.childViewControllers[0] as FriendCollectionViewController
        //child.loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        var widthConstraintChild = NSLayoutConstraint(item: self.childViewControllers[0].view, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        self.view.addConstraint(widthConstraintChild)
        
    }
    
    func send(){
        
        for object in self.convos{
            var message:PFObject = PFObject(className: "Message")
            message["text"] = self.messageText
            var convo = object as Conversation
            message["inConvo"] = convo.convo as PFObject
            message["sender"] = PFUser.currentUser()
            message.saveInBackgroundWithTarget(nil, selector: nil)
            convo.addRecipient(PFUser.currentUser(), isOwner: true)
            convo.save()
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        var child = self.childViewControllers[0] as FriendCollectionViewController
        if searchBar.text.isEmpty{
            child.isSearching = false
                child.collectionView?.reloadData()
        } else {
            child.isSearching = true
            child.filteredUsers.removeAllObjects()
            for var index = 0; index < child.users.count; index++
            {
                var currentUser = child.users.objectAtIndex(index) as PFObject
                var currentString = currentUser.objectForKey("realName") as String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    child.filteredUsers.addObject(currentUser)
                }
            }
            child.collectionView?.reloadData()
        }
    }

}