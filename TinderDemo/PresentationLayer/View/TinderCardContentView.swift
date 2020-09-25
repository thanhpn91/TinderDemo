//
//  TinderCardContentView.swift
//  TinderSample
//
//  Created by Thanh Pham on 9/15/20.
//  Copyright © 2020 Thanh Pham. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func setImage(_ imageStr: String,
                  placeHolder: UIImage? = nil,
                  rectInsets: UIEdgeInsets? = UIEdgeInsets.zero) {
        
        guard !imageStr.isEmpty else {return}
        guard let url = URL(string: imageStr) else {return}
        self.image = placeHolder
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let image = UIImage(data: data) {
                        self.image = image.withAlignmentRectInsets(rectInsets ?? UIEdgeInsets.zero)
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

class TinderCardContentView: UIView {
    
    var imageView: UIImageView!
    var lineView: UIView!
    
    init(withImage image: String) {
        super.init(frame: .zero)
        setupView()
        
        imageView.setImage(image, rectInsets: UIEdgeInsets(top: -1, left: -1, bottom: -1, right: -1))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not yet implemented")
        return nil
    }

    private func setupView() {
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.white
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.width.equalTo(self.snp.width).dividedBy(2)
            make.height.equalTo(imageView.snp.width)
            make.top.equalToSuperview().offset(64)
            make.centerX.equalToSuperview()
        }
        
        lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        insertSubview(lineView, belowSubview: imageView)
        lineView.snp.makeConstraints { (make) in
            make.height.equalTo(1)
            make.width.equalToSuperview()
            make.bottom.equalTo(imageView.snp.bottom)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.layer.borderWidth = 0.3
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.cornerRadius = imageView.bounds.width/2
        
        let offset = imageView.bounds.height * 0.3
        lineView.snp.updateConstraints { (make) in
            make.bottom.equalTo(imageView.snp.bottom).inset(offset)
        }
    }
}
