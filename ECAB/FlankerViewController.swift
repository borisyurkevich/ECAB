//
//  FlankerViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/20/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class FlankerViewController: CounterpointingViewController {
	
	var smallImages = false
	let barWidth: CGFloat = 72
    var isFlankerRandomized = false

    override func viewDidLoad() {
		greeingMessage = "Example stimuli..."
		sessionType = 1
        super.viewDidLoad()
		
		if (smallImages) {
			session.imageSizeComment = "Small images (1.5x)"
		} else {
			session.imageSizeComment = "Normal images (2x)"
		}
		
		addTouchTargetButtons()
        isFlankerRandomized = NSUserDefaults.standardUserDefaults().boolForKey("isFlankerRandmoized")
    }
	override func addTouchTargetButtons() {
		
		let screen = UIScreen.mainScreen().bounds
		let screenAreaLeft = CGRectMake(0, menuBarHeight, barWidth, screen.size.height-menuBarHeight)
		let screenAreaRight = CGRectMake(UIScreen.mainScreen().bounds.size.width - barWidth, menuBarHeight, barWidth, screen.size.height-menuBarHeight)
		let buttonLeft = UIButton(frame: screenAreaLeft)
		let buttonRight = UIButton(frame: screenAreaRight)
		buttonLeft.backgroundColor = UIColor.orangeColor()
		buttonRight.backgroundColor = UIColor.greenColor()
		buttonLeft.addTarget(self, action: #selector(CounterpointingViewController.handleTouchLeft), forControlEvents: UIControlEvents.TouchDown)
		buttonRight.addTarget(self, action: #selector(CounterpointingViewController.handleTouchRight), forControlEvents: UIControlEvents.TouchDown)
		
		let star = UIImage(named: "star")
		buttonLeft.setImage(star, forState: UIControlState.Normal)
		buttonLeft.imageView!.contentMode = UIViewContentMode.Center
		buttonRight.setImage(star, forState: UIControlState.Normal)
		buttonRight.imageView!.contentMode = UIViewContentMode.Center
		
		view.addSubview(buttonLeft)
		view.addSubview(buttonRight)
	}
	
	enum Picture {
		case Empty
		case Mouse
		case Fish
		case MouseInverted
		case FishInverted
	}
	
	enum Position {
		case Left
		case Middle
		case Right
	}
	
	func updateScreen(left: Picture, middle: Picture, right: Picture) {
		
		addImage(left, position: Position.Left)
		addImage(middle, position: Position.Middle)
		addImage(right, position: Position.Right)
	}
	
	func addImage(image: Picture, position:Position) {
		
		let fishImage = UIImage(named: "fish")
		let mouseImage = UIImage(named: "mouse")
		let fishInvertedImage = UIImage(named: "fish_iverse")
		let mouseInvertedImage = UIImage(named: "mouse_inverse")
		
		var scaleFactor:CGFloat = 2.0
		var mouseOffset = (view.frame.size.width / 4)
		if (smallImages) {
			scaleFactor = 1.5
			mouseOffset = (view.frame.size.width / 4) * 0.75
		}
		
		var imageView = UIImageView()
		
		switch image {
		case .Mouse:
			imageView = UIImageView(image: mouseImage)
			imageView.frame = CGRectMake(0, 0, mouseImage!.size.width*scaleFactor, mouseImage!.size.height*scaleFactor)
		case .Fish:
			imageView = UIImageView(image: fishImage)
			imageView.frame = CGRectMake(0, 0, fishImage!.size.width*scaleFactor, fishImage!.size.height*scaleFactor)
			leftTarget = false
		case .MouseInverted:
			imageView = UIImageView(image: mouseInvertedImage)
			imageView.frame = CGRectMake(0, 0, mouseImage!.size.width*scaleFactor, mouseImage!.size.height*scaleFactor)
		case .FishInverted:
			imageView = UIImageView(image: fishInvertedImage)
			imageView.frame = CGRectMake(0, 0, fishImage!.size.width*scaleFactor, fishImage!.size.height*scaleFactor)
			leftTarget = true
		default:
			break
		}
		
		switch position {
		case .Left:
			imageView.center = CGPointMake(view.center.x - mouseOffset, view.center.y)
		case .Middle:
			imageView.center = CGPointMake(view.center.x, view.center.y)
		case .Right:
			imageView.center = CGPointMake(view.center.x + mouseOffset, view.center.y)
		}
		
		view.addSubview(imageView)
	}
	
	override func skip() {
		currentScreenShowing = 22
		presentNextScreen()
	}
    
    override  func getComment() -> String {
        return session.comment
    }
	
	override func presentPreviousScreen() {
		if trainingMode {
			currentScreenShowing = -1
			presentNextScreen()
		} else {
			currentScreenShowing = 22
			presentNextScreen()
		}
	}
	
	override func presentNextScreen() {
    
        currentScreenShowing += 1
        cleanView()
        screenPresentedDate = NSDate()
        
        if isFlankerRandomized == false {
            
            switch currentScreenShowing {
            case 0:
                presentMessage(greeingMessage)
            case 1:
                updateScreen(.Empty, middle: .Fish, right: .Empty)
            case 2:
                updateScreen(.Empty, middle: .FishInverted, right: .Empty)
            case 3:
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 4:
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 5:
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 6:
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 7:
                presentMessage("Practice 1. Ready...")
                // Next line is to insert white space in the log.
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 8:
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 9:
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 10:
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 11:
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 12:
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 13:
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 14:
                presentMessage("...stop")
            case 15:
                presentMessage("Practice 2. Ready")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 16:
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 17:
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 18:
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 19:
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 20:
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 21:
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
            case 22:
                presentMessage("...stop")
            case 23:
                presentMessage("Game 1. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = false
                trainingMode = false
            case 24: // 0
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 25: // 1
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
            case 26: // 2
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
            case 27: // 3
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 28: // 4
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
            case 29: // 5
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 30: // 6
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
            case 31: // 7
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 32: // 8
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 33: // 9
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 34:
                presentMessage("...stop")
            case 35:
                presentMessage("Game 2. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = true
            case 36: // 10
                updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
            case 37: // 11
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 38: // 12
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 39: // 13
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 40: // 14
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 41: // 15
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
            case 42: // 16
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 43: // 17
                updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
            case 44: // 18
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 45: // 19
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 46:
                presentMessage("...stop")
            case 47:
                presentMessage("Game 3. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = true
            case 48: // 20
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 49: // 21
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 50: // 22
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 51: // 23
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
            case 52: // 24
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 53: // 25
                updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
            case 54: // 26
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
            case 55: // 27
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 56: // 28
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 57: // 29
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 58:
                presentMessage("...stop")
            case 59:
                presentMessage("Game 4. Ready")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = false
            case 60: // 30
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
            case 61: // 31
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 62: // 32
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
            case 63: // 33
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 64: // 34
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
            case 65: // 35
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 66: // 36
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
            case 67: // 37
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 68: // 38
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 69: // 39
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 70:
                presentMessage("...stop")
            case 71:
                presentPause()
            default:
                break
            }
            
        } else {
        
        /*
            The initial practice blocks are unchanged.
            
            After that, we have two blocks each of which contains 15 trials randomized between ‘inverted’ and ‘normal’ versions.
            I have added gameModeInversed = false before a trial every time we are changing from inverted to normal.  Similarly I have added  gameModeInversed = true  when we change from normal to inverted.  These are inserted before the relevant case nn: line.   I hope this is the right place and will mean that the results from the two types of trials will be correctly sorted for calculating the average times.
            I have adjusted the lines like   case 25: //1 so that there are successive numbers for each new screen including the screens that contain messages.  I hope this is correct.
            
            To make sure I was keeping track of which trial was of which type, I have included a number such as 6i  in red ( i meaning the sixth trial is inverted, with n for normal (non-inverted) trials) at the beginning of each updateScreen line.  I presume you will need to strip these off, but I hope they will help you to ensure that the two types are correctly handled.
            
            Oliver B.
        */
        
            switch currentScreenShowing {
            case 0:
                presentMessage("Example stimuli...")
            case 1:
                updateScreen(.Empty, middle: .Fish, right: .Empty)
            case 2:
                updateScreen(.Empty, middle: .FishInverted, right: .Empty)
            case 3:
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 4:
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 5:
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 6:
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 7:
                presentMessage("Practice 1. Ready...")
                // Next line is to insert white space in the log.
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 8:
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 9:
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 10:
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 11:
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 12:
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 13:
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 14:
                presentMessage("...stop")
            case 15:
                presentMessage("Practice 2. Ready")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 16:
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 17:
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 18:
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 19:
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 20:
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
            case 21:
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
            case 22:
                presentMessage("...stop")
            case 23:
                presentMessage("Game 1. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                trainingMode = false
                gameModeInversed = true
            case 24: // 0 1i
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
                gameModeInversed = false
            case 25: // 1 2n
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
            case 26: // 2 3n
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
                gameModeInversed = true
            case 27: // 3 4i
                updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
                gameModeInversed = false
            case 28: // 4 5n
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
                gameModeInversed = true
            case 29: // 5 6i
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
                gameModeInversed = false
            case 30: // 6 7n
                updateScreen(.Fish, middle: .Mouse, right: .Mouse)
            case 31: // 7 8n
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 32: // 8 9n
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 33: // 9 10n
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
                gameModeInversed = true
            case 34: // 10 11i
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 35: // 11 12i
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
                gameModeInversed = false
            case 36: // 12 13n
                updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
            case 37: // 13 14i
                gameModeInversed = true
                updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
            case 38: // 14 15i
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 39:
                presentMessage("...stop")
            case 40:
                presentMessage("Game 2. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                trainingMode = false
                gameModeInversed = false
            case 41: // 15 16n
                updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
            case 42: // 16 17n
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 43: // 17 18n
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
                gameModeInversed = true
            case 44: // 18 19i
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 45: // 19 20i
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 46: //20 21i
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
                gameModeInversed = false
            case 47: //21 22n
                updateScreen(.Mouse, middle: .Mouse, right: .Fish)
            case 48: //22 23n
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
                gameModeInversed = true
            case 49: //23 24i
                updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
                gameModeInversed = false
            case 50: //24 25n
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
            case 51: //25 26i
                gameModeInversed = true
                updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
            case 52: //26 27i
                updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
            case 53: //27 28i
                updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
            case 54: //28 29i
                updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
                gameModeInversed = false
            case 55:  //29 30n
                updateScreen(.Mouse, middle: .Fish, right: .Mouse)
            case 56: 
                presentMessage("...stop")
            case 57:
                presentPause()
            default:
                break
            }
        }
	}
}
