//
//  User.swift
//  QSCMobileV3
//
//  Created by 孙耀珠 on 2015-11-27.
//  Copyright © 2015年 QSC Tech. All rights reserved.
//

import Foundation
import CoreData


class User: NSManagedObject {

    @NSManaged var sid: String?
    @NSManaged var course: NSSet?
    @NSManaged var exam: NSSet?
    @NSManaged var score: NSSet?
    @NSManaged var semesterScore: NSSet?
    @NSManaged var statistics: NSSet?
    
    @NSManaged func addCourseObject(value: Course)
    @NSManaged func removeCourseObject(value: Course)
    @NSManaged func addExamObject(value: Exam)
    @NSManaged func removeExamObject(value: Exam)
    @NSManaged func addScoreObject(value: Score)
    @NSManaged func removeScoreObject(value: Score)
    @NSManaged func addSemesterScoreObject(value: SemesterScore)
    @NSManaged func removeSemesterScoreObject(value: SemesterScore)
    @NSManaged func addStatisticsObject(value: Statistics)
    @NSManaged func removeStatisticsObject(value: Statistics)

}
