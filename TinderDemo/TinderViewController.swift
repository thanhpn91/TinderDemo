//
//  TinderViewController.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation
import UIKit

class TinderViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserService.shared.getUsers(count: 5) { [weak self](userModels, error) in
            guard let self = self else {return}
            print(userModels)
        }
    }
}
