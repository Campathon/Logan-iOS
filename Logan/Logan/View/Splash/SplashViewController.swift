//
//  SplashViewController.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        connect()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func connect() {
        Utils.startAnimate()
        SocketManager.shared.establishConnection { [weak self] (isSuccess) in
            Utils.stopAnimate()
            if isSuccess {
                AppState.state = .connected
                self?.performSegue(withIdentifier: AppDefine.segue.splashToLogin.rawValue, sender: nil)
            } else {
                Utils.showAlertDefault("Lỗi kết nối", message: "Có lỗi khi kết nối, vui lòng thử lại", buttons: ["Thử lại"], completed: { [weak self] (_) in
                    self?.connect()
                })
            }
        }
    }
}
