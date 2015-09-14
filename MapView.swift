//
//  MapView.swift
//  ZouSiQi
//
//  Created by wdk on 15/7/13.
//  Copyright (c) 2015年 wdk. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

class MapView:UIView{
    
    
    //通过IB方式连接16个chessboard
    @IBOutlet var board00:ChessBoard!
    @IBOutlet var board01:ChessBoard!
    @IBOutlet var board02:ChessBoard!
    @IBOutlet var board03:ChessBoard!
    @IBOutlet var board10:ChessBoard!
    @IBOutlet var board11:ChessBoard!
    @IBOutlet var board12:ChessBoard!
    @IBOutlet var board13:ChessBoard!
    @IBOutlet var board20:ChessBoard!
    @IBOutlet var board21:ChessBoard!
    @IBOutlet var board22:ChessBoard!
    @IBOutlet var board23:ChessBoard!
    @IBOutlet var board30:ChessBoard!
    @IBOutlet var board31:ChessBoard!
    @IBOutlet var board32:ChessBoard!
    @IBOutlet var board33:ChessBoard!
    //黑白所有棋子
    var whiteChess1:Chess! = Chess(standPoint: "white", state: true, value: 0)
    var whiteChess2:Chess! = Chess(standPoint: "white", state: true, value: 0)
    var whiteChess3:Chess! = Chess(standPoint: "white", state: true, value: 0)
    var whiteChess4:Chess! = Chess(standPoint: "white", state: true, value: 0)
    var blackChess1:Chess! = Chess(standPoint: "black", state: true, value: 0)
    var blackChess2:Chess! = Chess(standPoint: "black", state: true, value: 0)
    var blackChess3:Chess! = Chess(standPoint: "black", state: true, value: 0)
    var blackChess4:Chess! = Chess(standPoint: "black", state: true, value: 0)
    //双方棋子的集合
    var whiteChesses:[Chess?] = [nil,nil,nil,nil]
    var blackChesses:[Chess?] = [nil,nil,nil,nil]
    //被选中的Board
    var selectedBoard:ChessBoard? = nil
    //被移动完的Board
    var movedBoard:ChessBoard? = nil

    //chessBoard的集合 用于遍历
    //二维数组的声明：（真JB费劲 但是也挺形象的）
    //    var chesses:Array<Array<Chess>>
    //或者 用于保存chess对象的引用(可能为空)
    //var chesses:[[Chess?]]=[[Chess.alloc()]]
    var chessBoards:[[ChessBoard?]] = [ [nil,nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil]]

    //当棋点被点击时调用此Action
    @IBAction func boardTouched(sender:AnyObject){

        var theTouchedBoard = sender as! ChessBoard
        if theTouchedBoard.theChess != nil{
            println("Board be touched:\(theTouchedBoard.theChess!.standPoint)")
        }else{
            println("Board be touched,But there is no Chess")
        }
        
       self.doWork(sender as! ChessBoard)

    }
    
    //获得点击的棋点后进行处理
    func doWork(theTouchedBoard:ChessBoard){
        println("doWork func get the Board,frame is :(\(theTouchedBoard.x) \(theTouchedBoard.y))")
        //如果点选的位置有chess 则将selectedboard置为该位置
        if(theTouchedBoard.theChess != nil){
            self.selectedBoard = theTouchedBoard
        }else{
            //如果点选的位置无chess 继续判断
            //selectedBoard不为空 进行move判断
            if(self.selectedBoard != nil){
                //是否可移动
                if isCanbeMove(self.selectedBoard!, aimBoard: theTouchedBoard){
                println("can Move")
                self.moveChess(fromBoard: self.selectedBoard!, toBoard: theTouchedBoard)
                //self.selectedBoard!.theChess = nil
                self.selectedBoard = nil
                                
                                //是否有棋子被吃掉
                                println("theTouchedBoar:(\(theTouchedBoard.theChess!.standPoint) \(theTouchedBoard.x) \(theTouchedBoard.y))")
                                var willBeremoveBoard = isSomeChessCanbeEat(theMovedBoard: theTouchedBoard)
                                if !willBeremoveBoard.isEmpty {
                                    for toBeRemoveBoard in willBeremoveBoard{
                                        println("the chess to be remove: (\(toBeRemoveBoard?.x) \(toBeRemoveBoard?.y))")
                                        if toBeRemoveBoard != nil{
                                            println("Remove on Chess!!!")
                                            self.removeChess(toBeRemoveBoard!)
                                        }
                                        
                                    }
                                }
                }else{
                    println("Can`t move,selectedBoar set nil")
                    println()
                    self.selectedBoard = nil
                }
            }else{
            //selectedBoard无值
            }
        }
        

    }
    //删除board上的chess （thechess指向空）
    func removeChess(boardRemoveChess:ChessBoard){
        boardRemoveChess.theChess = nil
        self.setNeedsDisplay()
    }
    //是否可以移动
    func isCanbeMove(orgBoard:ChessBoard,aimBoard:ChessBoard)->Bool{
        var xi = fabs(Float(orgBoard.x - aimBoard.x))
        var yi = fabs(Float(orgBoard.y - aimBoard.y))
        println("the canOrcan`t value is(\(xi) \(yi))")
        if ((xi == 0 && yi == 1 ) || (xi == 1 && yi == 0)) && aimBoard.theChess == nil{
            return true
        }else{
            return false
        }
    }
    //移动棋子
    func moveChess(fromBoard oldBoard:ChessBoard,toBoard newBoard:ChessBoard){
        newBoard.theChess = oldBoard.theChess
        oldBoard.theChess = nil
        self.movedBoard = newBoard
        self.setNeedsDisplay()
    }
    //当棋子移动到点上时 横纵向是否有对方的棋子可被吃掉
    //board:要移动到的棋点
    func isSomeChessCanbeEat(theMovedBoard board:ChessBoard)->[ChessBoard?]{
        var toBeRemoveBoard:[ChessBoard?] = [nil]
        //将对方棋子的计算值置为-1 自己的计算值置为2 如果横竖相加为0 返回对方为2的board
        for rowBoard in self.chessBoards{
            for anyBoard in rowBoard{
                //有chess
                if anyBoard!.theChess != nil{
                    if anyBoard!.theChess?.standPoint == board.theChess?.standPoint{
                        anyBoard?.theChess?.value = -1
                    }else{
                        anyBoard?.theChess?.value = 2
                    }
                }
            }
        }
        //board.theChess?.value = -1
        //横竖方向上找和为0的 并返回board
        //bug 这个地方 数组与map的对应还须待研究。。。
        var theX = board.y
        var theY = board.x
        var sumValueX:Int = 0
        var sumValueY:Int = 0
        var willBeRemoveChessOnBoard:[ChessBoard?]
        //抽出来的一横排 纵排board
        var otherChessOnBoardX:[ChessBoard] = []
        var otherChessOnBoardY:[ChessBoard] = []
        //抽取双方的board
        for x in 0...3{
            if self.chessBoards[theX][x]?.theChess !=  nil{
                otherChessOnBoardX.append(self.chessBoards[theX][x]!)
                println("append one board X (\(self.chessBoards[theX][x]!.x) \(self.chessBoards[theX][x]!.y) value:\(self.chessBoards[theX][x]!.theChess!.value) )")
                sumValueX += self.chessBoards[theX][x]!.theChess!.value
                println("sumValueX : \(sumValueX) move to (\(self.chessBoards[theX][x]!.theChess!.standPoint) \(theX) \(x) value is \(self.chessBoards[theX][x]!.theChess!.value )) to sum")
            }
            if self.chessBoards[x][theY]?.theChess != nil{
                otherChessOnBoardY.append(self.chessBoards[x][theY]!)
                println("append one board X (\(self.chessBoards[x][theY]!.x) \(self.chessBoards[x][theY]!.y))")
                sumValueY += self.chessBoards[x][theY]!.theChess!.value
                println("sumValueY : \(sumValueY) move to (\(self.chessBoards[x][theY]!.theChess!.standPoint) \(x) \(theY) value is \(self.chessBoards[x][theY]!.theChess!.value )) to sum")

            }
        }
        
        if sumValueX == 0{
            println("there is one chess maybe to be eated on X")
        }
        if sumValueY == 0{
            println("there is one chess maybe to be eated on Y")
        }

        //X 方向的removeBoard判断
        //满足两个己方子 对方一个子的条件(一排就3个子 而且一定有2个己方 一个对方 因为做完值判断了) 再判断是否相邻
        if sumValueX == 0 && otherChessOnBoardX.count == 3{
            
            var twoBoard:[ChessBoard?] = []
            var oneBoard:ChessBoard? = nil
            //抽离出双方的board
            for testBoard in otherChessOnBoardX{
                if testBoard.theChess?.value == -1{
                    twoBoard.append(testBoard)
                }
                if testBoard.theChess?.value == 2{
                    oneBoard = testBoard
                }
            }
            //检测位置
            var jifangzixiangling = abs(twoBoard[0]!.x - twoBoard[1]!.x) == 1 //两个己方子相邻
            var yuqizhongyigeyexiangling = abs(twoBoard[0]!.x - oneBoard!.x) == 1 || abs(twoBoard[1]!.x - oneBoard!.x) == 1 //对方子与己方其中一子相邻
            if jifangzixiangling && yuqizhongyigeyexiangling { //两己方子相邻 并且其中一个与对方子相邻
                toBeRemoveBoard.append(oneBoard)
            }
        }
        //Y 方向的removeBoard判断
        if sumValueY == 0 && otherChessOnBoardY.count == 3{
            
            var twoBoard:[ChessBoard?] = []
            var oneBoard:ChessBoard? = nil
            //抽离出双方的board
            for testBoard in otherChessOnBoardY{
                if testBoard.theChess?.value == -1{
                    twoBoard.append(testBoard)
                }
                if testBoard.theChess?.value == 2{
                    oneBoard = testBoard
                }
            }
            //检测位置
            var jifangzixiangling = abs(twoBoard[0]!.y - twoBoard[1]!.y) == 1 //两个己方子相邻
            var yuqizhongyigeyexiangling = abs(twoBoard[0]!.y - oneBoard!.y) == 1 || abs(twoBoard[1]!.y - oneBoard!.y) == 1 //对方子与己方其中一子相邻
            if jifangzixiangling && yuqizhongyigeyexiangling { //两己方子相邻 并且其中一个与对方子相邻
                toBeRemoveBoard.append(oneBoard)
            }
        }

        println()
        //重置所有board值
        for boards in self.chessBoards{
            for board in boards{
                if board?.theChess != nil {
                    board!.theChess!.value = 0
                }
            }
        }
        return toBeRemoveBoard
    }
    
    //drawLine
    func drawLine(from start:CGPoint,to end:CGPoint){
        var path:UIBezierPath = UIBezierPath()
        path.moveToPoint(start)
        path.lineWidth = 3
        UIColor.blackColor().set()
        path.addLineToPoint(end)
        path.stroke()
    }
    //drawChess
    func drawChess(board:ChessBoard){
        
        var bezier = UIBezierPath()
        //board有chess才画
        if board.theChess != nil{
            UIColor.blackColor().setStroke()
            
            if board.theChess?.standPoint == "white" {
                UIColor.blackColor().setStroke()
                UIColor.redColor().setFill()
            }else if board.theChess?.standPoint == "black" {
                UIColor.blackColor().setStroke()
                UIColor.blackColor().setFill()
            }
            var x = Float(board.x * 75) + Float(37.0)
            var y = Float(board.y * 75) + Float(37.0)
            var center = CGPoint(x: CGFloat(x), y: CGFloat(y))
            bezier.addArcWithCenter(center, radius: 30, startAngle: 0, endAngle: 180.0, clockwise: true)
            bezier.stroke()
            bezier.fill()
        }
        if board == self.selectedBoard{
            println("xuanzhongdeyaobianzhuyangshi")
        }
    }
    //重绘Map
    override func drawRect(rect: CGRect) {
        //半天的时间找到的bug
        //通过IB方式连进来的控件 在此方法回调是才会加载完 否则全为nil
        if(self.chessBoards[0][0] == nil){
            self.initBoardAndChess()
        }
       //画map
        self.drawLine(from: CGPointMake(0, 0), to: CGPointMake(0, 300))
        self.drawLine(from: CGPointMake(75, 0), to: CGPointMake(75,300))
        self.drawLine(from: CGPointMake(150, 0), to: CGPointMake(150, 300))
        self.drawLine(from: CGPointMake(225, 0), to: CGPointMake(225, 300))
        self.drawLine(from: CGPointMake(300, 0), to: CGPointMake(300, 300))
        self.drawLine(from: CGPointMake(0, 0), to: CGPointMake(300, 0))
        self.drawLine(from: CGPointMake(0, 75), to: CGPointMake(300, 75))
        self.drawLine(from: CGPointMake(0, 150), to: CGPointMake(300, 150))
        self.drawLine(from: CGPointMake(0, 225), to: CGPointMake(300, 225))
        self.drawLine(from: CGPointMake(0, 300), to: CGPointMake(300, 300))
//        迭代二维数组 对board刷新 让thechess值不为空的board显示
        for rowBard in self.chessBoards{
            for board in rowBard{
                if board!.theChess != nil{
                    self.drawChess(board!)
                }
            }
        }
        
    }
    
    func initBoardAndChess(){
        NSLog("ViewController initBoardAndChess")
        self.whiteChesses = [self.whiteChess1!,self.whiteChess2!,self.whiteChess3!,self.whiteChess4!]
        self.blackChesses = [self.blackChess1!,self.blackChess2!,self.blackChess3!,self.blackChess4!]
        
        NSLog("\(self.whiteChess1)")
        self.board00.myinit(self.whiteChess1, x: 0, y: 0, isSelected: false)
        self.board01.myinit(self.whiteChess2, x: 1, y: 0, isSelected: false)
        self.board02.myinit(self.whiteChess3, x: 2, y: 0, isSelected: false)
        self.board03.myinit(self.whiteChess4, x: 3, y: 0, isSelected: false)
        self.board10.myinit(nil, x: 0, y: 1, isSelected: false)
        self.board11.myinit(nil, x: 1, y: 1, isSelected: false)
        self.board12.myinit(nil, x: 2, y: 1, isSelected: false)
        self.board13.myinit(nil, x: 3, y: 1, isSelected: false)
        self.board20.myinit(nil, x: 0, y: 2, isSelected: false)
        self.board21.myinit(nil, x: 1, y: 2, isSelected: false)
        self.board22.myinit(nil, x: 2, y: 2, isSelected: false)
        self.board23.myinit(nil, x: 3, y: 2, isSelected: false)
        self.board30.myinit(self.blackChess1, x: 0, y: 3, isSelected: false)
        self.board31.myinit(self.blackChess2, x: 1, y: 3, isSelected: false)
        self.board32.myinit(self.blackChess3, x: 2, y: 3, isSelected: false)
        self.board33.myinit(self.blackChess4, x: 3, y: 3, isSelected: false)
        
        self.chessBoards[0][0] = self.board00
        self.chessBoards[0][1] = self.board01
        self.chessBoards[0][2] = self.board02
        self.chessBoards[0][3] = self.board03
        self.chessBoards[1][0] = self.board10
        self.chessBoards[1][1] = self.board11
        self.chessBoards[1][2] = self.board12
        self.chessBoards[1][3] = self.board13
        self.chessBoards[2][0] = self.board20
        self.chessBoards[2][1] = self.board21
        self.chessBoards[2][2] = self.board22
        self.chessBoards[2][3] = self.board23
        self.chessBoards[3][0] = self.board30
        self.chessBoards[3][1] = self.board31
        self.chessBoards[3][2] = self.board32
        self.chessBoards[3][3] = self.board33
        
    }
    
    //初始化时最先调用
    required init(coder aDecoder: NSCoder) {
        NSLog("ViewController required Init")
        NSLog("")
        super.init(coder: aDecoder)
        //self.initBoardAndChess()

    }
    override init(frame: CGRect) {
        NSLog("MapView Override Init")
        super.init(frame: frame)
    }

}