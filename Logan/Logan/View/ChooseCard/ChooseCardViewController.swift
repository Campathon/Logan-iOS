//
//  ChooseCardViewController.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import LetterAvatarKit
import Kingfisher
import RxSwift
import RxCocoa

class ChooseCardViewController: UIViewController {
    
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var lblPlayer: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    
    @IBOutlet weak var clPlayer: UICollectionView!
    @IBOutlet weak var clCard: UICollectionView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var heightHeaderContraint: NSLayoutConstraint!
    
    let idPlayer = "PlayerCollectionViewCell"
    let idCard = "CardCollectionViewCell"
    
    func setDataView() {
        self.lblRoom.text = "Phòng \(Room.curRoom.code?.intValue ?? -1)"
        self.lblPlayer.text = "\(Room.curRoom.users.count) người tham gia"
    }
    
    func setupCollectionView() {
        clPlayer.delegate = self
        clPlayer.dataSource = self
        clCard.delegate = self
        clCard.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDataView()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Card.cards.count == 0 {
            RequestManager.shared.apiGetCard { [weak self] (isSuccess, cards) in
                Card.cards = cards
                self?.clCard.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startGame() {
        if Room.curRoom.users.count < 1 {
            BannerManager.share.showMessage(withContent: "Chưa đủ số lượng người chơi tối thiểu", theme: BannerManager.BannerTheme.defaultTheme)
            return
        }
        if Card.cards.filter({ (card) -> Bool in
            return card.isSelect
        }).count < Room.curRoom.users.count {
            BannerManager.share.showMessage(withContent: "Chưa đủ số lượng bài", theme: BannerManager.BannerTheme.defaultTheme)
        } else {
            RequestManager.shared.apiPlayGame { [weak self] (isSuccess) in
                print("Start play")
                self?.performSegue(withIdentifier: AppDefine.segue.chooseCardToDashboard.rawValue, sender: nil)
            }
        }
    }
    
    @IBAction func leaveRoom() {
        RequestManager.shared.apiQuitGame { [weak self] (isSuccess) in
            if isSuccess {
                AppState.state = .connected
                SocketManager.shared.leftRooom()
                User.me = User()
            }
            
            self?.dismiss(animated: true, completion: nil)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension ChooseCardViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == clPlayer {
            return 1
        } else if collectionView == clPlayer {
            return 1
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == clPlayer {
            return Room.curRoom.users.count
        } else if collectionView == clCard {
            return Card.cards.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == clCard {
            if Room.curRoom.users.count == 0 {
                return CGSize.init(width: 0, height: 96)
            } else {
                return CGSize.init(width: 0, height: 214)
            }
        } else {
            return CGSize.init(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == clPlayer {
            let size = CGSize.init(width: 105, height: clPlayer.frame.size.height)
            return size
        } else if collectionView == clCard {
            let size = CGSize.init(width: (collectionView.frame.size.width - 32)/3, height: 156)
            return size
        } else {
            return CGSize.init(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == clPlayer {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idPlayer, for: indexPath) as? PlayerCollectionViewCell {
                let user = Room.curRoom.users[indexPath.row]
                cell.imgAvt.image = UIImage.makeLetterAvatar(withUsername: user.name ?? "NC")
                cell.lblName.text = user.name ?? ""
                return cell
            }
        } else if collectionView == clCard {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: idCard, for: indexPath) as? CardCollectionViewCell {
                cell.lblName.text = Card.cards[indexPath.row].name
                cell.lblQuantity.text = "\(Card.cards[indexPath.row].quantity)"
                cell.imgCard.kf.setImage(with: URL.init(string: Card.cards[indexPath.row].image ?? ""), placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
                cell.btnIns.rx.tap.bind { [weak self] in
                    Card.cards[indexPath.row].quantity += 1
                    cell.lblQuantity.text = "\(Card.cards[indexPath.row].quantity)"
                }.disposed(by: cell.disposeBag)
                cell.btnDes.rx.tap.bind { [weak self] in
                    if Card.cards[indexPath.row].quantity == 1 {
                        Card.cards[indexPath.row].isSelect = false
                        cell.contentView.backgroundColor = UIColor.clear
                        cell.quantityButtonView.isHidden = true
                        cell.quantityLabelView.isHidden = true
                        Card.cards[indexPath.row].quantity = 0
                    } else {
                        Card.cards[indexPath.row].quantity -= 1
                        cell.lblQuantity.text = "\(Card.cards[indexPath.row].quantity)"
                    }
                }.disposed(by: cell.disposeBag)
                if Card.cards[indexPath.row].isSelect {
                    cell.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                    cell.quantityButtonView.isHidden = false
                    cell.quantityLabelView.isHidden = false
                    cell.lblQuantity.text = "\(Card.cards[indexPath.row].quantity)"
                } else {
                    cell.contentView.backgroundColor = UIColor.clear
                    cell.quantityButtonView.isHidden = true
                    cell.quantityLabelView.isHidden = true
                }
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let card = Card.cards[indexPath.row]
        card.isSelect = !card.isSelect
        if let cell = collectionView.cellForItem(at: indexPath) as? CardCollectionViewCell {
            if card.isSelect {
                cell.contentView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
                cell.quantityButtonView.isHidden = false
                cell.quantityLabelView.isHidden = false
                cell.lblQuantity.text = "1"
                card.quantity = 1
            } else {
                cell.contentView.backgroundColor = UIColor.clear
                cell.quantityButtonView.isHidden = true
                cell.quantityLabelView.isHidden = true
                card.quantity = 0
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == clCard {
            let y = scrollView.contentOffset.y
            let bottomOffset = (scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height : scrollView.frame.size.height) - scrollView.frame.size.height - y
            if y <= 25 {
                if y >= 0 {
                    headerView.alpha = CGFloat(Float(y)/25)
                } else {
                    headerView.alpha = 0
                }
            } else {
                headerView.alpha = 1
            }
            if bottomOffset <= 22 {
                if bottomOffset >= 0 {
                    footerView.alpha = CGFloat(Float(bottomOffset)/22)
                } else {
                    footerView.alpha = 0
                }
            } else {
                footerView.alpha = 1
            }
        }
    }
    
}




