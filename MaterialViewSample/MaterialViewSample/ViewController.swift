//
//  ViewController.swift
//  MaterialViewSample
//
//  Created by Karthik M R on 6/23/15.
//  Copyright (c) 2015 Karthik M R. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  var materialView: MaterialView!

  @IBOutlet weak var itemsDirectionControl: UISegmentedControl!
  
  @IBOutlet weak var hintsDirectionControl: UISegmentedControl!
  
  @IBOutlet weak var hintsSwitch: UISwitch!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    let btn = UIButton()
    btn.backgroundColor = UIColor.redColor()
    btn.layer.cornerRadius = 35.0
    materialView = MaterialView(menuButton: btn, frameInWindow: CGRectMake(50, CGRectGetMidY(view.frame)-35.0, 70, 70), delegate: self)
  }
  
  func randomColor()->UIColor{
    let hue = ((CGFloat(arc4random()) % 256.0) / 256.0 );
    let saturation = ((CGFloat(arc4random()) % 128.0) / 256.0 ) + 0.5;
    let brightness = ((CGFloat(arc4random()) % 128.0) / 256.0 ) + 0.5;
    let color = UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    return color
  }
}

extension ViewController: MaterialViewDelegate{
  func itemsDirection(inMaterialView view: MaterialView) -> MaterialDirection {
    return MaterialDirection(rawValue: itemsDirectionControl.selectedSegmentIndex)!
  }
  
  func numberOfItems(inMaterialView view: MaterialView) -> Int {
    return 3
  }
  
  func minimumSpacingBetweenButtons(inMaterialView view: MaterialView) -> CGFloat {
    return 10.0
  }
  
  func materialView(view: MaterialView, materialButtonAtIndex index: Int) -> MaterialButton {
    let btn = MaterialButton(frame: CGRectMake(100, 100, 70, 70))
    btn.hint = "button " + "\(index)"
    btn.hintTextFont = UIFont(name: "Arial", size: 14.0)
    btn.hintTextColor = UIColor.blackColor()
    btn.backgroundColor = randomColor()
    btn.layer.cornerRadius = 35.0
    return btn
  }
  
  func shouldShowHint(inMaterialView view: MaterialView) -> Bool {
    return hintsSwitch.on
  }
  
  func hintDirection(inMaterialView view: MaterialView) -> MaterialDirection {
    return MaterialDirection(rawValue: hintsDirectionControl.selectedSegmentIndex)!
  }
  
  func overlayColor(inMaterialView view: MaterialView) -> UIColor {
    return UIColor(red: 10.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 0.1)
  }
  
  func materialView(view: MaterialView, clickedButtonAtIndex index: Int) {
    //
  }
  
  func materialViewItemsDidAppear(view: MaterialView) {
    //
  }
  
  func materialViewItemsDidDisappear(view: MaterialView) {
    //
  }
  
  @IBAction func reloadButtonClicked(sender: UIButton) {
    materialView.hidden = false
    materialView.animateMenuButton()
  }
}

