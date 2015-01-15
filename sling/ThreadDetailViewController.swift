//
//  ThreadDetailViewController.swift
//  sling
//
//  Created by Avi Chad-Friedman on 1/8/15.
//  Copyright (c) 2015 Avi Chad-Friedman. All rights reserved.
//

import Foundation
class ThreadDetailViewController : JSQMessagesViewController {
    
    //var messages = [Message]()
    var messageArray : NSMutableArray = NSMutableArray()
    // var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleGreenColor())
    var batchMessages = true
    var thread : PFObject = PFObject(className: "Thread")
    var timeLineData : NSMutableArray = NSMutableArray()
    
    func loadData(order: Int){
        println("loading messages")
        timeLineData.removeAllObjects()
        var findTimeLineData:PFQuery = PFQuery(className: "Reply")
        if(order == 0){
            findTimeLineData.orderByAscending("createdAt")
        }
        // Filtering questions to only see those posted by current user
        var currentUser = PFUser.currentUser()
        
        findTimeLineData.whereKey("inThread", equalTo: self.thread)
        findTimeLineData.findObjectsInBackgroundWithBlock{
            (objects:[AnyObject]!, error:NSError!)->Void in
            if !(error != nil){
                var i = 0
                for object in objects{
                    let pdf = object as PFObject
                    let text = pdf.objectForKey("text") as String
                    let sender = pdf["sender"].fetchIfNeeded() as PFUser
                    //self.messages[i] = Message(text: text, sender: sender)
                    self.messageArray.addObject(Reply(text: text, sender: sender))
                    i++
                    //self.timeLineData.addObject(pdf)
                }
            }
            self.collectionView?.reloadData()
        }
        
        
    }
    func sortByScore(){
        println("sortByScore called")
    }
    @IBAction func postQuestion(sender: AnyObject) {
        
    }
    
    func sendMessage(var text: String!, var sender: String!) {
        //println("sendMessage called")
        //let message = Message(text: text, sender: sender)
        var reply:PFObject = PFObject(className: "Reply")
        reply["text"] = text
        reply["inThread"] = self.thread as PFObject
        reply["sender"] = PFUser.currentUser()
        reply["score"] = 0
        self.thread.save()
        reply.saveInBackgroundWithTarget(nil, selector: nil)
        self.appendMessage(text, sender: PFUser.currentUser())
        self.loadData(0)
    }
    
    func appendMessage(text: String!, sender: PFUser!) {
        println("tempSendMessage called")
        let message = Reply(text: text, sender: sender)
        messageArray.addObject(message)
    }
    
    override func viewDidLoad() {
        //println("viewDidLoad called")
        super.viewDidLoad()
        self.title = self.thread.objectForKey("topic") as? String
        if(PFUser.currentUser() != nil) {
            self.loadData(0)
        }
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        
        sender = (sender != nil) ? sender : "Anonymous"
        
        
        
    }

    
    override func viewDidAppear(animated: Bool) {
        //println("viewDidDisappear called")
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        //println("viewWillDisappear called")
        super.viewWillDisappear(animated)
        
    }
    
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        println("rMessagePressed called")
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        println("didPressSendButton called")
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender)
        
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        //println("collectionView 1")
        //let message = Message(text: text, sender: sender)
        // self.append(message)
        //return messages[indexPath.item]
        return messageArray.objectAtIndex(indexPath.item) as Reply
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        //println("collectionView 2")
        //let message = messages[indexPath.item]
        let message = messageArray.objectAtIndex(indexPath.item) as Reply
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        if message.sender() == currentUser {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //println("collectionView 3")
        return messageArray.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //println("collectionView 4")
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        //let message = messages[indexPath.item]
        let reply = messageArray.objectAtIndex(indexPath.item) as Reply
        let currentUser = PFUser.currentUser().objectForKey("username") as String
        if reply.sender() == currentUser {
            println(sender)
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    override func collectionView(collectionView: UICollectionView, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath) -> UIImageView? {
        return nil
    }
    /*
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        //println("collectionView 5")
        // let message = messages[indexPath.item];
        let message = messageArray.objectAtIndex(indexPath.item) as Message
        if message.sender() == sender {
            return nil;
        }
        
        if indexPath.item > 0 {
            //let previousMessage = messages[indexPath.item - 1];
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as Message;
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:message.sender())
    }
    */
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        var description : String = "Score: "
        
        let reply = messageArray.objectAtIndex(indexPath.item) as Reply
        /*
        if message.sender() == sender {
            return nil;
        }
        
        if indexPath.item > 0 {
            let previousMessage = messageArray.objectAtIndex(indexPath.item-1) as Message;
            if previousMessage.sender() == message.sender() {
                return nil;
            }
        }
        */
        description += reply.stringScore()
        return NSAttributedString(string: description)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}
