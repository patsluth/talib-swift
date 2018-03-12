//
//  UIButton.swift
//  Sluthware
//
//  Created by Pat Sluth on 2017-12-02.
//  Copyright © 2017 Pat Sluth. All rights reserved.
//

import Foundation





public extension UIView
{
	public func constrainSizeTo(view: UIView, withEdgeInsets edgeInsets: UIEdgeInsets)
    {
        self.topAnchor.constraint(equalTo: view.topAnchor, constant: edgeInsets.top).isActive = true
        self.leftAnchor.constraint(equalTo: view.leftAnchor, constant: edgeInsets.left).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: edgeInsets.bottom).isActive = true
		self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: edgeInsets.right).isActive = true
    }
}





public extension UIView
{
	public var safeTopAnchor: NSLayoutYAxisAnchor {
		if #available(iOS 11.0, *) {
			return self.safeAreaLayoutGuide.topAnchor
		} else {
			return self.topAnchor
		}
	}
	
	public var safeLeadingAnchor: NSLayoutXAxisAnchor {
		if #available(iOS 11.0, *){
			return self.safeAreaLayoutGuide.leadingAnchor
		} else {
			return self.leadingAnchor
		}
	}
	
	public var safeTrailingAnchor: NSLayoutXAxisAnchor {
		if #available(iOS 11.0, *){
			return self.safeAreaLayoutGuide.trailingAnchor
		} else {
			return self.trailingAnchor
		}
	}
	
	public var safeBottomAnchor: NSLayoutYAxisAnchor {
		if #available(iOS 11.0, *) {
			return self.safeAreaLayoutGuide.bottomAnchor
		} else {
			return self.bottomAnchor
		}
	}
}




