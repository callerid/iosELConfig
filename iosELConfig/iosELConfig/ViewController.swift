//
//  ViewController.swift
//  iosELConfig
//
//  Created by mac on 3/23/17.
//  Copyright © 2017 CallerId.com. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UITableViewController, GCDAsyncUdpSocketDelegate {

    let commdata_datasource_delegate = CommDataView()
    
    //-----------------------------------------
    // LINK UI
    //-----------------------------------------
    
    @IBOutlet weak var btn_e: UIButton!
    @IBOutlet weak var btn_c: UIButton!
    @IBOutlet weak var btn_a: UIButton!
    @IBOutlet weak var btn_x: UIButton!
    @IBOutlet weak var btn_u: UIButton!
    @IBOutlet weak var btn_d: UIButton!
    @IBOutlet weak var btn_s: UIButton!
    @IBOutlet weak var btn_o: UIButton!
    @IBOutlet weak var btn_k: UIButton!
    @IBOutlet weak var btn_b: UIButton!
    @IBOutlet weak var btn_t: UIButton!
    
    @IBOutlet weak var tbv_comm: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tbv_comm.dataSource = commdata_datasource_delegate
        tbv_comm.delegate = commdata_datasource_delegate
        
        startServer()
        
        // Startup with V command to load parameters
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255")
        
    }

    //-------------------------------------------------------------------------
    // Actions
    //-------------------------------------------------------------------------
    
    @IBAction func btn_toggles_click(_ sender: Any) {
    
        sendPacket(body: "^^Id-V", ipAddString: "255.255.255.255")
    
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
        command_click(command: "V")
    }
    
    func command_click(command:String){
        
        let commandStr = "^^Id-\(command)"
        
        sendPacket(body: commandStr, ipAddString: "255.255.255.255")
        
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
                        btn_e.isEnabled = true
                        btn_c.isEnabled = true
                        btn_x.isEnabled = true
                        btn_u.isEnabled = true
                        btn_d.isEnabled = true
                        btn_a.isEnabled = true
                        btn_s.isEnabled = true
                        btn_o.isEnabled = true
                        btn_b.isEnabled = true
                        btn_k.isEnabled = true
                        btn_t.isEnabled = true
                    
                        // Update toggles
                        btn_e.setTitle(e, for: .normal)
                        if(e=="e"){
                            btn_e.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_e.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_e.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_e.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_c.setTitle(c, for: .normal)
                        if(c=="c"){
                            btn_c.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_c.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_c.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_c.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                        
                        btn_x.setTitle(x, for: .normal)
                        if(x=="x"){
                            btn_x.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_x.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_x.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_x.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
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
                        
                        btn_t.setTitle(t, for: .normal)
                        if(t=="t"){
                            btn_t.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                            btn_t.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
                        }
                        else{
                            btn_t.setTitleColor(#colorLiteral(red: 0.9412175004, green: 0.9755728998, blue: 1, alpha: 1), for: .normal)
                            btn_t.backgroundColor = #colorLiteral(red: 0.1651657283, green: 0.2489949437, blue: 0.4013115285, alpha: 1)
                        }
                    
                    }
                }
                
            }
            
            
        }
    }
    
    // -----------------
    // Sending
    // -----------------
    var _socketSend: GCDAsyncUdpSocket?
    var socketSend: GCDAsyncUdpSocket? {
        get {
            if _socketSend == nil {
                guard let port = UInt16("3520"), port > 0 else {
                    return nil
                }
                let socketSend = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
                do {
                    try socketSend.enableBroadcast(true)
                } catch _ as NSError {
                    socketSend.close()
                    return nil
                }
                _socketSend = socketSend
            }
            return _socketSend
        }
        set {
            _socketSend?.close()
            _socketSend = newValue
        }
    }
    
    deinit {
        socketSend = nil
    }
    
    func sendPacket(body: String,ipAddString:String){
        
        let host = ipAddString
        let port = UInt16("3520")
        
        guard socketSend != nil else {
            return
        }
        
        socketSend?.send(body.data(using: String.Encoding.utf8)!, toHost: host, port: port!, withTimeout: 2, tag: 0)
        
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

