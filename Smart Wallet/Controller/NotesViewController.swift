//
//  NotesViewController.swift
//  Smart Wallet
//
//  Created by Thinura Laksara on 2021-05-12.
//

import UIKit

class NotesViewController: UIViewController {

    @IBOutlet weak var notesTextView: UITextView!
    
    var notes: String? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        if let notes = notes {
            if let notesTextView = notesTextView {
                notesTextView.text = notes
            }
        }
    }

}
