//
//  LocationManager.swift
//  visitation-app
//
//  Created by Seth Saperstein on 8/7/19.
//  Copyright © 2019 Seth Saperstein. All rights reserved.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var locationStatus: NSString = "Not Started"
    var fieldCollector = Collection()
    var networker = Networking()
    
    override init() {
        super.init()
        initLocationManager()
    }
    
    func initLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        CLLocationManager.locationServicesEnabled()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationManager.stopUpdatingLocation()
        self.locationManager.stopMonitoringVisits()
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        var shouldIAllow = false
        switch status {
        case CLAuthorizationStatus.restricted:
            self.locationStatus = "restricted access to location"
        case CLAuthorizationStatus.denied:
            self.locationStatus = "user denied access to location"
        case CLAuthorizationStatus.notDetermined:
            self.locationStatus = "status not determined"
        default:
            self.locationStatus = "allowed location access"
            shouldIAllow = true
        }
        if (shouldIAllow) {
            NSLog("Location allowed")
            self.locationManager.startMonitoringVisits()
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        self.fieldCollector.collectVisitationFields(visit: visit)
        if self.fieldCollector.timeToSendData {
            // send data
            let data = self.fieldCollector.getVisitationPoints()
            self.networker.submitVisitationPoints(points: data) { (error) in
                if let error = error {
                    fatalError(error.localizedDescription)
                }
            }
            
            // reset our data
            self.fieldCollector.dataSent()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}
