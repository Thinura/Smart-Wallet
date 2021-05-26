//
//  ExpenseTableViewCell.swift
//  My Personal Manager
//
//  Created by Thinura Laksara on 2021-05-11.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    var cellDelegate: ExpenseTableViewCellDelegate?
    var notes: String = "Not Available"
    
    @IBOutlet weak var expenseNameLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var budgetRemainingProgressBar: LinearProgressBar!
    
    let now: Date = Date()
    //let colours: Colours = Colours()
    let formatter: Formatter = Formatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func categoryCellInit(_ expenseName: String, progressValue: Double, expenseBudget: Double, startDate:Date, dueDate: Date, notes: String) {
        //print("expense \(expenseName)")
        expenseNameLabel.text = expenseName
        budgetLabel.text = String(expenseBudget)
        dueDateLabel.text = "Due: \(formatter.formatDate(dueDate))"
    
        DispatchQueue.main.async {
            self.budgetRemainingProgressBar.startGradientColor = .linearHighlight
            self.budgetRemainingProgressBar.endGradientColor = .linearHighlight
            self.budgetRemainingProgressBar.progress = CGFloat(progressValue) / 100
        }
        self.notes = notes
    }
    
    @IBAction func handleViewNotes(_ sender: UIButton) {
        self.cellDelegate?.viewNotes(cell: self, sender: sender as! UIButton, data: notes)
    }
}

protocol ExpenseTableViewCellDelegate {
    func viewNotes(cell: ExpenseTableViewCell, sender button: UIButton, data data: String)
}
