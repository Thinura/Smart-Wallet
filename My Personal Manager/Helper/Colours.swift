//
//  Colours.swift
//  My Personal Manager
//
//  Created by Thinura Laksara on 2021-05-10.
//

import Foundation
import UIKit

extension UIColor{
    static var categoryTheme: [UIColor]{
        return [UIColor(named: "theme01") ?? .systemBackground,
                UIColor(named: "theme02") ?? .systemBackground,
                UIColor(named: "theme03") ?? .systemBackground,
                UIColor(named: "theme04") ?? .systemBackground,
                UIColor(named: "theme05") ?? .systemBackground,
                UIColor(named: "theme06") ?? .systemBackground,
                UIColor(named: "theme07") ?? .systemBackground,]
    }
    static var theme01: UIColor{
        return UIColor(named: "theme01") ?? .systemBackground
    }
    static var theme02: UIColor{
        return UIColor(named: "theme02") ?? .systemBackground
    }
    static var theme03: UIColor{
        return UIColor(named: "theme03") ?? .systemBackground
    }
    static var theme04: UIColor{
        return UIColor(named: "theme04") ?? .systemBackground
    }
    static var theme05: UIColor{
        return UIColor(named: "theme05") ?? .systemBackground
    }
    static var theme06: UIColor{
        return UIColor(named: "theme06") ?? .systemBackground
    }
    static var theme07: UIColor{
        return UIColor(named: "theme07") ?? .systemBackground
    }
    
    static var pieChart01: UIColor{
        return UIColor(named: "pieChart01") ?? .systemBackground
    }
    static var pieChart02: UIColor{
        return UIColor(named: "pieChart02") ?? .systemBackground
    }
    static var pieChart03: UIColor{
        return UIColor(named: "pieChart03") ?? .systemBackground
    }
    static var pieChart04: UIColor{
        return UIColor(named: "pieChart04") ?? .systemBackground
    }
    static var pieChart05: UIColor{
        return UIColor(named: "pieChart05") ?? .systemBackground
    }
    
    static var linearBackground: UIColor{
        return UIColor(named: "backgroundColor") ?? .systemBackground
    }
    static var linearHighlight: UIColor{
        return UIColor(named: "highlightColor") ?? .systemBackground
    }
}
