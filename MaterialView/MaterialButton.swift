//
//  MaterialButton.swift
//  MaterialSample
//
//  Created by Karthik M R on 6/18/15.
//  Copyright (c) 2015 Karthik M R. All rights reserved.
//

import UIKit

protocol MaterialButtonDelegate{
  func buttonDidAppearAnimated(button: MaterialButton)
  func buttonDidDisappearAnimated(button: MaterialButton)
}

class MaterialButton: UIButton {
  
  var centerPoint: CGPoint!{
    didSet{
      assert(centerPoint != nil, "centerPoint: CGPoint can't be nil")
    }
  }
  
  var originPoint: CGPoint!{
    didSet{
      assert(originPoint != nil, "originPoint: CGPoint can't be nil")
      self.center = originPoint
    }
  }
  var delegate: MaterialButtonDelegate?
  var initialScale: CGVector!{
    didSet{
      assert(initialScale != nil, "initialScale: CGVector can't be nil")
      if initialScale.dx > 1.0{
        initialScale.dx = 1.0
      }
      if initialScale.dy > 1.0{
        initialScale.dy = 1.0
      }
      self.transform = CGAffineTransformMakeScale(self.initialScale.dx, self.initialScale.dy)
    }
  }
  
  var hint: String?
  var hintTextColor: UIColor = UIColor.blackColor()
  var hintBackgroundColor: UIColor = UIColor(white: 1.0, alpha: 0.0)
  var hintTextFont: UIFont?
  
  convenience init(frame: CGRect, originPoint: CGPoint, centerPoint: CGPoint){
    self.init(frame: frame)
    self.centerPoint = centerPoint
    self.originPoint = originPoint
  }
  
  func buttonWillAppear(){
    self.alpha = 1.0
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.center = self.centerPoint
      self.transform = CGAffineTransformMakeScale(1.0, 1.0)
      }) { (completed) -> Void in
        delegate?.buttonDidAppearAnimated(self)
    }
  }
  
  func buttonWillDisappear(){
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.center = self.originPoint
      self.transform = CGAffineTransformMakeScale(self.initialScale.dx, self.initialScale.dy)
    }) { (completed) -> Void in
      self.alpha = 0.0
      self.delegate?.buttonDidDisappearAnimated(self)
    }
  }
}
