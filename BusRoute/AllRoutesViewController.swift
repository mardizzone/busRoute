//
//  ViewController.swift
//  BusRoute
//
//  Created by Michael Ardizzone on 12/29/17.
//  Copyright © 2017 Michael Ardizzone. All rights reserved.
//

import UIKit

class AllRoutesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    
    //if the user starts to scroll before the images are loaded, we delay reloading the tableview row until after the user has finished scrolling
    var queuedLoadOperations = [DispatchWorkItem]()
    var allRoutes = [Route]()
    var delegate : RouteInformationDelegate?

    //since we are working with static data, we know how the size of the data
    var tasks = [URLSessionTask?](repeating: nil, count: 35)
    var imageArray = [UIImage?](repeating: nil, count: 35)
    
    override func viewWillAppear(_ animated: Bool) {
        //if the we were working with dynamic data, we could add logic to determine when to check for new data
        //but since the data is small and not dynamic, we will only load once
        tableView.register(UINib(nibName: "RouteCell", bundle: nil), forCellReuseIdentifier: "busRouteCellIdentifier")
        tableView.estimatedRowHeight = 120

        //request our json data from server. If we already have it, we don't ask for it again
        if allRoutes.isEmpty {
            Networking.getAllBusRoutes(completion: { busroutes in
                self.allRoutes = busroutes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
    }
    
    // MARK: - Image downloading
    func urlComponents(index: Int) -> URL? {
        guard allRoutes[index].imageUrl != nil else {return nil}
        let imageURL = URL(string: allRoutes[index].imageUrl!)!
        return imageURL
    }
    
    func requestImage(forIndex: IndexPath) {
        if imageArray[forIndex.row] != nil {
            // Image is already loaded
            return
        }
        
        if tasks[forIndex.row] != nil
            && tasks[forIndex.row]!.state == URLSessionTask.State.running {
            // Wait for task to finish
            return
        }
        //add the image request to our tasks
        if let task = getTask(forIndex: forIndex) {
            tasks[forIndex.row] = task
            task.resume()
        } else {
            tasks[forIndex.row] = nil
        }

    }
    
    func getTask(forIndex: IndexPath) -> URLSessionDataTask? {
        if let imgURL = urlComponents(index: forIndex.row) {
            return URLSession.shared.dataTask(with: imgURL) { data, response, error in
                if error != nil {
                    print("Unable to load bus image for URL: \(error.debugDescription) most likely because the image doesn't exist")
                }
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() {
                    if let image = UIImage(data: data) {
                        self.imageArray[forIndex.row] = image
                    } else {
                        self.imageArray[forIndex.row] = UIImage(named: "busImage")
                    }
                    //we don't want the rows to reload when the user is scrolling
                    if !self.tableView.isDragging && !self.tableView.isDecelerating {
                        self.tableView.reloadRows(at: [forIndex], with: UITableViewRowAnimation.fade)
                    } else {
                        //if the user is scrolling, add the reload operation to a queue to be excecuted when the user is done scrolling
                        let loadWorkItem = DispatchWorkItem {  self.tableView.cellForRow(at: forIndex)?.contentView.layoutSubviews() }
                        self.queuedLoadOperations.append(loadWorkItem)
                    }
                }
            }
        } else {return nil}
    }
}

// MARK: TableView Methods
extension AllRoutesViewController: UITableViewDelegate, UITableViewDataSource, UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "busRouteCellIdentifier", for: indexPath) as! RouteCell
        
        cell.routeName.text = allRoutes[indexPath.row].name
        
        //if we already have an image, display it. Otherwise, request the image
        if let img = imageArray[indexPath.row] {
            cell.busImage.image = img
        }
        else {
            requestImage(forIndex: indexPath)
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            requestImage(forIndex: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths{
            if let task = tasks[indexPath.row] {
                if task.state != URLSessionTask.State.canceling {
                    task.cancel()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRoutes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let routeDetailVC = storyboard.instantiateViewController(withIdentifier: "routeDetail") as! RouteDetailViewController
        self.delegate = routeDetailVC
        self.navigationController?.pushViewController(routeDetailVC, animated: true)
        delegate?.finishPassing(routeInformation: allRoutes[indexPath.row], routePicture: imageArray[indexPath.row])
    }
    
}


// MARK: Scrolling Methods
extension AllRoutesViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if !queuedLoadOperations.isEmpty {
                for item in queuedLoadOperations {
                    item.perform()
                }
                //nil out our queued operations
                queuedLoadOperations = [DispatchWorkItem]()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !queuedLoadOperations.isEmpty {
            for item in queuedLoadOperations {
                item.perform()
            }
            //nil out our queued operations
            queuedLoadOperations = [DispatchWorkItem]()
        }
    }
    
}

protocol RouteInformationDelegate {
    func finishPassing(routeInformation: Route, routePicture: UIImage?)
}

