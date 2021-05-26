//
//  ExpenseViewController.swift
//  My Personal Manager
//
//  Created by Thinura Laksara on 2021-05-10.
//

import UIKit
import Foundation
import CoreData
import EventKit

protocol AddExpenseViewControllerDelegate {
    func completeSave()
}

class AddExpenseViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UITextViewDelegate {
    
    var expenses: [NSManagedObject] = []
    let dataFormatter: DateFormatter = DateFormatter()
    var startDatePickerVisible  = false
    var dueDatePickerVisible = false
    var expenseProgressPickerVisible = false
    var selectedCategory: Category?
    var editingExpenseMode: Bool = false
    let now = Date()
    var permissionGrantedReminder: Bool = false
    var permissionGrantedCalendar: Bool = false
    
    var totalExpense: Double = 0
    var selectedOccurrence: Int64 = 0
    var calendarReminder: Bool = false
    
    let formatter: Formatter = Formatter()
    let eventStore : EKEventStore = EKEventStore()
    var addExpenseDelegate: AddExpenseViewControllerDelegate?
    
    var isRecurrence = true
    
    var recurrenceFrequency: EKRecurrenceFrequency = .daily
    
    var eventId:String = ""
    
    @IBOutlet weak var addExpenseButton: UIBarButtonItem!
    
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var expenseNotesTextField: UITextView!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var addToCalendarButton: UISwitch!
    @IBOutlet weak var occurrenceSegmentController: UISegmentedControl!
    
    var editingExpense: Expense? {
        didSet{
            // Update the view
            editingExpenseMode = true
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        predefinedExpense()
        
        configureView()
        // Disable add button
        checkAddButton()
    }
    
    func predefinedExpense(){
        if !editingExpenseMode {
            
            expenseNotesTextField.delegate = self
            expenseNotesTextField.text = "Notes"
            expenseNotesTextField.textColor = UIColor.lightGray
            
            // Set end date to one minute ahead of current time
            var time = Date()
            time.addTimeInterval(TimeInterval(60.00))
            endDateLabel.text = formatter.formatDate(time)
            endDatePicker.minimumDate = time
            
        }
    }
    
    func configureView() {
        if editingExpenseMode {
            self.navigationItem.title = "Edit Expense"
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        
        
        if let category = selectedCategory{
            let objects = category.expenses?.allObjects as! [Expense]
            for expense in objects {
                totalExpense += expense.amount
            }
        }
        if let expense = editingExpense{
            if let expenseName = expenseNameTextField{
                expenseName.text = expense.name
            }
            
            if let expenseAmount = expenseAmountTextField{
                expenseAmount.text = String(expense.amount)
            }
            
            if let expenseNotes = expenseNotesTextField{
                expenseNotes.text = expense.note
            }
            
            if let expenseStartDate = startDatePicker{
                expenseStartDate.date = expense.startDate ?? now
            }
            
            if let expenseStartDateLabel = startDateLabel{
                expenseStartDateLabel.text = formatter.formatDate((expense.startDate ?? now))
            }
            
            if let expenseEndDate = endDatePicker{
                expenseEndDate.date = expense.endDate ?? now
            }
            
            if let expenseEndDateLabel = endDateLabel{
                expenseEndDateLabel.text = formatter.formatDate((expense.endDate ?? now))
            }
            
            if let expenseAddCalendar = addToCalendarButton{
                if expense.occurrence == 0 {
                    expenseAddCalendar.isOn = false
                } else{
                    expenseAddCalendar.isOn = true
                }
            }
            
            if let expenseOccurrence = occurrenceSegmentController{
                expenseOccurrence.selectedSegmentIndex = Int(expense.occurrence)
            }
        }
        
    }
    
    // Handles the add category button state
    func checkAddButton() {
        if validateInputFields() {
            addExpenseButton.isEnabled = true;
        } else {
            addExpenseButton.isEnabled = false;
        }
    }
    
    // Check if the required fields are empty or not
    func validateInputFields() -> Bool {
        if !(expenseNameTextField.text?.isEmpty)! &&
            !(expenseAmountTextField.text?.isEmpty)! &&
            !(expenseNotesTextField.text?.isEmpty)! {
            return true
        }
        return false
    }
    
    // Dismiss Popover
    func dismissPopOver() {
        dismiss(animated: true, completion: nil)
        //Change the target to 13 ios
        popoverPresentationController?.delegate?.popoverPresentationControllerDidDismissPopover?(popoverPresentationController!)
    }
    
    
    @IBAction func handleInputValue(_ sender: UITextField) {
        checkAddButton()
    }
    
    @IBAction func handleAmountInputValue(_ sender: UITextField) {
        checkAddButton()
        if sender.text != nil{
            let input = Double(sender.text!)
            if input == nil {
                let alert = UIAlertController(title: "Error", message: "Please enter only numbers.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {_ in sender.text = ""}))
                self.present(alert, animated: true, completion: nil)
            }else{
                if let category = selectedCategory{
                    if let inputAmount =  input{
                        if (category.monthlyBudget <= inputAmount) || (totalExpense + inputAmount > category.monthlyBudget){
                            let alert = UIAlertController(title: "Warning", message: "You are exceeding the budget you have allocated.", preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func handleStartDateChange(_ sender: UIDatePicker) {
        startDateLabel.text = formatter.formatDate(sender.date)
        
        // Set end date minimum to one minute ahead the start date
        let dueDate = sender.date.addingTimeInterval(TimeInterval(60.00))
        endDatePicker.minimumDate = dueDate
        endDateLabel.text = formatter.formatDate(dueDate)
    }
    
    @IBAction func handleEndDateChange(_ sender: UIDatePicker) {
        endDateLabel.text = formatter.formatDate(sender.date)
        // Set start date maximum to one minute before the end date
        startDatePicker.maximumDate = sender.date.addingTimeInterval(-TimeInterval(60.00))
        
    }
    
    
    @IBAction func handleCalendarReminder(_ sender: UISwitch) {
        requestPermissionCalendar()
        if sender.isOn {
            self.calendarReminder = true
        } else{
            self.calendarReminder = false
        }
    }
    
    func createEvent() {
            if self.calendarReminder {
                let startDate = startDatePicker.date
                let endDate = endDatePicker.date
//                eventStore.requestAccess(to: .event){ (granted, error) in
//                    if granted && error == nil{
                if permissionGrantedCalendar {
                        DispatchQueue.main.async {
                            let event: EKEvent = EKEvent(eventStore: self.eventStore)
                            event.calendar = self.eventStore.defaultCalendarForNewEvents

                            event.title = self.expenseNameTextField.text
                            event.startDate = endDate
                            event.endDate = endDate
                            event.notes = self.expenseNotesTextField.text
                            
                            if self.isRecurrence{
                                let recurrenceRule = EKRecurrenceRule(
                                    recurrenceWith: self.recurrenceFrequency,
                                    interval: 1,
                                    end: EKRecurrenceEnd(end: endDate)
                                )
                                event.recurrenceRules = [recurrenceRule]
                                
                            }
    //                        if want to add an alarm
    //                        let alarm =  EKAlarm(relativeOffset: 0)
    //                        event.addAlarm(alarm)
                            
                            do{
                                try self.eventStore.save(event, span: .futureEvents)
                                print("event.eventIdentifier \(event.eventIdentifier)")
                                self.eventId = event.eventIdentifier
                            }catch let error as NSError{
                                print("Failed to save calendar event with error: \(error)")
                            }
                        }
                        print("Save Event")
            }
//                    }else{
//                        print("Failed to save event with error: \(String(describing: error)) or access not granted")
//                    }
                //}
            }
    }
    
    func requestPermissionReminder(){
        eventStore.requestAccess(to: .reminder){
            (granted, error) in
            if granted && error == nil{
                self.permissionGrantedReminder = true

            }else{
                self.permissionGrantedReminder = false
                print("Failed to save reminder with error: \(String(describing: error)) or access not granted")
            }
        }
    }
    
    func requestPermissionCalendar(){
        eventStore.requestAccess(to: .event){
            (granted, error) in
            if granted && error == nil{
                self.permissionGrantedCalendar = true

            }else{
                self.permissionGrantedCalendar = false
                print("Failed to save event with error: \(String(describing: error)) or access not granted")
            }
        }
    }
    
    func createReminder() {
        //if self.calendarReminder {
            let startDate = startDatePicker.date
            let endDate = endDatePicker.date
//            var isRecurrence = true
//
//            var recurrenceFrequency: EKRecurrenceFrequency = .daily
//            let occurrenceIndex = selectedOccurrence
//            print("selectedOccurrence \(selectedOccurrence)")
//            switch occurrenceIndex{
//            case 1:
//                recurrenceFrequency = .daily
//            case 2:
//                recurrenceFrequency = .weekly
//            case 3:
//                recurrenceFrequency = .monthly
//            default:
//                isRecurrence = false
//            }
            
            
//            eventStore.requestAccess(to: .reminder){
//                (granted, error) in
//                if granted && error == nil{
        if permissionGrantedReminder {
            
                    DispatchQueue.main.async {
                        let reminder:EKReminder = EKReminder(eventStore: self.eventStore)
                        reminder.calendar = self.eventStore.defaultCalendarForNewReminders()

                        reminder.title = self.expenseNameTextField.text
                        reminder.notes = self.expenseNotesTextField.text
                        reminder.priority = Int(EKReminderPriority.high.rawValue)
                        //reminder.startDateComponents = Calendar.current.dateComponents([.year,.day,.weekday,.month], from: startDate)
                        reminder.dueDateComponents = Calendar.current.dateComponents([.year,.day,.weekday,.month,.timeZone,.hour,.minute,.second], from: endDate)
                        if self.isRecurrence{
                            let recurrenceRule = EKRecurrenceRule(
                                recurrenceWith: self.recurrenceFrequency,
                                interval: 1,
                                end: EKRecurrenceEnd(end: endDate)
                            )
                            reminder.recurrenceRules = [recurrenceRule]

                        }
                        
                        let alarm =  EKAlarm(relativeOffset: 0)
                        reminder.addAlarm(alarm)

                        do{
                            try self.eventStore.save(reminder, commit: true)
                        }catch let error as NSError{
                            print("Failed to save calendar event with error: \(error)")
                        }
                    }
                    print("Save Reminder")
        }
//                }else{
//                    print("Failed to save reminder with error: \(String(describing: error)) or access not granted")
//                }
            //}
            
//            eventStore.requestAccess(to: .event){ (granted, error) in
//                if granted && error == nil{
//                    DispatchQueue.main.async {
//                        let event: EKEvent = EKEvent(eventStore: self.eventStore)
//                        event.calendar = self.eventStore.defaultCalendarForNewEvents
//
//                        event.title = self.expenseNameTextField.text
//                        event.startDate = endDate
//                        event.endDate = endDate
//                        event.notes = self.expenseNotesTextField.text
//
//                        if self.isRecurrence{
//                            let recurrenceRule = EKRecurrenceRule(
//                                recurrenceWith: self.recurrenceFrequency,
//                                interval: 1,
//                                end: EKRecurrenceEnd(end: endDate)
//                            )
//                            event.recurrenceRules = [recurrenceRule]
//
//                        }
////                        if want to add an alarm
////                        let alarm =  EKAlarm(relativeOffset: 0)
////                        event.addAlarm(alarm)
//
//                        do{
//                            try self.eventStore.save(event, span: .futureEvents)
//                        }catch let error as NSError{
//                            print("Failed to save calendar event with error: \(error)")
//                        }
//                    }
//                    print("Save Event")
//                }else{
//                    print("Failed to save event with error: \(String(describing: error)) or access not granted")
//                }
//            }
        
        //}
    }
    
    @IBAction func handleOccurrenceSegment(_ sender: UISegmentedControl) {
        requestPermissionReminder()
        initSegmentUnit(index: sender.selectedSegmentIndex)
    }
    
    
    func initSegmentUnit(index: Int) {
        switch index {
        // Reminder on the specific date
        case 0:
            print("initSegmentUnit One Off")
            
        // Reminder on daily
        case 1:
            print("initSegmentUnit Daily")
            
        // Reminder on Weekly
        case 2:
            print("initSegmentUnit Weekly")
            
        // Reminder on Monthly
        case 3:
            print("initSegmentUnit Monthly")
        default:
            break
        }
        self.selectedOccurrence = Int64(index)
    }
    
    @IBAction func handleCancelButton(_ sender: UIBarButtonItem) {
        dismissPopOver()
    }
    
    @IBAction func handleAddButton(_ sender: UIBarButtonItem) {
        if validateInputFields(){
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            //let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Expense", in: managedContext)!
            var expense = NSManagedObject()
            if editingExpenseMode {
                expense = (editingExpense as? Expense)!
            } else{
                expense = NSManagedObject(entity: entity, insertInto: managedContext)
            }
            
            expense.setValue(expenseNameTextField.text!, forKey: "name")
            expense.setValue(expenseNotesTextField.text!, forKey: "note")
            expense.setValue(Double(expenseAmountTextField.text!)!, forKey: "amount")
            expense.setValue(Int64(self.selectedOccurrence), forKey: "occurrence")
            expense.setValue(startDatePicker.date, forKey: "startDate")
            expense.setValue(endDatePicker.date, forKey: "endDate")
            expense.setValue(self.calendarReminder, forKey: "reminder")
            expense.setValue(selectedCategory?.name, forKey: "category")
            selectedCategory?.addToExpenses(expense as! Expense)
            print("expense \(expense)")
            
            createEvent()
            createReminder()
            let newEvent = eventStore.event(withIdentifier: self.eventId)
//            eventStore.pre
//            eventStore.remove(<#T##reminder: EKReminder##EKReminder#>, commit: <#T##Bool#>)
            print("event id \(self.eventId)")
            print("newevent \(newEvent?.eventIdentifier)")
//            do{
//                try self.eventStore.remove(newEvent!, span: .futureEvents)
//            }catch let error as NSError{
//                print("Failed to save calendar event with error: \(error)")
//            }
            
            if newEvent != nil{
            do{
                // Save to Core data
                try managedContext.save()
                self.addExpenseDelegate?.completeSave()
                print("before append")
                expenses.append(expense)
                print("after all")
            }catch _ as NSError{
                let alert = UIAlertController(title: "Error", message: "An error occured while saving the project.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            }
        }else{
            let alert = UIAlertController(title: "Error", message: "Please fill the required fields.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Dismiss PopOver
        dismissPopOver()
    }
    
}


extension AddExpenseViewController{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            expenseNameTextField.becomeFirstResponder()
            tableView.reloadData()
        }
        
        if indexPath.section == 0 && indexPath.row == 1 {
            expenseAmountTextField.becomeFirstResponder()
            tableView.reloadData()
        }
        
        if indexPath.section == 0 && indexPath.row == 2 {
            expenseNotesTextField.becomeFirstResponder()
            tableView.reloadData()
        }
        
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension AddExpenseViewController: AddExpenseViewControllerDelegate{
    func completeSave() {
        print("uppppp")
    }
}
