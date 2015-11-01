//
//  ECABApplesCollectionViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSearch: TestViewController,
    UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
	
    var currentView = 0
    let reuseIdentifier = "ApplesCell"
    var gameSpeed: Double = 20 // Amount of seconds one view is visible, default is 20
	let transitionSpeed = 0.4
	private var checkedMarks = [Int]() // Every tapped target
	private var checkedTargets = [Int]() // Only red appples
	private var isTraining = true
	private var numberOfTargets = [1, 1, 2, 6, 6, 6, 6, 6, 6]
	private var collectionView: UICollectionView

    private var cellWidth:CGFloat = 190 // only for the first training view - very big
    private var cellHeight:CGFloat = 190
    private var board = VisualSearchBoard(stage: 0)
    private let interSpacing:CGFloat = 27
	private var timer = NSTimer()
	private var timerLastStarted = NSDate()
	
    private struct Insets {
        static var top:CGFloat = 100
        static let left:CGFloat = 10
        static let bottom:CGFloat = 10
        static let right:CGFloat = 10
    };
	
	// Inititial insets are very big
	private var insetTop: CGFloat = 260
	private var insetLeft: CGFloat = 172
	private var insetBottom = Insets.bottom
	private var insetRight: CGFloat = 172
	
    private var boardFlowLayout: UICollectionViewFlowLayout?
    
    var presenter: MenuViewController?
    var session: Session!
	
	private var crossLayer: CAShapeLayer = CAShapeLayer()
	
	init() {
		let flowLayout = UICollectionViewFlowLayout()
		collectionView = UICollectionView(frame: CGRectMake(0, 0, 0, 0), collectionViewLayout: flowLayout)
		
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
    override func viewDidLoad() {
		view = collectionView
        super.viewDidLoad()
		
		collectionView.frame = view.frame
		collectionView.delegate = self
		collectionView.dataSource = self
		
		if model.data.visSearchDifficulty == 1 { // Hard Mode
			currentView = 11
			numberOfTargets = [1, 1, 2, 9, 9, 9, 9]
			gameSpeed = model.data.visSearchSpeedHard.doubleValue
		} else {
			// Easy Mode
			gameSpeed = model.data.visSearchSpeed.doubleValue
		}
		
        boardFlowLayout = configureFlowLayout()
		collectionView.setCollectionViewLayout(boardFlowLayout!, animated: true)
		
        collectionView.registerClass(VisualSearchCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		// Insert fresh session entity
		model.addSession(model.data.selectedPlayer)
        session = model.data.sessions.lastObject as! Session
		session.speed = gameSpeed
		session.difficulty = model.data.visSearchDifficulty
		
        collectionView.backgroundColor = UIColor.whiteColor()
		
        // Disable scrolling
        collectionView.scrollEnabled = false
		
		backButton.setTitle("Back", forState: UIControlState.Normal)
	}
	
	var isGameStarted = false
	func startGame() {
		if !isGameStarted {
			isGameStarted = true
		}
	}
	
	override func skip() {
		currentView = 2
		presentNextScreen()
	}
	
	override func presentPreviousScreen() {
		if currentView == 0 {
			return
		} else {
			currentView -= 2
			presentNextScreen()
		}
	}
    
    override func presentNextScreen() {
		
		// Here we should set borard with new scene.
		currentView += 1
		
		if currentView == numberOfTargets.count {
			quit()
			return
		}
		        
        UIView.transitionWithView(view, duration: transitionSpeed, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            // animation...
            self.collectionView.alpha = 0.0
            
            }, completion: { (fininshed: Bool) -> () in
				
				var defaultSize:CGFloat = 70
				
				if self.model.data.visSearchDifficulty == 1 { // Hard mode
					defaultSize = 54
				}
				
				switch (self.currentView) {
				case 0, 11:
					self.cellWidth = 190
					self.cellHeight = 190
					
					self.insetTop = 260
					self.insetLeft = 172
					self.insetBottom = Insets.bottom
					self.insetRight = 172
				case 1, 12:
					self.cellWidth = 84
					self.cellHeight = 84
					self.insetTop = 220
					self.insetLeft = 340
					self.insetRight = 340
				case 2, 13:
					self.cellWidth = defaultSize
					self.cellHeight = defaultSize
					self.insetTop = 230
					self.insetLeft = 200
					self.insetRight = 200
				case 3 ... 5, 14 ... 15:
					// Real game starts on motor test
					// This is three motor screen tests
					self.startGame()
					self.cellWidth = defaultSize
					self.cellHeight = defaultSize
					self.insetTop = Insets.top
					self.insetLeft = Insets.left
					self.insetBottom = Insets.bottom
					self.insetRight = Insets.right
				default:
					// This is normal game mode
					self.cellWidth = defaultSize
					self.cellHeight = defaultSize
					self.insetTop = Insets.top
					self.insetLeft = Insets.left
					self.insetBottom = Insets.bottom
					self.insetRight = Insets.right
					self.isTraining = false
				}
				
				if self.model.data.visSearchDifficulty == 1 {  // Hard mode.
					if self.currentView != 11 && self.currentView != 12 && self.currentView != 13 {
						self.insetLeft = 100
						self.insetRight = 100
					}
					
					if self.currentView == 13 {
						self.insetLeft = 245
						self.insetRight = 245
					}
					
					Insets.top = 60
				} else {
					Insets.top = 100
				}
				
				print("Requesting fot the board \(self.currentView)")
                self.board = VisualSearchBoard(stage: self.currentView)
				self.checkedMarks = []
				self.checkedTargets = []
                
                // And reload data
                self.collectionView.reloadData()
				
				self.boardFlowLayout = self.configureFlowLayout()
				self.collectionView.setCollectionViewLayout(self.boardFlowLayout!, animated: false)
				
				if (self.isGameStarted) {
					
					self.timer.invalidate()
					self.timer = NSTimer.scheduledTimerWithTimeInterval(self.gameSpeed, target: self, selector: "showBlankScreen", userInfo: nil, repeats: false)
					self.timerLastStarted = NSDate()
				}
				
                UIView.transitionWithView(self.view, duration: self.transitionSpeed, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    
                    self.collectionView.alpha = 1
                    
					}, completion: { (Bool) in
						self.model.addMove(0, column: 0, session: self.session, isSuccess: false, isRepeat: false, isTraining: false, screen: self.currentView, isEmpty: true, extraTime: 0)})
        })
    }
	
	func showBlankScreen() {
		
		if currentView == numberOfTargets.count {
			quit()
			return
		}
		
		self.board = VisualSearchBoard(stage: 10)
		
		collectionView.performBatchUpdates({
			
			self.collectionView.deleteSections(NSIndexSet(index: 0))

			self.collectionView.insertSections(NSIndexSet(index: 0))
			
		}, completion: nil)
	}
	
    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.board.numberOfCells
    }

    func collectionView(collectionView: UICollectionView,
               cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! VisualSearchCell
		
		// Remove all subviews
		for subview in cell.subviews {
			subview.removeFromSuperview()
		}
				
        cell.backgroundColor = UIColor.redColor()
        
        let aFruit:TestItem = self.board.data[indexPath.row]
        cell.imageView = UIImageView(frame: CGRectMake(0, 0, cellWidth, cellHeight));
        cell.imageView.image = aFruit.image
        cell.addSubview(cell.imageView)
        
        cell.fruit = aFruit
            
        // In case cell was selected previously
        cell.userInteractionEnabled = true
                
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(cellWidth, cellHeight)
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        let returnValue = UICollectionViewFlowLayout()
        
        returnValue.sectionInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight)
        
        returnValue.minimumInteritemSpacing = interSpacing
        returnValue.minimumLineSpacing = interSpacing
        
        return returnValue
    }
    
    // MARK: UICollectionViewDelegate
	
	func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
		
		let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! VisualSearchCell
		
		var isRepeat = false
		for item in checkedMarks {
			if indexPath.row == item {
				isRepeat = true
				break
			}
		}
		if !isRepeat {
			checkedMarks.append(indexPath.row) // For calculating repeat.
			if cell.fruit.isValuable {
				checkedTargets.append(indexPath.row)
			}
		}
		
		// Calculate row and column of the collection view
		var total = 60
		var rows = 6
		
		switch currentView {
		case 0, 11:
			total = 3
			rows = 1
		case 1, 12:
			total = 9
			rows = 3
		case 2, 13:
			total = 18
			rows = 3
		default:
			break
		}
		
		let elementsInOneRow = total / rows
		
		var row = Double(indexPath.row + 1) / Double(elementsInOneRow)
		if elementsInOneRow == 1 || row == 0 {
			row = 1
		}
		let rowNumber = ceil(row) // This will to go into stats.
		var normalizedRow = Int(rowNumber)
		
		if normalizedRow != 0 {
			normalizedRow -= 1
		}
		
		let columnNumber = (indexPath.row - (normalizedRow * elementsInOneRow)) + 1 // This will to go into stats.
		
		let timePassed: Double = abs(timerLastStarted.timeIntervalSinceNow)
		let interval: Double = gameSpeed
		let timeLeft: Double = interval - timePassed
		
		model.addMove(Int(rowNumber), column: columnNumber, session: session, isSuccess: cell.fruit.isValuable, isRepeat: isRepeat, isTraining: isTraining, screen: currentView, isEmpty: false, extraTime: timeLeft)
		
		if cell.fruit.isValuable {
			
			if isRepeat == false {
				
				let crossImage = UIImage(named: "cross_gray")
				let cross = UIImageView(image: crossImage)
				cross.frame = cell.imageView.frame
				cell.imageView.addSubview(cross)
				
				cross.center.x = cell.contentView.center.x
				cross.center.y = cell.contentView.center.y
				
				if (!isTraining) {
					let times = session.score.integerValue
					session.score = NSNumber(integer: (times + 1))
				}
				
				// Play the success sound
				successSound.play()
				
				// Hard mode
				var gameStage = currentView
				if model.data.visSearchDifficulty == 1 { // Hard mode.
					gameStage -= 11
				}
				
				if checkedTargets.count == numberOfTargets[gameStage] {
					// Player finished fast
					timer.invalidate()
					
					if gameStage != numberOfTargets.count - 1 { // the last screen
						showBlankScreen()
					} else {
						quit()
					}
				}
				
//				print("checkedMarks.count = \(checkedMarks.count) numberOfTargets[screen] = \(numberOfTargets[gameStage])")
//				print("\(checkedMarks)")
//				print("targets = \(checkedTargets)")
			} else {
				// Repeat
				failureSound.play()
			}
			
		} else {
			// Not valuable fruit selected
			
			if (!isTraining) {
				let times = session.failureScore.integerValue
				session.failureScore = NSNumber(integer: (times + 1))
			}
			failureSound.play()
		}
	}
	
	
	func lineDrawingLayer() -> CAShapeLayer {
		let shapeLayer = CAShapeLayer()
		
		shapeLayer.strokeEnd = 0
		shapeLayer.lineWidth = 5
		shapeLayer.lineCap = kCALineCapRound
		shapeLayer.lineJoin = kCALineJoinRound
		shapeLayer.frame = self.view.layer.bounds
		shapeLayer.backgroundColor = UIColor.clearColor().CGColor
		shapeLayer.fillColor = nil
		
		return shapeLayer
	}
	
	func crossPath() -> CGPathRef {
		let path = linePath()
		
		path.moveToPoint(CGPointMake(45, 78))
		path.addLineToPoint(CGPointMake(77, 42))
		path.moveToPoint(CGPointMake(45, 42))
		path.addLineToPoint(CGPointMake(82, 78))
		
		return path.CGPath;
	}
	
	func linePath() -> UIBezierPath {
		let path = UIBezierPath()
		path.lineCapStyle = CGLineCap.Round
		path.lineWidth = 5
		
		return path
	}
	
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(MenuViewController) {
            let dest = segue.destinationViewController as! MenuViewController
            dest.setNeedsStatusBarAppearanceUpdate()
        }
    }

}
