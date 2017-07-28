//
//  ViewController.swift
//  iosELConfig
//
//  Created by mac on 3/23/17.
//  Copyright © 2017 CallerId.com. All rights reserved.
//

import UIKit
import CocoaAsyncSocket
import QuartzCore

class ViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, GCDAsyncUdpSocketDelegate {

    let commdata_datasource_delegate = CommDataView()
    
    var suggestedIP = Array(arrayLiteral: 0,0,0,0)
    
    static let elConfigSaveFile = "iosELConfigSaves.txt"
    static var preventUpdates = false
    
    //-----------------------------------------
    // LINK UI
    //-----------------------------------------
    @IBOutlet weak var tb_header: UINavigationItem!
    
    @IBOutlet weak var btn_c: UIButton!
    @IBOutlet weak var btn_a: UIButton!
    @IBOutlet weak var btn_u: UIButton!
    @IBOutlet weak var btn_d: UIButton!
    @IBOutlet weak var btn_s: UIButton!
    @IBOutlet weak var btn_o: UIButton!
    @IBOutlet weak var btn_k: UIButton!
    @IBOutlet weak var btn_b: UIButton!
    
    @IBOutlet weak var btn_retrieve_toggles: UIButton!
    @IBOutlet weak var btn_adv_settings: UIButton!
    
    @IBOutlet weak var btn_t1: UIButton!
    @IBOutlet weak var btn_t2: UIButton!
    @IBOutlet weak var btn_t3: UIButton!
    @IBOutlet weak var tb_code: UITextField!
    @IBOutlet weak var lb_code: UILabel!
    
    @IBOutlet weak var tbv_comm: UITableView!
    
    @IBOutlet weak var lbSetSuggested: UIButton!
    
    @IBOutlet weak var tb_unit_ip: UITextField!
    
    @IBOutlet weak var pickerview_lnCnt: UIPickerView!
    
    @IBOutlet weak var tv_network_settings: UITableViewCell!
    @IBOutlet weak var tv_commands: UITableViewCell!
    // ----------------
    // Globals
    // ----------------
    let pickerDataSource = ["01","05","09","17","21","25","33"]
    static var boxPort:String = "3520"
    // ----------------
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        let titleData = pickerDataSource[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 15.0)!,NSForegroundColorAttributeName:#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1)])
        
        return myTitle
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // update line count
        var sendString:String = ""
        switch (pickerDataSource[row]){
            
            case "1":
                sendString = "^^Id-N0000007701\r\n"
            break
            
            case "5":
                sendString = "^^Id-N0000007705\r\n"
            break
            
            case "9":
                sendString = "^^Id-N0000007709\r\n"
            break
            
            case "17":
                sendString = "^^Id-N0000007711\r\n"
            break
            
            case "21":
                sendString = "^^Id-N0000007715\r\n"
            break
            
            case "25":
                sendString = "^^Id-N0000007719\r\n"
            break
            
            case "33":
                sendString = "^^Id-N0000007721\r\n"
            break
            
            default:
                sendString = "^^Id-N0000007701\r\n"
            break
        }
        
        sendPacket(body: sendString, ipAddString: "255.255.255.255", port: ViewController.boxPort)
        
    }
    
    // ----------------
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        pickerview_lnCnt.delegate = self
        pickerview_lnCnt.dataSource = self
        
        tv_network_settings.selectionStyle = .none
        tv_commands.selectionStyle = .none
        
            
        btn_retrieve_toggles.layer.cornerRadius = 10
        btn_retrieve_toggles.clipsToBounds = true
            
        tb_unit_ip.addTarget(self, action: #selector(ViewController.tb_ip_validation(txtField:)), for: UIControlEvents.editingChanged)
        
        btn_adv_settings.layer.cornerRadius = 10
        btn_adv_settings.clipsToBounds = true
            
        btn_t1.layer.cornerRadius = 10
        btn_t1.clipsToBounds = true
            
        btn_t2.layer.cornerRadius = 10
        btn_t2.clipsToBounds = true
            
        btn_t3.layer.cornerRadius = 10
        btn_t3.clipsToBounds = true
            
        tbv_comm.dataSource = commdata_datasource_delegate
        tbv_comm.delegate = commdata_datasource_delegate
        
        // Startup with V command to load parameters
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: ViewController.boxPort)
        
        // Setup update timer for tech connections
         _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startRepeatingUpdates), userInfo: nil, repeats: false)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        ViewController.preventUpdates = false
        startServer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ViewController.preventUpdates = true
        ViewController.saveDestPort()
        stopServer()
    }

    static func saveDestPort(){
        
        let text = ViewController.boxPort
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let path = dir.appendingPathComponent(ViewController.elConfigSaveFile)
            
            //writing
            do {
                try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
            }
            catch {/* error handling here */}
            
        }
        
    }
    
    func startRepeatingUpdates(){
        
        // Setup update timer for tech connections
        _ = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(updateParameters), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(getToggles), userInfo: nil, repeats: true)
        
    }
    //-------------------------------------------------------------------------
    // Actions
    //-------------------------------------------------------------------------
    @IBAction func tb_unit_ip_undo(_ sender: Any) {
        tb_unit_ip?.undoManager?.removeAllActions()
    }
    
    @IBAction func tb_unit_ip_did_end(_ sender: Any) {
    
        let hexIP = convertIPToHexString(ipAddress: (tb_unit_ip?.text!)!);
        if(hexIP != "-1"){
            
            sendPacket(body: "^^IdI" + hexIP, ipAddString: "255.255.255.255", port: ViewController.boxPort)//External IP
            updateParameters();
            
        }else{
            
            // Show message that IP is in incorrect format
            showPopup(parent: self, title: "Invalid IP Address", message: "The IP Address you have entered is not a valid IP address. Please retry.",yesOrNo: false)
            
        }
        
    }
    
    @IBAction func setSuggested_click(_ sender: Any) {
        
        let suggestedIPString = String(suggestedIP[0]) + "." + String(suggestedIP[1]) + "." + String(suggestedIP[2]) + "." + String(suggestedIP[3])
        
        let hexIP = convertIPToHexString(ipAddress: suggestedIPString);
        if(hexIP != "-1"){
            
            sendPacket(body: "^^IdI" + hexIP, ipAddString: "255.255.255.255", port: ViewController.boxPort)//External IP
            updateParameters();
            
        }else{
            
            // Show message that IP is in incorrect format
            showPopup(parent: self, title: "Invalid IP Address", message: "The IP Address you have entered is not a valid IP address. Please retry.",yesOrNo: false)
            
        }
        
    }
    
    // -------------------
    // Toggles
    // -------------------
    @IBAction func btn_toggles_click(_ sender: Any) {
    
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: ViewController.boxPort)
    
    }
    
    @IBAction func c_click(_ sender: Any) {
        
        if(btn_c.titleLabel?.text=="c"){
            command_click(command: "C")
        }
        else{
            command_click(command: "c")
        }
        
    }
    
    @IBAction func u_click(_ sender: Any) {
        
        if(btn_u.titleLabel?.text=="u"){
            command_click(command: "U")
        }
        else{
            command_click(command: "u")
        }
        
    }
    
    @IBAction func d_click(_ sender: Any) {
        
        if(btn_d.titleLabel?.text=="d"){
            command_click(command: "D")
        }
        else{
            command_click(command: "d")
        }
        
    }
    
    @IBAction func a_click(_ sender: Any) {
        
        if(btn_a.titleLabel?.text=="a"){
            command_click(command: "A")
        }
        else{
            command_click(command: "a")
        }
        
    }
    
    @IBAction func s_click(_ sender: Any) {
        
        if(btn_s.titleLabel?.text=="s"){
            command_click(command: "S")
        }
        else{
            command_click(command: "s")
        }
        
    }
    
    @IBAction func o_click(_ sender: Any) {
        
        if(btn_o.titleLabel?.text=="o"){
            command_click(command: "O")
        }
        else{
            command_click(command: "o")
        }
        
    }
    
    @IBAction func b_click(_ sender: Any) {
        
        if(btn_b.titleLabel?.text=="b"){
            command_click(command: "B")
        }
        else{
            command_click(command: "b")
        }
        
    }
    
    @IBAction func k_click(_ sender: Any) {
        
        if(btn_k.titleLabel?.text=="k"){
            command_click(command: "K")
        }
        else{
            command_click(command: "k")
        }
        
    }
    
    // -------------------
    // Tech connections
    // -------------------
    
    @IBAction func tb_code_change(_ sender: Any) {
        
        ViewController.connectCode = tb_code.text!
        
    }
    
    
    static var connectCode = "0000"
    static var connectToTech = 0
    
    @IBAction func t1_click(_ sender: Any) {
        
        ViewController.connectToTech = 1
        
        btn_t1.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        btn_t1.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        
        btn_t2.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
        btn_t2.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
        
        btn_t3.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
        btn_t3.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
        
        tb_code.isHidden = false
        lb_code.isHidden = false
        
    }
    
    @IBAction func t2_click(_ sender: Any) {
        
        ViewController.connectToTech = 2
        
        btn_t2.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        btn_t2.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        
        btn_t1.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
        btn_t1.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
        
        btn_t3.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
        btn_t3.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
        
        tb_code.isHidden = false
        lb_code.isHidden = false
        
    }
    
    @IBAction func t3_click(_ sender: Any) {
        
        ViewController.connectToTech = 3
        
        btn_t3.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        btn_t3.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        
        btn_t2.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
        btn_t2.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
        
        btn_t1.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
        btn_t1.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
        
        tb_code.isHidden = false
        lb_code.isHidden = false
        
    }
    
    // UDP repeat of recevied data
    func techRepeat(repeatString:String){
        
        if(ViewController.connectToTech == 0) {
            return
        }
        
        let sendString = "<" + tb_code.text! + ">" + repeatString
        
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
        
        let sendString = "<" + tb_code.text! + ">" + dataString
        
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
    
    // --------------------
    
    // -------------------------------
    // Update parameters
    // -------------------------------
    
    func updateParameters(){
    
        let destination_port = ViewController.boxPort
        sendPacket(body: "^^IdX", ipAddString: "255.255.255.255", port: destination_port)
        
    }
    
    //-------------------------------------------------------------------------
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func comm_data_clear(_ sender: Any) {
    
        commdata_datasource_delegate.clear()
        tbv_comm.reloadData()
        
    }
    
    @IBAction func v_click(_ sender: Any) {
        
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: ViewController.boxPort)
        
    }
    
    func command_click(command:String){
        
        let commandStr = "^^Id-\(command)"
        
        sendPacket(body: commandStr, ipAddString: "255.255.255.255",port: ViewController.boxPort)
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getToggles), userInfo: nil, repeats: false)
        
        
    }
    
    func getToggles() {
        
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: ViewController.boxPort)
        
    }
    
    //--------------------------------------------------------------------------
    // Log comm data
    //--------------------------------------------------------------------------
    
    func logCommData(data:String){

        if(commdata_datasource_delegate.logCommData(data: data)){
            
            let comm_data_count = commdata_datasource_delegate.getCommDataCount()
            
            tbv_comm.beginUpdates()
            tbv_comm.insertRows(at: [IndexPath(row: comm_data_count-1, section: 0)], with: .automatic)
            tbv_comm.endUpdates()
        
        }
        
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
        
        if(ViewController.preventUpdates){
            return nil
        }
        
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
    
    fileprivate func startServer() {
        
        do {
            if(socket == nil){
                socket = getNewSocket()
            }
            else if(socket?.isClosed())!{
                socket = getNewSocket()
            }
            try socket?.beginReceiving()
        } catch _ as NSError {
            
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
        
        if let udpRecieved = NSString(data: data, encoding: String.Encoding.ascii.rawValue) {
            
            if(udpRecieved.length>10){
                
                // parse and handle udp data----------------------------------------------
                // declare used variables for matching
                var lineNumber = "n/a"
                var startOrEnd = "n/a"
                var inboundOrOutbound = "n/a"
                var duration = "n/a"
                var ckSum = "B"
                var callRing = "n/a"
                var callTime = "01/01 0:00:00"
                var phoneNumber = "n/a"
                var callerId = "n/a"
                var detailedType = "n/a"
                
                // define CallerID.com regex strings used for parsing CallerID.com hardware formats
                let callRecordPattern = ".*(\\d\\d) ([IO]) ([ES]) (\\d{4}) ([GB]) (.)(\\d) (\\d\\d/\\d\\d \\d\\d:\\d\\d [AP]M) (.{8,15})(.*)"
                let detailedPattern = ".*(\\d\\d) ([NFR]) {13}(\\d\\d/\\d\\d \\d\\d:\\d\\d:\\d\\d)"
                
                let callRecordRegex = try! NSRegularExpression(pattern: callRecordPattern, options: [])
                let detailedRegex = try! NSRegularExpression(pattern: detailedPattern, options: [])
                
                // get matches for regular expressions
                let callRecordMatches = callRecordRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: udpRecieved.length))
                let detailedMatches = detailedRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: udpRecieved.length))
                
                // look at call record matches first to determine if call record
                if(callRecordMatches.count>0){
                    
                    // IS CALL RECORD
                    // -- get groups out of regex
                    callRecordRegex.enumerateMatches(in: udpRecieved as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:udpRecieved.length))
                    {(result : NSTextCheckingResult?, _, _) in
                        let capturedRange = result!.rangeAt(1)
                        if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                            
                            lineNumber = udpRecieved.substring(with: result!.rangeAt(1))
                            inboundOrOutbound = udpRecieved.substring(with: result!.rangeAt(2))
                            startOrEnd = udpRecieved.substring(with: result!.rangeAt(3))
                            duration = udpRecieved.substring(with: result!.rangeAt(4))
                            ckSum = udpRecieved.substring(with: result!.rangeAt(5))
                            callRing = udpRecieved.substring(with: result!.rangeAt(6)) + udpRecieved.substring(with: result!.rangeAt(7))
                            callTime = udpRecieved.substring(with: result!.rangeAt(8))
                            phoneNumber = udpRecieved.substring(with: result!.rangeAt(9))
                            callerId = udpRecieved.substring(with: result!.rangeAt(10))
                            
                        }
                        
                        // Log the call
                        let betweenPadding = 1
                        
                        logCommData(data: lineNumber.padding(toLength: 3 + betweenPadding, withPad: " ", startingAt: 0) +
                            inboundOrOutbound.padding(toLength: 2 + betweenPadding, withPad: " ", startingAt: 0) +
                            startOrEnd.padding(toLength: 2 + betweenPadding, withPad: " ", startingAt: 0) +
                            duration.padding(toLength: 6 + betweenPadding, withPad: " ", startingAt: 0) +
                            ckSum.padding(toLength: 2 + betweenPadding, withPad: " ", startingAt: 0) +
                            callRing.padding(toLength: 4 + betweenPadding, withPad: " ", startingAt: 0) +
                            callTime.padding(toLength: 16 + betweenPadding, withPad: " ", startingAt: 0) +
                            phoneNumber.padding(toLength: 16 + betweenPadding, withPad: " ", startingAt: 0) +
                            callerId.padding(toLength: 16 + betweenPadding, withPad: " ", startingAt: 0))
                        
                    }
                    
                    // -----------------------------
                    
                }
                
                // look at detail matches if detailed record
                if(detailedMatches.count>0){
                    
                    // IS DETAILED RECORD
                    detailedRegex.enumerateMatches(in: udpRecieved as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:udpRecieved.length))
                    {(result : NSTextCheckingResult?, _, _) in
                        let capturedRange = result!.rangeAt(1)
                        if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                            
                            lineNumber = udpRecieved.substring(with: result!.rangeAt(1))
                            detailedType = udpRecieved.substring(with: result!.rangeAt(2))
                            callTime = udpRecieved.substring(with: result!.rangeAt(3))
                            
                            let betweenPadding = 1;
                            
                            logCommData(data: lineNumber.padding(toLength: 3 + betweenPadding, withPad: " ", startingAt: 0) +
                                detailedType.padding(toLength: 2 + betweenPadding, withPad: " ", startingAt: 0) +
                                callTime.padding(toLength: 16, withPad: " ", startingAt: 0))
                            
                        }
                    }
                    
                }
                
            }
            
            
        }
        
        // If comm data then log
        if(data.count > 10){
            
            let udpRecieved = NSString(data: data, encoding: String.Encoding.ascii.rawValue)
            
            let commPattern = "([Ee])([Cc])([Xx])([Uu])([Dd])([Aa])([Ss])([Oo])([Bb])([Kk])([Tt]) L=(\\d{1,2}) (\\d{1,2}/\\d{1,2} (\\d{1,2}:\\d{1,2}:\\d{1,2}))"
            let commRegex = try! NSRegularExpression(pattern: commPattern, options: [])
            let commMatches = commRegex.matches(in: udpRecieved! as String, options: [], range: NSRange(location: 0, length: (udpRecieved?.length)!))
            
            if(commMatches.count>0){
                
                var recData = "n/a"
                var e = "n/a"
                var c = "n/a"
                var x = "n/a"
                var u = "n/a"
                var d = "n/a"
                var a = "n/a"
                var s = "n/a"
                var o = "n/a"
                var b = "n/a"
                var k = "n/a"
                var t = "n/a"
                var line = "n/a"
                var date = "n/a"
                
                commRegex.enumerateMatches(in: udpRecieved! as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:(udpRecieved?.length)!))
                {(result : NSTextCheckingResult?, _, _) in
                    let capturedRange = result!.rangeAt(1)
                    if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                        
                        recData = (udpRecieved?.substring(with: result!.rangeAt(0)))!
                        e = (udpRecieved?.substring(with: result!.rangeAt(1)))!
                        c = (udpRecieved?.substring(with: result!.rangeAt(2)))!
                        x = (udpRecieved?.substring(with: result!.rangeAt(3)))!
                        u = (udpRecieved?.substring(with: result!.rangeAt(4)))!
                        d = (udpRecieved?.substring(with: result!.rangeAt(5)))!
                        a = (udpRecieved?.substring(with: result!.rangeAt(6)))!
                        s = (udpRecieved?.substring(with: result!.rangeAt(7)))!
                        o = (udpRecieved?.substring(with: result!.rangeAt(8)))!
                        b = (udpRecieved?.substring(with: result!.rangeAt(9)))!
                        k = (udpRecieved?.substring(with: result!.rangeAt(10)))!
                        t = (udpRecieved?.substring(with: result!.rangeAt(11)))!
                        line = (udpRecieved?.substring(with: result!.rangeAt(12)))!
                        date = (udpRecieved?.substring(with: result!.rangeAt(13)))!
                        
                    }
                    
                    // set line
                    let lntCntIndex = pickerDataSource.index(of: line)
                    pickerview_lnCnt.selectRow(lntCntIndex!, inComponent: 0, animated: true)
                    
                    if(btn_a != nil){
                        
                        // if got toggles then enable them
                        btn_c.isEnabled = true
                        btn_u.isEnabled = true
                        btn_d.isEnabled = true
                        btn_a.isEnabled = true
                        btn_s.isEnabled = true
                        btn_o.isEnabled = true
                        btn_b.isEnabled = true
                        btn_k.isEnabled = true
                        
                        // Update toggles
                        btn_c.setTitle(c, for: .normal)
                        if(c=="c"){
                            btn_c.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_c.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_c.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_c.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_u.setTitle(u, for: .normal)
                        if(u=="u"){
                            btn_u.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_u.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_u.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_u.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_d.setTitle(d, for: .normal)
                        if(d=="d"){
                            btn_d.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_d.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_d.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_d.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_a.setTitle(a, for: .normal)
                        if(a=="a"){
                            btn_a.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_a.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_a.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_a.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_s.setTitle(s, for: .normal)
                        if(s=="s"){
                            btn_s.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_s.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_s.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_s.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_o.setTitle(o, for: .normal)
                        if(o=="o"){
                            btn_o.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_o.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_o.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_o.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_b.setTitle(b, for: .normal)
                        if(b=="b"){
                            btn_b.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_b.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_b.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_b.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_k.setTitle(k, for: .normal)
                        if(k=="k"){
                            btn_k.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_k.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_k.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_k.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
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
            
            // Get UNIT IP address
            let unit_ip_1 = data[33]
            let unit_ip_2 = data[34]
            let unit_ip_3 = data[35]
            let unit_ip_4 = data[36]
            
            let unit_ip = String(unit_ip_1) + "." + String(unit_ip_2) + "." + String(unit_ip_3) + "." + String(unit_ip_4)
            
            if(tb_unit_ip != nil && !tb_unit_ip.isEditing){
                tb_unit_ip.text = unit_ip
            }
        
            // Get suggested IP
            let deviceIP:String = getIFAddresses()
            let deviceIP_parts = deviceIP.characters.split(separator: ".")
            
            let endingIP:Int = Int(String(deviceIP_parts[3]))!
            
            var suggestedPart = "90"
            
            if(endingIP<50 || endingIP>150) {
                suggestedPart = "90";
            }
            if(endingIP>50 && endingIP<150) {
                suggestedPart = "190";
            }
            
            let suggestedEnding = Int(suggestedPart)
            
            suggestedIP[0] = Int(String(deviceIP_parts[0]))!
            suggestedIP[1] = Int(String(deviceIP_parts[1]))!
            suggestedIP[2] = Int(String(deviceIP_parts[2]))!
            suggestedIP[3] = suggestedEnding!
            
            
            // Check suggested IP
            var isSuggested = false
            if (suggestedIP[0] == Int(unit_ip_1) &&
                suggestedIP[1] == Int(unit_ip_2) &&
                suggestedIP[2] == Int(unit_ip_3) &&
                suggestedIP[3] == Int(unit_ip_4)){
                
                isSuggested = true
                
            }
            
            if(isSuggested){
                lbSetSuggested.isHidden = true
            }
            else{
                lbSetSuggested.isHidden = false
                
                let fullSuggested = "Set Suggested IP: " + String(suggestedIP[0]) + "." + String(suggestedIP[1]) + "." + String(suggestedIP[2]) + "." + String(suggestedIP[3])
                
                lbSetSuggested.setTitle(fullSuggested, for: .normal)
            }
            
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
            
            // Get Dest IP address
            let dest_ip_1 = data[40]
            let dest_ip_2 = data[41]
            let dest_ip_3 = data[42]
            let dest_ip_4 = data[43]
            
            let dest_ip = String(dest_ip_1) + "." + String(dest_ip_2) + "." + String(dest_ip_3) + "." + String(dest_ip_4)
            
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
            
            techUpdate(units: unitsDetected, serial: serial_number, unitNumber: unit_number, unitIP: unit_ip, unitMAC: unit_mac_address, unitPort: dest_port, destIP: dest_ip, destMAC: dest_mac_address)
            
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

