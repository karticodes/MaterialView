# MaterialView

Material Floating Button for iOS - Swift

MaterialView is a replica of Material design's Floating Action Button(FAB) for iOS with more customizable options. It is written in Swift programming language and it provides customizations through delegates.

### Features

* Customizable items direction
* Switch between Show/Hide hints
* Customizable hints direction
* Change background overlay color
* Customizable hint label
* Customizable item spacing

### Sample

##### Items Direction - Bottom / Hints Direction - Right
![alt tag](https://raw.githubusercontent.com/karticodes/MaterialView/Images/Images/BottomRight.gif)

##### Items Direction - Right / Hints Direction - Top
![alt tag](https://raw.githubusercontent.com/karticodes/MaterialView/Images/Images/RightTop.gif)

### Installation

1. Add [MaterialButton.swift](https://github.com/karticodes/MaterialView/blob/master/MaterialView/MaterialButton.swift) and [MaterialView.swift](https://github.com/karticodes/MaterialView/blob/master/MaterialView/MaterialView.swift) to your project.
2. Instantiate MaterialView

```swift
var materialView = MaterialView(menuButton: btn, frameInWindow: CGRectMake(50, CGRectGetMidY(view.frame)-35.0, 70, 70), delegate: self)
```

3. Implement all required methods 'MaterialViewDelegate'

4. Follow *Project > Run* in XCode

5. Implement other optional delegate methods for more customization.

Mail karticodes@gmail.com for queries.