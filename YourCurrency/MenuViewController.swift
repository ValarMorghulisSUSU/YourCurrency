//
//  MenuViewController.swift
//  YourCurrency
//
//  Created by Екатерина Полупанова on 15.06.2021.
//

import UIKit

class MenuViewController: UIViewController {
    
    @IBOutlet weak var dp1: UIDatePicker!
    @IBOutlet weak var dp2: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    enum State {
        case closed
        case open
        
        var opposite: State {
            return self == .open ? .closed: .open
        }
    }
    @IBOutlet weak var openTableView: UIButton!
    @IBOutlet weak var setDate: UIButton!
    @IBOutlet weak var setValue: UIButton!
    
    
    
    private var rssItems: [RSSItem]?
    
    var state: State = .closed
    var runningAnimators: [UIViewPropertyAnimator] = []
    var viewOffset = 250
    let now = Calendar.current.dateComponents(in: .current, from: Date())
    let dateFormatter = DateFormatter()
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var titleConstr: NSLayoutConstraint!
    @IBOutlet weak var datePickersConstr:NSLayoutConstraint!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        dp2.maximumDate = Date()
        dp1.maximumDate = Calendar.current.date(from:DateComponents(year: now.year, month: now.month, day: now.day! - 1))!
        
        if UserSettings.userValue.isZero {
            textField.text = "0.0"
        } else {
        textField.text = String(UserSettings.userValue)
        }
        
        dateFormatter.dateFormat = "dd/MM/yyyy"
        fetchData()
    }
    
    private func fetchData()
    {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: "http://cbr.ru/scripts/XML_daily.asp"){
            (rssItems) in
            self.rssItems = rssItems
            OperationQueue.main.addOperation {
                self.rssItems?.forEach{
                    if $0.num == "840"{
                        let repleced = String($0.value.map {$0 == "," ? "." : $0 })
                        UserSettings.dailyValue = Double(repleced)
                    }
                }
            }
        }
        
    }
    
    
    func animateView(to state: State, duration: TimeInterval) {
        
        guard runningAnimators.isEmpty else {
            return
        }
        
        let basicAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn, animations: nil)
        basicAnimator.addAnimations {
            switch state {
            case .open:
                self.datePickersConstr.constant = CGFloat(self.viewOffset)
                
            case .closed:
                self.datePickersConstr.constant = 0
                
                
            }
            self.view.layoutIfNeeded()
        }
        
        basicAnimator.addAnimations {
            switch state {
            case .open:
                self.titleConstr.constant = self.dateView.frame.width / 2 - 90
                self.dateTitle.transform = CGAffineTransform(scaleX: 1, y: 1)
            case .closed:
                self.titleConstr.constant = 20
                self.dateTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                
            }
            self.view.layoutIfNeeded()
        }
        
        let blurAnimation = UIViewPropertyAnimator(duration: duration, controlPoint1: CGPoint(x: 0.8, y: 0.2), controlPoint2: CGPoint(x: 0.8, y: 0.2)) {
            switch state {
            case .open :
                self.blurView.effect = UIBlurEffect(style: .light)
            case .closed:
                self.blurView.effect = nil
            }
        }
        blurAnimation.scrubsLinearly = false
        blurAnimation.addCompletion{ (animator) in
            self.runningAnimators.removeAll()
            self.state = self.state.opposite
        }
        
        runningAnimators.append(basicAnimator)
        runningAnimators.append(blurAnimation)
    }

    func setupViews() {
        self.datePickersConstr.constant = 0
        self.dateTitle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        self.blurView.effect = nil
        self.blurView.isHidden = false
        self.view.layoutIfNeeded()
        
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onDrag(_:)))
        self.dateView.addGestureRecognizer(panGesture)
        
        self.dateView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        self.dateView.layer.shadowColor = UIColor.black.cgColor
        self.dateView.layer.shadowOpacity = 1
        self.dateView.layer.shadowRadius = 3
    }
    
    @objc func onDrag(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animateView(to: state.opposite, duration: 0.4)
        case .changed:
            let translation = gesture.translation(in: dateView)
            let fraction = abs(translation.y / CGFloat(viewOffset))
            
            runningAnimators.forEach{ (animator) in
                animator.fractionComplete = fraction
            }
        case .ended:
            runningAnimators.forEach{ $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)}
        default:
            break
        }
    }
    @IBAction func showTableViewCurrency(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tableVC") as! CurrencyTableViewController
        let date = Calendar.current.date(from:DateComponents(year: now.year, month: now.month, day:1))!
        
        let strdateb = dateFormatter.string(from: date)
        let strdatee = dateFormatter.string(from: Date())
        vc.newURL(url: "http://cbr.ru/scripts/XML_dynamic.asp?date_req1=\(strdateb)&date_req2=\(strdatee)&VAL_NM_RQ=R01235")
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func acceptSetDate(_ sender: UIButton)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tableVC") as! CurrencyTableViewController
        var date = dp1.date
        let strdateb = dateFormatter.string(from: date)
        date = dp2.date
        let strdatee = dateFormatter.string(from: date)
        vc.newURL(url: "http://cbr.ru/scripts/XML_dynamic.asp?date_req1=\(strdateb)&date_req2=\(strdatee)&VAL_NM_RQ=R01235")
        navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func setValue(_ sender: UIButton) {
        UserSettings.userValue = Double(textField.text!)
    }
}
