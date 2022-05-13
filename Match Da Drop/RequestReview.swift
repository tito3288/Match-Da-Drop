//
//  RequestReview.swift
//  Match Da Drop
//
//  Created by Bryan Arambula on 5/6/22.
//

import Foundation
import StoreKit

class ReviewService{
    private init() {}

    static let shared = ReviewService()
    private let defaults = UserDefaults.standard
    
    private var lastRequest: Date?{
        get {
            return defaults.value(forKey: ".lastRequest") as? Date
        }
        set{
            defaults.set(newValue, forKey: ".lastRequest")
        }
    }
    
    private var oneWeekAgo: Date{
        return Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    }
    
    private var shouldRequestReview: Bool {
        if lastRequest == nil{
            return true
        }else if let lastRequest = lastRequest, lastRequest < oneWeekAgo{
            return true
        }
        return false
    }
    
    func requestReview(){
        guard shouldRequestReview else {return}
        SKStoreReviewController.requestReview()
        lastRequest = Date()
    }
    
}


