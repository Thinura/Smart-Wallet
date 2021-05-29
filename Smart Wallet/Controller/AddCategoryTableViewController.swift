//
//  CategoryTableViewController.swift
//  Smart Wallet
//
//  Created by Thinura Laksara on 2021-05-10.
//

import Foundation
import UIKit
import CoreData
import EventKit

protocol AddCategoryTableViewControllerDelegate {
    func completeSaveCategory()
}

class AddCategoryTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    
    var selectedTheme: UIButton? = nil
    var selectedThemeTag: Int = 0
    var selectedCount: Int64 = 1
    
    var addCategoryTableViewDelegate: AddCategoryTableViewControllerDelegate?
    
    // Navigation buttons
    @IBOutlet weak var addCategoryButton: UIBarButtonItem!
    
    // Category details input fields
    @IBOutlet weak var categoryNameInputField: UITextField!
    @IBOutlet weak var categoryBudgetInputField: UITextField!
    
    // Colour theme buttons
    @IBOutlet weak var firstThemeButton: UIButton!
    @IBOutlet weak var secondThemeButton: UIButton!
    @IBOutlet weak var thirdThemeButton: UIButton!
    @IBOutlet weak var fourthThemeButton: UIButton!
    @IBOutlet weak var fifthThemeButton: UIButton!
    @IBOutlet weak var sixthThemeButton: UIButton!
    @IBOutlet weak var seventhThemeButton: UIButton!
    var themeArray: [UIButton] {
        return [firstThemeButton, secondThemeButton, thirdThemeButton, fourthThemeButton, fifthThemeButton, sixthThemeButton, seventhThemeButton]
    }
    
    // Category notes input fields
    @IBOutlet weak var categoryNotesTextInputField: UITextView!
    
    var categories: [NSManagedObject] = []
    var datePickerVisible: Bool = false
    var editCategoryMode: Bool = false
    let currentDate = Date();
    
    let formatter: Formatter = Formatter()
    
    // Setting the category
    var editingCategory: Category? {
        didSet {
            // Update the view.
            editCategoryMode = true

            configureEditCategoryView()

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        predefineCategory()
        configureEditCategoryView()
        
        // Disable add category button
        checkAddButton()
        
    }
    
    
    func configureEditCategoryView() {
        //print("editCategoryMode \(editCategoryMode)")
        if editCategoryMode{
            self.navigationItem.title = "Edit Project"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        if let category = editingCategory {
            print("category.monthlyBudget \(category.monthlyBudget)")
            if let categoryName = categoryNameInputField{
                categoryName.text = category.name
            }
            if let categoryBudget = categoryBudgetInputField{
                categoryBudget.text = String(category.monthlyBudget)
            }
            if let button = firstThemeButton {
                self.selectedThemeTag = Int(editingCategory?.theme ?? 0)
                    updateButtonView(tag: Int(editingCategory?.theme ?? 0))
            }
            
            if let categoryNotes = categoryNotesTextInputField{
                categoryNotes.text = editingCategory?.note
            }
            
            self.selectedCount = editingCategory?.selectedCount ?? 1
            
        }
    }
    
    
    // check the status and configure the necessary changes
    func predefineCategory() {
        if !editCategoryMode{
            // Settings the placeholder for notes inputField
            categoryNotesTextInputField.delegate = self
            categoryNotesTextInputField.text = "Notes"
            categoryNotesTextInputField.textColor = UIColor.lightGray
        }
    }
    
    // Handles the add category button state
    func checkAddButton() {
        if validateInputFields() {
            addCategoryButton.isEnabled = true;
        } else {
            addCategoryButton.isEnabled = false;
        }
    }
    
    // Check if the required fields are empty or not
    func validateInputFields() -> Bool {
        if !(categoryNameInputField.text?.isEmpty)! &&
            !(categoryBudgetInputField.text?.isEmpty)! &&
            !(categoryNotesTextInputField.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    @IBAction func handleThemeSelector(_ sender: UIButton){
        checkWhichThemeSelected(sender: sender)
        checkAddButton()
        
    }
    
    /**
     This function which theme is selected
     */
    func checkWhichThemeSelected(sender: UIButton) {
        self.selectedTheme = getThemeByTag(tag: sender.tag, themeArray: themeArray)
        self.selectedThemeTag = sender.tag
        updateButtonView(tag: sender.tag)
    }
    
    func updateButtonView(tag:Int){
        for index in 0...themeArray.count-1{
            if (index == tag){
                themeArray[index].layer.borderWidth = 2
            }else{
                themeArray[index].layer.borderWidth = 0
            }
        }
    }
    
    func getThemeByTag(tag: Int, themeArray: [UIButton]) -> UIButton {
        var theme: UIButton = themeArray[0]
        for index in 0...themeArray.count-1{
            if (index == tag){
                theme = themeArray[index]
                return theme
            }
        }
        return theme
    }
    
    // Cancel the category creation
    @IBAction func handleCancelButtonClick(_ sender: UIBarButtonItem) {
        dismissPopOver()
    }
    
    @IBAction func handleInputValue(_ sender: UITextField) {
        checkAddButton()
        
    }
    
    
    @IBAction func handleBudgetInputValue(_ sender: UITextField) {
        checkAddButton()
        if sender.text != nil{
            let input = Int(sender.text!)
            if input == nil {
                let alert = UIAlertController(title: "Error", message: "Please enter only numbers.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in sender.text = ""}))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    // Add the category creation
    @IBAction func handleAddButtonClick(_ sender: UIBarButtonItem) {
        if validateInputFields(){
            
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedContext)!
            var category = NSManagedObject()
            if editCategoryMode {
                category = (editingCategory as? Category)!
            }else{
                category = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            
            category.setValue(categoryNameInputField.text!, forKey: "name")
            category.setValue(categoryNotesTextInputField.text!, forKey: "note")
            category.setValue(Double(categoryBudgetInputField.text!), forKey: "monthlyBudget")
            category.setValue(Int64(self.selectedThemeTag), forKey: "theme")
            category.setValue(self.selectedCount, forKey: "selectedCount")

            //print(category)
            do{
                // Save to Core data
                try managedContext.save()
                self.addCategoryTableViewDelegate?.completeSaveCategory()
                categories.append(category)
            }catch _ as NSError{
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the project.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
        }else{
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissPopOver()
    }
    
    // Dismiss Popover
    func dismissPopOver() {
        dismiss(animated: true, completion: nil)
        //Change the target to 13 ios
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
}

extension AddCategoryTableViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            categoryNameInputField.becomeFirstResponder()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            categoryNotesTextInputField.becomeFirstResponder()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}


extension AddCategoryTableViewController: AddCategoryTableViewControllerDelegate{
    func completeSaveCategory() {}
    
}
