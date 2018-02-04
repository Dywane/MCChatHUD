//
//  ChooseTypeViewController.swift
//  MCChatHUD
//
//  Created by duwei on 2018/2/4.
//  Copyright © 2018年 Dywane. All rights reserved.
//

import UIKit

class ChooseTypeViewController: UITableViewController {
    
    /// 类型数组
    private let typeArray = ["Bar style", "Line style"]
    
    /// 选择的类型
    private var selectedIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return typeArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseTypeCellID", for: indexPath)
        cell.textLabel?.text = typeArray[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "ShowRecordViewController", sender: self)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecordViewController" {
            guard let type = HUDType(rawValue: selectedIndex) else {
                return
            }
            let recordVC = segue.destination as! RecordViewController
            recordVC.HUDType = type
        }
    }
}
