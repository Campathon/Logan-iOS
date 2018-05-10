//
//  DashboardViewController.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import LetterAvatarKit

class DashboardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var btnExit: UIButton!
    
    let idCell = "DashboardTableViewCell"
    
    func setData() {
        lblRoom.text = "Phòng \(Room.curRoom.code?.intValue ?? -1)"
        lblPlayer.text = "\(Room.curRoom.users.count) người tham gia"
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setData()
        setTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnExitClose() {
        RequestManager.shared.apiQuitGame { [weak self] (isSuccess) in
            if isSuccess {
                AppState.state = .connected
                SocketManager.shared.leftRooom()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension DashboardViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Room.curRoom.users.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 98
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath) as? DashboardTableViewCell {
            let user = Room.curRoom.users[indexPath.row]
            cell.imgAvt.image = UIImage.makeLetterAvatar(withUsername: user.name ?? "")
            cell.lblname.text = user.name ?? ""
            cell.imgCard.kf.setImage(with: URL.init(string: user.card?.image ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            cell.lblCard.text = user.card?.name ?? ""
            if user.status == "left" {
                cell.contentView.alpha = 0.5
            } else {
                cell.contentView.alpha = 1
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    
}
