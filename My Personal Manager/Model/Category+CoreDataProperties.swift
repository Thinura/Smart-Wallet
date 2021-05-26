//
//  Category+CoreDataProperties.swift
//  My Personal Manager
//
//  Created by Thinura Laksara on 2021-05-27.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var monthlyBudget: Double
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var selectedCount: Int64
    @NSManaged public var theme: Int64
    @NSManaged public var expenses: NSSet?

}

// MARK: Generated accessors for expenses
extension Category {

    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: Expense)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: Expense)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}

extension Category : Identifiable {

}
