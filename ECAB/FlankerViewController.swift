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
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

		
		addImage(left, x: 19, y: 356)
		addImage(middle, x: 457, y: 356)
		addImage(right, x: 300, y: 356)
	}
	
	func addImage(image: Picture, x: CGFloat, y: CGFloat) {
		
		let fishImage = UIImage(named: "fish")
		let mouseImage = UIImage(named: "mouse")
		let fishInvertedImage = UIImage(named: "fish_iverse")
		let mouseInvertedImage = UIImage(named: "mouse_invrse")
		
		switch image {
		case .Mouse:
			let imageView = UIImageView(image: mouseImage)
			imageView.frame = CGRectMake(x, y, mouseImage!.size.width, mouseImage!.size.height)
			view.addSubview(imageView)
			break
		case .Fish:
			let imageView = UIImageView(image: fishImage)
			imageView.frame = CGRectMake(x, y, fishImage!.size.width, fishImage!.size.height)
//			println("View center x: \(view.center.x) y: \(view.center.y)")
//			println("Img view center x: \(imageView.center.x) y: \(imageView.center.y)")
			view.addSubview(imageView)
			break
		case .MouseInverted:
			let imageView = UIImageView(image: mouseInvertedImage)
			imageView.frame = CGRectMake(x, y, pictureWidth, pictureHeight)
			view.addSubview(imageView)
			break
		case .FishInverted:
			let imageView = UIImageView(image: fishInvertedImage)
			imageView.frame = CGRectMake(x, y, pictureWidth, pictureHeight)
			view.addSubview(imageView)
			break
		default:
			break
		}
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
		default:
			break
		}
	}

}
