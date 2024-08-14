//
//  WorkLogModel.swift
//  Metrolog
//
//  Created by jay on 07/08/24.
//

import Foundation

class WorkLogModel{
        var date: String
        var day: String
        var timeRange: String
        var hours: String
        var status: String
     
    init(date: String, day: String, timeRange: String, hours: String, status: String) {
            self.date = date
            self.day = day
            self.timeRange = timeRange
            self.hours = hours
            self.status = status
        }
}




