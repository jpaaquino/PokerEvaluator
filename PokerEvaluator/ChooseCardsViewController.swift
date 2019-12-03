//
//  ChooseCardsViewController.swift
//  StudGames
//
//  Created by Joao Paulo Aquino on 01/12/19.
//  Copyright © 2019 Joao Paulo Aquino. All rights reserved.

protocol ChooseCardViewControllerDelegate:class {
    func selectedCard(_ card: Card)
}

import UIKit

class ChooseCardsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    weak var delegate: ChooseCardViewControllerDelegate?

    @IBOutlet weak var collectionView: UICollectionView!
    
    var maxCards: Int?
    var cards: [Card?] = []
    var selectedCards: Card?

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cardSelected = cards[indexPath.row] else {return}
        delegate?.selectedCard(cardSelected)
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        (cell.viewWithTag(1) as! UIImageView).image = cards[indexPath.row]?.image
        return cell;
    }

}
