import UIKit


extension UIView{
    func popUpView(show:Bool){
        if show && self.isHidden{
            self.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
            } completion: { (success) in
                if success{
                    self.isHidden = false
                }
            }
            
        }else if !show && !self.isHidden{
            self.alpha = 1.0
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0.0
            } completion: { (success) in
                if success{
                    self.isHidden = true
                }
            }
        }
    }
}

