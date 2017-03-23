//
//  CommDataView.swift
//  iosELConfig
//
//  Created by mac on 3/23/17.
//  Copyright © 2017 CallerId.com. All rights reserved.
//

import UIKit

class CommDataView: UITableView, UITableViewDataSource, UITableViewDelegate {

    var commData:[String] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel?.text = commData[indexPath.row]
        
        return cell
        
    }
    
    public func logCommData(data:String){
        
        commData.append(data)
        
    }
    
    public func getCommDataCount() -> Int{
        return commData.count
    }

}
