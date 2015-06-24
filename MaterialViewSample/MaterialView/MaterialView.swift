//
//  MaterialView.swift
//
//  Created by Karthik M R on 6/18/15.
//  Copyright (c) 2015 Karthik M R. All rights reserved.
//

import UIKit

//MARK: - Array Extension
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

/**
enum to define the direction of menu and hints
*/
@objc enum MaterialDirection: Int{
  case Top, Bottom, Left, Right
}

//MARK: - MaterialViewDelegate Protocol Definition
/**
MaterialViewDelegate

Required

- `func numberOfItems(inMaterialView view: MaterialView)->Int`
- `func minimumSpacingBetweenButtons(inMaterialView view:MaterialView)->CGFloat`
- `func materialView(view:MaterialView, materialButtonAtIndex index: Int)->MaterialButton`

Optional

- `func materialMenu(view: MaterialView, buttonDirectionInRect frame:CGRect)->MaterialDirection`
- `func hintDirection(inMaterialView view: MaterialView)->MaterialDirection`
- `func shouldShowHint(inMaterialView view: MaterialView)->Bool`
- `func overlayColor(inMaterialView view: MaterialView)->UIColor`
- `func materialViewItemsDidAppear(view:MaterialView)`
- `func materialViewItemsDidDisappear(view:MaterialView)`
- `func materialView(view : MaterialView, clickedButtonAtIndex index:Int)`
*/
@objc protocol MaterialViewDelegate{
  /**
  **Required**
  
  returns the number of items in MaterialView
  
  :param: view current MaterialView instance
  
  :returns: number of items in MaterialView
  */
  func numberOfItems(inMaterialView view: MaterialView)->Int
  
  /**
  **Required**
  
  returns the minimum space between items
  
  :param: view current MaterialView instance
  
  :returns: minimum space between items
  */
  func minimumSpacingBetweenButtons(inMaterialView view:MaterialView)->CGFloat
  
  /**
  **Required**

  returns the Material Button
  
  :param: view current MaterialView instance
  :param: index current item index
  
  :returns: button for the index w/o `hint`, `hintTextColor`, `hintBackgroundColor`, `hintTextFont`
  */
  func materialView(view:MaterialView, materialButtonAtIndex index: Int)->MaterialButton
  
  /**
  **Optional**

  returns the enum which specifies the direction of material view items
  
  **Default - MaterialDirection.Top**
  
  :param: view current MaterialView instance
  :param: frame frame in rect of Menu Button
  
  :returns: direction of material view items
  */
  optional func materialMenu(view: MaterialView, buttonDirectionInRect frame:CGRect)->MaterialDirection
  
  /**
  **Optional**

  returns the enum which specifies the direction of hints
  
  **Default - MaterialDirection.Left**
  
  :param: view current MaterialView instance
  
  :returns: direction of hints
  */
  optional func hintDirection(inMaterialView view: MaterialView)->MaterialDirection
  
  /**
  **Optional**

  returns a bool specifies the visibility of hints
  
  **Default - false**
  
  :param: view current MaterialView instance
  
  :returns: bool specifies the visibility of hints
  */
  optional func shouldShowHint(inMaterialView view: MaterialView)->Bool
  
  /**
  **Optional**

  returns the color of the background overlay
  
  **Default - Transparent**
  
  :param: view current MaterialView instance
  
  :returns: number of items in MaterialView
  */
  optional func overlayColor(inMaterialView view: MaterialView)->UIColor
  
  /**
  **Optional**

  Material view items appeared after the animation.
  
  :param: view current MaterialView instance
  */
  optional func materialViewItemsDidAppear(view:MaterialView)
  
  /**
  **Optional**

  Material view items disappeared after the animation.
  
  :param: view current MaterialView instance
  */
  optional func materialViewItemsDidDisappear(view:MaterialView)
  
  /**
  **Optional**

  User has clicked the material item
  
  :param: view current MaterialView instance
  :param: index index of clicked material view item
  */
  optional func materialView(view : MaterialView, clickedButtonAtIndex index:Int)
}

//MARK: - MaterialView Class
/**
**MaterialView**

**Note -**
Use the following initializer to show the button

`init(menuButton: UIButton, frameInWindow buttonFrame: CGRect, delegate: MaterialViewDelegate)`

:param: menuButton button to be displayed on the window
:param: buttonFrame CGRect w.r.t window
:param: delegate MaterialViewDelegate to populate the items

*/
class MaterialView: NSObject {
  
  var menuButton: UIButton!
  var delegate: MaterialViewDelegate!
  var isMenuItemsVisible: Bool{
    get{
      return (buttons.count > 0)
    }
  }
  
  var hidden: Bool = false{
    didSet{
      if isMenuItemsVisible{
        hideHints()
        for btn in buttons{
          buttons.removeObject(btn)
          btn.removeFromSuperview()
        }
        overlayView?.hidden = true
        tapGesture = nil
      }
      menuButton.hidden = hidden
    }
  }
  
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
  
  private var mainWindow: UIWindow{
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
  
  /**
  Animates the scale of menu button from 0.1 to 1.0
  */
  func animateMenuButton(){
    self.menuButton.transform = CGAffineTransformMakeScale(0.1, 0.1)
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.menuButton.transform = CGAffineTransformMakeScale(1.0, 1.0)
    })
  }
  
  /**
  performs Menu Button click action
  
  :param: sender MenuButton instance
  */
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
  
  private func initValues(){
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

//MARK: - Show/Hide Items
extension MaterialView{
  private func getInitialSpace()->CGFloat{
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
  
  private func setCenterPoint(inout btn: MaterialButton,inout totalSpace: CGFloat, spacing: CGFloat){
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
      addHint(forButton: btn)
      btn.initialScale = CGVectorMake(CGRectGetWidth(menuButton.frame)/CGRectGetWidth(btn.frame), CGRectGetHeight(menuButton.frame)/CGRectGetHeight(btn.frame))
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
  
  private func invalidateTimer(){
    animationTimer?.invalidate()
    animationTimer = nil
  }
  
  func materialButtonClicked(sender: MaterialButton){
    delegate?.materialView?(self, clickedButtonAtIndex: sender.tag)
  }
  
  private func addTapGesture(behindButton button: MaterialButton){
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

//MARK: - MaterialButtonDelegate Implementation
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

//MARK: - Show/Hide Hints
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
      lblFrame.origin.y = CGRectGetMinY(btnRect)-(spacing+CGRectGetHeight(lblFrame))
      label.textAlignment = .Center
    case .Bottom:
      lblFrame.size.width = CGRectGetWidth(btnRect)
      lblFrame.origin.x = CGRectGetMinX(btnRect)
      lblFrame.origin.y = CGRectGetMaxY(btnRect)+spacing
      label.textAlignment = .Center
    case .Left:
      lblFrame.origin.x = CGRectGetMinX(btnRect)-(spacing+CGRectGetWidth(lblFrame))
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
