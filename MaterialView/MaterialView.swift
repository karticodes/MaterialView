//
//  MaterialView.swift
//
//  Created by Karthik M R on 6/18/15.
//  Copyright (c) 2015 Karthik M R. All rights reserved.
//

import UIKit

extension Array {
  mutating func removeObject<U: Equatable>(object: U) -> Bool {
    for (idx, objectToCompare) in enumerate(self) {
      if let to = objectToCompare as? U {
        if object == to {
          self.removeAtIndex(idx)
          return true
        }
      }
    }
    return false
  }
}

@objc enum MaterialDirection: Int{
  case Top, Bottom, Left, Right
}

typealias ButtonHints = (hint: String, backgroundColor: UIColor, textColor: UIColor)

@objc protocol MaterialViewDelegate{
  func numberOfItems(inMaterialView view: MaterialView)->Int
  func minimumSpacingBetweenButtons(inMaterialView view:MaterialView)->CGFloat
  func materialView(view:MaterialView, materialButtonAtIndex index: Int)->MaterialButton
  
  optional func materialMenu(view: MaterialView, buttonDirectionInRect frame:CGRect)->MaterialDirection
  optional func hintDirection(inMaterialView view: MaterialView)->MaterialDirection
  optional func shouldShowHint(inMaterialView view: MaterialView)->Bool
  optional func overlayColor(inMaterialView view: MaterialView)->UIColor
  optional func materialViewItemsDidAppear(view:MaterialView)
  optional func materialViewItemsDidDisappear(view:MaterialView)
  optional func materialView(view : MaterialView, didClickedButtonAtIndex index:Int)
}

class MaterialView: NSObject {
  
  var menuButton: UIButton!
  var delegate: MaterialViewDelegate!
  
  private var direction = MaterialDirection.Top
  private var hintDirection = MaterialDirection.Left
  private var spacing : CGFloat = 0.0
  private var shouldShowHints: Bool = false
  private var items = 0
  private var buttons: [MaterialButton] = []
  private var hints: [UILabel] = []
  private var animationTimer: NSTimer?
  private var tapGesture: UITapGestureRecognizer?
  private var overlayView: UIView?
  
  var mainWindow: UIWindow{
    return UIApplication.sharedApplication().delegate!.window!!
  }
  
  convenience init(menuButton: UIButton, frameInWindow buttonFrame: CGRect, delegate: MaterialViewDelegate){
    self.init()
    self.menuButton = menuButton
    self.menuButton.frame = buttonFrame
    self.menuButton.addTarget(self, action: Selector("menuButtonClicked:"), forControlEvents: .TouchUpInside)
    self.delegate = delegate
    mainWindow.addSubview(menuButton)
    animateMenuButton()
  }
  
  func animateMenuButton(){
    self.menuButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.menuButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
    })
  }
  
  func menuButtonClicked(sender: UIButton!){
    if let _ = animationTimer{
      return
    }
    if buttons.count > 0{
      hideMenu()
    }else{
      showMenu()
    }
  }
  
  func initValues(){
    items = delegate.numberOfItems(inMaterialView: self)

    if let dir = delegate.materialMenu?(self, buttonDirectionInRect: menuButton.frame){
      direction = dir
    }
    if let show = delegate.shouldShowHint?(inMaterialView: self){
      self.shouldShowHints = show
    }
    if let dir = delegate.hintDirection?(inMaterialView: self){
      self.hintDirection = dir
    }
  }
}

extension MaterialView{
  func getInitialSpace()->CGFloat{
    var space: CGFloat
    switch direction{
    case .Top:
      space = CGRectGetMinY(menuButton.frame)
    case .Bottom:
      space = CGRectGetMaxY(menuButton.frame)
    case .Left:
      space = CGRectGetMinX(menuButton.frame)
    case .Right:
      space = CGRectGetMaxX(menuButton.frame)
    }
    return space
  }
  
  func setCenterPoint(inout btn: MaterialButton,inout totalSpace: CGFloat, spacing: CGFloat){
    switch direction{
    case .Top:
      btn.centerPoint = CGPointMake(btn.originPoint.x, totalSpace-(spacing+CGRectGetHeight(btn.frame)/2))
      totalSpace-=(spacing+CGRectGetHeight(btn.frame))
    case .Bottom:
      btn.centerPoint = CGPointMake(btn.originPoint.x, totalSpace+spacing+CGRectGetHeight(btn.frame)/2)
      totalSpace+=spacing+CGRectGetHeight(btn.frame)
    case .Left:
      btn.centerPoint = CGPointMake(totalSpace-(spacing+CGRectGetWidth(btn.frame)/2), btn.originPoint.y)
      totalSpace-=(spacing+CGRectGetWidth(btn.frame))
    case .Right:
      btn.centerPoint = CGPointMake(totalSpace+spacing+CGRectGetWidth(btn.frame)/2, btn.originPoint.y)
      totalSpace+=spacing+CGRectGetWidth(btn.frame)
    }
  }
  
  func showMenu(){
    initValues()
    spacing = delegate.minimumSpacingBetweenButtons(inMaterialView: self)
    var totalSpace = getInitialSpace()
    for index in 0...items-1{
      var btn = delegate.materialView(self, materialButtonAtIndex: index)
      btn.originPoint = menuButton.center
      btn.tag = index
      btn.alpha = 0.0
      btn.delegate = self
      btn.addTarget(self, action: Selector("materialButtonClicked:"), forControlEvents: .TouchUpInside)
      setCenterPoint(&btn, totalSpace: &totalSpace, spacing: spacing)
      btn.initialScale = CGVectorMake(CGRectGetWidth(menuButton.frame)/CGRectGetWidth(btn.frame), CGRectGetHeight(menuButton.frame)/CGRectGetHeight(btn.frame))
      addHint(forButton: btn)
      mainWindow.insertSubview(btn, belowSubview: (buttons.count == 0 ? menuButton: buttons[index-1]))
      buttons.append(btn)
    }
    
    var duration = 0.5/CGFloat(items)
    items = 0
    animationTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(duration), target: self, selector: Selector("animateShowNextItem:"), userInfo: nil, repeats: true)
  }
  
  func animateShowNextItem(sender: NSTimer){
    if items == buttons.count{
      invalidateTimer()
      return
    }
    var btn = buttons[items]
    btn.buttonWillAppear()
    items++
  }
  
  func hideMenu(){
    hideHints()
    var duration = 0.5/CGFloat(items)
    animationTimer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(duration), target: self, selector: Selector("animateHideNextItem:"), userInfo: nil, repeats: true)
  }
    
  func animateHideNextItem(sender: NSTimer){
    if items == 0{
      invalidateTimer()
      return
    }
    var btn = buttons[items-1]
    btn.buttonWillDisappear()
    items--
  }
  
  func invalidateTimer(){
    animationTimer?.invalidate()
    animationTimer = nil
  }
  
  func materialButtonClicked(sender: MaterialButton){
    delegate?.materialView?(self, didClickedButtonAtIndex: sender.tag)
  }
  
  func addTapGesture(behindButton button: MaterialButton){
    if overlayView == nil{
      overlayView = UIView(frame: mainWindow.frame)
      overlayView!.userInteractionEnabled = true
      mainWindow.insertSubview(overlayView!, belowSubview: button)
      tapGesture = UITapGestureRecognizer(target: self, action: Selector("handleTapGesture:"))
      overlayView!.addGestureRecognizer(tapGesture!)
    }
    if let bgColor = delegate.overlayColor?(inMaterialView: self){
      overlayView!.backgroundColor = bgColor
    }
    overlayView?.hidden = false
  }
  
  func handleTapGesture(sender: UITapGestureRecognizer){
    hideMenu()
  }
}

extension MaterialView : MaterialButtonDelegate{
  func buttonDidAppearAnimated(button: MaterialButton) {
    if button.tag == buttons.count-1{
      showHints()
      addTapGesture(behindButton: button)
      delegate?.materialViewItemsDidAppear?(self)
    }
  }
  
  func buttonDidDisappearAnimated(button: MaterialButton) {
    buttons.removeObject(button)
    button.removeFromSuperview()
    if buttons.count == 0{
      overlayView?.hidden = true
      tapGesture = nil
      delegate?.materialViewItemsDidDisappear?(self)
    }
  }
}

extension MaterialView{
  func showHints(){
    if shouldShowHints{
      for label in hints{
        mainWindow.addSubview(label)
      }
    }
  }
  
  func hideHints(){
    if shouldShowHints{
      for label in hints{
        label.removeFromSuperview()
      }
      hints.removeAll()
    }
  }
  
  
  func addHint(forButton btn: MaterialButton){
    if shouldShowHints{
      if let hint = btn.hint{
        var label = UILabel()
        label.tag = btn.tag
        label.text = hint
        label.backgroundColor = btn.hintBackgroundColor
        label.textColor = btn.hintTextColor
        if let font = btn.hintTextFont{
          label.font = font
        }
        label.sizeToFit()
        label.layoutIfNeeded()
        updateFrame(&label, btn: btn)
        hints.append(label)
      }
    }
  }
  
  func updateFrame(inout label:UILabel, btn: MaterialButton){
    var lblFrame = label.frame
    var btnRect = btn.frame
    btnRect.origin.x = btn.centerPoint.x - CGRectGetWidth(btnRect)/2.0
    btnRect.origin.y = btn.centerPoint.y - CGRectGetHeight(btnRect)/2.0
    switch hintDirection{
    case .Top:
      lblFrame.size.width = CGRectGetWidth(btnRect)
      lblFrame.origin.x = CGRectGetMinX(btnRect)
      lblFrame.origin.y = CGRectGetMinY(btnRect)-spacing-CGRectGetHeight(lblFrame)
      label.textAlignment = .Center
    case .Bottom:
      lblFrame.size.width = CGRectGetWidth(btnRect)
      lblFrame.origin.x = CGRectGetMinX(btnRect)
      lblFrame.origin.y = CGRectGetMaxY(btnRect)+spacing
      label.textAlignment = .Center
    case .Left:
      lblFrame.origin.x = CGRectGetMinX(btnRect)-spacing-CGRectGetWidth(lblFrame)
      lblFrame.origin.y = CGRectGetMidY(btnRect)-(CGRectGetHeight(lblFrame)/2.0)
      label.textAlignment = .Right
    case .Right:
      lblFrame.origin.x = CGRectGetMaxX(btnRect)+spacing
      lblFrame.origin.y = CGRectGetMidY(btnRect)-(CGRectGetHeight(lblFrame)/2.0)
      label.textAlignment = .Left
    }
    label.frame = lblFrame
  }
}
