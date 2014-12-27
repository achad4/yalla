//
//  QuestionFeedTableView.swift
//  sling
//
//  Created by Avi Chad-Friedman on 10/16/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class QuestionFeedTableView : UITableViewController, UITableViewDelegate, UITableViewDataSource{
    //var managedContext : NSManagedObjectContext = NSManagedObjectContext()
    var timeLineData : NSMutableArray = NSMutableArray()
    

    @IBAction func logout(sender: AnyObject) {
        if(PFUser.currentUser() != nil){
            PFUser.logOut()
            viewDidAppear(true)
        }
    }

    
    override func viewDidAppear(animated: Bool) {
        //self.loadData()
        if ((PFUser.currentUser()) == nil) {
            
            //Create an UIAlertController if there isn't an user
            var loginAlert:UIAlertController = UIAlertController(title: "Sign Up/ Log In", message: "Please sign up or log in", preferredStyle: UIAlertControllerStyle.Alert)
            
            //Add a textView in the Log In Alert for the username
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Username"
            })
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Email"
            })
            
            //Add a textView in the Log In Alert for the password
            loginAlert.addTextFieldWithConfigurationHandler({
                textfield in
                textfield.placeholder = "Your Password"
                textfield.secureTextEntry = true
            })
            
            //Place the user-input into an array and set the username and password accordingly for Log In
            loginAlert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let emailTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(2) as UITextField
                
                PFUser.logInWithUsernameInBackground(usernameTextfield.text, password: passwordTextfield.text){
                    (user:PFUser!, error:NSError!)->Void in
                    if ((user) != nil){
                        println("Login successfull")
                    }else{
                        println("Login failed")
                    }
                    
                }
                
            }))
            
            //Place the user-input into an array and set the username and password accordingly for Sign Up
            loginAlert.addAction(UIAlertAction(title: "Sign Up", style: UIAlertActionStyle.Default, handler: {
                alertAction in
                let textFields:NSArray = loginAlert.textFields! as NSArray
                let usernameTextfield:UITextField = textFields.objectAtIndex(0) as UITextField
                let emailTextfield:UITextField = textFields.objectAtIndex(1) as UITextField
                let passwordTextfield:UITextField = textFields.objectAtIndex(2) as UITextField
                
                var slinger:PFUser = PFUser()
                slinger.username = usernameTextfield.text
                slinger.email = emailTextfield.text
                slinger.password = passwordTextfield.text
                
                slinger.signUpInBackgroundWithBlock{
                    (success:Bool!, error:NSError!)->Void in
                    if !(error != nil){
                        println("Sign Up successfull")
                    }else{
                        let errorString = error.userInfo!["error"] as NSString
                        println(errorString)
                    }
                    
                    
                }
            }))
            self.presentViewController(loginAlert, animated: true, completion: nil)
        
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        self.loadData(1)
        //self.tableView.reloadData()
    }
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        // Return the number of sections.
        return 1
    }
    func loadData(order: Int){
        
        //let filterPredicate = NSPredicate(format:"score = 0")
        var findTimeLineData:PFQuery = PFQuery(className: "Message")
        if(order == 0){
            findTimeLineData.orderByDescending("createdAt")
        }
        //else if(order == 1){
        //    findTimeLineData.orderByDescending("score")
        //}
        
        // Filtering questions to only see those posted by current user
        var currentUser = PFUser.currentUser();
        
        //findTimeLineData.whereKey("recieved", equalTo: PFUser.currentUser())
        
        // Option to limit number of results from query (if needed)
        //findTimeLineData.limit = 3
      
        
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                for object in objects{
                    let pdf = object as PFObject
                    self.timeLineData.addObject(pdf)
                }
                //let array:NSArray = self.timeLineData.reverseObjectEnumerator().allObjects
                //self.timeLineData = array as NSMutableArray
                
                self.tableView.reloadData()
            }
        }
    }
    func sortByScore(){
        
    }
    @IBAction func postQuestion(sender: AnyObject) {
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeLineData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as TableCell
        //let question:PFObject = self.timeLineData.objectAtIndex(indexPath.row) as PFObject
        let message:PFObject = self.timeLineData.objectAtIndex(indexPath.row) as PFObject
        cell.questionText.text = " " as NSString
        
        if(message.objectForKey("text") != nil){
            cell.questionText.text = message.objectForKey("text") as NSString
        }
        //let score = question.objectForKey("score") as NSNumber
        //let stringScore = score.stringValue
        //cell.score.text = stringScore
        let date = message.createdAt as NSDate
        let stringDate = NSDateFormatter.localizedStringFromDate(date, dateStyle: .MediumStyle, timeStyle: .ShortStyle) as NSString
        println(stringDate)
        cell.timePosted.text = stringDate as NSString
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    /*
    DISCARDED
    func readData()->Array<Question>{
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    var err : NSErrorPointer = NSErrorPointer()
    var fetchRequest : NSFetchRequest = NSFetchRequest(entityName: "Question")
    var questions = managedContext.executeFetchRequest(fetchRequest, error: err)
    return questions! as  Array<Question>
    }
    
    func addQuestion(text:String){
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    let entity =  NSEntityDescription.entityForName("Question", inManagedObjectContext:managedContext)
    let question = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
    question.setValue(text, forKey: "text")
    question.setValue(0, forKey: "score")
    question.setValue(NSDate(), forKey: "timeCreated")
    questions.append(question)
    //self.tableView.reloadData()
    }
    */
}
