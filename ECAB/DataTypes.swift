//
//  DataTypes.swift
//  ECAB
//
//  Created by Raphaël Bertin on 29/06/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum GamesIndex: NSNumber {
    case VisualSearch = 0
    case Counterpointing = 1
    case Flanker = 2
    case VisualSust = 3
    case AuditorySust = 4
    case DualSust = 5
    case Verbal = 6
    case Balloon = 7
}

enum Difficulty: NSNumber {
    case Easy = 0
    case Hard = 1
}

enum Side {
    case Left
    case Right
}

enum Picture: String {
    case Empty = "white_rect"
    case Bed = "bed_inverse"
    case Ball = "ball"
    case Bike = "bike_inverse"
    case Boat = "boat_inverse"
    case Book = "book"
    case Boot = "boot"
    case Bus = "bus"
    case Cake = "cake"
    case Car = "car_inverse"
    case Cat = "cat_inverse"
    case Chair = "chair"
    case Clock = "clock"
    case Dog = "dog"
    case Door = "door"
    case Fish = "fish_iverse"
    case Horse = "horse_inverse"
    case Key = "key"
    case Leaf = "leaf"
    case Mouse = "mouse"
    case Pig = "pig"
    case Sock = "sock"
    case Spoon = "spoon"
    case Sun = "sun"
    case Star = "star_yellow"
    case Train = "train_inverse"
    case Tree = "tree"
}

enum Sound: String {
    case Positive = "positive"
    case Negative = "negative"
    case Attention = "attention"
    case Practice1 = "practice1"
    case EndOfPractice = "endofpractice"
    case Game1 = "game1"
    case EndOfGame = "endofgame"
    
    case Empty = "empty"
    case Bed = "bed"
    case Ball = "ball"
    case Bike = "bike"
    case Boat = "boat"
    case Book = "book"
    //case Boot = "boot"
    case Bus = "bus"
    case Cake = "cake"
    case Car = "car"
    case Cat = "cat"
    case Chair = "chair"
    case Clock = "clock"
    case Dog = "dog"
    case Door = "door"
    case Fish = "fish"
    case Horse = "horse"
    case Key = "key"
    case Leaf = "leaf"
    //case Mouse = "mouse"
    case Pig = "pig"
    case Shoe = "shoe"
    case Sock = "sock"
    case Spoon = "spoon"
    case Star = "star"
    case Sun = "sun"
    case Train = "train"
    case Tree = "tree"
}

enum PlayerAction {
    case Miss
    case FalsePositive
    case Hit
}

enum MenuConstants: String {
    case second = "s"
}

enum GameTitle: String {
    case visual = "Visual search"
    case counterpointing = "Counterpointing"
    case flanker = "Flanker"
    case visualSust = "Visual sustained"
    case auditorySust = "Auditory sustained"
    case dualSust = "Dual sustained"
    case verbal = "Verbal opposites"
    case balloon = "Balloon sorting"
}

enum VisualSustainMistakeType: Double {
    case Miss = 100
    case FalsePositive = 200
    case Unknown = 0
}

enum VisualSustainSkip: CGFloat {
    case NoSkip = 0
    case FourSkips = -100
}