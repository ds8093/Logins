//
//  ViewController.swift
//  Logins
//
//  Created by Deepak on 9/17/18.
//  Copyright © 2018 Deepak. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class User {
    static func shared() -> User {
        return sharedInstance
    }
    static let sharedInstance = { () -> User in
        let user = User()
        return user
    }()
    var proceedFlag = false
    var userEmailId = String()
    var userFirstName = "Hello"
    var userImage: UIImage?
    var userLoginFrom = String()
}



class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBAction func loginFB(_ sender: Any) {
        print(User.shared().userFirstName)
        loginWithFacebook()
    }
   
    
    func loginWithFacebook() {
        let loginManager = FBSDKLoginManager.init()
        loginManager.logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, err) in
            if !(result?.isCancelled)! || err == nil{
                if !(FBSDKAccessToken.current().isExpired){
                    let graph = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id, first_name, picture.type(large), email"])
                    graph!.start(completionHandler: { (_, result, error) in
                        if let data = result as? NSDictionary, error == nil{
                            let user = User.shared()
                            if let email = data.object(forKey: "email") as? String, email.count > 0{
                                user.userEmailId = email
                            }
                            if let first_name = data.object(forKey: "first_name") as? String, first_name.count > 0{
                                user.userFirstName = first_name
                            }
                            if let picture = data.object(forKey: "picture") as? NSDictionary,let dat = picture.object(forKey: "data") as? NSDictionary, let url = dat.object(forKey: "url") as? String{
                                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                                    let urlFb = URL.init(string: url)
                                    let dataImageFb = NSData.init(contentsOf: urlFb!)
                                    let image = UIImage.init(data: dataImageFb! as Data)
                                    user.userImage = image
                                    user.userLoginFrom = "Facebook"
                                    self.getUser()
                                }
                            }
                        }
                    })
                }
            }
        }
    }
    
    @IBAction func loginGoogle(_ sender: Any) {
        loginWithGoogle()
    }
    func loginWithGoogle(){
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user != nil{
            if let profile = user!.profile{
                if let email = profile.email, email.count > 0{
                    User.shared().userEmailId = email
                }
                if let name = profile.name, name.count > 0{
                    User.shared().userFirstName = name
                }
                if let imageURL = profile.imageURL(withDimension: 200){
                    DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                        let dataImageGI = NSData.init(contentsOf: imageURL)
                        let image = UIImage.init(data: dataImageGI! as Data)
                        User.shared().userImage = image
                        User.shared().userLoginFrom = "Google"
                        self.getUser()
                    }
                }
            }
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    }
    
    func getUser() {
        print(User.shared().userEmailId,User.shared().userFirstName,User.shared().userImage, User.shared().userLoginFrom)
    }
    
    
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

