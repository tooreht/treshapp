//
//  SensorViewController.swift
//  treshapp
//
//  Created by Marc Zimmermann on 31/05/16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit
import CocoaMQTT

class SensorViewController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var waitingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var sensor:Sensor!
    var mqtt: CocoaMQTT?
    var topic:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.topic = "siot/DAT/\(AppConstants.centerGUID)/\(self.sensor.guid)"
        displayLabel.text = sensor.name
        dataLabel.hidden = true
        activityIndicator.startAnimating()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: nil, usingBlock: { notification in
            self.connectMqtt()
        })
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil, usingBlock: { notification in
            self.disconnectMqtt()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        self.connectMqtt()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.disconnectMqtt()
    }
    
    func connectMqtt() {
        //        let mqttCli = CocoaMQTTCli()
        let clientIdPid = "CocoaMQTT-" + String(NSProcessInfo().processIdentifier)
        let mqtt = CocoaMQTT(clientId: clientIdPid, host: AppConstants.siotURL.host!, port: 1883)
        //        mqtt.username = "test"
        //        mqtt.password = "public"
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 90
        mqtt.delegate = self
        
        mqtt.connect()
        
        //        dispatch_main()
    }
    
    func disconnectMqtt() {
        print("unsubscribe from topic " + self.topic)
        self.mqtt?.unsubscribe(self.topic)
        self.mqtt?.disconnect()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func displayData(data: String) {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        dataLabel.hidden = false
        dataLabel.text = data
        waitingLabel.text = "Data received. Waiting for next udpate"
        
    }
}


extension SensorViewController: CocoaMQTTDelegate {
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        //print("didConnectAck \(ack.rawValue)")
        if ack == .ACCEPT {
            print(topic)
            mqtt.subscribe(topic, qos: CocoaMQTTQOS.QOS1)
            mqtt.ping()
        }
        
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage with message: \(message.string)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck with id: \(id)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceivedMessage: \(message.string) with id \(id)")
        NSNotificationCenter.defaultCenter().postNotificationName("MQTTMessageNotification" + "Foo", object: self, userInfo: ["message": message.string!, "topic": message.topic])
        displayData(message.string!)
    }
    
    func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
        print("didSubscribeTopic to \(topic)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("didUnsubscribeTopic to \(topic)")
    }
    
    func mqttDidPing(mqtt: CocoaMQTT) {
        print("didPing")
    }
    
    func mqttDidReceivePong(mqtt: CocoaMQTT) {
        _console("didReceivePong")
    }
    
    func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
        _console("mqttDidDisconnect")
    }
    
    func _console(info: String) {
        print("Delegate: \(info)")
    }
    
}
