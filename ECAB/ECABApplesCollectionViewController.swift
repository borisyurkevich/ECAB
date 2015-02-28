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
    
    let model: ECABData = ECABData.sharedInstance
    var presenter: ECABApplesViewController?
    
    private let reuseIdentifier = "ApplesCell"
    private let board = ECABGameBoard(targets: 7,
                                  fakeTargers: 20,
                                 otherTargets: 50)
    
    var session: ECABSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.session = ECABSession(with: ECABApplesGame(), subject: self.model.subject)
        // Start session
        
        let labelText: String = "Pause"
        let pauseButton: UIButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
        let size: CGSize = labelText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        let screen: CGSize = UIScreen.mainScreen().bounds.size
        pauseButton.setTitle(labelText, forState: UIControlState.Normal)
        pauseButton.frame = CGRectMake(screen.width - (size.width*2), 4, size.width * 2, size.height)
        pauseButton.addTarget(self, action: "presentPause", forControlEvents: UIControlEvents.TouchUpInside)
        self.collectionView!.addSubview(pauseButton)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
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

    func presentPause() {
        let alertView = UIAlertController(title: "Game paused", message: "You can quit the game. All progress will be lost.", preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Quit", style: .Default, handler: { (alertAction) -> Void in
            self.quit()
        }))
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    func quit() {
        model.subject.sessions.append(session)
        self.presenter?.setNeedsStatusBarAppearanceUpdate()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.session?.end()
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
                // Sorry for magic numbers, for some reason contentView.center
                // is not looking like real center.
                
                if cell.fruit.isCrossed == false {
                    self.session!.score.scores += 1
                    cell.fruit.isCrossed = true
                }

            } else {

            }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(ECABApplesViewController) {
            var dest = segue.destinationViewController as ECABApplesViewController
            dest.setNeedsStatusBarAppearanceUpdate()
        }
    }
}
