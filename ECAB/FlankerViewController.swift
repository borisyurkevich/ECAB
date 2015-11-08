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

    override func viewDidLoad() {
		greeingMessage = "Example stimuli..."
		sessionType = 1
        super.viewDidLoad()
		
		if (smallImages) {
			session.imageSizeComment = "Small images (1.5x)"
		} else {
			session.imageSizeComment = "Normal images (2x)"
		}
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
		
		let barWidth: CGFloat = 72
		
		let leftBarView = UIView(frame: CGRectMake(0, 0, barWidth, UIScreen.mainScreen().bounds.size.height))
		leftBarView.backgroundColor = UIColor.orangeColor()
		view.addSubview(leftBarView)
		
		let star = UIImage(named: "star")
		let starImg = UIImageView(image: star)
		starImg.center = leftBarView.center
		leftBarView.addSubview(starImg)
		
		let rightBarView = UIView(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width - barWidth, 0, barWidth, UIScreen.mainScreen().bounds.size.height))
		rightBarView.backgroundColor = UIColor.greenColor()
		view.addSubview(rightBarView)
		
		let rightStarImg = UIImageView(image: star)
		rightStarImg.center = CGPointMake(rightBarView.bounds.size.width/2, rightBarView.bounds.size.height/2)
		rightBarView.addSubview(rightStarImg)
		
		// Gestures
		super.addGestures() // Will clean the gestures.
		
		let leftTapView = UIView(frame: starImg.frame)
		leftBarView.addSubview(leftTapView)
		let rightTapView = UIView(frame: rightStarImg.frame)
		rightBarView.addSubview(rightTapView)
		
		let leftTap = UITapGestureRecognizer(target: self, action: "tapHandler:")
		let rightTap = UITapGestureRecognizer(target: self, action: "tapHandler:")
		leftTapView.addGestureRecognizer(leftTap)
		rightTapView.addGestureRecognizer(rightTap)
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
	
	override func presentNextScreen() {
		currentScreenShowing++
		cleanView()
		screenPresentedDate = NSDate()
		
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
			quit()
		default:
			break
		}
	}
}
