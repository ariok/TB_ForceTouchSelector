import UIKit

class ViewController: UIViewController {

    @IBOutlet var deletedLabel:UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func delete(){
        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut){
            self.deletedLabel.alpha = 1.0
        }
        
        animator.startAnimation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}

