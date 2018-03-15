//
//  TImer Extension.swift
//  ECAB
//
//  Created by Boris Yurkevich on 16/06/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import ObjectiveC

#if os(iOS)
    import UIKit
#else
    import AppKit
#endif


private var pauseStartKey:UInt8 = 0;
private var previousFireDateKey:UInt8 = 0;

extension Timer
{
    private var pauseStart: NSDate!{
        get{
            return objc_getAssociatedObject(self, &pauseStartKey) as? NSDate
            
        }
        set(newValue)
        {
            objc_setAssociatedObject(self, &pauseStartKey,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    private var previousFireDate: NSDate!{
        get{
            return objc_getAssociatedObject(self, &previousFireDateKey) as? NSDate
            
        }
        set(newValue)
        {
            objc_setAssociatedObject(self, &previousFireDateKey,newValue,objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    
    
    func pause()
    {
        pauseStart = NSDate();
        previousFireDate = self.fireDate as NSDate;
        self.fireDate = Date.distantFuture ;
    }
    
    func resume()
    {
        if(pauseStart != nil)
        {
            let pauseTime = -1 * pauseStart.timeIntervalSinceNow;
            let date = Date(timeInterval:pauseTime, since:previousFireDate as Date );
            self.fireDate = date;
        }
        
    }
}
