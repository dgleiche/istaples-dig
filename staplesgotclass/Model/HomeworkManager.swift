//
//  HomeworkManager.swift
//  staplesgotclass
//
//  Created by Dylan on 8/24/16.
//  Copyright © 2016 Dylan Gleicher. All rights reserved.
//

import Foundation
import RealmSwift

protocol HomeworkManagerDelegate: class {
    func homeworkDidLoad()
}

class HomeworkManager: NSObject {
    static var sharedInstance: HomeworkManager?
    
    static let realm = try! Realm()
    
    //Keyed by periodID
    var homework = [Int: [Homework]]()
    
    weak var delegate: HomeworkManagerDelegate!
    
    private init(delegate: HomeworkManagerDelegate) {
        self.delegate = delegate
        
        super.init()
    }
    
    class func setup(delegate: HomeworkManagerDelegate) {
        sharedInstance = HomeworkManager(delegate: delegate)
    }
    
    class func destroy() {
        sharedInstance = nil
    }
    
    class func setHomework(forPeriod periodID: Int, assignment: String, dueDate: NSDate) {
        let homeworkObject = Homework()
        homeworkObject.assignment = assignment
        homeworkObject.periodID = periodID
        homeworkObject.dueDate = dueDate
        
        try! realm.write {
            self.realm.add(homeworkObject)
        }
    }
    
    class func deleteHomework(forPeriod periodID: Int, assignment: String, dueDate: NSDate) {
        let homeworkObject = Homework()
        homeworkObject.assignment = assignment
        homeworkObject.periodID = periodID
        homeworkObject.dueDate = dueDate
        
        try! HomeworkManager.realm.write {
            HomeworkManager.realm.delete(homeworkObject)
        }
    }
    
    func loadSavedData() {
        let homeworkObjects = Array(HomeworkManager.realm.objects(Homework.self))
        
        homework = [Int: [Homework]]()
        //Associate each homework object with a course in the class dictionary
        for homeworkObject in homeworkObjects {
            if homework[homeworkObject.periodID] == nil {
                homework[homeworkObject.periodID] = [Homework]()
            }
            
            homework[homeworkObject.periodID]!.append(homeworkObject)
        }
        
        delegate.homeworkDidLoad()
    }
    
    func getHomework(forPeriod periodID: Int) -> [Homework]? {
        return homework[periodID]
    }
}