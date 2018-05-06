//
//  DashboardClientViewController.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit

class DashboardClientViewController: UIViewController {
    
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblCard: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let idCell = "ClientCollectionViewCell"
    
    var isStarted = false
    
    func setupData() {
        lblRoom.text = "Phòng \(Room.curRoom.code?.intValue ?? -1)"
        lblPlayer.text = "\(Room.curRoom.users.count) người tham gia"
        if isStarted {
            imgCard.kf.setImage(with: URL.init(string: User.me.card?.image ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
            lblCard.text = User.me.card?.name ?? ""
        } else {
            lblCard.text = "Đang chờ mọi người sẵn sàng"
        }
        self.collectionView.reloadData()
    }
    
    func setTable() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func handleSocket() {
//        SocketManager.shared.startGame { [weak self] (users) in
//            Room.curRoom.users = users
//            if let me = Room.curRoom.users.filter({ (user) -> Bool in
//                return user._id == User.me._id
//            }).first {
//                User.me = me
//            }
//
//            self?.isStarted = true
//            self?.setupData()
//        }
//        SocketManager.shared.listenClosedRoom(complete: { [weak self] in
//            BannerManager.share.showMessage(withContent: "Phòng đã bị đóng", theme: BannerManager.BannerTheme.warning)
//            self?.leaveRoom()
//        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setTable()
        setupData()
        handleSocket()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leaveRoom() {
        RequestManager.shared.apiLeave { [weak self] (success) in
            if success {
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

extension DashboardClientViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Room.curRoom.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 105, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCell, for: indexPath) as? ClientCollectionViewCell {
            let user = Room.curRoom.users[indexPath.row]
            cell.imgAvt.image = UIImage.makeLetterAvatar(withUsername: user.name ?? "NC")
            cell.lblname.text = user.name ?? ""
            return cell
        }
        return UICollectionViewCell()
    }
}
