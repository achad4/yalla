//
//  Conversation.swift
//  sling
//
//  Created by Evan O'Connor on 12/23/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import CoreData
@objc(Conversation)
class Conversation : NSManagedObject {
    
    @NSManaged var messageCount: Int
    @NSManaged var messages: NSSet
    @NSManaged var participants: NSSet
    
}
/*
func addData(){
    var appDel: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var context: NSManagedObjectContext = appDel.managedObjectContext!
    
    var conversationEntity = NSEntityDescription.entityForName("Conversation", inManagedObjectContext: context)
    var newConversation = Conversation(entity: conversationEntity, insertIntoManagedObjectContext: context)
    newFather.messageCount = 0
    
    
    var childEntity = NSEntityDescription.entityForName("Child", inManagedObjectContext: context)
    var child1 = Child(entity: childEntity, insertIntoManagedObjectContext: context)
    child1.name = "child1"
    var child2 = Child(entity: childEntity, insertIntoManagedObjectContext: context)
    child2.name = "child2"
    
    //How to map these 2 childs to father? Need help in code here!
    
    context.save(nil)
    
} */