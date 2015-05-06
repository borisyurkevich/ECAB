//
//  ECABApplesCollectionViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class RedAppleCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    
    let model: Model = Model.sharedInstance
    var currentView = 0
    let reuseIdentifier = "ApplesCell"
    let gameSpeed: Double = 10 // Amount of seconds one view is visible

    private let cellWidth:CGFloat = 100
    private let cellHeight:CGFloat = 100
    private var board = RedAppleBoard(stage: 0)
    
    private struct Insets {
        static let top:CGFloat = 10
        static let left:CGFloat = 10
        static let bottom:CGFloat = 10
        static let right:CGFloat = 10
    };
    
    private var pauseButton: UIButton?
    private var boardFlowLayout: UICollectionViewFlowLayout?
    
    var presenter: RedAppleMenuViewController?
    var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardFlowLayout = configureFlowLayout()
        
        collectionView!.registerClass(RedAppleCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView!.setCollectionViewLayout(boardFlowLayout!, animated: true)
        
        self.session = Session(with: RedAppleGame(), subject: model.subject)
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
        
        view.addSubview(pauseButton!)
        // Add pause button
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "guidedAccessNotificationHandler:", name: "kECABGuidedAccessNotification", object: nil)
        
        // Start the game timer
        NSTimer.scheduledTimerWithTimeInterval(gameSpeed, target: self, selector: "timerDidFire", userInfo: nil, repeats: false)
        
        // Disable scrolling
        collectionView?.scrollEnabled = false;
    }
    
    func timerDidFire() {
        
        UIView.transitionWithView(self.view, duration: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            // animation...
            self.collectionView!.alpha = 0.0
            
            }, completion: { (fininshed: Bool) -> () in
                
                // Here we shoulf set borard with new scene.
                self.currentView += 1
                self.board = RedAppleBoard(stage: self.currentView)
                
                // And reload data
                self.collectionView?.reloadData()
                
                // Set new timer. No need timer on the last step.
                if self.currentView != 2 {
                    NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "timerDidFire", userInfo: nil, repeats: false)
                } else {
                    NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "quit", userInfo: nil, repeats: false)
                }
                
                UIView.transitionWithView(self.view, duration: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    self.collectionView!.alpha = 1
                    
                }, completion: nil)
        })
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

    override func collectionView(collectionView: UICollectionView,
               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! RedAppleCollectionViewCell
        cell.backgroundColor = UIColor.redColor()
        
        let aFruit:GamePeace = self.board.data[indexPath.row]
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
            
            let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! RedAppleCollectionViewCell
            
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
        if segue.destinationViewController.isKindOfClass(RedAppleMenuViewController) {
            var dest = segue.destinationViewController as! RedAppleMenuViewController
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
