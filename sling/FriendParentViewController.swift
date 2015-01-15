//
//  FriendParentViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/7/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class FriendParentViewController : UIViewController, UISearchBarDelegate{
    

    var convo : Conversation = Conversation(sender: PFUser.currentUser())
    var messageText : String = ""
    
    @IBAction func doneAdding(sender: AnyObject) {
        println("here")
        var storyboard = UIStoryboard(name: "Messages", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("MessageDetail") as MessagesViewController
        controller.convo = self.convo
        self.presentViewController(controller, animated: true, completion: nil)
    
    }
    
    @IBOutlet weak var message: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.message.text = "\nMessage to send: \n \""+self.messageText+"\""
    }
    @IBAction func send(sender: AnyObject) {
        //var messageText:String        = postText.text
        var child = self.childViewControllers[0] as FriendCollectionViewController
        var message:PFObject           = PFObject(className: "Message")
        message["text"] = self.messageText;
        message["inConvo"] = self.convo.convo as PFObject
        message["sender"] = PFUser.currentUser()
        self.convo.save()
        message.saveInBackgroundWithTarget(nil, selector: nil)
    
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
                var currentString = currentUser.objectForKey("username") as String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    child.filteredUsers.addObject(currentUser)
                }
            }
            child.collectionView?.reloadData()
        }
    }

    
    /*
    func search(searchText: String){
        var child = self.childViewControllers[0] as FriendCollectionViewController
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
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.search(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.search(self.searchDisplayController!.searchBar.text)
        return true
    }
    */
    
}