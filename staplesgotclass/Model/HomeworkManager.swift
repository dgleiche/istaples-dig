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
    
    //Keyed by periodNumber
    var homework = [Int: [Homework]]()
    
    weak var delegate: HomeworkManagerDelegate?
    
    private init(delegate: HomeworkManagerDelegate?) {
        self.delegate = delegate
        super.init()
        HomeworkManager.sharedInstance = self
        self.loadSavedData()
    }
    
    class func setup() {
        sharedInstance = HomeworkManager(delegate: nil)
    }
    
    class func setup(delegate delegate: HomeworkManagerDelegate?) {
        sharedInstance = HomeworkManager(delegate: delegate)
    }
    
    class func destroy() {
        sharedInstance = nil
    }
    
    class func setHomework(forPeriod periodNumber: Int, assignment: String, dueDate: NSDate) {
        let homeworkObject = Homework()
        homeworkObject.assignment = assignment
        homeworkObject.periodNumber = periodNumber
        homeworkObject.dueDate = dueDate
        
        try! realm.write {
            self.realm.add(homeworkObject)
        }
    }
    
    class func update(homework homework: Homework, assignment: String, dueDate: NSDate) {
        try! realm.write {
            homework.assignment = assignment
            homework.dueDate = dueDate
        }
    }
    
    class func deleteHomework(homework: Homework) {
        try! HomeworkManager.realm.write {
            HomeworkManager.realm.delete(homework)
        }
    }
    
    func loadSavedData() {
        let homeworkObjects = Array(HomeworkManager.realm.objects(Homework.self))
        
        homework = [Int: [Homework]]()
        //Associate each homework object with a course in the class dictionary
        for homeworkObject in homeworkObjects {
            if homework[homeworkObject.periodNumber] == nil {
                homework[homeworkObject.periodNumber] = [Homework]()
            }
            
            homework[homeworkObject.periodNumber]!.append(homeworkObject)
        }
        
        delegate?.homeworkDidLoad()
    }
    
    func getHomework(forPeriod periodNumber: Int) -> [Homework]? {
        return homework[periodNumber]
    }
}