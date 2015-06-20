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
			trainingMode = false
			view.addSubview(backButton!)
			break
		default:
			break
		}
	}

}
