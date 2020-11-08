//
//  JourneyDetailVC.swift
//  My_Map
//
//  Created by umer malik on 05/11/2020.
//

import UIKit

class JourneyDetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    let journeyTable = UITableView()
    var destination = [String]()

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return destination.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JourneyCell
        cell.textLabel?.text = destination[indexPath.row].description
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    

    

    override func viewDidLoad() {
        super.viewDidLoad()

        constraints()
    }



    func constraints() {

        journeyTable.register(JourneyCell.self, forCellReuseIdentifier: "cell")
        journeyTable.delegate = self
        journeyTable.dataSource = self
        journeyTable.separatorStyle = .none
        view.addSubview(journeyTable)
        journeyTable.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
    }
    


}
