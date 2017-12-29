//
//  RouteDetailViewController.swift
//  BusRoute
//
//  Created by Michael Ardizzone on 12/29/17.
//  Copyright © 2017 Michael Ardizzone. All rights reserved.
//

import UIKit

class RouteDetailViewController: UIViewController, RouteInformationDelegate {

    var routeData : Route?
    var routeImage : UIImage?
    @IBOutlet var tableView: UITableView!
    @IBOutlet var accessibleImageView: UIImageView!
    @IBOutlet var routeImageView: UIImageView!
    @IBOutlet var routeName: UILabel!
    @IBOutlet var routeDescription: UILabel!
    var routeDataForTableView = [Stop]()
    
    func finishPassing(routeInformation: Route, routePicture: UIImage?) {
        self.routeData = routeInformation
        routeImage = routePicture
        //routeDescription.text = routeInformation.description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "StopsCell", bundle: nil), forCellReuseIdentifier: "stopCellIdentifier")
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateUI() {
        if let routePicture = routeImage {
            routeImageView.image = routePicture
        }
        routeName.text = routeData?.name
        routeDescription.text = routeData?.description
        if (routeData?.accessible)! {
            accessibleImageView.image = UIImage(named: "accessibleIcon")
        }
        if let busStops = routeData?.stops {
            routeDataForTableView = busStops
            self.tableView.reloadData()
        }
    }
}

// MARK: TableView Methods
extension RouteDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stopCellIdentifier", for: indexPath) as! StopsCell
        cell.stopNameLabel.text = routeDataForTableView[indexPath.section].name
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return routeDataForTableView.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //add vertical line connecting the stops
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let lastSectionNumber = routeDataForTableView.count - 1
        if section != lastSectionNumber {
            let lineSuperView = UIView()
            let lineView = UIImageView()
            lineView.image = UIImage(named: "verticalLine")
            lineView.frame = CGRect(x: 22, y: -20, width: 10, height: 75)
            lineSuperView.addSubview(lineView)
            return lineSuperView
        } else {
            return nil
        }
    }
}

