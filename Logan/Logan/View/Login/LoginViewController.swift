//
//  LoginViewController.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlet
    @IBOutlet weak var tfRoom: UITextField!
    @IBOutlet weak var tfUserName: UITextField!
    @IBOutlet weak var btnJoin: UIButton!
    @IBOutlet weak var btnCreateRoom: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnJoinTaped() {
        if (tfRoom.text ?? "").isEmpty {
            Utils.showAlertDefault("Lỗi", message: "Bạn chưa nhập số phòng", buttons: ["Đóng"], completed: nil)
        } else if (tfUserName.text ?? "").isEmpty || (tfUserName.text?.count ?? 0) < 4 {
            Utils.showAlertDefault("Lỗi", message: "Tên hiển thị phải có ít nhất 4 kí tự", buttons: ["Đóng"], completed: nil)
        } else {
            Utils.startAnimate()
            SocketManager.shared.joinRoom(room: Int(tfRoom.text ?? "") ?? -1, complete: { [weak self] (code) in
                Utils.stopAnimate()
                AppState.role = .client
                AppState.state = .waiting
                RequestManager.shared.apiJoinRoom(name: self?.tfUserName.text ?? "", room: self?.tfRoom.text ?? "", complete: { [weak self] (isSuccess) in
                    if isSuccess {
                        Room.curRoom.code = NSNumber.init(value: Int(self?.tfRoom.text ?? "") ?? -1)
                        
                        self?.performSegue(withIdentifier: AppDefine.segue.loginToClient.rawValue, sender: nil)
                    }
                })
            })
        }
    }
    
    @IBAction func btnCreateRoomTapped() {
        RequestManager.shared.apiCreateRoom { [weak self] (isSuccess, code) in
            Utils.startAnimate()
            SocketManager.shared.joinRoom(room: code, complete: { [weak self] (code) in
                Utils.stopAnimate()
                AppState.role = .host
                AppState.state = .waiting
                self?.performSegue(withIdentifier: AppDefine.segue.loginToChooseCard.rawValue, sender: nil)
            })
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
