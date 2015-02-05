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
    UICollectionViewDelegateFlowLayout,
    UIAlertViewDelegate {
    
    let model: ECABData = ECABData.sharedInstance
    
    private let reuseIdentifier = "ApplesCell"
    private let board = ECABGameBoard(targets: 7,
                                  fakeTargers: 20,
                                 otherTargets: 50)
    
    var session: ECABSession?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.session = ECABSession(with: ECABApplesGame(), subject: self.model.subject)
        // Start session
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
        
        cell.fruit = aFruit
                
        return cell
    }

    @IBAction func handleTaps(sender: UITapGestureRecognizer) {
        sender.numberOfTouchesRequired = 3
        
        if sender.numberOfTouches() == 3 {
            let alert = UIAlertView(title: "Game paused", message: "Tap quit to ext the game. All progrss will be lost.", delegate: self, cancelButtonTitle: "Continue", otherButtonTitles: "Quit")
            alert.show()
        }
    }
    
    // MARKL UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.dismissViewControllerAnimated(true, completion: nil)
            self.session?.end()
        }
    }
    
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            
            let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as ECABApplesCollectionViewCell
            
            if cell.fruit.isValuable {
                let crossImage = UIImage(named: "cross_gray")
                var cross = UIImageView(image: crossImage)
                cross.frame = cell.imageView.frame
                cell.imageView.addSubview(cross)
                
                cross.center.x = cell.contentView.center.x-7
                cross.center.y = cell.contentView.center.y-7
                // Sorry for magin numbers, for some reason contentView.center
                // is not looking like real center.
                
                if cell.fruit.isCrossed == false {
                    self.session!.score.scores += 1
                    cell.fruit.isCrossed = true
                }

            } else {

            }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
}
