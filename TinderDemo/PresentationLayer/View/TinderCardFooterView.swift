//
//  TinderCardFooterView.swift
//  TinderSample
//
//  Created by Thanh Pham on 9/15/20.
//  Copyright © 2020 Thanh Pham. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

struct InfoDisplayItem {
    let title: String
    let text: String
}

extension InfoDisplayItem {
    static func parse(_ cardDisplayItem: TinderCardDisplayItem) -> [InfoDisplayItem] {
        let profile = InfoDisplayItem(title: "My name is", text: cardDisplayItem.name)
        let dob = InfoDisplayItem(title: "My dob is", text: cardDisplayItem.dob)
        let location = InfoDisplayItem(title: "My address is", text: cardDisplayItem.address)
        let phone = InfoDisplayItem(title: "My phone number is", text: cardDisplayItem.phone)
        let pwd = InfoDisplayItem(title: "My password is", text: cardDisplayItem.password)
        return [profile, dob, location, phone, pwd]
    }
}

struct TabItemFactory {
    static func defaultItems() -> [TabItems] {
        let items = [
            TabItems(name: "profile", icon: UIImage(named: "ic_profile")),
            TabItems(name: "dob", icon: UIImage(named: "ic_calendar")),
            TabItems(name: "location", icon: UIImage(named: "ic_place")),
            TabItems(name: "phone", icon: UIImage(named: "ic_phone")),
            TabItems(name: "password", icon: UIImage(named: "ic_lock"))
        ]
        return items
    }
}

struct TabItems {
    let name: String
    let icon: UIImage?
}

class TinderCardFooterView: UIView {
    
    var displayItems: [InfoDisplayItem] = []
    var tabItems: [TabItems] = TabItemFactory.defaultItems()
    var selectedIndex = 1

    var infoView: InfoView!
    var tabCollectionView: UICollectionView!
    var selectedLineView: UIView!
    
    struct Constant {
        static let tabSize = CGSize(width: 32, height: 32)
        static let tabInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    init(displayItems: [InfoDisplayItem], selectedIndex: Int) {
        super.init(frame: .zero)
        self.displayItems = displayItems
        self.selectedIndex = selectedIndex
        setupView()
        reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not yet implemented")
        return nil
    }

    private func setupView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal

        tabCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tabCollectionView.backgroundColor = UIColor.clear
        tabCollectionView.register(TinderTabCell.self, forCellWithReuseIdentifier: TinderTabCell.identifier)
        tabCollectionView.showsVerticalScrollIndicator = false
        tabCollectionView.showsHorizontalScrollIndicator = false
        tabCollectionView.contentInset = Constant.tabInsets
        tabCollectionView.delegate = self
        tabCollectionView.dataSource = self
        
        addSubview(tabCollectionView)
        tabCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(48.0)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(32)
        }
        
        infoView = InfoView()
        addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.centerX.equalToSuperview()
        }
        
        selectedLineView = UIView()
        selectedLineView.backgroundColor = UIColor.orange
        addSubview(selectedLineView)
    }
    
    private func selectTabItemAtIndexPath(_ indexPath: IndexPath, animated: Bool) {
        tabCollectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .left)
        moveIndicatorViewToIndexPath(indexPath, animated: animated)
    }
    
    private func reloadData() {
        if selectedIndex < tabItems.count {
            let indexPath = IndexPath(row: self.selectedIndex, section: 0)
            tabCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .left)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.moveIndicatorViewToIndexPath(indexPath)
            }
        }
        
        if displayItems.count > 0, selectedIndex < displayItems.count {
            let displayItem = displayItems[selectedIndex]
            self.infoView.titleLabel.text = displayItem.title
            self.infoView.infoLabel.text = displayItem.text
        }
    }
}

extension TinderCardFooterView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func moveIndicatorViewToIndexPath(_ indexPath: IndexPath, animated: Bool = false) {
        if let selectedCell = self.tabCollectionView.cellForItem(at: indexPath) {
            self.selectedLineView.snp.remakeConstraints { (make) in
                make.height.equalTo(2)
                make.width.equalTo(Constant.tabSize.width + 16)
                make.bottom.equalTo(self.tabCollectionView.snp.top)
                make.centerX.equalTo(selectedCell.snp.centerX)
            }
            
            if animated {
                UIView.animate(withDuration: 0.2) {
                    self.layoutIfNeeded()
                }
            } else {
                self.layoutIfNeeded()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TinderTabCell.identifier, for: indexPath) as! TinderTabCell
    
        if indexPath.row < tabItems.count {
            let tabItem = tabItems[indexPath.row]
            cell.image = tabItem.icon
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectTabItemAtIndexPath(indexPath, animated: true)
        if indexPath.count < displayItems.count {
            let displayItem = displayItems[indexPath.row]
            self.infoView.titleLabel.text = displayItem.title
            self.infoView.infoLabel.text = displayItem.text
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if tabItems.count <= 1 {
            return 0.0
        }

        let itemSize = Constant.tabSize
        let lineSpacingSize = (collectionView.bounds.width - (CGFloat(tabItems.count) * itemSize.width)) - (Constant.tabInsets.left + Constant.tabInsets.right)
        return lineSpacingSize / (CGFloat(tabItems.count) - 1)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constant.tabSize
    }
}

class TinderTabCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            reloadImageView()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            reloadImageView()
        }
    }
    
    private var iconImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("not yet implemented")
    }
    
    private func setupView() {
        iconImageView = UIImageView()
        iconImageView.contentMode = .scaleAspectFill
        iconImageView.tintColor = UIColor.lightGray
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(2)
        }
    }
    
    private func reloadImageView() {
        let isSelected = self.isSelected
        iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
        iconImageView.tintColor = isSelected ? UIColor.orange : UIColor.lightGray
    }
}

extension UICollectionViewCell {
    class var identifier: String {
        return String(describing: self)
    }
}


class InfoView: UIView {
    var titleLabel: UILabel!
    var infoLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not yet implemented")
        return nil
    }

    private func setupView() {
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.lightGray
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        infoLabel = UILabel()
        infoLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        infoLabel.textColor = UIColor.black
        infoLabel.textAlignment = .center
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.left.right.equalToSuperview()
        }
    }
}
