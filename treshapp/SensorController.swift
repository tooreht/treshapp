//
//  SensorController.swift
//  treshapp
//
//  Created by Marc Zimmermann on 31/05/16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit
import CocoaMQTT

class SensorController: UIViewController {
    
    @IBOutlet weak var displayLabel: UILabel!
    
    var sensor:Sensor!
    var mqtt: CocoaMQTT?
    
    @IBAction func saySomethingTapped(sender: UIButton) {
        displayLabel.text = "Hello World!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.connectMqtt()
        displayLabel.text = sensor.name
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func connectMqtt() {
        //        let mqttCli = CocoaMQTTCli()
        let clientIdPid = "CocoaMQTT-" + String(NSProcessInfo().processIdentifier)
        let mqtt = CocoaMQTT(clientId: clientIdPid, host: "siot.net", port: 1883)
        //        mqtt.username = "test"
        //        mqtt.password = "public"
        mqtt.willMessage = CocoaMQTTWill(topic: "/will", message: "dieout")
        mqtt.keepAlive = 90
        mqtt.delegate = self
        
        mqtt.connect()
        
        //        dispatch_main()
    }
}


extension SensorController: CocoaMQTTDelegate {
    func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        print("didConnect \(host):\(port)")
    }
    
    func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        //print("didConnectAck \(ack.rawValue)")
        if ack == .ACCEPT {
            //            mqtt.subscribe("chat/room/animals/client/+", qos: CocoaMQTTQOS.QOS1)
            mqtt.subscribe("siot/DAT/7F73-24E5-EBAB-4B71-A62F-98D4FDA02809/e42093a5-f420-894a-cf1b-1c8215014454", qos: CocoaMQTTQOS.QOS1)
            mqtt.subscribe("siot/DAT/7F73-24E5-EBAB-4B71-A62F-98D4FDA02809/35aff35c-c8d3-e0cd-40ab-2c797ae102a7", qos: CocoaMQTTQOS.QOS1)
            mqtt.ping()
            
            //            let chatViewController = storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController
            //            chatViewController?.mqtt = mqtt
            //            navigationController!.pushViewController(chatViewController!, animated: true)
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
