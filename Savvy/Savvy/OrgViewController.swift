//
//  OrgViewController.swift
//  Savvy
//
//  Created by Bhavya on 12/21/22.
//  Copyright © 2022 uiuc. All rights reserved.
//

import Foundation
import PopupDialog
import UIKit
import NotificationCenter
import UserNotifications
import DropDown

class orgCell: UITableViewCell {
    
   @IBOutlet weak var titleLabel: UILabel!

   @IBOutlet weak var arrowLabel: UILabel!

    override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
}
override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
}

}
class orgViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @objc let defaults = UserDefaults.standard

    @IBOutlet var tableView: UITableView!
    
    var minScale:CGFloat = 1.0
    var maxScale:CGFloat = 5.0
    var cumulativeScale:CGFloat = 1.0
    var isZoom = false
    
    @objc var orgs: [String] = ["iConquerMS", "Multiple Sclerosis Association of America (MSAA)","Multiple Sclerosis Foundation (MS Focus)","National Multiple Sclerosis Society"]
    
    @objc var urls: [String] = ["https://www.iconquerms.org/", "https://mymsaa.org/","https://msfocus.org/","https://nationalmssociety.org/"]
                                
    @objc func pinchedView(_ gestureRecognizer : UIPinchGestureRecognizer) { guard gestureRecognizer.view != nil else { return }
            if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
                //            print(gestureRecognizer.scale)
                self.cumulativeScale  *= gestureRecognizer.scale
                if (self.cumulativeScale >= self.minScale && self.cumulativeScale <= self.maxScale){
                    self.isZoom = true
                    //                 print("here",self.cumulativeScale,self.minScale)
                    gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
                var changeCenter = CGPoint(x:self.view.center.x,y:self.view.center.y)
                    
                var change = false
                if self.view.center.x > self.view.frame.width/2{
                    changeCenter.x = self.view.frame.width/2
                    
                    change = true
                }
                else if self.view.center.x+self.view.frame.width/2 < self.view.bounds.maxX{
                    changeCenter.x = self.view.bounds.maxX - self.view.frame.width/2
                    change = true
                    
                    }
                
                if self.view.center.y > self.view.frame.height/2{
                    changeCenter.y = self.view.frame.height/2
                    change = true
                }
                else if self.view.center.y+self.view.frame.height/2 < self.view.bounds.maxY{
                    changeCenter.y = self.view.bounds.maxY - self.view.frame.height/2
                    change = true
                }
                if change{
                    UIView.animate(withDuration: 0.3) {
                        self.view.center = changeCenter
                    }
                }
                
                
                gestureRecognizer.scale = 1.0
            }
            else{
                self.isZoom = false
                self.cumulativeScale = 1.0
                //                  print("here2",self.cumulativeScale,self.minScale)
                UIView.animate(withDuration: 0.3) {
                    self.view.transform = .identity
                    self.view.center = CGPoint(x: self.view.frame.width*0.5, y: self.view.frame.height*0.5)
                }
            }}
    }
    
    var initialCenter = CGPoint()  // The initial center point of the view.
    @IBAction func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        guard gestureRecognizer.view != nil else {return}
        if self.isZoom{
            
            let piece = gestureRecognizer.view!
            // Get the changes in the X and Y directions relative to
            // the superview's coordinate space.
            let translation = gestureRecognizer.translation(in: piece.superview)
            
            if gestureRecognizer.state == .began {
                // Save the view's original position.
                self.initialCenter = piece.center
            }
            // Update the position for the .began, .changed, and .ended states
            if gestureRecognizer.state != .cancelled {
                // Add the X and Y translation to the view's original position.
                let newCenter = CGPoint(x: piece.center.x + translation.x, y: piece.center.y + translation.y)
                
                //             print(self.view.bounds, piece.center,translation,piece.center.x+translation.x,piece.center.y+translation.y,self.view.frame.width/2,self.view.frame.height/2,newCenter.y + piece.frame.height/2,newCenter.x + piece.frame.width/2)
                
                if newCenter.x <= piece.frame.width/2  && newCenter.x + piece.frame.width/2>=self.view.bounds.maxX && newCenter.y <= piece.frame.height/2 && newCenter.y + piece.frame.height/2>=self.view.bounds.maxY {
                    piece.center = newCenter
                }
                
                gestureRecognizer.setTranslation(.zero, in: piece.superview)
            }
            else {
                // On cancellation, return the piece to its original location.
                piece.center = initialCenter
            }
        }
    }
   
   @IBAction func back(_sender: UIButton){
        goBack()
    }
    
    
    func goBack(){
        if let nvc = navigationController {
            nvc.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchedView))
        var panGesture = UIPanGestureRecognizer(target: self, action: #selector(panPiece))
        
        view.isUserInteractionEnabled = true
        
        view.addGestureRecognizer(pinchGesture)
        view.addGestureRecognizer(panGesture)
        
        
        
    }
    
   
    
    @objc func reloadData(notification:Notification){
        // reload function here, so when called it will reload the tableView
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
   

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = defaults.string(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"org" as AnyObject,"action":"appear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if UserDefaults.standard.object(forKey: "userID") != nil{

        let uid = defaults.string(forKey: "userID")
        
        var logging_parameters:[String:AnyObject] = ["id":uid as AnyObject,"page":"org" as AnyObject,"action":"disappear" as AnyObject,"json":[:] as AnyObject]
        self.remoteLogging(logging_parameters )
        }
    }
  
    
   
    
    
    override func viewWillDisappear(_ animated: Bool) {
    
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            return orgs.count ;
       
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "orgCell", for: indexPath) as! orgCell

        cell.titleLabel!.text =    self.orgs[indexPath.row]
        
        cell.titleLabel?.numberOfLines = 0
        cell.titleLabel?.lineBreakMode = .byWordWrapping
       
        return cell
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
         
       
        self.showWebView(self.urls[indexPath.row])
     }
}
