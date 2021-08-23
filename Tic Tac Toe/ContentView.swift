//
//  ContentView.swift
//  Tic Tac Toe
//
//  Created by Siriluk Rachaniyom on 23/8/2564 BE.
//

import SwiftUI

struct ContentView: View {
    @State private var moves: [Move?] = Array(repeating: nil, count: 9) //ให้เป็นoptionalเนื่อจากตอนยังไม่ได้กดX O ช่องว่างจะเป็น nil
    @State private var isGameboardDisabled = false //เพื่อให้ขณะที่เป็นตาของคอมพิวเตอร์เราจะคลิ้กไม่ได้ เนื่องจากเราใช้asyncAfterในการทำdelay
    @State private var alertItem: AlertItem? //เป็นoptionalเพื่อให้ค่าที่สร้างเป็นnilอัตโนมัติ
    @State private var firstPlayer = true
    
    var body: some View {
        NavigationView {
            LazyVGrid(columns: [GridItem(), GridItem(),GridItem()]){
                ForEach(0..<9) { i in
                    ZStack{
                        Color.red
                            .opacity(0.5)
                            .frame(width: squareSize(), height: squareSize())
                            .cornerRadius(15)
                        
                        Image(systemName: moves[i]?.mark ?? "xmark.circle") //ถ้าไม่เป็น nil ก็จะX O ลงในช่องว่างที่คลิ้ก แต่ถ้าเป็น nil ก็ไม่ต้องใส่อะไร
                            .resizable()
                            .frame(width: markSize(), height: markSize())
                            .foregroundColor(.white)
                            .opacity(moves[i] == nil ? 0 : 1) //ถ้าเป็นnilจะให้เป็น0หรือบล่องหนแต่ถ้าไม่ใช่ให้เป็น1
                    
                }
                .onTapGesture {
                    if isSquareOccupied(in: moves, forIndex: i) { return } //ทำให้ไม่สามารถคลิ้กช่องที่คลิ้กไปแล้วได้
                        
                    moves[i] = Move(player: .human, boardIndex: i)
                        
                        
                    if checkWinConditon(for: .human, in: moves){
                        firstPlayer.toggle()
                        alertItem = AlertContext.humanWin
                        return
                    }
                        
                    if checkForDraw(in: moves){
                        firstPlayer.toggle()
                        alertItem = AlertContext.draw
                        return
                        }
                        
                        isGameboardDisabled.toggle()
                    
                    
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { //ทำให้เวลาตาคอมพิวเตอร์กดมีdelay โดยเพิ่ม 0.5วินาที หลังเราคลิ้ก
                            let computerPosition = determineComputerMove(in: moves)
                            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition) //เก็บข้อมูลที่move
                            isGameboardDisabled.toggle()
                            
                            if checkWinConditon(for: .computer, in: moves){
                                firstPlayer.toggle()
                                alertItem = AlertContext.computerWin
                            }
                        }
                    }
                }
            }
            .padding()
            .disabled(isGameboardDisabled) //เพื่อให้ขณะที่เป็นตาของคอมพิวเตอร์เราจะคลิ้กไม่ได้ ถ้าisGameboardDisabled เป็น true
            .navigationTitle("Tic Tac Toe")//ชื่อเกม
            .alert(item: $alertItem) { alertItem in
                Alert(title: Text(alertItem.title), message: Text(alertItem.message), dismissButton: .default(Text(alertItem.buttonTitle), action: resetGame))
            }
        }
    }
        
    func resetGame() {
        moves = Array(repeating: nil, count: 9)
        
        if firstPlayer == false {
            let computerPosition = determineComputerMove(in: moves)
            moves[computerPosition] = Move(player: .computer, boardIndex: computerPosition)
            
        }
    }
    func checkForDraw(in moves: [Move?]) -> Bool {
        moves.compactMap { $0 }.count == 9 //ถ้านับmovesที่ตัดnilออกเท่ากับ9 แปลว่าเสมอกัน
    }
    func checkWinConditon(for player: Player, in moves: [Move?]) -> Bool { //ไว้เช็คว่าPlayerชนะแล้วรึยัง
        let winPatterns: Array<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        //let playerMoves = moves.compactMap {$0}.filter{$0.player == player} //ตัดค่าที่เป็นnilออกจากmove โดยfilterเฉพาะของplayer
        //let playerPositions = playerMoves.map {$0.boardIndex} //เอาเฉพาตำแหน่งของplayerที่เลือก
        //รวม2บรรทัดบนลงมาเป็นบรรทัดเดียวได้
        let playerPositions = Set(moves.compactMap {$0}
                                    .filter{$0.player == player}
                                    .map {$0.boardIndex}) //ที่ให้เป็นsetเพราะเราไม่สนใจลำดับ
        
        for pattern in winPatterns{
            if pattern.isSubset(of: playerPositions) {
                return true //ถ้าตำแหน่งที่playerกดตรงกับpatternของwinPatterns
            }
        }
        return false //ถ้าไม่ตรงกับwinPatterns
    }
    func isSquareOccupied(in moves: [Move?], forIndex index: Int) -> Bool { //เช็คว่าตำแหน่งที่เรากดเป็นnilหรือว่างไหม
        moves[index] != nil
    }
    
    func determineComputerMove(in moves: [Move?]) -> Int { //ให้คอมพิวเตอร์เดินด้วยการสุ่มหาตำแหน่งที่ว่าง
        let winPatterns: Array<Set<Int>> = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]]
        
        //If AI can win, then wins
        let computerPositions = Set(moves.compactMap {$0}
                                    .filter{$0.player == .computer}
                                    .map {$0.boardIndex})
        for pattern in winPatterns {
            let winPositions = pattern.subtracting(computerPositions)
            if winPositions.count == 1 {
                if !isSquareOccupied(in: moves, forIndex: winPositions.first!) {//winPositions.first! คือตำแหน่งที่เหลือที่ลงแล้วจะชนะ เนื่องจากเป็นsetจึงต้องมี ! เพื่อ unrap ค่า
                    return winPositions.first!
                }
            }
        }
        
        //If AI can't win, then blocks
        let humanPositions = Set(moves.compactMap {$0}
                                    .filter{$0.player == .human}
                                    .map {$0.boardIndex})
        for pattern in winPatterns {
            let blockPositions = pattern.subtracting(humanPositions)
            if blockPositions.count == 1 {
                if !isSquareOccupied(in: moves, forIndex: blockPositions.first!) {//winPositions.first! คือตำแหน่งที่เหลือที่ลงแล้วจะชนะ เนื่องจากเป็นsetจึงต้องมี ! เพื่อ unrap ค่า
                    return blockPositions.first!
                }
            }
        }
        
        //If AI can't block, then take middle square
        let middlePosition = 4
        if !isSquareOccupied(in: moves, forIndex: middlePosition) {
            return middlePosition
        }
        
        //If AI can't take middle square, then take random availble square
        var movePosition = Int.random(in: 0..<9)
        
        while isSquareOccupied(in: moves, forIndex: movePosition){ //ถ้่าตำแหน่งที่สุ่มไปโดนตำแหน่งที่ไม่ว่างหรือไม่ใช่nilก็จะทำการสุ่มใหม่ไปเรื่อยๆ
            movePosition = Int.random(in: 0..<9)
        }
        
        return movePosition
    }
        
    func squareSize() -> CGFloat { //เอาไว้คำนวณขนาดของหน้าจอที่แสดง
        UIScreen.main.bounds.width / 3 - 15
    }
    
    func markSize() -> CGFloat{ //ขนาดของรูป X O ให้ตามหน้าจอแสดงผล
        squareSize() / 2
    }
}

enum Player {
    case human, computer
}
struct Move { //ไว้เก็บค่าตำแหน่งและplayer
    let player: Player
    let boardIndex: Int //ตำแหน่งที่กดลงไป
    
    var mark: String {
        player == .human ? "xmark" : "circle"
    }
}

struct AlertItem: Identifiable { //Itemของการแจ้งเตือน
    let id = UUID()
    let title: String
    let message: String
    let buttonTitle: String
}

struct AlertContext { //หน้าต่างแจ้งเตือนที่จะpopupขึ้นมาเวลาแพ้,ชนะ,เสมอ
    static let humanWin = AlertItem(title: "You Win!", message: "Congratulations", buttonTitle: "Play Again")
    static let draw = AlertItem(title: "Draw!", message: "Good Game", buttonTitle: "Play Again")
    static let computerWin = AlertItem(title: "You Lose!", message: "Try harder", buttonTitle: "Play Again")
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
