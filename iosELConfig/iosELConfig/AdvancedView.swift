//
//  AdvancedView.swift
//  iosELConfig
//
//  Created by mac on 7/12/17.
//  Copyright © 2017 CallerId.com. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class AdvancedView: UITableViewController, GCDAsyncUdpSocketDelegate {

    let rawdata_datasource_delegate = RawDataView()
    
    // References
    @IBOutlet weak var tb_dest_ip: UITextField!
    @IBOutlet weak var tb_dest_mac: UITextField!
    @IBOutlet weak var tb_unit_number: UITextField!
    @IBOutlet weak var tb_dest_port: UITextField!
    @IBOutlet weak var lb_listening_port: UILabel!
    
    @IBOutlet weak var tbv_raw_data: UITableView!
    
    @IBOutlet weak var lb_date_time: UIButton!
    
    @IBOutlet weak var tv_dest_ip: UITableViewCell!
    @IBOutlet weak var tv_dest_mac: UITableViewCell!
    @IBOutlet weak var tv_unit_num: UITableViewCell!
    @IBOutlet weak var tv_dest_port: UITableViewCell!
    @IBOutlet weak var tv_unit_time: UITableViewCell!
    @IBOutlet weak var tv_info: UITableViewCell!
    @IBOutlet weak var tv_resets: UITableViewCell!
    //-----------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startServer()
        
        tv_dest_ip.selectionStyle = .none
        tv_dest_mac.selectionStyle = .none
        tv_unit_num.selectionStyle = .none
        tv_dest_port.selectionStyle = .none
        tv_unit_time.selectionStyle = .none
        tv_info.selectionStyle = .none
        tv_resets.selectionStyle = .none
        
        // Startup with V command to load parameters
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: ViewController.boxPort)
        
        // Advanced Settings
        tb_dest_ip?.addTarget(self, action: #selector(AdvancedView.tb_ip_validation(txtField:)), for: UIControlEvents.editingChanged)
        
        tb_dest_mac?.addTarget(self, action: #selector(AdvancedView.tb_dest_mac_validation(txtField:)), for: UIControlEvents.editingChanged)
        
        tb_dest_port?.addTarget(self, action: #selector(AdvancedView.tb_dest_port_validation(txtField:)), for: UIControlEvents.editingChanged)
        
        tb_unit_number?.addTarget(self, action: #selector(AdvancedView.tb_unit_number_validation(txtField:)), for: UIControlEvents.editingChanged)
        
        tbv_raw_data.dataSource = rawdata_datasource_delegate
        tbv_raw_data.delegate = rawdata_datasource_delegate
        
        lb_listening_port.text = "Listening on port: " + ViewController.boxPort
        
        // Setup update timer for tech connections
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startRepeatingUpdates), userInfo: nil, repeats: false)
        
    }
    
    // Save time
    
    @IBAction func btn_set_time_click(_ sender: Any) {
        
        let date = Date()
        let calendar = Calendar.current
        var month = String(calendar.component(.month, from: date))
        var day = String(calendar.component(.day, from: date))
        var hour = String(calendar.component(.hour, from: date))
        var minutes = String(calendar.component(.minute, from: date))
        
        if(month.characters.count == 1){
            month = "0" + month
        }
        
        if(day.characters.count == 1){
            day = "0" + day
        }
        
        if(hour.characters.count == 1){
            hour = "0" + hour
        }
        
        if(minutes.characters.count == 1){
            minutes = "0" + minutes
        }
        
        let sendString:String = "^^Id-Z" + month + day + hour + minutes + "\r";
        
        sendPacket(body: sendString, ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
    }
    
    //--------------------------------------------------------------------------
    // Log comm data
    //--------------------------------------------------------------------------
    
    @IBAction func btn_clear_raw_log_click(_ sender: Any) {
        
        rawdata_datasource_delegate.clear()
        tbv_raw_data.reloadData()
        
    }
    
    
    func logRawData(data:String){
        
        if(rawdata_datasource_delegate.logRawData(data: data)){
            
            let raw_data_count = rawdata_datasource_delegate.getRawDataCount()
            
            tbv_raw_data.beginUpdates()
            tbv_raw_data.insertRows(at: [IndexPath(row: raw_data_count-1, section: 0)], with: .automatic)
            tbv_raw_data.endUpdates()
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ViewController.preventUpdates = false
        ViewController.saveDestPort()
        stopServer()
    }
    
    // -------------------
    // Editing restaints
    // -------------------
    @IBAction func tb_dest_ip_undo(_ sender: Any) {
        // Keep program from crashing on other non-entry inputs to text field
        tb_dest_ip?.undoManager?.removeAllActions()
    }
    @IBAction func tb_dest_mac_undo(_ sender: Any) {
        // Keep program from crashing on other non-entry inputs to text field
        tb_dest_mac?.undoManager?.removeAllActions()
    }
    @IBAction func tb_unit_number_undo(_ sender: Any) {
        // Keep program from crashing on other non-entry inputs to text field
        tb_unit_number?.undoManager?.removeAllActions()
    }
    @IBAction func tb_dest_port_undo(_ sender: Any) {
        // Keep program from crashing on other non-entry inputs to text field
        tb_dest_port?.undoManager?.removeAllActions()
    }
    
    func tb_ip_validation(txtField: UITextField){
        
        let text = txtField.text
        let limit = 15
        var newChar:String = ""
        var preText:String = ""
        
        if(text?.characters.count == 0 || (text?.characters.count)! > limit) {
            return
        }
        
        if(text?.characters.count == 1){
            
            newChar = text!
            preText = ""
            
        }
        else{
            
            newChar = (text?.substring(from: (text?.index(before: (text?.endIndex)!))!))!
            preText = (text?.substring(to: (text?.index(before: (text?.endIndex)!))!))!
            
        }
        
        let testChar = Int(newChar)
        if(testChar == nil && newChar != "."){
            txtField.text = preText
            return
        }
        
        let partsOfIP = text?.components(separatedBy: ".")
        var valid:Bool = false
        
        if(partsOfIP?.count==1){
            
            let num = Int((partsOfIP?[0])!)
            
            if(num! > -1 && num! < 256){
                valid = true
            }
            
            
        }
        else if(partsOfIP?.count==2){
            
            let num1 = Int((partsOfIP?[0])!)
            let num2 = Int((partsOfIP?[1])!)
            
            if(num2 == nil){
                if(num1! > -1 && num1! < 256){
                    valid = true
                }
            }
            else{
                if(num1! > -1 && num1! < 256 &&
                    num2! > -1 && num2! < 256){
                    valid = true
                }
            }
        }
        else if(partsOfIP?.count==3){
            
            let num1 = Int((partsOfIP?[0])!)
            let num2 = Int((partsOfIP?[1])!)
            let num3 = Int((partsOfIP?[2])!)
            
            if(num2 == nil && num3 == nil){
                valid = false
            }else{
                if(num3 == nil){
                    if(num1! > -1 && num1! < 256 &&
                        num2! > -1 && num2! < 256){
                        valid = true
                    }
                }
                else{
                    if(num1! > -1 && num1! < 256 &&
                        num2! > -1 && num2! < 256 &&
                        num3! > -1 && num3! < 256){
                        valid = true
                    }
                }
            }
        }
        else if(partsOfIP?.count==4){
            
            let num1 = Int((partsOfIP?[0])!)
            let num2 = Int((partsOfIP?[1])!)
            let num3 = Int((partsOfIP?[2])!)
            let num4 = Int((partsOfIP?[3])!)
            
            if(num3 == nil && num4 == nil){
                valid=false
            }
            else{
                if(num4 == nil){
                    if(num1! > -1 && num1! < 256 &&
                        num2! > -1 && num2! < 256 &&
                        num3! > -1 && num3! < 256){
                        valid = true
                    }
                }
                else{
                    if(num1! > -1 && num1! < 256 &&
                        num2! > -1 && num2! < 256 &&
                        num3! > -1 && num3! < 256 &&
                        num4! > -1 && num4! < 256){
                        valid = true
                    }
                }
            }
        }
        else{
            valid = false
        }
        
        if(valid){
            return
        }else{
            txtField.text = preText
        }
        
        
    }
    
    func tb_dest_mac_validation(txtField: UITextField){
        
        let text = txtField.text
        let limit = 17
        var newChar:String = ""
        var preText:String = ""
        
        if(text?.characters.count == 0) {
            return
        }
        
        if(text?.characters.count == 1){
            
            newChar = text!
            preText = ""
            
        }
        else{
            
            newChar = (text?.substring(from: (text?.index(before: (text?.endIndex)!))!))!
            preText = (text?.substring(to: (text?.index(before: (text?.endIndex)!))!))!
            
        }
        
        if((text?.characters.count)! > limit){
            txtField.text = preText
            return
        }
        
        let areMatches = matches(for: "[0-9A-Fa-f\\-]", in: newChar)
        if(areMatches.count == 0){
            txtField.text = preText
            return
        }
        
        if(newChar == "-"){
            if(text!.characters.count % 3 != 0){
                txtField.text = preText
                return
            }
        }
        
        let partsOfMac = text?.components(separatedBy: "-")
        var valid:Bool = false
        
        if((partsOfMac?[(partsOfMac?.count)!-1].characters.count)! > 2){
            txtField.text = preText
            return
        }
        
        for part in partsOfMac!{
            
            let isValid = matches(for: "[0-9A-Fa-f]{1,2}", in: part)
            if(isValid.count > 0){
                valid = true
            }
            
        }
        
        // If valid input then return without cutting off last char
        // If invalid cut off last char
        if(valid){
            return
        }
        else{
            txtField.text = preText
        }
        
    }
    
    func tb_unit_number_validation(txtField: UITextField){
        
        let text = txtField.text
        let limit = 6
        var newChar:String = ""
        var preText:String = ""
        
        if(text?.characters.count == 0) {
            return
        }
        
        if(text?.characters.count == 1){
            
            newChar = text!
            preText = ""
            
        }
        else{
            
            newChar = (text?.substring(from: (text?.index(before: (text?.endIndex)!))!))!
            preText = (text?.substring(to: (text?.index(before: (text?.endIndex)!))!))!
            
        }
        
        if((text?.characters.count)! > limit){
            txtField.text = preText
            return
        }
        
        let areMatches = matches(for: "[0-9]", in: newChar)
        if(areMatches.count == 0){
            txtField.text = preText
            return
        }
        
        
    }
    func tb_dest_port_validation(txtField: UITextField){
        
        let text = txtField.text
        let limit = 4
        var newChar:String = ""
        var preText:String = ""
        
        if(text?.characters.count == 0) {
            return
        }
        
        if(text?.characters.count == 1){
            
            newChar = text!
            preText = ""
            
        }
        else{
            
            newChar = (text?.substring(from: (text?.index(before: (text?.endIndex)!))!))!
            preText = (text?.substring(to: (text?.index(before: (text?.endIndex)!))!))!
            
        }
        
        if((text?.characters.count)! > limit){
            txtField.text = preText
            return
        }
        
        let areMatches = matches(for: "[0-9]", in: newChar)
        if(areMatches.count == 0){
            txtField.text = preText
            return
        }
        
    }
    
    // -------------------
    // Changes
    // -------------------
    @IBAction func tb_unit_number_end_edit(_ sender: Any) {
        
        // Save unit number
        var unitNumber = tb_unit_number?.text
        while((unitNumber?.characters.count)!<6){
            unitNumber = "0" + unitNumber!;
        }
        
        let destination_port = ViewController.boxPort
        
        sendPacket(body: "^^IdU000000" + unitNumber!, ipAddString: "255.255.255.255", port: destination_port)
        
    }
    @IBAction func tb_dest_ip_did_end(_ sender: Any) {
        
        // Save unit number
        let hexIP = convertIPToHexString(ipAddress: (tb_dest_ip?.text!)!);
        if(hexIP != "-1"){
            
            sendPacket(body: "^^IdD" + hexIP, ipAddString: "255.255.255.255", port: ViewController.boxPort)//External IP
            updateParameters();
            
        }else{
            
            // Show message that IP is in incorrect format
            showPopup(parent: self, title: "Invalid IP Address", message: "The IP Address you have entered is not a valid IP address. Please retry.",yesOrNo: false)
            
        }
        
    }
    @IBAction func tb_dest_mac_did_end(_ sender: Any) {
        
        // Save destination MAC
        let macParts = tb_dest_mac?.text?.components(separatedBy: "-")
        var partsOfMac = Array(repeating: "", count: 6)
        
        var cnt = 0
        for part in macParts!{
            partsOfMac[cnt] = part.uppercased()
            cnt += 1
        }
        
        if(partsOfMac.count != 6){
            
            // incorrect format
            showPopup(parent: self, title: "MAC Invalid", message: "The MAC address you entered is invalid. Please retry.",yesOrNo: false)
            return;
        }
        
        var hexMac:String = partsOfMac[0]
        hexMac += partsOfMac[1]
        hexMac += partsOfMac[2]
        hexMac += partsOfMac[3]
        hexMac += partsOfMac[4]
        hexMac += partsOfMac[5]
        
        sendPacket(body: "^^IdC" + hexMac, ipAddString: "255.255.255.255", port: ViewController.boxPort)//Destination MAC address
        updateParameters();
        
    }
    
    @IBAction func tb_dest_port_did_end(_ sender: Any) {
        
        if Int((tb_dest_port?.text!)!) != nil{
            
            let num = Int((tb_dest_port?.text!)!)
            
            var hexPort = intToHex(num: num!)
            
            while(hexPort.characters.count<4){
                hexPort = "0" + hexPort
            }
            
            hexPort = hexPort.uppercased()
            
            sendPacket(body: "^^IdT" + hexPort, ipAddString: "255.255.255.255", port: ViewController.boxPort)
            ViewController.boxPort = tb_dest_port.text!
            ViewController.saveDestPort()
            
            _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(resetServer), userInfo: nil, repeats: false)
            
            
        }
        else{
            
            // display error popup
            showPopup(parent: self, title: "Invalid Port", message: "The port you entered is invalid. Please retry.",yesOrNo: false)
            
        }
        
    }
    
    // Advanced - needed functions
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func intToHex(num:Int)->String{
        
        return String(format:"%2X", num)
        
    }
    
    func convertIPToHexString(ipAddress:String)->String{
        
        let partsOfIpAddress = ipAddress.components(separatedBy: ".")
        
        var allAreInts = true;
        
        var hexStrings = Array(repeating: "", count: 4)
        
        var cnt = 0
        for ipPart in partsOfIpAddress{
            
            if let num = Int(ipPart){
                
                if(num > 255){
                    return "-1"
                }
                hexStrings[cnt] = String(format:"%2X",num)
                hexStrings[cnt] = hexStrings[cnt].uppercased()
                
                if(hexStrings[cnt].characters.count == 1){
                    hexStrings[cnt] = "0" + hexStrings[cnt]
                }
                
                cnt += 1
                
            }
            else{
                allAreInts = false
            }
            
        }
        
        if(!allAreInts){
            return "-1"
        }
        
        return hexStrings[0] + hexStrings[1] + hexStrings[2] + hexStrings[3]
        
        
    }
    
    @IBAction func btnResetELDefaults_Click(_ sender: Any) {
        
        showPopup(parent: self, title: "Reset Ethernet Defaults?", message: "Are you sure you wish to reset to Ethernet Link Defaults? This will take a moment.", yesOrNo: true)
        
    }
    
    func resetEL(){
        
        //Destination IP
        sendPacket(body: "^^IdDFFFFFFFF", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        //Unit ID
        sendPacket(body: "^^IdU000000000001", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        //Internal IP
        sendPacket(body: "^^IdIC0A8005A", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        //Destination MAC address
        sendPacket(body: "^^IdCFFFFFFFFFFFF", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        //Internal MAC address
        sendPacket(body: "^^IdM0620101332CC", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        //Port Number
        sendPacket(body: "^^IdT0DC0", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        // Update
        updateParameters();
    }
    
    @IBAction func btnResetUnitDefaults_Click(_ sender: Any) {
        
        showPopup(parent: self, title: "Reset Unit Defaults?", message: "Are you sure you wish to reset to Unit Defaults? This will take a moment.", yesOrNo: true)
        
        
    }
    
    func resetUnit(){
        
        //External IP
        sendPacket(body: "^^Id-N0000007701", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        //Reset
        sendPacket(body: "^^Id-R", ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
        sleep(1)
        
        // Update
        updateParameters();
    }
    
    // ----------------------------
    // POPUP
    // ----------------------------
    func showPopup(parent: UIViewController,title: String,message: String,yesOrNo: Bool){
        
        let popup = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "styBrdPopup") as! PopupView
        
        parent.addChildViewController(popup)
        popup.view.frame = parent.view.frame
        parent.view.addSubview(popup.view)
        popup.didMove(toParentViewController: parent)
        popup.setText(title: title, message: message, yesOrNo: yesOrNo)
        
    }
    
    // ---------------------------------------------------------------------
    
    func startRepeatingUpdates(){
        
        // Setup update timer for tech connections
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateParameters), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(getToggles), userInfo: nil, repeats: true)
        
    }
    
    func resetServer(){
     
        lb_listening_port?.text = "Listening on port: " + (tb_dest_port?.text!)!
        
        stopServer()
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startServer), userInfo: nil, repeats: false)
        
    }
    
    // -------------------------------
    // Update parameters
    // -------------------------------
    
    func updateParameters(){
        
        let destination_port = ViewController.boxPort
        sendPacket(body: "^^IdX", ipAddString: "255.255.255.255", port: destination_port)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UDP repeat of recevied data
    func techUpdate(units:Int,serial:String,unitNumber:String,unitIP:String,unitMAC:String,unitPort:String,destIP:String,destMAC:String){
        
        if(ViewController.connectToTech == 0) {
            return
        }
        
        let thisIP = getIFAddresses()
        
        let dataString = "<1>\(units)</1>" +
            "<2>\(serial)</2>" +
            "<3>\(unitNumber)</3>" +
            "<4>\(unitIP)</4>" +
            "<5>\(unitMAC)</5>" +
            "<6>\(unitPort)</6>" +
            "<7>\(destIP)</7>" +
            "<8>\(destMAC)</8>" +
        "<9>\(thisIP)</9>"
        
        let sendString = "<" + ViewController.connectCode + ">" + dataString
        
        var techPort = "3520"
        switch ViewController.connectToTech {
            
        case 1:
            techPort = "3531"
            break
            
        case 2:
            techPort = "3532"
            break
            
        case 3:
            techPort = "3534"
            break
            
        default:
            break
        }
        
        sendPacket(body: sendString, ipAddString: "72.16.182.60", port: techPort)
        
    }

    func getToggles() {
        
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: ViewController.boxPort)
        
    }
    
    //--------------------------------------------------------------------------
    // Low Level UDP code
    //--------------------------------------------------------------------------
    
    // -----------------
    // Receiving
    // -----------------
    
    fileprivate var _socket: GCDAsyncUdpSocket?
    fileprivate var socket: GCDAsyncUdpSocket? {
        get {
            if _socket == nil {
                _socket = getNewSocket()
            }
            return _socket
        }
        set {
            if _socket != nil {
                _socket?.close()
            }
            _socket = newValue
        }
    }
    
    fileprivate func getNewSocket() -> GCDAsyncUdpSocket? {
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(ViewController.elConfigSaveFile)
            
            //reading
            do {
                ViewController.boxPort = try String(contentsOf: path, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}
            
        }
        
        // Bind to CallerID.com port (3520)
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            
            let port = UInt16(ViewController.boxPort)
            
            try sock.bind(toPort: port!)
            try sock.enableBroadcast(true)
            
        } catch _ as NSError {
            
            return nil
            
        }
        return sock

    }
    
    @objc fileprivate func startServer() {
        
        do {
            try socket?.beginReceiving()
        } catch _ as NSError{
            
            return
            
        }
        
    }
    
    fileprivate func stopServer() {
        
        if socket != nil {
            socket?.pauseReceiving()
            socket?.close()
            socket = nil
        }
        
    }
    
    // --------------------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    //                     Receive data from a UDP broadcast
    // -------------------------------------------------------------------------
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        
        if let udpRecieved = NSString(data: data, encoding: String.Encoding.ascii.rawValue){
        
            let commPattern = "([Ee])([Cc])([Xx])([Uu])([Dd])([Aa])([Ss])([Oo])([Bb])([Kk])([Tt]) L=(\\d{1,2}) (\\d{1,2}/\\d{1,2} (\\d{1,2}:\\d{1,2}:\\d{1,2}))"
            let commRegex = try! NSRegularExpression(pattern: commPattern, options: [])
            let commMatches = commRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: (udpRecieved.length)))
        
            if(commMatches.count>0){
            
                var date = "n/a"
            
                commRegex.enumerateMatches(in: udpRecieved as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:(udpRecieved.length)))
                {(result : NSTextCheckingResult?, _, _) in
                    let capturedRange = result!.rangeAt(1)
                    if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                        date = (udpRecieved.substring(with: result!.rangeAt(13)))
                        
                        lb_date_time.setTitle(date, for: .normal)
                        
                    }
                
                }
            }
        }

    
        // ---------------------
        // X COMMAND RECEIVED
        // ---------------------
        let length = data.count
        if(length > 85){
    
            // Make sure it is a CallerID X command packet
            if(!(data[0]==94 && data[1]==94)){
                return
            }
    
            /*
             <1>units dectected</1>
             <2>serial number</2>
             <3>Unit number</3>
             <4>unit ip</4>
             <5>unit mac</5>
             <6>unit port</6>
             <7>dest ip</7>
             <8>dest mac</8>
             <9>this ip</9>
             */
            
            // Only one unit at a time
            let unitsDetected = 1
            
            // Serial Number
            let serial_number = "<ios device>"
            
            // Unit Number
            let unit_num_1 = data[57]
            let unit_num_2 = data[58]
            let unit_num_3 = data[59]
            let unit_num_4 = data[60]
            let unit_num_5 = data[61]
            let unit_num_6 = data[62]
            
            let unit_number = String(unit_num_1) + String(unit_num_2) + String(unit_num_3) + String(unit_num_4) + String(unit_num_5) + String(unit_num_6)
            
            if(tb_unit_number != nil && !tb_unit_number.isEditing){
                tb_unit_number?.text = unit_number
            }
            
            
            // Get UNIT IP address
            let unit_ip_1 = data[33]
            let unit_ip_2 = data[34]
            let unit_ip_3 = data[35]
            let unit_ip_4 = data[36]
            
            let unit_ip = String(unit_ip_1) + "." + String(unit_ip_2) + "." + String(unit_ip_3) + "." + String(unit_ip_4)
            
            // Get UNIT MAC address
            var unit_mac_1 = String(format:"%X", data[24])
            if(unit_mac_1.characters.count<2){
                unit_mac_1 = "0" + unit_mac_1
            }
            
            var unit_mac_2 = String(format:"%X", data[25])
            if(unit_mac_2.characters.count<2){
                unit_mac_2 = "0" + unit_mac_2
            }
            
            var unit_mac_3 = String(format:"%X", data[26])
            if(unit_mac_3.characters.count<2){
                unit_mac_3 = "0" + unit_mac_3
            }
            
            var unit_mac_4 = String(format:"%X", data[27])
            if(unit_mac_4.characters.count<2){
                unit_mac_4 = "0" + unit_mac_4
            }
            
            var unit_mac_5 = String(format:"%X", data[28])
            if(unit_mac_5.characters.count<2){
                unit_mac_5 = "0" + unit_mac_5
            }
            
            var unit_mac_6 = String(format:"%X", data[29])
            if(unit_mac_6.characters.count<2){
                unit_mac_6 = "0" + unit_mac_6
            }
            
            let unit_mac_address = unit_mac_1 + "-" + unit_mac_2 + "-" + unit_mac_3 + "-" + unit_mac_4 + "-" + unit_mac_5 + "-" + unit_mac_6
            
            // Unit PORT
            let port_hex = String(format:"%X", data[52]) + String(format:"%X", data[53])
            let port_int = Int(port_hex, radix: 16)
            let port_i : Int = port_int!
            let dest_port = String(port_i)
            
            if(tb_dest_port != nil && !tb_dest_port.isEditing){
                tb_dest_port?.text = dest_port
            }
            
            
            // Get Dest IP address
            let dest_ip_1 = data[40]
            let dest_ip_2 = data[41]
            let dest_ip_3 = data[42]
            let dest_ip_4 = data[43]
            
            let dest_ip = String(dest_ip_1) + "." + String(dest_ip_2) + "." + String(dest_ip_3) + "." + String(dest_ip_4)
            
            if(tb_dest_ip != nil && !tb_dest_ip.isEditing){
                tb_dest_ip?.text = dest_ip
            }
            
            
            // Get UNIT MAC address
            var dest_mac_1 = String(format:"%X", data[66])
            if(dest_mac_1.characters.count<2){
                dest_mac_1 = "0" + dest_mac_1
            }
            
            var dest_mac_2 = String(format:"%X", data[67])
            if(dest_mac_2.characters.count<2){
                dest_mac_2 = "0" + dest_mac_2
            }
            
            var dest_mac_3 = String(format:"%X", data[68])
            if(dest_mac_3.characters.count<2){
                dest_mac_3 = "0" + dest_mac_3
            }
            
            var dest_mac_4 = String(format:"%X", data[69])
            if(dest_mac_4.characters.count<2){
                dest_mac_4 = "0" + dest_mac_4
            }
            
            var dest_mac_5 = String(format:"%X", data[70])
            if(dest_mac_5.characters.count<2){
                dest_mac_5 = "0" + dest_mac_5
            }
            
            var dest_mac_6 = String(format:"%X", data[71])
            if(dest_mac_6.characters.count<2){
                dest_mac_6 = "0" + dest_mac_6
            }
            
            let dest_mac_address = dest_mac_1 + "-" + dest_mac_2 + "-" + dest_mac_3 + "-" + dest_mac_4 + "-" + dest_mac_5 + "-" + dest_mac_6
            
            if(tb_dest_mac != nil && !tb_dest_mac.isEditing){
                tb_dest_mac?.text = dest_mac_address
            }
            
            techUpdate(units: unitsDetected, serial: serial_number, unitNumber: unit_number, unitIP: unit_ip, unitMAC: unit_mac_address, unitPort: dest_port, destIP: dest_ip, destMAC: dest_mac_address)
            
        }
        else{
            if(length < 7){
                return
            }
            
            var displayString:String = ""
            let bArray = Array(data)
            for n in bArray{
                
                var num = n
                let d = NSData(bytes: &num, length: 1)
                
                let isAscii = (num > 31 && num < 127)
                
                if (isAscii){
                    
                    let c = String(data: d as Data, encoding: String.Encoding(rawValue: String.Encoding.ascii.rawValue))
                    displayString.append(c!)
                }
                else{
                    displayString.append("x")
                }
                
            }
            
            logRawData(data: displayString)
            
            
        }
        
    }
    
    // -----------------
    // Sending
    // -----------------
    func sendPacket(body: String,ipAddString:String,port:String){
        
        let host = ipAddString
        let port = UInt16(port)
        
        guard socket != nil else {
            return
        }
        
        socket?.send(body.data(using: String.Encoding.utf8)!, toHost: host, port: port!, withTimeout: 2, tag: 0)
        
    }
    
    //-----------------------------------
    // Lower level functions
    //-----------------------------------
    func convertPointerToArray(length: Int, data: UnsafePointer<Int8>) -> [Int8] {
        
        let buffer = UnsafeBufferPointer(start: data, count: length);
        return Array(buffer)
        
    }
    
    func getIFAddresses() -> String {
        
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return "unknown" }
        guard let firstAddr = ifaddr else { return "unknown" }
        
        // For each interface ...
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let flags = Int32(ptr.pointee.ifa_flags)
            var addr = ptr.pointee.ifa_addr.pointee
            
            // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
            if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                    nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                        let address = String(cString: hostname)
                        addresses.append(address)
                    }
                }
            }
        }
        
        freeifaddrs(ifaddr)
        
        for address in addresses {
            
            let ipPattern = "\\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\\.|$)){4}\\b"
            let ipRegex = try! NSRegularExpression(pattern: ipPattern, options: [])
            let ipMatches = ipRegex.matches(in: address, options: [], range: NSRange(location: 0, length: address.characters.count))
            
            if(ipMatches.count>0){
                return address
            }
        }
        
        return "unknown"
        
    }
}

extension String {
    var asciiArray: [UInt32] {
        return unicodeScalars.filter{$0.isASCII}.map{$0.value}
    }
}
extension Character {
    var asciiValue: UInt32? {
        return String(self).unicodeScalars.filter{$0.isASCII}.first?.value
    }
}
