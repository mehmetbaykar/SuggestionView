import UIKit
extension UIView{
    func popUpView(show:Bool){
        if let superView = superview{
            superView.bringSubviewToFront(self)
        }
        if show && self.isHidden{
            self.alpha = 0.0
            self.isHidden = false
            UIView.animate(withDuration: 0.2) {
                self.alpha = 1.0
            }
        }else if !show && !self.isHidden{
            self.alpha = 1.0
            UIView.animate(withDuration: 0.2) {
                self.alpha = 0.0
                self.isHidden = true
            }
        }
    }
}

