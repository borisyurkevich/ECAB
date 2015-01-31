//
//  ECABApplesCollectionViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABApplesCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "ApplesCell"
    private let board = ECABGameBoard(targets: 2,
                                  fakeTargers: 3,
                                 otherTargets: 10)
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.board.numberOfCells
    }

    override func collectionView(collectionView: UICollectionView,
               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as ECABApplesCollectionViewCell
        cell.backgroundColor = UIColor.redColor()
        
        let aFruit:ECABGamePeace = self.board.data[indexPath.row]
        cell.imageView.image = aFruit.image
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
}
