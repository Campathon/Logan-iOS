//
//  CardCollectionViewCell.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import RxSwift

class CardCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var quantityButtonView: UIView!
    @IBOutlet weak var quantityLabelView: UIView!
    @IBOutlet weak var lblQuantity: UILabel!
    @IBOutlet weak var btnIns: UIButton!
    @IBOutlet weak var btnDes: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
}
