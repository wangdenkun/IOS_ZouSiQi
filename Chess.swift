//
//  Chess.swift
//  ZouSiQi
//
//  Created by wdk on 15/7/13.
//  Copyright (c) 2015年 wdk. All rights reserved.
//

import Foundation
import UIKit

class Chess: NSObject {
    //那一方
    var standPoint:String = ""
    //是否存在
    var state:Bool = true
    //计算值
    var value:Int = 0
    
    init(standPoint : String,state : Bool,value : Int) {
        self.standPoint = standPoint
        self.state      = state
        self.value      = value
    }
}
