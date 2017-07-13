//
//  RawDataViewViewController.swift
//  iosELConfig
//
//  Created by mac on 7/13/17.
//  Copyright © 2017 CallerId.com. All rights reserved.
//

import UIKit

class RawDataView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var rawData:[String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rawData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = rawData[indexPath.row]
        cell.textLabel?.font = UIFont(name:"Courier", size:16)
        
        return cell
        
    }
    
    public func logRawData(data:String) -> Bool{
        
        if(rawData.count>0){
            
            let rData = NSMutableData()
            let str = data.data(using: String.Encoding(rawValue: String.Encoding.ascii.rawValue))
            rData.append(str!)
            
            var matched = false
            
            if let udpRecieved = NSString(data: rData as Data, encoding: String.Encoding.ascii.rawValue){
                
                let commPattern = "([Ee])([Cc])([Xx])([Uu])([Dd])([Aa])([Ss])([Oo])([Bb])([Kk])([Tt]) L=(\\d{1,2}) (\\d{1,2}/\\d{1,2} (\\d{1,2}:\\d{1,2}:\\d{1,2}))"
                let commRegex = try! NSRegularExpression(pattern: commPattern, options: [])
                let commMatches = commRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: (udpRecieved.length)))
                
                if(commMatches.count>0){
                    
                    matched = true
                }
            }

            if(matched){
                return false
            }
            
        }
        rawData.append(data)
        
        return true
        
    }
    
    public func getRawDataCount() -> Int{
        return rawData.count
    }
    
    public func clear(){
        rawData = []
    }
    
}

