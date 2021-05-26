//
//  StoreData.swift
//  My Personal Manager
//
//  Created by Thinura Laksara on 2021-05-11.
//

import Foundation
import CoreData
import UIKit

struct StoreDataCategory{
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //Data for the table
    var category:[Category]?
    
    // Create a new category
    public func createCategory(name: String, note: String, monthlyBudget: Double, theme: Int, selectedCount: Int) -> Bool {
        let category = Category(context: context)
        category.name = name
        category.note = note
        category.monthlyBudget = monthlyBudget
        category.theme = Int64(theme)
        category.selectedCount = Int64(selectedCount)
        
        // Save the data
        do{
            try context.save()
            return true
        }
        catch{
            print("Error while saving")
        }
        return false
    }
    
    // fetch an category by name
    func getCategoryName() -> Category {
        var category: Category? = nil
        
        return category!
    }
    
    // fetch all categories
    func getAllCategories() -> [Category]{
        var allCategory: [Category]? = nil
        do{
            let request = Category.fetchRequest() as NSFetchRequest<Category>
            allCategory = try context.fetch(request) as [Category]
            if allCategory?.count ?? 0 > 0 {
                return allCategory!
            }
        }catch{
            print("Error while getting the data from core data")
        }
        return []
    }
    
    // Update an category
    func editCategory()->Category {
        var category: Category? = nil
        
        return category!
    }
    
    // Delete an category
    func deleteCategory() ->Bool {
        var category: Category? = nil
        
        return false
    }
}
