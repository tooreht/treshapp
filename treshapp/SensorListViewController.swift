//
//  SensorListViewController.swift
//  treshapp
//
//  Created by Marc Zimmermann on 26/04/16.
//  Copyright © 2016 BFH. All rights reserved.
//

import UIKit
import Alamofire


class SensorListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // These strings will be the data for the table view cells
    var sensors = [Sensor]()
    var selectedSensor:Sensor!
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getSensors()
    }
    
    // number of rows in table view
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sensors.count
    }
    
    // create a cell for each table view row
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        cell.textLabel?.text = self.sensors[indexPath.row].name
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You tapped cell number \(indexPath.row).")
        
        // Get Cell Label
        let indexPath = tableView.indexPathForSelectedRow!
        // let currentCell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        
        selectedSensor = self.sensors[indexPath.row]
        self.performSegueWithIdentifier("SensorDetail", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "SensorDetail") {
            
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destinationViewController as! SensorViewController
            // your new view controller should have property that will store passed value
            viewController.sensor = self.selectedSensor
        }
        
    }
    
    func getSensors() {
        // Do any additional setup after loading the view, typically from a nib.

        let parameters = [
            "centerUID": AppConstants.centerGUID,
//            "sensorUID": "35aff35c-c8d3-e0cd-40ab-2c797ae102a7",
        ]
        Alamofire.request(.POST, AppConstants.siotURL.absoluteString + "getsensor", parameters: parameters)
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serializatio
                
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
