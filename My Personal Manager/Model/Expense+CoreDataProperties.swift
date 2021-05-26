//
//  Expense+CoreDataProperties.swift
//  My Personal Manager
//
//  Created by Thinura Laksara on 2021-05-27.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var endDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var occurrence: Int64
    @NSManaged public var reminder: Bool
    @NSManaged public var startDate: Date?
    @NSManaged public var eventId: String?
    @NSManaged public var reminderId: String?
    @NSManaged public var expenseCategory: Category?

}

extension Expense : Identifiable {

}
