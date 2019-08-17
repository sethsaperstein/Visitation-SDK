//
//  Collection.swift
//  visitation-app
//
//  Created by Seth Saperstein on 8/7/19.
//  Copyright © 2019 Seth Saperstein. All rights reserved.
//

import UIKit
import CoreLocation
import AdSupport

struct VisitationPoint: Codable {
    let arrival: String
    let departure: String
    let duration: Int
    let horizontalAccuracy: Double
    let latitude: Double
    let longitude: Double
    let uuid: String
}

struct VisitationPointsToSend: Codable {
    var Data: [VisitationPoint]
    let PartitionKey: Int
}


class Collection: NSObject {
    
    var visitationPoints = VisitationPointsToSend(Data: [], PartitionKey: 1)
    var timeToSendData = false
    var lastTimeSent = Date()

    func collectVisitationFields(visit: CLVisit) {
        
        let arrival = visit.arrivalDate.description
        let departure = visit.departureDate.description
        let duration = self.getDuration(t1: visit.arrivalDate, t2: visit.departureDate)
        
        let latitude = visit.coordinate.latitude
        let longitude = visit.coordinate.longitude
        
        let horizontalAccuracy = visit.horizontalAccuracy
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        
        let newVisit = VisitationPoint(arrival: arrival, departure: departure, duration: duration, horizontalAccuracy: horizontalAccuracy, latitude: latitude, longitude: longitude, uuid: uuid)
        
        self.visitationPoints.Data.append(newVisit)
    }
    
    func getDuration(t1: Date, t2: Date) -> Int {
        let cal = Calendar.current
        let components = cal.dateComponents([.minute], from: t1, to: t2)
        let diff = components.minute!
        return diff
    }
    
    func checkToSendData(newTimestamp: Date) {
        let cal = Calendar.current
        let components = cal.dateComponents([.minute], from: self.lastTimeSent, to: newTimestamp)
        let diff = components.minute!
        if diff > 10 {
            self.timeToSendData = true
            print("time to send")
        }
    }
    
    func dataSent() {
        print("reset local data")
        self.timeToSendData = false
        self.lastTimeSent = Date()
        self.visitationPoints.Data = []
    }
    
    func getVisitationPoints() -> VisitationPointsToSend {
        return self.visitationPoints
    }
}
