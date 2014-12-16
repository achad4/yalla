//
//  Question.swift
//  sling
//
//  Created by Avi Chad-Friedman and Evan on 10/16/14.
//  Copyright (c) 2014 Avi Chad-Friedman. All rights reserved.
//

import Foundation
import CoreData
@objc(Question)
class Question : NSManagedObject {
    @NSManaged var text : String
    @NSManaged var score : Int
    @NSManaged var timeCreated : NSDate
}
