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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 2
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 2
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
