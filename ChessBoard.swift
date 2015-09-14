//
//  ChessBoard.swift
//  ZouSiQi
//
//  Created by wdk on 15/7/15.
//  Copyright (c) 2015年 wdk. All rights reserved.
//

import Foundation
import UIKit


    //每个ChessBoard都是棋盘上的一个交点
class ChessBoard:UIButton{
    //该位置可能无chess
    var theChess:Chess?
    var x:Int=0
    var y:Int=0
    var Select:Bool = false
    //初始化一个chessbord
    func myinit(chess:Chess?,x:Int,y:Int,isSelected:Bool) -> ChessBoard{
        if chess == nil{
            self.theChess = nil
        }else{
            self.theChess = chess
        }
        
        self.x = x
        self.y = y
        self.Select = isSelected
        return self
    }
    
    //点击棋点的action
//    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
//        NSLog("ChessBoard get touch")
//        self.mapView?.boardTouched(self)
//        
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
}