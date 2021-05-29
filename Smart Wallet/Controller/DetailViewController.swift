//
//  DetailViewController.swift
//  Smart Wallet
//
//  Created by Thinura Laksara on 2021-05-11.
//

import UIKit
import CoreData
import EventKit

protocol DetailViewControllerDelegate {
    func completeSaveExpense()
}

class DetailViewController: UIViewController,  NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate{
    
    let eventStore : EKEventStore = EKEventStore()

    var detailVC: DetailViewController? = nil
    var managedOC: NSManagedObjectContext? = nil
    let now: Date = Date()
    var totalBudget: Double = 0
    var detailDelegate: DetailViewControllerDelegate?
    
    let pieChartView = PieChartView()

    @IBOutlet weak var expenseTableView: UITableView!
    
    // Category details
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var categoryDetailView: UIView!
    @IBOutlet weak var firstHighestValue: UILabel!
    @IBOutlet weak var secondHighestValue: UILabel!
    @IBOutlet weak var thirdHighestValue: UILabel!
    @IBOutlet weak var fourthHighestValue: UILabel!
    @IBOutlet weak var otherValue: UILabel!
    @IBOutlet weak var totalCategoryValue: UILabel!
    @IBOutlet weak var spentCategoryValue: UILabel!
    @IBOutlet weak var remainingCategoryValue: UILabel!
    @IBOutlet weak var expenseChart: PieChartView!
    
    // Cell Buttons
    @IBOutlet weak var addExpenseButton: UIBarButtonItem!
    @IBOutlet weak var editExpenseButton: UIBarButtonItem!
    
    var selectedCategory: Category?{
        didSet {
            // Update the view
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view
        configureView()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
            return
        }
        
        self.managedOC = appDelegate.persistentContainer.viewContext
        
        // Initialize the custom cell
        let nibName = UINib(nibName: "ExpenseTableViewCell", bundle: nil)
        expenseTableView.register(nibName, forCellReuseIdentifier: "expenseCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let category = selectedCategory{
            totalBudget = category.monthlyBudget
            totalCategoryValue.text = "Total Budget £\(totalBudget)"
            if category.expenses!.count == 0 {
                //print("expenses \(category.expenses!.count)")
                editExpenseButton.isEnabled = false

            }

        }
        
        
        // Set the default selected row
        let indexPath = IndexPath(row: 0, section: 0)
        if expenseTableView.hasRowAtIndexPath(indexPath: indexPath as NSIndexPath){
            expenseTableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
    }
    
    func configureView() {
        if let category = selectedCategory{
            if let nameCategory = categoryNameLabel{
                expenseTableView.isHidden = false
               categoryDetailView.isHidden = false
                updateSpentAmount()
                updateRemainingAmount()
                updateExpenseLabels()
                nameCategory.text = category.name
                expenseTableView.reloadData()
            }
        }
        
        if selectedCategory == nil {
             expenseTableView.isHidden = true
            categoryDetailView.isHidden = true
        }
    }
    
    func updateSpentAmount() {
        let objects = self.selectedCategory?.expenses?.allObjects as! [Expense]
        var totalExpense: Double = 0
        for expense in objects {
            totalExpense += expense.amount
        }
        spentCategoryValue.text = "Spent £ \(String(totalExpense))"
    }
    
    func updateRemainingAmount(){
        let objects = self.selectedCategory?.expenses?.allObjects as! [Expense]
        var totalExpense: Double = 0
        for expense in objects {
            totalExpense += expense.amount
        }
        if let category = selectedCategory{
            let remainder = category.monthlyBudget - totalExpense
            if remainder < 0{
                remainingCategoryValue.textColor = UIColor.red
            }
        remainingCategoryValue.text = "Remaining £ \(String(remainder))"
        }
    }
    
    func updateExpenseLabels() {
        var firstHV:CGFloat = 0, secondHV:CGFloat = 0, thirdHV:CGFloat = 0, fourthHV:CGFloat = 0, otherHV:CGFloat = 0
        let objects = self.selectedCategory?.expenses?.allObjects as! [Expense]
        var expenses:[Double] = []
        for expense in objects {
            expenses.append(expense.amount)
        }
        let sortedExpenses = objects.sorted { $0.amount > $1.amount }
        
        var free:Double = self.selectedCategory?.monthlyBudget ?? 0
        print("sorted expenses \(sortedExpenses)")
            switch sortedExpenses.count {
            case 1:
                firstHighestValue.text = sortedExpenses[0].name ?? ""
                free = free - sortedExpenses[0].amount
                firstHV = CGFloat(sortedExpenses[0].amount)
            case 2:
                firstHighestValue.text = sortedExpenses[0].name ?? ""
                secondHighestValue.text = sortedExpenses[1].name ?? ""
                free = free - (sortedExpenses[0].amount + sortedExpenses[1].amount)

                firstHV = CGFloat(sortedExpenses[0].amount)
                secondHV = CGFloat(sortedExpenses[1].amount)
            case 3:
                firstHighestValue.text = sortedExpenses[0].name ?? ""
                secondHighestValue.text = sortedExpenses[1].name ?? ""
                thirdHighestValue.text = sortedExpenses[2].name ?? ""
                free = free - (sortedExpenses[0].amount + sortedExpenses[1].amount + sortedExpenses[2].amount)
                firstHV = CGFloat(sortedExpenses[0].amount)
                secondHV = CGFloat(sortedExpenses[1].amount)
                thirdHV = CGFloat(sortedExpenses[2].amount)
            case 4:
                firstHighestValue.text = sortedExpenses[0].name ?? ""
                secondHighestValue.text = sortedExpenses[1].name ?? ""
                thirdHighestValue.text = sortedExpenses[2].name ?? ""
                fourthHighestValue.text = sortedExpenses[3].name ?? ""
                free = free - (sortedExpenses[0].amount + sortedExpenses[1].amount + sortedExpenses[2].amount + sortedExpenses[3].amount)
                firstHV = CGFloat(sortedExpenses[0].amount)
                secondHV = CGFloat(sortedExpenses[1].amount)
                thirdHV = CGFloat(sortedExpenses[2].amount)
                fourthHV  = CGFloat(sortedExpenses[3].amount)
            default:
                print("")
            }

        if sortedExpenses.count > 4{
            firstHighestValue.text = sortedExpenses[0].name ?? ""
            secondHighestValue.text = sortedExpenses[1].name ?? ""
            thirdHighestValue.text = sortedExpenses[2].name ?? ""
            fourthHighestValue.text = sortedExpenses[3].name ?? ""

            
            firstHV = CGFloat(sortedExpenses[0].amount)
            secondHV = CGFloat(sortedExpenses[1].amount)
            thirdHV = CGFloat(sortedExpenses[2].amount)
            fourthHV  = CGFloat(sortedExpenses[3].amount)
            var otherTotal:Double = 0
            print(sortedExpenses.count)
            for item in 4...sortedExpenses.count-1 {
                print(item)
                otherTotal += sortedExpenses[item].amount
            }
            print("other \(otherTotal)")
            otherValue.text = "other"
            free = free - (sortedExpenses[0].amount + sortedExpenses[1].amount + sortedExpenses[2].amount + sortedExpenses[3].amount + otherTotal)
            otherHV = CGFloat(otherTotal)
        }
        
        var freeValue =  CGFloat(free)
        if sortedExpenses.count > -1{
            pieChartView.frame = CGRect(x: 0, y: 0, width: 155, height: 155)
            pieChartView.segments = [
              Segment(color: .pieChart01, value: firstHV),
              Segment(color: .pieChart02, value: secondHV),
              Segment(color: .pieChart03, value: thirdHV),
              Segment(color: .pieChart04, value: fourthHV),
              Segment(color: .pieChart05, value: otherHV),
                Segment(color: .pieChart06, value: freeValue)
            ]
            expenseChart.addSubview(pieChartView)
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpense" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddExpenseViewController
            controller.selectedCategory = selectedCategory
            controller.addExpenseDelegate = self
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 320, height: 500)
            }
        }
        
        if segue.identifier == "showCategoryNotes" {
            let controller = segue.destination as! NotesViewController
            controller.notes = selectedCategory!.note
            if let controller = segue.destination as? UIViewController {
                controller.popoverPresentationController!.delegate = self
                controller.preferredContentSize = CGSize(width: 300, height: 250)
            }
        }
        
        if segue.identifier == "editExpense" {
            if let indexPath = expenseTableView.indexPathForSelectedRow{
                let object = (self.selectedCategory?.expenses?.allObjects as! [Expense])[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! AddExpenseViewController
                controller.addExpenseDelegate = self
                controller.editingExpense = object as Expense
                controller.selectedCategory = selectedCategory
            }
        }
    }
    
    // MARK: - Fetched results controller
    var fetchedResultsController: NSFetchedResultsController<Expense> {

        if _fetchedResultsController != nil{
            return _fetchedResultsController!
        }

        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()

         //Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        // Edit the sort key as appropriate
        let sortDescriptor = NSSortDescriptor(key: "name",ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sortDescriptor]

        if selectedCategory != nil {
            //print("\(selectedCategory)")
            // Setting a predicate
            let predicate = NSPredicate(format: "category == %@", selectedCategory!)
            fetchRequest.predicate = predicate
        }



        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController<Expense>(fetchRequest: fetchRequest, managedObjectContext: managedOC!, sectionNameKeyPath: #keyPath(Expense.category), cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController


        do{
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Expense>? = nil
    
    // MARK: - Configure the cell
    func configureCell(_ cell: ExpenseTableViewCell, withExpense expense: Expense, index: Int) {
        if let category = selectedCategory{
            print("expense.amount \(expense.amount)")
            var reminder:EKReminder
            if expense.reminderId == "" {
                reminder = EKReminder(eventStore: self.eventStore)
            }else{
                reminder = eventStore.calendarItem(withIdentifier: expense.reminderId ?? "") as! EKReminder
            }
            print("reminder.isCompleted \(reminder.isCompleted)")
            if reminder.isCompleted{
                print("reminder.completionDate \(reminder.completionDate)")
            }
            cell.expenseCellInit(expense.name ?? "",progressValue: (expense.amount/category.monthlyBudget)*100, expenseBudget: expense.amount,startDate: expense.startDate ?? now,dueDate: expense.endDate ?? now, notes: expense.note ?? "", reminder: expense.reminder)
            
        }

        

    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            expenseTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            expenseTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            expenseTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            expenseTableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            configureCell(expenseTableView.cellForRow(at: indexPath!)! as! ExpenseTableViewCell, withExpense: anObject as! Expense, index: indexPath!.row)
        case .move:
            configureCell(expenseTableView.cellForRow(at: indexPath!)! as! ExpenseTableViewCell, withExpense: anObject as! Expense, index: indexPath!.row)
            expenseTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
        configureView()
    }
    
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        expenseTableView.endUpdates()
    }
    
    func showNotes (cell: ExpenseTableViewCell, forButton button: UIButton, forNotes notes: String) {
        let buttonFrame = button.frame
        var showRect = cell.convert(buttonFrame, to: expenseTableView)
        showRect = expenseTableView.convert(showRect, to: view)
        showRect.origin.y -= 5
        
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "NotesViewController") as? NotesViewController
        controller?.modalPresentationStyle = .popover
        controller?.preferredContentSize = CGSize(width: 300, height: 250)
        controller?.notes = notes
        
        if let popoverPresentationController = controller?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .up
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = showRect
            
            if let popoverController = controller {
                present(popoverController, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let category = self.selectedCategory else {
            return 0
        }
        print("selected \(self.selectedCategory?.expenses?.count)")
        let sectionInfo = (category.expenses?.allObjects as! [Expense])
        if selectedCategory == nil{
            categoryDetailView.isHidden = true
            expenseTableView.setEmptyMessage("Add a new Expense to manage Tasks", UIColor.black)
            return 0
        }

        if sectionInfo.count == 0{
            editButtonItem.isEnabled = false
            expenseTableView.setEmptyMessage("No expense available for this Category", UIColor.black)
        }
        
        let count  = (category.expenses?.allObjects as! [Expense]).count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  expenseTableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath) as! ExpenseTableViewCell
        
        let expense = (self.selectedCategory?.expenses?.allObjects as! [Expense])[indexPath.row]
        print("expense ---\(expense.name)")
        configureCell(cell, withExpense: expense, index: indexPath.row)
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let context = fetchedResultsController.managedObjectContext
            let deleteExpense = (self.selectedCategory?.expenses?.allObjects as! [Expense])[indexPath.row]
            if(deleteExpense.eventId! != ""){
                let event = self.eventStore.event(withIdentifier: deleteExpense.eventId!)!
                    do{
                        try             self.eventStore.remove(event, span: .futureEvents)
                        
                    }catch let error as NSError{
                        print("Failed to REMOVE from calendar event with error: \(error)")
                    }
            }
            
            let reminder = eventStore.calendarItem(withIdentifier: deleteExpense.reminderId!) as! EKReminder
            do{
                try             self.eventStore.remove(reminder, commit: true)
                
                
            }catch let error as NSError{
                print("Failed to REMOVE from calendar reminder with error: \(error)")
            }
            
            context.delete(deleteExpense)
            
            self.detailDelegate?.completeSaveExpense()
            do{
                try context.save()
            } catch{
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func save(){
        print("Detail update")
        self.detailDelegate?.completeSaveExpense()
    }
}

extension DetailViewController: ExpenseTableViewCellDelegate{
    func viewNotes(cell: ExpenseTableViewCell, sender button: UIButton, data: String) {
        self.showNotes(cell: cell, forButton: button, forNotes: data)
        
    }
}

extension DetailViewController: AddExpenseViewControllerDelegate {
    func completeSave() {
        self.save()
    }
    
}

extension DetailViewController: DetailViewControllerDelegate{
    func completeSaveExpense() {
    }
}
