//
//  SettingsTableVC.swift
//  ForshMag
//
//  Created by  Tim on 19.03.17.
//  Copyright © 2017  Tim. All rights reserved.
//

import UIKit
import SafariServices

class SettingsTableVC: UITableViewController {

    @IBOutlet weak var switchNotificationView: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        switchNotificationView.addTarget(self, action: #selector(switchNotifications), for: .valueChanged)
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
    }
    
    func switchNotifications() {
        if switchNotificationView.isOn == true {
            print ("on")
        } else {
            print ("off")
        }
    }
    
    @IBAction func clearCache(_ sender: Any) {
        let myOptionMenu = UIAlertController(title: nil, message: "Очистить кэш?", preferredStyle: .actionSheet)
        
        let clearAction = UIAlertAction(title: "Да", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            FeedVC.imageCache.removeAllObjects()
            print("Clear")
        })
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        myOptionMenu.addAction(cancelAction)
        myOptionMenu.addAction(clearAction)
        
        present(myOptionMenu, animated: true, completion: nil)

        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        //header.textLabel?.font = UIFont(name: "SF UI Text", size: 13)
        header.textLabel?.textColor = UIColor.lightGray
        header.backgroundView?.backgroundColor = UIColor.clear
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }

    @IBAction func showImpactHub(_ sender: Any) {
        let url = NSURL(string: "https://impacthub.odessa.ua/")
        let svc = SFSafariViewController(url: url! as URL)
        present(svc, animated: true, completion: nil)
    }
}
