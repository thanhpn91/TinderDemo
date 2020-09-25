//
//  TinderCard.swift
//  TinderSample
//
//  Created by Thanh Pham on 9/15/20.
//  Copyright © 2020 Thanh Pham. All rights reserved.
//

import Foundation
import UIKit

class TinderCard: SwipeCard {
        
    weak var parrentView: SwipeCardStack?
    
    var contentView: TinderCardContentView!
    var footerView: TinderCardFooterView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor.white
        tapGestureRecognizer.delegate = self

        applyShadow(radius: 2, opacity: 0.5, offset: CGSize(width: 0, height: 1))
    }
    
    func configure(_ displayItem: TinderCardDisplayItem) {
        contentView = TinderCardContentView(withImage: displayItem.picture)
        contentView.imageView.setImage(displayItem.picture)
        self.content = contentView
              
        let infoDisplayItems = InfoDisplayItem.parse(displayItem)
        footerView = TinderCardFooterView(displayItems: infoDisplayItems, selectedIndex: 0)
        self.footer = footerView
        self.footerHeight = ((parrentView?.bounds.height) ?? 0.0) * 0.5
    }
}

extension TinderCard: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let touchView = touch.view, touchView.isDescendant(of: footerView.tabCollectionView) {
            return false
        }
        
        return true
    }

}

extension UIView {
    func applyShadow(radius: CGFloat,
                     opacity: Float,
                     offset: CGSize,
                     color: UIColor = .black) {
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}
