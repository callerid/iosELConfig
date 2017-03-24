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
    
    @IBOutlet weak var tbv_comm: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tbv_comm.dataSource = commdata_datasource_delegate
        tbv_comm.delegate = commdata_datasource_delegate
        
        startServer()
        
    }

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
    @IBAction func e_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func c_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func x_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func u_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func d_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func a_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func s_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func o_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func b_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func k_click(_ sender: Any) {
        command_click(command: "V")
    }
    @IBAction func t_click(_ sender: Any) {
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

        commdata_datasource_delegate.logCommData(data: data)
        let comm_data_count = commdata_datasource_delegate.getCommDataCount()
        
        tbv_comm.beginUpdates()
        tbv_comm.insertRows(at: [IndexPath(row: comm_data_count-1, section: 0)], with: .automatic)
        tbv_comm.endUpdates()
        
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
                    
                    
                    logCommData(data: recData)
                    
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

