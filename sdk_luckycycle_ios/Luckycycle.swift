//
//  Luckycycle.swift
//  iOS_LC_Webview
//
//  Created by jm goemaere on 12/12/17.
//  Copyright © 2017 jm goemaere. All rights reserved.
//

import UIKit
import Alamofire

//struct LineItem {
//    var id:Int = 0
//    var quantity:Int = 0
//    var price:Decimal = 0
//    var name:String = ""
//    var categoryId:String = ""
//    var productId:String = ""
//    var manufacturerId:String = ""
//    var otherId:String = ""
//    var reference:String = ""
//}

enum BoxMode {
    case fullScreen
    case popin
    case bottomSlidein
}

open class Luckycycle: NSObject, UIWebViewDelegate {
    
    var parameters:Parameters = [
        "skip_check_draw": true,
        "poke_software_version":"iOS_SDK_1",
        "cart":Parameters()
        ]
    
    var cart: [Dictionary<String, String>] = []
    
    let pokeUrl:String
    let bucketId:String
    let parentView:UIView

//    let controller:UIViewController
//    let closeSelector: Selector
    
    var boxMode = BoxMode.popin
    var computedHash:String = ""
    var boxMargin:CGFloat = 10
    var topMargin:CGFloat = 60
    var bottomMargin:CGFloat = 60
    var overlayTransparency:CGFloat = 0.4
    var dontShowBox: Bool = false
    var transparentButton: CloseButton
    var frame = UIScreen.main.bounds
    var webView: UIWebView
    
    let headers: HTTPHeaders = ["Accept": "application/json",]
    
    // constructor - only needs storeId or operationId (can be obtained via an API call or hard coded) & a ref to the parent view
    init(bucketId:String, parentView: UIView) {
        self.bucketId = bucketId
        self.pokeUrl = "https://www.luckycycle.com/client/poke/\(bucketId)"
        self.parentView = parentView
        self.transparentButton = CloseButton(frame: frame)
        self.webView = UIWebView(frame: self.frame)
        self.cart = []
    }
    
    
    func pushLineItem(lineItem:Dictionary<String, String>) {
        self.cart.append(lineItem)
    }
  
    // setData with 6 names params
    func setData(
        itemUId:String,
        itemValue:String,
        userUid: String = "",
        email: String = "",
        segment: String = "",
        language: String = "en"
        ) {
        self.parameters["item_uid"] = itemUId
        self.parameters["item_value"] = itemValue
        self.parameters["user_uid"] = userUid
        self.parameters["email"] = email
    }
    
    // alt setData taking a Dictionary (hash in ruby or object in js)
    func setData(data:Dictionary<String, Any>) {
        // TODO : check is mandatory fields are there
        for (key, value) in data {
            if(key == "cart"){
                self.parameters[key] = value
            } else {
                self.parameters[key] = String(describing:value)
            }
        }
        print("param:\(self.parameters)")
    }
    
    func showBox() {
        var x,y,w,h:CGFloat
        
        // TODO add a clickable view to close the box
        transparentButton.backgroundColor = UIColor.black.withAlphaComponent(self.overlayTransparency)
        transparentButton.setTitle("", for: .normal)
        transparentButton.alpha = 1
        transparentButton.isUserInteractionEnabled = true
        transparentButton.addTarget(self, action:#selector(CloseButton.closeAll), for: .touchUpInside)
        parentView.addSubview(transparentButton)
        UIView.animate(withDuration: 0.7) {
            self.transparentButton.alpha = 1
        }
        
        switch self.boxMode {
        case .fullScreen:
            x = 0
            y = 0
            w = frame.size.width
            h = frame.size.height
        case .bottomSlidein:
            x = 0
            y = self.boxMargin + self.topMargin
            w = frame.size.width
            h = frame.size.height - self.boxMargin - self.topMargin
        default:
            x = self.boxMargin
            y = self.boxMargin + self.topMargin
            w = frame.size.width - (2 * self.boxMargin)
            h = frame.size.height - (2 * self.boxMargin) - self.topMargin - self.bottomMargin
        }
        
        frame.origin.x = x
        frame.origin.y = y
        frame.size.width = w
        frame.size.height =  h
        
        let webView:UIWebView = UIWebView(frame: frame)
        
        // border to webview?
        //                    webView.layer.borderWidth = 3
        //                    webView.layer.borderColor = UIColor.init(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        webView.layer.cornerRadius = 0
        webView.layer.shadowColor = UIColor.init(red:0/255.0, green:0/255.0, blue:0/255.0, alpha: 1.0).cgColor
        webView.layer.shadowOpacity = 0.4
        webView.layer.shadowRadius = 18.0
        
        //webView.delegate = self
        self.transparentButton.addSubview(webView)
        
        // todo use self.url
        if let url = URL(string: "https://www.luckycycle.com/play/\(self.computedHash)?source=email_full") {
            let request = URLRequest(url: url)
            webView.loadRequest(request)
            webView.frame.origin.y = webView.frame.origin.y + frame.size.height
            UIView.animate(withDuration: 0.3, delay: 0.7, options: .curveEaseIn, animations: {
                webView.frame.origin.y = webView.frame.origin.y - self.frame.size.height
            })
        }
    }
    
    func pokeAndShowBox() {
        // TODO verif minimal data before poke
        Alamofire.request(
            self.pokeUrl,
            method: .post,
            parameters: self.parameters,
            encoding: JSONEncoding.default,
            headers: self.headers
            ).responseJSON { response in
                
                if let status = response.response?.statusCode, let result = response.result.value {
                    if status == 200 {
                        
                        let JSON = result as! NSDictionary
                        self.computedHash = JSON["computed_hash"]! as! String
                        
                        if (self.computedHash.count > 0) {
                            if(!self.dontShowBox) {
                                self.showBox()
                            }
                        } else {
                            print("NO POKE: user not eligible")
                        }
                    } else {
                        print("SOMETHING went WRONG, \(status)")
                    }
                }
        }
    }
    
}
