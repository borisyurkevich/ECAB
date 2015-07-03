//
//  VisualSustainViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 02/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSustainViewController: CounterpointingViewController {

    override func viewDidLoad() {
		sessionType = 2
		greeingMessage = "Practice 1"
        super.viewDidLoad()
    }
	
	enum Picture: String {
		case Empty = ""
		case Mouse = "mouse"
		case Fish = "fish"
		case FishInverse = "fish_iverse"
		case Pig = "pig"
		case Dog = "dog"
		case HorseInverse = "horse_inverse"
		case Cat = "cat_inverse"
	}
	
	func updateView(pic: Picture) {
		
		// Add Image
		let image = UIImage(named: pic.rawValue)
		let imageView = UIImageView(image: image)
		imageView.frame = CGRectMake(0, 0, imageView.frame.size.width * 2, imageView.frame.size.height * 2)
		imageView.center = view.center
		view.addSubview(imageView)
		
		// Gesture
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func showFirstView() {
		updateView(.Cat)
	}
	
	override func tapHandler(sender: UITapGestureRecognizer) {
		
	}
	
	override func presentPreviousScreen() { // Restarts the practice
		
		switch currentScreenShowing {
		case 7:
			currentScreenShowing -= 8
		case 15:
			currentScreenShowing -= 16
		case 23:
			currentScreenShowing -= 24
		default:
			break
		}
		
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
		case 1:
			showFirstView()
			break
		default:
			break
		}
	}

}
