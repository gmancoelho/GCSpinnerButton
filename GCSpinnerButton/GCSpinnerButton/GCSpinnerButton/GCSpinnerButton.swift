import Foundation
import UIKit

@IBDesignable
open class GCSpinnerButton : UIButton {
  
  // MARK: - Spinner
  
  private lazy var spiner: SpinerLayer! = {
    let s = SpinerLayer(frame: self.frame)
    self.layer.addSublayer(s)
    return s
  }()
  
  // MARK: - IBInspectable

  @IBInspectable open var spinnerColor: UIColor = UIColor.white {
    didSet {
      spiner.spinnerColor = spinnerColor
      self.setTitleColor(spinnerColor, for: .normal)
    }
  }
  
  //Normal state bg and border
  @IBInspectable var normalBorderColor: UIColor? {
    didSet {
      layer.borderColor = normalBorderColor?.cgColor
    }
  }
  
  @IBInspectable var normalBackgroundColor: UIColor? {
    didSet {
      setBgColorForState(color: normalBackgroundColor, forState: .normal)
    }
  }
  
  //Highlighted state bg and border
  @IBInspectable var highlightedBorderColor: UIColor?
  
  @IBInspectable var highlightedBackgroundColor: UIColor? {
    didSet {
      setBgColorForState(color: highlightedBackgroundColor, forState: .highlighted)
    }
  }
  
  // MARK: - Properties
  
  let springGoEase = CAMediaTimingFunction(controlPoints: 0.45, -0.36, 0.44, 0.92)
  let shrinkCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
  let expandCurve = CAMediaTimingFunction(controlPoints: 0.95, 0.02, 1, 0.05)
  let shrinkDuration: CFTimeInterval  = 0.2
  
  open var normalCornerRadius: CGFloat = 4.0 {
    didSet {
      self.layer.cornerRadius = normalCornerRadius
    }
  }
  
  private var cachedTitle: String?
  private var cachedHeight: CGFloat?
  private var cachedWidth: CGFloat?

  // MARK: - Callback
  
  open var didEndFinishAnimation : (()->())? = nil

  // MARK: - Init
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.setup()
  }
  
  public required init!(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    self.setup()
  }
  
  // MARK: - SetUp
  
  private func setup() {
    
    self.clipsToBounds = true
    spiner.spinnerColor = spinnerColor
    self.layer.cornerRadius = normalCornerRadius
    self.setTitleColor(spinnerColor, for: .normal)

  }
  // MARK: - Class Methods
  
  private func setBgColorForState(color: UIColor?, forState: UIControl.State){
    if color != nil {
      setBackgroundImage(UIImage.imageWithColor(color: color!), for: forState)
      
    } else {
      setBackgroundImage(nil, for: forState)
    }
  }
  
  private func startFinishAnimation(_ delay: TimeInterval, completion:(()->())?) {
    _ = Timer.schedule(delay: delay) { _ in
      
      self.didEndFinishAnimation = completion
      self.spiner.stopAnimation()
      self.returnToOriginalState()
      
    }
  }
  
  private func setOriginalState() {
    self.returnToOriginalState()
    self.spiner.stopAnimation()
  }
  
  private func startLoadingAnimation() {
    
    self.isUserInteractionEnabled = false
    self.cachedTitle = title(for: UIControl.State())
    
    self.cachedWidth = self.frame.width
    self.cachedHeight = self.frame.height
    
    self.setTitle("", for: UIControl.State())
    
    UIView.animate(withDuration: 0.1, animations: { () -> Void in
      self.layer.cornerRadius = self.frame.height / 2
    }, completion: { (done) -> Void in
      self.shrink()
      _ = Timer.schedule(delay: self.shrinkDuration - 0.25) { _ in
        self.spiner.animation()
      }
    })
    
  }
  
  private func returnToOriginalState() {
    
    UIView.animate(withDuration: 0.1, animations: { () -> Void in
      
      self.spiner.stopAnimation()
      self.expand()
      self.layer.cornerRadius = self.normalCornerRadius
      
    }, completion: { (done) -> Void in
      _ = Timer.schedule(delay: self.shrinkDuration - 0.25) { _ in
        
        self.setTitle(self.cachedTitle, for: UIControl.State())
        self.isUserInteractionEnabled = true
        self.layer.removeAllAnimations()
      }
    })
  }
  
  // MARK: - Animations
  
  open func animate(_ duration: TimeInterval, completion:(()->())?) {
    startLoadingAnimation()
    startFinishAnimation(duration, completion: completion)
  }
  
  // MARK: - CAAnimations
  
  private func shrink() {
    let shrinkAnim = CABasicAnimation(keyPath: "bounds.size.width")
    shrinkAnim.fromValue = frame.width
    shrinkAnim.toValue = frame.height
    shrinkAnim.duration = shrinkDuration
    shrinkAnim.timingFunction = shrinkCurve
    shrinkAnim.fillMode = CAMediaTimingFillMode.forwards
    shrinkAnim.isRemovedOnCompletion = false
    layer.add(shrinkAnim, forKey: shrinkAnim.keyPath)
  }
  
  private func expand() {
    let expandAnim = CABasicAnimation(keyPath: "bounds.size.width")
    expandAnim.fromValue = frame.width
    expandAnim.toValue = cachedWidth
    expandAnim.timingFunction = expandCurve
    expandAnim.duration = 0.3
    expandAnim.delegate = self
    expandAnim.fillMode = CAMediaTimingFillMode.forwards
    expandAnim.isRemovedOnCompletion = true
    layer.add(expandAnim, forKey: expandAnim.keyPath)
  }
  
}

// MARK: - Extensions

extension GCSpinnerButton: CAAnimationDelegate {
  
  public func animationDidStop(_ anim: CAAnimation, finishe0d flag: Bool) {
    let a = anim as! CABasicAnimation
    if a.keyPath == "transform.scale" {
      
      didEndFinishAnimation?()
      
      _ = Timer.schedule(delay: 1) { _ in
        self.returnToOriginalState()
      }
      
    }
  }
}


