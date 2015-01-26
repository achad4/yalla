//
//  FriendParentViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/7/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendParentViewController : UIViewController, UISearchBarDelegate{
    

    //var convo : Conversation = Conversation(sender: PFUser.currentUser())
    var convo : Conversation!
    var messageText : String = ""
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func controlSelected(sender: UISegmentedControl) {
        var child = self.childViewControllers[0] as FriendCollectionViewController
        child.messageText = self.messageText
        if (segmentedControl.selectedSegmentIndex == 0) {
            child.segment = 1
            child.loadData(1)
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            child.segment = 2
            child.loadData(1)
        }
    }

    
    
    @IBAction func doneAdding(sender: AnyObject) {
        var storyboard = UIStoryboard(name: "Messages", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("MessageDetail") as MessagesViewController
        controller.convo = self.convo
        self.presentViewController(controller, animated: true, completion: nil)
    
    }
    
    @IBOutlet weak var message: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var child = self.childViewControllers[0] as FriendCollectionViewController
        self.segmentedControl.selectedSegmentIndex = 0
        child.segment = 1
        child.loadData(1)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        var child = self.childViewControllers[0] as FriendCollectionViewController
        if(child.segment == 2){
            if searchBar.text.isEmpty{
                child.isSearching = false
                child.collectionView?.reloadData()
            } else {
                child.isSearching = true
                child.filteredUsers.removeAllObjects()
                for var index = 0; index < child.users.count; index++
                {
                    var currentUser = child.users.objectAtIndex(index) as PFObject
                    var currentString = currentUser.objectForKey("username") as String
                    if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                        child.filteredUsers.addObject(currentUser)
                    }
                }
                child.collectionView?.reloadData()
            }
        }
        else if(child.segment == 1){
            if searchBar.text.isEmpty{
                child.isSearching = false
                child.collectionView?.reloadData()
            } else {
                child.isSearching = true
                child.filteredUsers.removeAllObjects()
                for var index = 0; index < child.users.count; index++
                {
                    var currentUser = child.users.objectAtIndex(index) as PFObject
                    var currentString = currentUser.objectForKey("topic") as String
                    if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                        child.filteredUsers.addObject(currentUser)
                    }
                }
                child.collectionView?.reloadData()
            }

        }
    }

}