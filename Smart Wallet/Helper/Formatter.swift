//
//  Formatter.swift
//  Smart Wallet
//
//  Created by Thinura Laksara on 2021-05-10.
//

import Foundation
import UIKit

public class Formatter {
    // Helper to format date
    public func formatDate(_ date: Date) -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        return dateFormatter.string(from: date)
    }
}
