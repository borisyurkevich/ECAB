//
//  ECABApplesCollectionViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class RedAppleCollectionViewController:
    UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    
    let model: Model = Model.sharedInstance
    var currentView = 0
    let reuseIdentifier = "ApplesCell"
    let gameSpeed: Double = 20 // Amount of seconds one view is visible, default is 20
	var player = AVAudioPlayer()
	var playerFailure = AVAudioPlayer()
	private var checkedMarks = [-1]
	private var isTraining = true
	private let numberOfTargets = [1, 1, 2, 7, 4, 7, 6, 6, 6]

    private var cellWidth:CGFloat = 190 // only for the first training view - very big
    private var cellHeight:CGFloat = 190
    private var board = RedAppleBoard(stage: 0)
    private let interSpacing:CGFloat = 27
	private var timer = NSTimer()
    
    private struct Insets {
        static let top:CGFloat = 95
        static let left:CGFloat = 10
        static let bottom:CGFloat = 10
        static let right:CGFloat = 10
    };
	
	// Inititial insets are very big
	private var insetTop: CGFloat = 260
	private var insetLeft: CGFloat = 172
	private var insetBottom = Insets.bottom
	private var insetRight: CGFloat = 172
    
    private var pauseButton: UIButton?
	private var nextButton: UIButton?
	private var prevButton: UIButton?
    private var boardFlowLayout: UICollectionViewFlowLayout?
    
    var presenter: MenuViewController?
    var session: Session!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardFlowLayout = configureFlowLayout()
		collectionView!.setCollectionViewLayout(boardFlowLayout!, animated: true)
		
        collectionView!.registerClass(RedAppleCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		// Instert fresh session entity
		model.addSession("Apple", player: model.data.selectedPlayer)
        session = model.data.sessions.lastObject as! Session
        
        let whiteColor = UIColor.whiteColor()
        collectionView?.backgroundColor = whiteColor
        
        let labelText: String = "Pause"
        pauseButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
        let size: CGSize = labelText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16.0)])
        let screen: CGSize = UIScreen.mainScreen().bounds.size
        pauseButton!.setTitle(labelText, forState: UIControlState.Normal)
        pauseButton!.frame = CGRectMake(screen.width - (size.width*2), 16, size.width * 2, size.height)
        pauseButton!.addTarget(self, action: "presentPause", forControlEvents: UIControlEvents.TouchUpInside)
		
		nextButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
        nextButton!.setTitle("Next", forState: UIControlState.Normal)
		nextButton!.frame = CGRectMake(76, 16, size.width * 2, size.height)
		nextButton!.addTarget(self, action: "timerDidFire", forControlEvents: UIControlEvents.TouchUpInside)
		
		prevButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
		prevButton!.setTitle("Previous", forState: UIControlState.Normal)
		prevButton!.frame = CGRectMake(10, 16, size.width * 2, size.height)
		prevButton!.addTarget(self, action: "goBack", forControlEvents: UIControlEvents.TouchUpInside)
		
        view.addSubview(pauseButton!)
		view.addSubview(prevButton!)
		view.addSubview(nextButton!)
        // Add pause button
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "guidedAccessNotificationHandler:", name: "kECABGuidedAccessNotification", object: nil)
        
		
        // Disable scrolling
        collectionView?.scrollEnabled = false;
        
        // Disable player name on to right corner
		
		// Sounds
		let successSoundPath = NSBundle.mainBundle().pathForResource("slide-magic", ofType: "aif")
		let successSoundURL = NSURL(fileURLWithPath: successSoundPath!)
		var error: NSError?
		player = AVAudioPlayer(contentsOfURL: successSoundURL, error: &error)
		player.prepareToPlay()
		
		let failureSoundPath = NSBundle.mainBundle().pathForResource("beep-attention", ofType: "aif")
		let failureSoundURL = NSURL(fileURLWithPath: failureSoundPath!)
		var errorFailure: NSError?
		playerFailure = AVAudioPlayer(contentsOfURL: failureSoundURL, error: &errorFailure)
		playerFailure.prepareToPlay()
    }
	
	var isGameStarted = false
	func startGame() {
		if !isGameStarted {
			isGameStarted = true
		}
	}
	
	func goBack() {
		if currentView == 0 {
			return
		} else {
			currentView -= 2
		}
		timer.invalidate()
		timerDidFire()
	}
    
    func timerDidFire() {
		        
        UIView.transitionWithView(self.view, duration: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            
            // animation...
            self.collectionView!.alpha = 0.0
            
            }, completion: { (fininshed: Bool) -> () in
                
                // Here we shoulf set borard with new scene.
                self.currentView += 1
				
				switch (self.currentView) {
				case 0:
					self.cellWidth = 190
					self.cellHeight = 190
					
					self.insetTop = 260
					self.insetLeft = 172
					self.insetBottom = Insets.bottom
					self.insetRight = 172
					break;
				case 1:
					self.cellWidth = 84
					self.cellHeight = 84
					self.insetTop = 220
					self.insetLeft = 340
					self.insetRight = 340
					break;
				case 2:
					self.cellWidth = 70
					self.cellHeight = 70
					self.insetTop = 230
					self.insetLeft = 200
					self.insetRight = 200
					break;
				case 3 ... 5:
					// Real game starts on motor test
					// This is three motor screen tests
					self.startGame()
					self.nextButton?.hidden = true
					self.cellWidth = 70
					self.cellHeight = 70
					self.insetTop = Insets.top
					self.insetLeft = Insets.left
					self.insetBottom = Insets.bottom
					self.insetRight = Insets.right
					break;
				default:
					// This is normal game mode
					self.cellWidth = 70
					self.cellHeight = 70
					self.insetTop = Insets.top
					self.insetLeft = Insets.left
					self.insetBottom = Insets.bottom
					self.insetRight = Insets.right
					self.isTraining = false
					break;
				}
				println("Requesting fot the board \(self.currentView)")
                self.board = RedAppleBoard(stage: self.currentView)
				self.checkedMarks = [-1]
                
                // And reload data
                self.collectionView?.reloadData()
				
				self.boardFlowLayout = self.configureFlowLayout()
				self.collectionView!.setCollectionViewLayout(self.boardFlowLayout!, animated: false)
				
				// TODO: It is better move this logic to the Switch statement
				if (self.isGameStarted && self.currentView == 8) {
					self.timer = NSTimer(timeInterval: self.gameSpeed, target: self, selector: "quit", userInfo: nil, repeats: false)
					NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
				} else if (self.isGameStarted && self.currentView != 8) {
					self.timer = NSTimer(timeInterval: self.gameSpeed, target: self, selector: "showBlankScreen", userInfo: nil, repeats: false)
					NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSRunLoopCommonModes)
				}
                
                UIView.transitionWithView(self.view, duration: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    self.collectionView!.alpha = 1
                    
                }, completion: nil)
        })
    }
	
	func showBlankScreen() {
		
		self.board = RedAppleBoard(stage: 10)
		
		collectionView!.performBatchUpdates({
			
			self.collectionView!.deleteSections(NSIndexSet(index: 0))

			self.collectionView!.insertSections(NSIndexSet(index: 0))
			
		}, completion: nil)
		
		self.nextButton?.hidden = false
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
		
		// Remove all subviews
		for subview in cell.subviews {
			subview.removeFromSuperview()
		}
				
        cell.backgroundColor = UIColor.redColor()
        
        let aFruit:GamePeace = self.board.data[indexPath.row]
        cell.imageView = UIImageView(frame: CGRectMake(0, 0, cellWidth, cellHeight));
        cell.imageView.image = aFruit.image
        cell.addSubview(cell.imageView)
        
        cell.fruit = aFruit
            
        // In case cell was selected previously
        cell.userInteractionEnabled = true
                
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
        
        returnValue.sectionInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight)
        
        returnValue.minimumInteritemSpacing = interSpacing
        returnValue.minimumLineSpacing = interSpacing
        
        return returnValue
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
			
			// Calculate row and column of the collection view
			var total = 60
			var rows = 6
			
			switch currentView {
			case 0:
				total = 3
				rows = 1
				break
			case 1:
				total = 9
				rows = 3
				break
			case 2:
				total = 18
				rows = 3
				break
			default:
				break
			}
			
			var elementsInOneRow = total / rows
			
			var row = Double(indexPath.row) / Double(elementsInOneRow)
			if elementsInOneRow == 1 || row == 0{
				row = 1
			}
			let rowNumber = ceil(row)
			var normalizedRow = Int(rowNumber)
			if normalizedRow != 0 {
				normalizedRow -= 1
			}
			let columnNumber = (indexPath.row - (normalizedRow * elementsInOneRow)) + 1
			
            let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as! RedAppleCollectionViewCell
			
            if cell.fruit.isValuable {
				
				var isRepeat = false
				
				for item in checkedMarks {
					if indexPath.row == item {
						model.addMove(Int(rowNumber), column: columnNumber, session: session, isSuccess: true, isRepeat: true, isTraining: isTraining, screen: currentView)
						playerFailure.play()
						isRepeat = true
						break
					}
				}
				
				if isRepeat == false {
					let crossImage = UIImage(named: "cross_gray")
					var cross = UIImageView(image: crossImage)
					cross.frame = cell.imageView.frame
					cell.imageView.addSubview(cross)
					
					cross.center.x = cell.contentView.center.x
					cross.center.y = cell.contentView.center.y
					
					if (!isTraining) {
						let times = session.score.integerValue
						session.score = NSNumber(integer: (times + 1))
					}
					
					model.addMove(Int(rowNumber), column: columnNumber, session: session, isSuccess: true, isRepeat: false, isTraining: isTraining, screen: currentView)
					
					player.play()
					
					checkedMarks.append(indexPath.row)
					
					if checkedMarks.count == numberOfTargets[currentView] + 1 {
						// Player finished fast
						timer.invalidate()
						showBlankScreen()
					}
					
					println("cm = \(checkedMarks.count) nt = \(numberOfTargets[currentView])")
					println("\(checkedMarks)")
				}
				
            } else {
				
                // Not valuable fruit selected
				if (!isTraining) {
					let times = session.failureScore.integerValue
					session.failureScore = NSNumber(integer: (times + 1))
				}
				
				model.addMove(Int(rowNumber), column: columnNumber, session: session, isSuccess: false, isRepeat: false, isTraining: isTraining, screen: currentView)
				
				playerFailure.play()
            }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(MenuViewController) {
            var dest = segue.destinationViewController as! MenuViewController
            dest.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func quit() {
		timer.invalidate()
		
        self.presenter?.setNeedsStatusBarAppearanceUpdate()
        self.dismissViewControllerAnimated(true, completion: nil)
		
		// TODO: Fix this.
		// Session will not persist this.
		// I think it is more efficent created filled with data Session obj after game is finished
		// Right here and not call for the model every move
		session.dateEnd = NSDate()
		
        println("Result: \(session.score)")
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
