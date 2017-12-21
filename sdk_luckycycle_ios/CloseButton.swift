//
//  CloseButton.swift
//  iOS_LC_Webview
//
//  Created by jm goemaere on 20/12/17.
//  Copyright © 2017 jm goemaere. All rights reserved.
//

import UIKit

class CloseButton: UIButton {
    
    @objc func closeAll() {
        self.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
