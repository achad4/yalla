//
//  ThreadFeedViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/5/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadFeedViewController : UITableViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    var threads : NSMutableArray = NSMutableArray()
    var filteredThreads : NSMutableArray = NSMutableArray()
    var isSearching : Bool!
    override func viewDidLoad(){
        isSearching = false
        super.viewDidLoad()
        if(PFUser.currentUser() != nil){
            self.loadData(1)
        }
        
    }
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if(segue.identifier == "to_thread_detail"){
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as ThreadCell
            let parent = segue.destinationViewController as ThreadDetailViewController
            parent.thread = cell.thread
        }
        
    }
    

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        var upVote = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Upvote" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as ThreadCell
            let thread : PFObject = cell.thread
            if(thread["score"] != nil){
                var score : Int = thread["score"] as Int
                score = score + 1
                thread["score"] = score
            }
            else{
                thread["score"] = 1
            }
            thread.saveInBackgroundWithTarget(nil, selector: nil)
            /*
            let shareMenu = UIAlertController(title: nil, message: "Share using", preferredStyle: .ActionSheet)
            
            let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: nil)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
            
            shareMenu.addAction(twitterAction)
            shareMenu.addAction(cancelAction)
            
            
            self.presentViewController(shareMenu, animated: true, completion: nil)
            */
        })
        
        var downVote = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Downvote" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as ThreadCell
            let thread : PFObject = cell.thread
            if(thread["score"] != nil){
                var score : Int = thread["score"] as Int
                score = score - 1
                thread["score"] = score
            }
            else{
                thread["score"] = -1
            }
            thread.saveInBackgroundWithTarget(nil, selector: nil)
        })
        return [upVote, downVote]
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    func loadData(order: Int){
        self.threads.removeAllObjects()
        var findTimeLineData:PFQuery = PFQuery(className: "Thread")
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
        
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    self.threads.addObject(pdf)
                }
                
                self.tableView.reloadData()
            }
        }
        
        
        
        
    }
   
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text.isEmpty{
            isSearching = false
            self.tableView.reloadData()
        } else {
            isSearching = true
            filteredThreads.removeAllObjects()
            for var index = 0; index < threads.count; index++
            {
                var currentThread = threads.objectAtIndex(index) as PFObject
                var currentString = currentThread.objectForKey("topic") as String
                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
                    filteredThreads.addObject(currentThread)
                }
            }
            self.tableView.reloadData()
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearching == true){
            return self.filteredThreads.count
        }
        return self.threads.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as ThreadCell
        var thread:PFObject = self.threads.objectAtIndex(indexPath.row) as PFObject
        if(isSearching == true){
            thread = self.filteredThreads.objectAtIndex(indexPath.row) as PFObject
        }
        let date = thread.createdAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as NSString
        cell.topic.text = thread.objectForKey("topic") as? String
        cell.date.text = stringDate as NSString
        cell.thread = thread
        println(thread.objectId)
        var query:PFQuery = PFQuery(className: "Thread")
        var threadsFollowing : NSMutableArray = NSMutableArray()
        query.whereKey("follower", equalTo: PFUser.currentUser())
        var count : Int = 0;
        query.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    count++
                    let pdf = object as PFObject
                    threadsFollowing.addObject(pdf)
                }
            }
            var followRelation : PFRelation = thread.relationForKey("follower")
            if(count == 0){
                println("User is not a follower")
                cell.follow.setTitle("Follow", forState: UIControlState.Normal)
                //followRelation.addObject(PFUser.currentUser())
                
            }
            else{
                println("User is a follower")
                cell.follow.setTitle("Unfollow", forState: UIControlState.Normal)
                //followRelation.removeObject(PFUser.currentUser())
                
            }
        }

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

}