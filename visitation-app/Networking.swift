//
//  Networking.swift
//  visitation-app
//
//  Created by Seth Saperstein on 8/8/19.
//  Copyright © 2019 Seth Saperstein. All rights reserved.
//

import Foundation
import UIKit

class Networking: NSObject {
    func submitVisitationPoints(points: VisitationPointsToSend, completion:((Error?) -> Void)?) {
        var request = URLRequest(url: URL(string:"https://z4kqm8veeh.execute-api.us-east-1.amazonaws.com/test-dashboard/Streams/location_ingestion_stream1/record")!)
        request.httpMethod = "PUT"
        
        var headers = request.allHTTPHeaderFields ?? [:]
        headers["Content-Type"] = "application/json"
        request.allHTTPHeaderFields = headers
        
        var data: Data?
        
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(points)
            data = jsonData
        } catch { print(error) }
        
        request.httpBody = data!
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let task = session.dataTask(with: request) { (responseData, response, responseError) in
            guard responseError == nil else {
                completion?(responseError!)
                return
            }
            
            if let data = responseData, let utf8Representation = String(data: data, encoding: .utf8) {
                print("response:", utf8Representation)
            } else {
                print("no readable data received")
            }
        }
        task.resume()
    }
}
