//
//  TinderViewController.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation
import UIKit
import SnapKit

class TinderViewController: UIViewController, TinderViewControllerInterface {
    
    var interactor: TinderInteractorInterface? = TinderInteractor()
    
    private var decoratorView: UIView!
    private var cardStack: SwipeCardStack!
    private var loadingIndicatorView: UIActivityIndicatorView!
    
    private var undoButton: UIButton!
    private var favoriteButton: UIButton!
    
    private var displayItems: [TinderCardDisplayItem] = []
    
    private struct Constant {
        static let backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1)
    }
        
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = Constant.backgroundColor
        
        let topOffset = 80
        decoratorView = UIView()
        decoratorView.backgroundColor = UIColor.black
        view.addSubview(decoratorView)
        decoratorView.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.left.right.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(64 + topOffset)
        }
        
        cardStack = SwipeCardStack()
        cardStack.delegate = self
        cardStack.dataSource = self
        view.addSubview(cardStack)
        cardStack.snp.makeConstraints { (make) in
            make.top.equalTo(decoratorView.snp.top).offset(2)
            make.left.right.equalTo(decoratorView).inset(2)
            make.centerX.equalToSuperview()
            make.height.equalTo(cardStack.snp.width).multipliedBy(1.5)
        }
        
        loadingIndicatorView = UIActivityIndicatorView(style: .large)
        loadingIndicatorView.isHidden = true
        view.addSubview(loadingIndicatorView)
        loadingIndicatorView.snp.makeConstraints { (make) in
            make.center.equalTo(cardStack)
        }
        
        configureNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interactor?.view = self
        interactor?.onViewReadyToLoad()
    }

    private func configureNavigationBar() {
        undoButton = UIButton()
        undoButton.addTarget(self, action: #selector(didTapUndo(_:)), for: .touchUpInside)
        undoButton.setImage(UIImage(named: "ic_reset"), for: .normal)
        undoButton.tag = 1
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: undoButton)
        
        favoriteButton = UIButton()
        favoriteButton.addTarget(self, action: #selector(didTapFavorite(_:)), for: .touchUpInside)
        favoriteButton.setImage(UIImage(named: "ic_heart_red")?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.setImage(UIImage(named: "ic_heart_red")?.withRenderingMode(.alwaysOriginal), for: .selected)
        favoriteButton.tintColor = UIColor.gray

        favoriteButton.tag = 2
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc
    func didTapUndo(_ sender: UIButton) {
        cardStack.undoLastSwipe(animated: true)
    }
    
    @objc
    func didTapFavorite(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.interactor?.onViewSelectFavoriteList()
        } else {
            self.interactor?.onViewDeselectFavoriteList()
        }
    }
    
    func display(_ viewState: ViewState) {
        switch viewState {
        case .loading:
            loadingIndicatorView.isHidden = false
            loadingIndicatorView.startAnimating()
            break
        case .ready:
            loadingIndicatorView.stopAnimating()
            loadingIndicatorView.isHidden = true
            break
        }
    }
    
    func display(_ errorMsg: String) {
        
    }
    
    func display(_ displayItems: [TinderCardDisplayItem]) {
        self.displayItems = displayItems
        self.cardStack.reloadData()
    }
}

extension TinderViewController: SwipeCardStackDataSource, SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        let displayItem = displayItems[index]
        
        let card = TinderCard()
        card.parrentView = cardStack
        card.swipeDirections = [.left, .up, .right]
        card.configure(displayItem)

        return card
    }

    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return displayItems.count
    }

    func didSwipeAllCards(_ cardStack: SwipeCardStack) {
        print("Swiped all cards!")
    }

    func cardStack(_ cardStack: SwipeCardStack, didUndoCardAt index: Int, from direction: SwipeDirection) {
        print("Undo \(direction) swipe on \(displayItems[index].name)")
    }

    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        switch direction {
        case .right:
            self.interactor?.onViewAddToFavoriteItemAtIndex(index)
            break
        case .left,.up:
            self.interactor?.onViewRemoveItemAtIndex(index)
            break
        default:
            break
        }
        print("Swiped \(direction) on \(displayItems[index].name)")
    }

    func cardStack(_ cardStack: SwipeCardStack, didSelectCardAt index: Int) {
        print("Card tapped")
    }
}


