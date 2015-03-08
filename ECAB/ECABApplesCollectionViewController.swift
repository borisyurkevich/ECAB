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
    let reuseIdentifier = "ApplesCell"

    private let board = ECABGameBoard(targets: 7,
                                  fakeTargers: 20,
                                 otherTargets: 50)
    private struct Insets {
        static let top:CGFloat = 10
        static let left:CGFloat = 10
        static let bottom:CGFloat = 10
        static let right:CGFloat = 10
    };
    
    private var pauseButton: UIButton?
    private var boardFlowLayout: UICollectionViewFlowLayout?
    
    var presenter: ECABApplesViewController?
    var session: ECABSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardFlowLayout = configureFlowLayout()
        
        collectionView!.registerClass(ECABApplesCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.setCollectionViewLayout(boardFlowLayout!, animated: true)
        
        self.session = ECABSession(with: ECABApplesGame(), subject: self.model.subject)
        // Start session
        
        let whiteColor = UIColor.whiteColor()
        collectionView?.backgroundColor = whiteColor
        
        let labelText: String = "Pause"
        pauseButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
        let size: CGSize = labelText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(14.0)])
        let screen: CGSize = UIScreen.mainScreen().bounds.size
        pauseButton!.setTitle(labelText, forState: UIControlState.Normal)
        pauseButton!.frame = CGRectMake(screen.width - (size.width*2), 4, size.width * 2, size.height)
        pauseButton!.addTarget(self, action: "presentPause", forControlEvents: UIControlEvents.TouchUpInside)
        self.collectionView!.addSubview(pauseButton!)
        // Add pause button
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "guidedAccessNotificationHandler:", name: "kECABGuidedAccessNotification", object: nil)
    }
    
    func guidedAccessNotificationHandler(notification: NSNotification) {
        
        let enabled: Bool = notification.userInfo!["restriction"] as! Bool!
        pauseButton?.enabled = enabled
        
        if pauseButton?.enabled == true {
           pauseButton?.hidden = false
        } else {
            pauseButton?.hidden = true
        }
        // Hide button completly
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: UICollectionViewDataSource

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.board.numberOfCells
    }
    
    private let cellWidth:CGFloat = 50
    private let cellHeight:CGFloat = 50

    override func collectionView(collectionView: UICollectionView,
               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! ECABApplesCollectionViewCell
        cell.backgroundColor = UIColor.redColor()
        
        let aFruit:ECABGamePeace = self.board.data[indexPath.row]
        cell.imageView = UIImageView(frame: CGRectMake(0, 0, cellWidth, cellHeight));
        cell.imageView.image = aFruit.image
        cell.addSubview(cell.imageView)
        
        cell.fruit = aFruit
                
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout
    {
        var returnValue = UICollectionViewFlowLayout()
        
        returnValue.sectionInset = UIEdgeInsetsMake(Insets.top, Insets.left, Insets.bottom, Insets.right)
        
        return returnValue
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
            
            let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! ECABApplesCollectionViewCell
            
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
            var dest = segue.destinationViewController as! ECABApplesViewController
            dest.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func quit() {
        model.subject.sessions.append(session)
        self.presenter?.setNeedsStatusBarAppearanceUpdate()
        self.dismissViewControllerAnimated(true, completion: nil)
        self.session?.end()
    }
    
    func presentPause() {
        let alertView = UIAlertController(title: "Game paused", message: "You can quit the game. All progress will be lost.", preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: "Quit", style: .Default, handler: { (alertAction) -> Void in
            self.quit()
        }))
        alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        presentViewController(alertView, animated: true, completion: nil)
    }
}
