//
//  ViewController.swift
//  treshapp
//
//  Created by Marc Zimmermann on 26/04/16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit
// import SocketIOClientSwift
import Alamofire

struct Sensor {
    var name:String
    var guid:String
}


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // These strings will be the data for the table view cells
//    let animals: [String] = ["Horse", "Cow", "Camel", "Sheep", "Goat"]
    var sensors = [Sensor]()
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSensors()
    }
    
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.animals.count
        return self.sensors.count
    }
    
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
//        cell.textLabel?.text = self.animals[indexPath.row]
        cell.textLabel?.text = self.sensors[indexPath.row].name
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }

    func getSensors() {
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        Alamofire.request(.GET, "https://httpbin.org/get", parameters: ["foo": "bar"])
//            .responseJSON { response in
//                print(response.request)  // original URL request
//                print(response.response) // URL response
//                print(response.data)     // server data
//                print(response.result)   // result of response serialization
//                
//                if let JSON = response.result.value {
//                    print("JSON: \(JSON)")
//                }
//        }
        
        let parameters = [
            "centerUID": "7F73-24E5-EBAB-4B71-A62F-98D4FDA02809",
//            "sensorUID": "35aff35c-c8d3-e0cd-40ab-2c797ae102a7",
            
        ]
        Alamofire.request(.POST, "http://siot.net:15780/getsensor", parameters: parameters)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
                
                for sensor in response.result.value as! [Dictionary<String, AnyObject>] {
                    let name = sensor["name"] as! String
                    let guid = sensor["guid"] as! String
                    let sensor = Sensor(name: name, guid: guid)
                    self.sensors.append(sensor)
                }
                self.tableView.reloadData()
        }
        
        
        
//        let socket = SocketIOClient(socketURL: NSURL(string: "http://siot.net:15781")!, options: [.Log(true), .ForcePolling(true)])
//        
//        socket.on("connect") {data, ack in
//            print("socket connected")
//        }
//        
//        socket.on("currentAmount") {data, ack in
//            if let cur = data[0] as? Double {
//                socket.emitWithAck("canUpdate", cur)(timeoutAfter: 0) {data in
//                    socket.emit("update", ["amount": cur + 2.50])
//                }
//                
//                ack.with("Got your currentAmount", "dude")
//            }
//        }
//        
//        socket.onAny() {data in
//            print(data)
//        }
//        
//        socket.connect()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

