import UIKit

enum ConfirmActionButtonState {
    case idle
    case updating
    case selected
    case confirmed
}

class ConfirmActionButton: UIButton {
    
    private var intention: CGFloat = 0.0
    private let size = CGSize(width:100, height:100)
    private var selectionState:ConfirmActionButtonState = .idle {
        didSet{
            switch self.selectionState {
            case .idle, .updating:
                if oldValue != .updating || oldValue != .idle {
                    circle.strokeColor = UIColor.white.cgColor
                    circle.shadowColor = UIColor.white.cgColor
                    circle.transform = CATransform3DIdentity
                    msgLabel.string = ""
                }
                
            case .selected:
                if oldValue != .selected{
                    circle.strokeColor = UIColor.red.cgColor
                    circle.shadowColor = UIColor.red.cgColor
                    circle.transform = CATransform3DMakeScale(1.1, 1.1, 1)
                    msgLabel.string = "CONFIRM"
                }
                
            case .confirmed:
                if oldValue != .confirmed{
                    circle.strokeColor = UIColor.green.cgColor
                    circle.shadowColor = UIColor.green.cgColor
                    circle.transform = CATransform3DMakeScale(1.3, 1.3, 1)
                    msgLabel.string = "OK"
                }
            }
            circle.setNeedsLayout()
        }
    }
    
    private var currentSelection:Int = 0
    private let circle = CAShapeLayer()
    private let msgLabel = CATextLayer()
    private let container = CALayer()
    
    // Fallback mode properties 
    private var waitingInterval:TimeInterval = 1.0
    private var timer:Timer? = nil
    private var lastTouchPosition = UITouch()
    
    // MARK: - UI Flow 
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.drawControl()
    }
    
    // MARK: - Drawing
    
    private func drawControl(){
        
        // Circle
        var transform = CGAffineTransform.identity
        circle.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        circle.path = CGPath(ellipseIn: CGRect(x: 0,y: 0,width: size.width, height: size.height),
                             transform: &transform)
        
        circle.strokeColor = UIColor.white.cgColor
        circle.fillColor = UIColor.clear.cgColor
        circle.lineWidth = 1
        circle.lineCap = kCALineCapRound
        circle.strokeEnd = 0 // Initially, set to 0
        circle.shadowColor = UIColor.white.cgColor
        circle.shadowRadius = 2.0
        circle.shadowOpacity = 1.0
        circle.shadowOffset = CGSize.zero
        circle.contentsScale = UIScreen.main.scale

        // Label
        msgLabel.font = UIFont.systemFont(ofSize: 3.0)
        msgLabel.fontSize = 12
        msgLabel.foregroundColor = UIColor.white.cgColor
        msgLabel.string = ""
        msgLabel.alignmentMode = "center"
        msgLabel.frame = CGRect(x: 0, y: (size.height / 2) - 8.0, width: size.width, height: 12)
        msgLabel.contentsScale = UIScreen.main.scale

        // Put it all together
        container.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        container.addSublayer(msgLabel)
        container.addSublayer(circle)
        
        layer.addSublayer(container)
    }
    
    private func updateUI(with value:CGFloat){
        circle.strokeEnd = value
    }
    
    private func updateSelection(with touch: UITouch) {
        
        if self.traitCollection.forceTouchCapability == UIForceTouchCapability.available{
            intention = 1.0 * (min(touch.force, 3.0) / min(touch.maximumPossibleForce, 3.0))
        }
        
        if intention > 0.97 {
            if container.frame.contains(touch.location(in:self)){
                selectionState = .confirmed
            }else{
                selectionState = .selected
            }
            updateUI(with: 1.0)
        }
        else{
            if !container.frame.contains(touch.location(in:self)){
                selectionState = .updating
                updateUI(with: intention)

            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        if traitCollection.forceTouchCapability != UIForceTouchCapability.available{
            timer = Timer.scheduledTimer(timeInterval: 0.1,
                                         target: self,
                                         selector: #selector(ConfirmActionButton.updateTimedIntention),
                                         userInfo: nil,
                                         repeats: true)
            timer?.fire()
        }
        
        let initialLocation = touch.location(in: self)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        container.position = initialLocation ++ CGPoint(x: 0, y: -size.height)
        CATransaction.commit()
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        lastTouchPosition = touch
        updateSelection(with:touch)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        timer?.invalidate()
        intention = 0
        
        if selectionState == .confirmed{
            self.sendActions(for: UIControlEvents.valueChanged)
        }
        
        selectionState = .idle
        circle.strokeEnd = 0
    }
    
    func updateTimedIntention(){
        intention += CGFloat(0.1 / waitingInterval)
        updateSelection(with: lastTouchPosition)
    }

}


infix operator ++ : AdditionPrecedence
func ++ (left:CGPoint, right:CGPoint)->CGPoint{
    let res = CGPoint(x: left.x + right.x, y: left.y + right.y)
    return res
}

