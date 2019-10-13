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
        isFlankerRandomized = UserDefaults.standard.bool(forKey: "isFlankerRandmoized")
        
        if isFlankerRandomized {
            sessionType = SessionType.flankerRandomized.rawValue
        } else {
            sessionType = SessionType.flanker.rawValue
        }
        super.viewDidLoad()
		
		if (smallImages) {
			session.imageSizeComment = "Small images (1.5x)"
		} else {
			session.imageSizeComment = "Normal images (2x)"
		}
		
		addTouchTargetButtons()
        
    }
	override func addTouchTargetButtons() {
		
		let screen = UIScreen.main.bounds
		let screenAreaLeft = CGRect(x: 0, y: menuBarHeight, width: barWidth, height: screen.size.height-menuBarHeight)
		let screenAreaRight = CGRect(x: UIScreen.main.bounds.size.width - barWidth, y: menuBarHeight, width: barWidth, height: screen.size.height-menuBarHeight)
		let buttonLeft = UIButton(frame: screenAreaLeft)
		let buttonRight = UIButton(frame: screenAreaRight)
		buttonLeft.backgroundColor = UIColor.orange
		buttonRight.backgroundColor = UIColor.green
		buttonLeft.addTarget(self, action: #selector(CounterpointingViewController.handleTouchLeft), for: UIControl.Event.touchDown)
		buttonRight.addTarget(self, action: #selector(CounterpointingViewController.handleTouchRight), for: UIControl.Event.touchDown)
		
		let star = UIImage(named: "star")
		buttonLeft.setImage(star, for: UIControl.State())
		buttonLeft.imageView!.contentMode = UIView.ContentMode.center
		buttonRight.setImage(star, for: UIControl.State())
		buttonRight.imageView!.contentMode = UIView.ContentMode.center
		
		view.addSubview(buttonLeft)
		view.addSubview(buttonRight)
	}
	
	enum Picture {
		case empty
		case mouse
		case fish
		case mouseInverted
		case fishInverted
	}
	
	enum Position {
		case left
		case middle
		case right
	}
	
	func updateScreen(_ left: Picture, middle: Picture, right: Picture) {
		
		addImage(left, position: Position.left)
		addImage(middle, position: Position.middle)
		addImage(right, position: Position.right)
        
        toggleNavigationButtons(isEnabled: false)
	}
	
	func addImage(_ image: Picture, position:Position) {
		
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
		case .mouse:
			imageView = UIImageView(image: mouseImage)
			imageView.frame = CGRect(x: 0, y: 0, width: mouseImage!.size.width*scaleFactor, height: mouseImage!.size.height*scaleFactor)
		case .fish:
			imageView = UIImageView(image: fishImage)
			imageView.frame = CGRect(x: 0, y: 0, width: fishImage!.size.width*scaleFactor, height: fishImage!.size.height*scaleFactor)
			leftTarget = false
		case .mouseInverted:
			imageView = UIImageView(image: mouseInvertedImage)
			imageView.frame = CGRect(x: 0, y: 0, width: mouseImage!.size.width*scaleFactor, height: mouseImage!.size.height*scaleFactor)
		case .fishInverted:
			imageView = UIImageView(image: fishInvertedImage)
			imageView.frame = CGRect(x: 0, y: 0, width: fishImage!.size.width*scaleFactor, height: fishImage!.size.height*scaleFactor)
			leftTarget = true
		default:
			break
		}
		
		switch position {
		case .left:
			imageView.center = CGPoint(x: view.center.x - mouseOffset, y: view.center.y)
		case .middle:
			imageView.center = CGPoint(x: view.center.x, y: view.center.y)
		case .right:
			imageView.center = CGPoint(x: view.center.x + mouseOffset, y: view.center.y)
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
        screenPresentedDate = Date()
        
        if isFlankerRandomized == false {
            
            switch currentScreenShowing {
            case 0:
                presentMessage(greeingMessage)
            case 1:
                updateScreen(.empty, middle: .fish, right: .empty)
            case 2:
                updateScreen(.empty, middle: .fishInverted, right: .empty)
            case 3:
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 4:
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 5:
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 6:
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 7:
                presentMessage("Practice 1. Ready...")
                // Next line is to insert white space in the log.
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 8:
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 9:
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
            case 10:
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 11:
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 12:
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
            case 13:
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 14:
                presentMessage("...stop")
            case 15:
                presentMessage("Practice 2. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 16:
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 17:
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 18:
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 19:
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
            case 20:
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 21:
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
            case 22:
                presentMessage("...stop")
            case 23:
                presentMessage("Game 1. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = false
                trainingMode = false
            case 24: // 0
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 25: // 1
                updateScreen(.mouse, middle: .fish, right: .mouse)
            case 26: // 2
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
            case 27: // 3
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 28: // 4
                updateScreen(.mouse, middle: .fish, right: .mouse)
            case 29: // 5
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 30: // 6
                updateScreen(.mouse, middle: .fish, right: .mouse)
            case 31: // 7
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
            case 32: // 8
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 33: // 9
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 34:
                presentMessage("...stop")
            case 35:
                presentMessage("Game 2. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = true
            case 36: // 10
                updateScreen(.mouseInverted, middle: .fish, right: .mouseInverted)
            case 37: // 11
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 38: // 12
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 39: // 13
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 40: // 14
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 41: // 15
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
            case 42: // 16
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 43: // 17
                updateScreen(.mouseInverted, middle: .fish, right: .mouseInverted)
            case 44: // 18
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
            case 45: // 19
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 46:
                presentMessage("...stop")
            case 47:
                presentMessage("Game 3. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = true
            case 48: // 20
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
            case 49: // 21
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 50: // 22
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 51: // 23
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
            case 52: // 24
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 53: // 25
                updateScreen(.mouseInverted, middle: .fish, right: .mouseInverted)
            case 54: // 26
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
            case 55: // 27
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
            case 56: // 28
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 57: // 29
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 58:
                presentMessage("...stop")
            case 59:
                presentMessage("Game 4. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                gameModeInversed = false
            case 60: // 30
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
            case 61: // 31
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 62: // 32
                updateScreen(.mouse, middle: .fish, right: .mouse)
            case 63: // 33
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 64: // 34
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
            case 65: // 35
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 66: // 36
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
            case 67: // 37
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
            case 68: // 38
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 69: // 39
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
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
                updateScreen(.empty, middle: .fish, right: .empty)
            case 2:
                updateScreen(.empty, middle: .fishInverted, right: .empty)
            case 3:
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 4:
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 5:
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 6:
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 7:
                presentMessage("Practice 1. Ready...")
                // Next line is to insert white space in the log.
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 8:
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 9:
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
            case 10:
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 11:
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 12:
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
            case 13:
                updateScreen(.fish, middle: .mouse, right: .mouse)
            case 14:
                presentMessage("...stop")
            case 15:
                presentMessage("Practice 2. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
            case 16:
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 17:
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 18:
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 19:
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
            case 20:
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 21:
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
            case 22:
                presentMessage("...stop")
            case 23:
                presentMessage("Game 1. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                trainingMode = false
                gameModeInversed = true
            case 24: // 0
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
                gameModeInversed = true
            case 25: // 1
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
                gameModeInversed = false
            case 26: // 2
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
                gameModeInversed = false
            case 27: // 3
                updateScreen(.mouseInverted, middle: .fish, right: .mouseInverted)
                gameModeInversed = true
            case 28: // 4
                updateScreen(.mouse, middle: .fish, right: .mouse)
                gameModeInversed = false
            case 29: // 5
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
                gameModeInversed = true
            case 30: // 6
                updateScreen(.fish, middle: .mouse, right: .mouse)
                gameModeInversed = false
            case 31: // 7
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 32: // 8
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 33: // 9
                updateScreen(.mouse, middle: .fish, right: .mouse)
                gameModeInversed = false
            case 34: // 10
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
                gameModeInversed = true
            case 35: // 11
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
                gameModeInversed = true
            case 36: // 12
                updateScreen(.fishInverted, middle: .mouseInverted, right: .mouseInverted)
                gameModeInversed = false
            case 37: // 13
                gameModeInversed = true
                updateScreen(.mouseInverted, middle: .fish, right: .mouseInverted)
            case 38: // 14
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
                gameModeInversed = true
            case 39:
                presentMessage("...stop")
            case 40:
                presentMessage("Game 2. Ready...")
                model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
                trainingMode = false
                gameModeInversed = false
            case 41: // 15
                updateScreen(.mouseInverted, middle: .fishInverted, right: .mouseInverted)
            case 42: // 16
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 43: // 17
                updateScreen(.mouse, middle: .mouse, right: .fish)
            case 44: // 18
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
                gameModeInversed = true
            case 45: // 19
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 46: //20
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
            case 47: //21
                updateScreen(.mouse, middle: .mouse, right: .fish)
                gameModeInversed = false
            case 48: //22
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fishInverted)
            case 49: //23
                updateScreen(.mouseInverted, middle: .mouseInverted, right: .fish)
                gameModeInversed = true
            case 50: //24
                updateScreen(.mouse, middle: .fish, right: .mouse)
                gameModeInversed = false
            case 51: //25
                gameModeInversed = true
                updateScreen(.mouse, middle: .mouse, right: .fishInverted)
            case 52: //26
                updateScreen(.mouse, middle: .fishInverted, right: .mouse)
            case 53: //27
                updateScreen(.fishInverted, middle: .mouse, right: .mouse)
            case 54: //28
                updateScreen(.fish, middle: .mouseInverted, right: .mouseInverted)
                gameModeInversed = true
            case 55:  //29
                updateScreen(.mouse, middle: .fish, right: .mouse)
                gameModeInversed = false
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
