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
    
    let realm = try! Realm()
    
    var homework = [Course: [Homework]]()
    
    weak var delegate: HomeworkManagerDelegate!
    
    private init(delegate: HomeworkManagerDelegate) {
        self.delegate = delegate
        super.init()
        HomeworkManager.sharedInstance = self
        self.loadSavedData()
    }
    
    class func setup(delegate: HomeworkManagerDelegate) {
        sharedInstance = HomeworkManager(delegate: delegate)
    }
    
    class func destroy() {
        sharedInstance = nil
    }
    
    func setHomework(forCourse course: Course, assignment: String, dueDate: NSDate) {
        let homeworkObject = Homework()
        homeworkObject.assignment = assignment
        homeworkObject.course = course
        homeworkObject.dueDate = dueDate
        
        try! realm.write {
            self.realm.add(homeworkObject)
        }
    }
    
    func deleteHomework(forCourse course: Course, assignment: String, dueDate: NSDate) {
        let homeworkObject = Homework()
        homeworkObject.assignment = assignment
        homeworkObject.course = course
        homeworkObject.dueDate = dueDate
        
        try! realm.write {
            self.realm.delete(homeworkObject)
        }
    }
    
    func loadSavedData() {
        let homeworkObjects = Array(realm.objects(Homework.self))
        
        homework = [Course: [Homework]]()
        //Associate each homework object with a course in the class dictionary
        for homeworkObject in homeworkObjects {
            if let course = homeworkObject.course {
                if homework[course] == nil {
                    homework[course] = [Homework]()
                }
                
                homework[course]!.append(homeworkObject)
            }
        }
        
        delegate.homeworkDidLoad()
    }
    
    func getHomework(forCourse course: Course) -> [Homework]? {
        return homework[course]
    }
}