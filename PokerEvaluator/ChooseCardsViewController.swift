//
//  ChooseCardsViewController.swift
//
//  Created by Joao Paulo Aquino on 01/12/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.

protocol ChooseCardViewControllerDelegate:class {
    func selectedCard(_ card: Card)
}

import UIKit

class ChooseCardsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: ChooseCardViewControllerDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var cards: [Card?] = []
    
    var spades: [Card?] {
        return [Card?](cards[0...13])
    }
    
    var diamonds: [Card?] {
        return [Card?](cards[13...25])
    }
    
    var hearts: [Card?] {
        return [Card?](cards[26...38])
    }
    
    var clubs: [Card?] {
        return [Card?](cards[39...51])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cardIndex = (indexPath.section)*13 + indexPath.row
        guard let cardSelected = cards[cardIndex] else {return}
        delegate?.selectedCard(cardSelected)
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 13
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            (cell.viewWithTag(1) as! UIImageView).image = spades[indexPath.row]?.image ?? UIImage(named: "gray_back")
            return cell;
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            (cell.viewWithTag(1) as! UIImageView).image = diamonds[indexPath.row]?.image ?? UIImage(named: "gray_back")
            return cell;
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            (cell.viewWithTag(1) as! UIImageView).image = hearts[indexPath.row]?.image ?? UIImage(named: "gray_back")
            return cell;
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            (cell.viewWithTag(1) as! UIImageView).image = clubs[indexPath.row]?.image ?? UIImage(named: "gray_back")
            return cell;
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
            (cell.viewWithTag(1) as! UIImageView).image = cards[indexPath.row]?.image ?? UIImage(named: "gray_back")
            return cell;
            
        }        
    }
    
}
