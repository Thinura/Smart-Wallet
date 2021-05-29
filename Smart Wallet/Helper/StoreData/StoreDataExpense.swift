//
//  StoreDataExpense.swift
//  Smart Wallet
//
//  Created by Thinura Laksara on 2021-05-11.
//

import Foundation
import CoreData
import UIKit

public class StoreDataExpense{
    
    //Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var expenses: [Expense]?
    
    // Create a new expense
    func createExpense() -> Expense {
        var expense: Expense? = nil
        
        return expense!
    }
    
    // fetch an expense by name
    func getExpenseName() -> Expense {
        var expense: Expense? = nil
        
        return expense!
    }
    
    // fetch all expenses
    func getAllExpenses() -> [Expense]{
        var allExpense: [Expense]? = nil
        
        return allExpense ?? []
    }
    
    // Update an expense
    func editExpense()->Expense {
        var expense: Expense? = nil
        
        return expense!
    }
    
    // Delete an expense
    func deleteExpense() ->Bool {
        var expense: Expense? = nil
        
        return false
    }
}
