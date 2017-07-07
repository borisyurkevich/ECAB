//
//  ECABApplesCollectionViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSearchViewController: TestViewController,
    UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
	
    var currentView = 0
    let reuseIdentifier = "ApplesCell"
    var gameSpeed: Double = VisualSearchSpeed.easyMode // Amount of seconds one view is visible, default is 20
	let transitionSpeed = 0.4
	private var checkedMarks = [Int]() // Every tapped target
	private var checkedTargets = [Int]() // Only red appples
	private var isTraining = true
	private var numberOfTargets = [0] // Depends on test difficulty
	private var collectionView: UICollectionView

    private var cellWidth:CGFloat = 190 // only for the first training view - very big
    private var cellHeight:CGFloat = 190
    private var board = VisualSearchBoard(stage: 0)
    private let interSpacing:CGFloat = 27
	private var timer = Timer()
	private var timerLastStarted = NSDate()
    
    enum Mode: Int {
        case easy = 0
        case hard = 1
    }
	
    private struct Insets {
        static var top:CGFloat = 100
        static let left:CGFloat = 10
        static let bottom:CGFloat = 10
        static let right:CGFloat = 10
    };
	
	// Inititial insets are very big
	private var insetTop: CGFloat = 260
	private var insetLeft: CGFloat = 172
    private var insetBottom:CGFloat = 10
	private var insetRight: CGFloat = 172
	
    private var boardFlowLayout: UICollectionViewFlowLayout?
    
    var presenter: MenuViewController?
    var session: Session!
	
	private var crossLayer: CAShapeLayer = CAShapeLayer()
	
	init() {
		let flowLayout = UICollectionViewFlowLayout()
		collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: flowLayout)
		
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
		
		if model.data.visSearchDifficulty.intValue == Mode.hard.rawValue {
			currentView = VisualSearchHardModeView.trainingOne.rawValue
			numberOfTargets = VisualSearchTargets.hardMode
			gameSpeed = model.data.visSearchSpeedHard.doubleValue
		} else {
			// Easy Mode
			gameSpeed = model.data.visSearchSpeed.doubleValue
            numberOfTargets = VisualSearchTargets.easyMode
		}
		
        boardFlowLayout = configureFlowLayout()
		collectionView.setCollectionViewLayout(boardFlowLayout!, animated: true)
		
        collectionView.register(VisualSearchCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		
		// Insert fresh session entity
		model.addSession(model.data.selectedPlayer)
        session = model.data.sessions.lastObject as! Session
		session.speed = NSNumber(value: gameSpeed)
		session.difficulty = model.data.visSearchDifficulty
		
        collectionView.backgroundColor = UIColor.white
		
        // Disable scrolling
        collectionView.isScrollEnabled = false
		
		backButton.setTitle("Back", for: UIControlState())
	}
    
    override func presentPause() {
        timer.pause()
        super.presentPause()
    }
    override func resumeTest() {
        timer.resume()
    }
	
	var isGameStarted = false
	func startGame() {
		if !isGameStarted {
			isGameStarted = true
		}
	}
	
    let theViewWhenTestStartsNormal = 2 // Motor One - 1
    let theViewWhenTestStartsHard = VisualSearchHardModeView.motorOne.rawValue - 1
	override func skip() {
        if model.data.visSearchDifficulty.intValue == Mode.easy.rawValue {
            currentView = theViewWhenTestStartsNormal
        } else {
            currentView = theViewWhenTestStartsHard
        }
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
		
        if model.data.visSearchDifficulty.intValue == Mode.easy.rawValue {
            if currentView == 8 + 1 { // TODO Change 8 to enum
                presentPause()
                return
            }
        } else if model.data.visSearchDifficulty.intValue == Mode.hard.rawValue {
            if currentView == VisualSearchHardModeView.two.rawValue + 1 {
                presentPause()
                return
            }
        }
		        
        UIView.transition(with: view, duration: transitionSpeed, options: UIViewAnimationOptions(), animations: {
            // animation...
            self.collectionView.alpha = 0.0
            
            }, completion: { (fininshed: Bool) -> () in
				
                // UI collection view insets.
                self.updateInsets()
				
                // Request new board
                self.board = VisualSearchBoard(stage: self.currentView)
				self.checkedMarks = []
				self.checkedTargets = []
                
                // And reload data
                self.collectionView.reloadData()
				
				self.boardFlowLayout = self.configureFlowLayout()
				self.collectionView.setCollectionViewLayout(self.boardFlowLayout!, animated: false)
				
				if (self.isGameStarted) {
					
					self.timer.invalidate()
					self.timer = Timer.scheduledTimer(timeInterval: self.gameSpeed,
						target: self,
						selector: #selector(VisualSearchViewController.showBlankScreen),
						userInfo: nil,
						repeats: false)
					self.timerLastStarted = NSDate()
				}
				
                UIView.transition(with: self.view, duration: self.transitionSpeed, options: UIViewAnimationOptions(), animations: {
                    
                    self.collectionView.alpha = 1
                    
					}, completion: { (Bool) in
						self.model.addMove(0, column: 0, session: self.session, isSuccess: false, isRepeat: false, isTraining: false, screen: self.currentView, isEmpty: true, extraTime: 0)})
        })
    }
    
    func updateInsets() {
        var defaultSize:CGFloat = 70
        if self.model.data.visSearchDifficulty.intValue == Mode.hard.rawValue {
            defaultSize = 54
        }
        
        switch (self.currentView) {
        case VisualSearchEasyModeView.trainingOne.rawValue, VisualSearchHardModeView.trainingOne.rawValue:
            self.cellWidth = 190
            self.cellHeight = 190
            
            self.insetTop = 260
            self.insetLeft = 172
            self.insetBottom = 10
            self.insetRight = 172
        case VisualSearchEasyModeView.trainingTwo.rawValue, VisualSearchHardModeView.trainingTwo.rawValue:
            self.cellWidth = 84
            self.cellHeight = 84
            self.insetTop = 220
            self.insetLeft = 340
            self.insetRight = 340
        case VisualSearchEasyModeView.trainingThree.rawValue, VisualSearchHardModeView.trainingThree.rawValue:
            self.cellWidth = defaultSize
            self.cellHeight = defaultSize
            self.insetTop = 230
            self.insetLeft = 200
            self.insetRight = 200
        case VisualSearchEasyModeView.motorOne.rawValue ... VisualSearchEasyModeView.motorThree.rawValue,
        VisualSearchHardModeView.motorOne.rawValue ... VisualSearchHardModeView.motorTwo.rawValue:
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
        
        if self.model.data.visSearchDifficulty.intValue == Mode.hard.rawValue {
            //
            // Hard Mode.
            // Training #3 needs bigger left and right insets because items have
            // smaller size. The same size as hard motor and hard test.
            if self.currentView == VisualSearchHardModeView.trainingThree.rawValue {
                self.insetTop = 230 + 35 // 230 is easy mode. 35 is needed to rougly center the collection vertically
                self.insetLeft = 245
                self.insetRight = 245
            }
            
            if self.currentView != VisualSearchHardModeView.trainingOne.rawValue
                && self.currentView != VisualSearchHardModeView.trainingTwo.rawValue
                && self.currentView != VisualSearchHardModeView.trainingThree.rawValue {
                    //
                    // Motor and Normal Test has smaller insets on top
                    // in order to fit all items on the screen.
                    self.insetTop = 60
                    self.insetLeft = 100
                    self.insetRight = 100
            }
        }
    }
	
	func showBlankScreen() {
		
		if currentView == numberOfTargets.count {
			presentPause()
			return
		}
		
		self.board = VisualSearchBoard(stage: 10)
		
		collectionView.performBatchUpdates({
			
			self.collectionView.deleteSections(IndexSet(integer: 0))

			self.collectionView.insertSections(IndexSet(integer: 0))
			
		}, completion: nil)
	}
	
    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.board.numberOfCells
    }

    func collectionView(_ collectionView: UICollectionView,
               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VisualSearchCell
		
		// Remove all subviews
		for subview in cell.subviews {
			subview.removeFromSuperview()
		}
				
        cell.backgroundColor = UIColor.red
        
        let aFruit:TestItem = self.board.data[indexPath.row]
        cell.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: cellWidth, height: cellHeight));
        cell.imageView.image = aFruit.image
        cell.addSubview(cell.imageView)
        
        cell.fruit = aFruit
            
        // In case cell was selected previously
        cell.isUserInteractionEnabled = true
                
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func configureFlowLayout() -> UICollectionViewFlowLayout {
        let returnValue = UICollectionViewFlowLayout()
        
        returnValue.sectionInset = UIEdgeInsetsMake(insetTop, insetLeft, insetBottom, insetRight)
        
        returnValue.minimumInteritemSpacing = interSpacing
        returnValue.minimumLineSpacing = interSpacing
        
        return returnValue
    }
    
    // MARK: UICollectionViewDelegate
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		
		let cell = self.collectionView.cellForItem(at: indexPath) as! VisualSearchCell
        
        // Sound
        if cell.fruit.isValuable {
            playSound(.positive)
        } else {
            playSound(.negative)
        }
		
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
		case 0, VisualSearchHardModeView.trainingOne.rawValue:
			total = 3
			rows = 1
		case 1, VisualSearchHardModeView.trainingTwo.rawValue:
			total = 9
			rows = 3
		case 2, VisualSearchHardModeView.trainingThree.rawValue:
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
					let times = session.score.intValue
					session.score = NSNumber(value: (times + 1) as Int)
				}
				
				var gameStage = currentView
                if model.data.visSearchDifficulty.intValue == Mode.hard.rawValue {
					gameStage -= VisualSearchHardModeView.trainingOne.rawValue
				}
				
				if checkedTargets.count == numberOfTargets[gameStage] {
					// Player finished fast
					timer.invalidate()
					
					if gameStage != numberOfTargets.count - 1 { // the last screen
						showBlankScreen()
					} else {
						presentPause()
					}
				}

			}
		} else {
			// Not valuable fruit selected
			if (!isTraining) {
				let times = session.failureScore.intValue
				session.failureScore = NSNumber(value: (times + 1) as Int)
			}
		}
	}
	
	
	func lineDrawingLayer() -> CAShapeLayer {
		let shapeLayer = CAShapeLayer()
		
		shapeLayer.strokeEnd = 0
		shapeLayer.lineWidth = 5
		shapeLayer.lineCap = kCALineCapRound
		shapeLayer.lineJoin = kCALineJoinRound
		shapeLayer.frame = self.view.layer.bounds
		shapeLayer.backgroundColor = UIColor.clear.cgColor
		shapeLayer.fillColor = nil
		
		return shapeLayer
	}
	
	func crossPath() -> CGPath {
		let path = linePath()
		
		path.move(to: CGPoint(x: 45, y: 78))
		path.addLine(to: CGPoint(x: 77, y: 42))
		path.move(to: CGPoint(x: 45, y: 42))
		path.addLine(to: CGPoint(x: 82, y: 78))
		
		return path.cgPath;
	}
	
	func linePath() -> UIBezierPath {
		let path = UIBezierPath()
		path.lineCapStyle = CGLineCap.round
		path.lineWidth = 5
		
		return path
	}
    
    override  func getComment() -> String {
        return session.comment
    }
    override func addComment(_ alert: UIAlertController) {
        if let fields = alert.textFields {
            let textField = fields[0]
            if let existingComment = textField.text {
                self.session.comment = existingComment
            }
        }
    }
	
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: MenuViewController.self) {
            let dest = segue.destination as! MenuViewController
            dest.setNeedsStatusBarAppearanceUpdate()
        }
    }

}
