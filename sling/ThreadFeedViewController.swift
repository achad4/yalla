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
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func controlSelected(sender: UISegmentedControl) {
        
        if (segmentedControl.selectedSegmentIndex == 0) {
            self.loadData(0)
            self.tableView.reloadData()
        }
        else if (segmentedControl.selectedSegmentIndex == 1) {
            self.loadData(1)
            self.tableView.reloadData()
        }
        else {
            self.loadData(2)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad(){
        isSearching = false
        super.viewDidLoad()
        if(PFUser.currentUser() != nil){
            if(segmentedControl.selectedSegmentIndex == 0) {
                self.loadData(0)
            
            } else if(segmentedControl.selectedSegmentIndex == 1) {
                self.loadData(1)
            }
            else {
                self.loadData(2)
            }
        }
        
        let recognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeft:")
        recognizer.direction = .Right
        self.view .addGestureRecognizer(recognizer)
        
    }
    
    @IBAction func swipeLeft(recognizer : UISwipeGestureRecognizer) {
        
        var storyboard = UIStoryboard(name: "Messages", bundle: nil)
        var controller = storyboard.instantiateViewControllerWithIdentifier("InitialView") as UIViewController
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    
    override func prepareForSegue(segue: (UIStoryboardSegue!), sender: AnyObject!) {
        if(segue.identifier == "to_thread_detail"){
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as ThreadCell
            let parent = segue.destinationViewController as ThreadDetailViewController
            parent.thread = cell.thread
            parent.newThread = false
        }
        else if(segue.identifier == "new_thread_segue"){
            var topic:String        = ""
            var thread:Thread = Thread(sender: PFUser.currentUser(), topic: topic)
            thread.save()
            let parent = segue.destinationViewController as ThreadDetailViewController
            parent.thread = thread.thread
            parent.newThread = true
            println("yuppp")
        }
        
    }
    

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]?  {
        var upVote = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Upvote" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let cell = self.tableView.cellForRowAtIndexPath(indexPath!) as ThreadCell
            let thread : PFObject = cell.thread
            
            // Perform a query for threads current user has downvoted
            var hasDownvoted = false
            var downvoteQuery:PFQuery = PFQuery(className: "Thread")
            
            downvoteQuery.whereKey("downvoted", equalTo: PFUser.currentUser())
            downvoteQuery.findObjectsInBackgroundWithBlock{
                (objects:[AnyObject]!, error:NSError!)->Void in
                if !(error != nil){
                    for object in objects{
                        if(object.objectId == thread.objectId) {
                            hasDownvoted = true
                        }
                    }
                }
            }
            
            // If user has downvoted, allow them to change to an upvote (net +2 points)
            var downvoteRelation : PFRelation = thread.relationForKey("downvoted")
            var upvoteRelation : PFRelation = thread.relationForKey("upvoted")
            if(hasDownvoted == true) {
                println("changing vote from downvote to upvote" )
                downvoteRelation.removeObject(PFUser.currentUser())
                upvoteRelation.addObject(PFUser.currentUser())
                var score : Int = thread["score"] as Int
                thread["score"] = score + 2
                thread.saveInBackgroundWithTarget(nil, selector: nil)
                println(score+2)
            }
            
            // User has not downvoted, so check if they have upvoted
            else {
                
                var upvoteQuery:PFQuery = PFQuery(className: "Thread")
                upvoteQuery.whereKey("upvoted", equalTo: PFUser.currentUser())
                upvoteQuery.findObjectsInBackgroundWithBlock{
                    (objects:[AnyObject]!, error:NSError!)->Void in
                    if !(error != nil){
                        var hasUpvoted = false
                        for object in objects{
                            if(object.objectId == thread.objectId) {
                                hasUpvoted = true
                            }
                        }
                        // Allow user to upvote for the first time
                        if(hasUpvoted == false) {
                            println("upvoting for the first time" )
                            var upvoteRelation : PFRelation = thread.relationForKey("upvoted")
                            upvoteRelation.addObject(PFUser.currentUser())
                            var score2 : Int = thread["score"] as Int
                            thread["score"] = score2 + 1
                            thread.saveInBackgroundWithTarget(nil, selector: nil)
                            println(score2+1)
                        // Alert user that they have already upvoted
                        } else {
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Voting failed!"
                            alertView.message = "You have already upvoted this thread"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                        
                        }
                    }
                
                }
            }
           
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
            
            // Perform a query for threads current user has upvoted
            var hasUpvoted = false
            var upvoteQuery:PFQuery = PFQuery(className: "Thread")
            upvoteQuery.whereKey("upvoted", equalTo: PFUser.currentUser())
            upvoteQuery.findObjectsInBackgroundWithBlock{
                (objects:[AnyObject]!, error:NSError!)->Void in
                if !(error != nil){
                    for object in objects{
                        if(object.objectId == thread.objectId) {
                            hasUpvoted = true
                            println("UPVOTE")
                        }
                    }
                }
            }
            
            // If user has upvoted, allow them to change to a downvote (net -2 points)
            var upvoteRelation : PFRelation = thread.relationForKey("upvoted")
            var downvoteRelation : PFRelation = thread.relationForKey("downvoted")
            if(hasUpvoted == true) {
                println("changing vote from up to down")
                upvoteRelation.removeObject(PFUser.currentUser())
                downvoteRelation.addObject(PFUser.currentUser())
                var score : Int = thread["score"] as Int
                score = score - 2
                thread["score"] = score
                println(score-2)
                thread.saveInBackgroundWithTarget(nil, selector: nil)
            }
                
            // User has not upvoted, so check if they have downvoted
            else {
                println("else")
                var downvoteQuery:PFQuery = PFQuery(className: "Thread")
                downvoteQuery.whereKey("downvoted", equalTo: PFUser.currentUser())
                downvoteQuery.findObjectsInBackgroundWithBlock{
                    (objects:[AnyObject]!, error:NSError!)->Void in
                    if !(error != nil){
                        var hasDownvoted = false
                        for object in objects{
                            if(object.objectId == thread.objectId) {
                                hasDownvoted = true
                            }
                        }
                        // Allow user to downvote for the first time
                        if(hasDownvoted == false) {
                            println("First time downvote")
                            var downvoteRelation : PFRelation = thread.relationForKey("downvoted")
                            downvoteRelation.addObject(PFUser.currentUser())
                            var score : Int = thread["score"] as Int
                            score = score + 1
                            thread["score"] = score
                            println(score+1)
                            thread.saveInBackgroundWithTarget(nil, selector: nil)
                            
                            // Alert user that they have already downvoted
                        } else {
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Voting failed!"
                            alertView.message = "You have already downvoted this thread"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            
                        }
                    }
                    
                }
            }
        
        
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
        } else if(order == 1){
            findTimeLineData.orderByDescending("score")
        }
        else {
            findTimeLineData.whereKey("follower", equalTo: PFUser.currentUser())
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
                var isFollowing = false
                for object in objects{
                    if(object.objectId == thread.objectId) {
                        isFollowing = true
                    }
                    /*
                    let pdf = object as PFObject
                    threadsFollowing.addObject(pdf)
                    */
                    
                }
                if(isFollowing == true) {
                    cell.follow.setTitle("Unfollow", forState: UIControlState.Normal)
                }
                else {
                    cell.follow.setTitle("Follow", forState: UIControlState.Normal)
                }
            }
        }

        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }

}