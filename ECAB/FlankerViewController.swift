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

    override func viewDidLoad() {
		greeingMessage = "Example stimuli..."
		sessionType = 1
        super.viewDidLoad()

    }
	
	enum Picture {
		case Empty
		case Mouse
		case Fish
		case MouseInverted
		case FishInverted
	}
	
	func updateScreen(left: Picture, middle: Picture, right: Picture) {
		// Add image to the left

		
		addImage(left, x: 95, y: 328)
		addImage(middle, x: 402, y: 328)
		addImage(right, x: 717, y: 328)
		
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func addImage(image: Picture, x: CGFloat, y: CGFloat) {
		
		let fishImage = UIImage(named: "fish")
		let mouseImage = UIImage(named: "mouse")
		let fishInvertedImage = UIImage(named: "fish_iverse")
		let mouseInvertedImage = UIImage(named: "mouse_inverse")
		
		switch image {
		case .Mouse:
			let imageView = UIImageView(image: mouseImage)
			imageView.frame = CGRectMake(x, y, mouseImage!.size.width*2, mouseImage!.size.height*2)
			view.addSubview(imageView)
			break
		case .Fish:
			let imageView = UIImageView(image: fishImage)
			imageView.frame = CGRectMake(x, y, fishImage!.size.width*2, fishImage!.size.height*2)
//			println("View center x: \(view.center.x) y: \(view.center.y)")
//			println("Img view center x: \(imageView.center.x) y: \(imageView.center.y)")
			view.addSubview(imageView)
			leftTarget = false
			break
		case .MouseInverted:
			let imageView = UIImageView(image: mouseInvertedImage)
			imageView.frame = CGRectMake(x, y, mouseImage!.size.width*2, mouseImage!.size.height*2)
			view.addSubview(imageView)
			break
		case .FishInverted:
			let imageView = UIImageView(image: fishInvertedImage)
			imageView.frame = CGRectMake(x, y, fishImage!.size.width*2, fishImage!.size.height*2)
			view.addSubview(imageView)
			leftTarget = true
			break
		default:
			break
		}
	}
	
	override func presentPreviousScreen() { // Restarts the practice
		currentScreenShowing -= 8
		trainingMode = true
		presentNextScreen()
	}
	
	override func presentNextScreen() {
		currentScreenShowing++
		cleanView()
		screenPresentedDate = NSDate()
		
		switch currentScreenShowing {
		case 0:
			presentMessage(greeingMessage)
			break
		case 1:
			updateScreen(.Empty, middle: .Fish, right: .Empty)
			break
		case 2:
			updateScreen(.Empty, middle: .FishInverted, right: .Empty)
			break
		case 3:
			updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
			break
		case 4:
			updateScreen(.Mouse, middle: .Mouse, right: .Fish)
			break
		case 5:
			updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
			break
		case 6:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
			break
		case 7:
			presentMessage("Practice 1. Ready...")
			view.addSubview(backButton!)
			break
		case 8:
			updateScreen(.Fish, middle: .Mouse, right: .Mouse)
			break
		case 9:
			updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
			break
		case 10:
			updateScreen(.Fish, middle: .Mouse, right: .Mouse)
			break
		case 11:
			updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
			break
		case 12:
			updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
			break
		case 13:
			updateScreen(.Fish, middle: .Mouse, right: .Mouse)
			break
		case 14:
			presentMessage("...stop")
			break
		case 15:
			presentMessage("Practice 2. Ready")
			break
		case 16:
			updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
			break
		case 17:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
			break
		case 18:
			updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
			break
		case 19:
			updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
			break
		case 20:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
			break
		case 21:
			updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
			break
		case 22:
			presentMessage("...stop")
			break
		case 23:
			presentMessage("Game 1. Ready...")
			trainingMode = false
			break
		case 24:
			updateScreen(.Mouse, middle: .Mouse, right: .Fish)
			break
		case 25:
			updateScreen(.Mouse, middle: .Fish, right: .Mouse)
			break
		case 26:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
			break
		case 27:
			updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
			break
		case 28:
			updateScreen(.Mouse, middle: .Fish, right: .Mouse)
			break
		case 29:
			updateScreen(.Mouse, middle: .Mouse, right: .Fish)
			break
		case 30:
			updateScreen(.Mouse, middle: .Fish, right: .Mouse)
			break
		case 31:
			updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
			break
		case 32:
			updateScreen(.Mouse, middle: .Mouse, right: .Fish)
			break
		case 33:
			updateScreen(.Fish, middle: .Mouse, right: .Mouse)
			break
		case 34:
			presentMessage("...stop")
			break
		case 35:
			presentMessage("Game 2. Ready...")
			break
		case 36:
			updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
			break
		case 37:
			updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
			break
		case 38:
			updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
			break
		case 39:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
			break
		case 40:
			updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
			break
		case 41:
			updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
			break
		case 42:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
			break
		case 43:
			updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
			break
		case 44:
			updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
			break
		case 45:
			updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
			break
		case 46:
			presentMessage("...stop")
			break
		case 47:
			presentMessage("Game 3. Ready...")
			break
		case 48:
			updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
			break
		case 49:
			updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
			break
		case 50:
			updateScreen(.Mouse, middle: .FishInverted, right: .Mouse)
			break
		case 51:
			updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
			break
		case 52:
			updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
			break
		case 53:
			updateScreen(.MouseInverted, middle: .Fish, right: .MouseInverted)
			break
		case 54:
			updateScreen(.Fish, middle: .MouseInverted, right: .MouseInverted)
			break
		case 55:
			updateScreen(.Mouse, middle: .Mouse, right: .FishInverted)
			break
		case 56:
			updateScreen(.FishInverted, middle: .Mouse, right: .Mouse)
			break
		case 57:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .Fish)
			break
		case 58:
			presentMessage("...stop")
			break
		case 59:
			presentMessage("Game 4. Ready")
			break
		case 60:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
			break
		case 61:
			updateScreen(.Mouse, middle: .Mouse, right: .Fish)
			break
		case 62:
			updateScreen(.Mouse, middle: .Fish, right: .Mouse)
			break
		case 63:
			updateScreen(.MouseInverted, middle: .FishInverted, right: .MouseInverted)
			break
		case 64:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
			break
		case 65:
			updateScreen(.Mouse, middle: .Mouse, right: .Fish)
			break
		case 66:
			updateScreen(.MouseInverted, middle: .MouseInverted, right: .FishInverted)
			break
		case 67:
			updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
			break
		case 68:
			updateScreen(.Fish, middle: .Mouse, right: .Mouse)
			break
		case 69:
			updateScreen(.FishInverted, middle: .MouseInverted, right: .MouseInverted)
			break
		case 70:
			presentMessage("...stop")
			break
		case 71:
			quit()
			break
		default:
			break
		}
	}
}
