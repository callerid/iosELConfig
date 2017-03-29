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

class ViewController: UITableViewController, GCDAsyncUdpSocketDelegate {

    let commdata_datasource_delegate = CommDataView()
    
    //-----------------------------------------
    // LINK UI
    //-----------------------------------------
    
    @IBOutlet weak var btn_c: UIButton!
    @IBOutlet weak var btn_a: UIButton!
    @IBOutlet weak var btn_u: UIButton!
    @IBOutlet weak var btn_d: UIButton!
    @IBOutlet weak var btn_s: UIButton!
    @IBOutlet weak var btn_o: UIButton!
    @IBOutlet weak var btn_k: UIButton!
    @IBOutlet weak var btn_b: UIButton!
    
    @IBOutlet weak var btn_t1: UIButton!
    @IBOutlet weak var btn_t2: UIButton!
    @IBOutlet weak var btn_t3: UIButton!
    @IBOutlet weak var tb_code: UITextField!
    @IBOutlet weak var lb_code: UILabel!
    
    @IBOutlet weak var tbv_comm: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        btn_t1.layer.cornerRadius = 10
        btn_t1.clipsToBounds = true
        
        btn_t2.layer.cornerRadius = 10
        btn_t2.clipsToBounds = true
        
        btn_t3.layer.cornerRadius = 10
        btn_t3.clipsToBounds = true
        
        tbv_comm.dataSource = commdata_datasource_delegate
        tbv_comm.delegate = commdata_datasource_delegate
        
        startServer()
        
        // Startup with V command to load parameters
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: "3520")
        
        // Setup update timer for tech connections
         _ = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(updateParameters), userInfo: nil, repeats: true)
        
    }

    //-------------------------------------------------------------------------
    // Actions
    //-------------------------------------------------------------------------
    // -------------------
    // Toggles
    // -------------------
    @IBAction func btn_toggles_click(_ sender: Any) {
    
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: "3520")
    
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
    
    var connectCode = "0000"
    var connectToTech = 0
    
    @IBAction func t1_click(_ sender: Any) {
        
        connectToTech = 1
        
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
        
        connectToTech = 2
        
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
        
        connectToTech = 3
        
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
        
        if(connectToTech == 0) {
            return
        }
        
        let sendString = "<" + tb_code.text! + ">" + repeatString
        
        var techPort = "3520"
        switch connectToTech {
            
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
        
        if(connectToTech == 0) {
            return
        }
        
        sendPacket(body: "^^IdX", ipAddString: "255.255.255.255", port: "3520")
        
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
        switch connectToTech {
            
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
        
        */
    }
    
    // -------------------------------
    // Update parameters
    // -------------------------------
    
    func updateParameters(){
    
        let nullStr:Character = "0"
        let sendString = "^^IdX".padding(toLength: 24, withPad: String(nullStr), startingAt: 0)
        sendPacket(body: sendString, ipAddString: "255.255.255.255", port: "3520")
        
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
        
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: "3520")
        
    }
    
    func command_click(command:String){
        
        let commandStr = "^^Id-\(command)"
        
        sendPacket(body: commandStr, ipAddString: "255.255.255.255",port: "3520")
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(getToggles), userInfo: nil, repeats: false)
        
        
    }
    
    func getToggles() {
        
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255",port: "3520")
        
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
        
        // set port to CallerID.com port --> 3520
        let port = UInt16(3520)
        
        // Bind to CallerID.com port (3520)
        let sock = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do {
            
            try sock.bind(toPort: port)
            try sock.enableBroadcast(true)
            
        } catch _ as NSError {
            
            return nil
            
        }
        return sock
    }
    
    fileprivate func startServer() {
        
        do {
            try socket?.beginReceiving()
        } catch _ as NSError {
            
            return
            
        }
        
    }
    
    fileprivate func stopServer(_ sender: AnyObject) {
        if socket != nil {
            socket?.pauseReceiving()
        }
        
    }
    
    // --------------------------------------------------------------------------------------
    
    // -------------------------------------------------------------------------
    //                     Receive data from a UDP broadcast
    // -------------------------------------------------------------------------
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        if let udpRecieved = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            
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
                        
                    }
                }
                
            }
            
            // If comm data then log
            if(lineNumber=="n/a"){
                
                let commPattern = "([Ee])([Cc])([Xx])([Uu])([Dd])([Aa])([Ss])([Oo])([Bb])([Kk])([Tt]) L=(\\d{1,2}) (\\d{1,2}/\\d{1,2} (\\d{1,2}:\\d{1,2}:\\d{1,2}))"
                let commRegex = try! NSRegularExpression(pattern: commPattern, options: [])
                let commMatches = commRegex.matches(in: udpRecieved as String, options: [], range: NSRange(location: 0, length: udpRecieved.length))
                
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
                    
                    commRegex.enumerateMatches(in: udpRecieved as String, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length:udpRecieved.length))
                    {(result : NSTextCheckingResult?, _, _) in
                        let capturedRange = result!.rangeAt(1)
                        if !NSEqualRanges(capturedRange, NSMakeRange(NSNotFound, 0)) {
                        
                            recData = udpRecieved.substring(with: result!.rangeAt(0))
                            e = udpRecieved.substring(with: result!.rangeAt(1))
                            c = udpRecieved.substring(with: result!.rangeAt(2))
                            x = udpRecieved.substring(with: result!.rangeAt(3))
                            u = udpRecieved.substring(with: result!.rangeAt(4))
                            d = udpRecieved.substring(with: result!.rangeAt(5))
                            a = udpRecieved.substring(with: result!.rangeAt(6))
                            s = udpRecieved.substring(with: result!.rangeAt(7))
                            o = udpRecieved.substring(with: result!.rangeAt(8))
                            b = udpRecieved.substring(with: result!.rangeAt(9))
                            k = udpRecieved.substring(with: result!.rangeAt(10))
                            t = udpRecieved.substring(with: result!.rangeAt(11))
                            line = udpRecieved.substring(with: result!.rangeAt(12))
                            date = udpRecieved.substring(with: result!.rangeAt(13))
                        
                        }
                    
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
    
    func getIFAddresses() -> [String] {
        
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return [] }
        guard let firstAddr = ifaddr else { return [] }
        
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
        return addresses
    }

}

