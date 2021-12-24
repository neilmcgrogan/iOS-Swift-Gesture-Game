//
//  GameView.swift
//  game
//
//  Created by Neil McGrogan on 10/25/21.
//

import SwiftUI

/*
 
 GUIDE to coordinates
 
 0 < x < 1000
 leading < x < trailing
 
 0 < y < 1000
 top < y < bottom
 
 */

struct GameView: View {
    @EnvironmentObject var viewRouter: ViewModel
    @EnvironmentObject var level: LevelModel
    
    @State var player = Player()
    
    @State var bullet = [Item]()
    @State var food = [Item]()
    @State var bomb = [Item]()
    
    @State var elapsedSec = 0.0
    @State var lastDate = Date()
    @State var updateTimer = Timer.publish(every: 0.001, on: .current, in: .common).autoconnect()
    
    @State private var livesRemaining = 3
    @State private var gameState = 0
    
    let PLAYER_LOGO = "🕳", BULLET_LOGO = "💣", FOOD_LOGO = "❄️", BOMB_LOGO = "🧨"
    let INIT_STATE = 0, PLAYING_STATE = 1, PASSED_STATE = 2, FAILED_STATE = 3
    
    var body: some View {
        ZStack(alignment: .trailing) {
            GeometryReader { geometry in
                switch gameState {
                case INIT_STATE:
                    VStack {
                        Button("Ready") {
                            self.gameState = PLAYING_STATE
                            spawn(geometry: geometry)
                        }
                        
                        Button("Simulate lvl 20") {
                            level.level = 20
                            self.gameState = PLAYING_STATE
                            spawn(geometry: geometry)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case PLAYING_STATE:
                    VStack {
                        ZStack {
                            VStack {
                                Color.white
                                    .frame(width: geometry.size.width, height: 1, alignment: .center)
                                
                                Spacer()
                                
                                Color.white
                                    .frame(width: geometry.size.width, height: 1, alignment: .center)
                            }
                            
                            ZStack {
                                // bomb
                                ForEach(self.bomb, id: \.id) { item in
                                    Text(BOMB_LOGO)
                                        //.frame(width: item.radius * 2, height: item.radius * 6)
                                        .foregroundColor(Color.bomb)
                                        .cornerRadius(2)
                                        .position(item.pos)
                                }
                                
                                // bullet
                                ForEach(self.bullet, id: \.id) { item in
                                    Text(BULLET_LOGO)
                                        .rotationEffect(Angle(degrees: 150))
                                        //.fill(Color.bullet)
                                        //.frame(width: item.radius, height: item.radius)
                                        .shadow(radius: 3)
                                        .position(item.pos)
                                        
                                }
                                
                                ZStack {
                                    /*
                                    Circle()
                                        .frame(width: 16 + self.shieldSize(), height: 16 + self.shieldSize())
                                        .position(self.player.pos)
                                        .foregroundColor(.blue)
                                        .opacity(0.3)
                                    */
                                    
                                    // player
                                    Text(PLAYER_LOGO)
                                    //Triangle()
                                        //.frame(width: 16, height: 16)
                                        .position(self.player.pos)
                                }
                                
                                // food
                                ForEach(self.food, id: \.id) { item in
                                    Text(FOOD_LOGO)
                                        .shadow(radius: 3)
                                        .position(item.pos)
                                }
                            }
                            
                            if self.food.count >= 0 {
                                HStack(spacing: 0) {
                                    Text("\(self.food.count)")
                                        .bold()
                                        .opacity(0.4)
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                    
                                    Text("\(self.livesRemaining)")
                                        .bold()
                                        .opacity(0.4)
                                        .foregroundColor(.red)
                                        .font(.largeTitle)
                                }
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                    .background(Color.backgroundColor)
                    .gesture(
                        DragGesture(minimumDistance: 50)
                            .onEnded { v in
                                self.player.vel.x = (v.location.x - v.startLocation.x) * 1.5
                                self.player.target.x = self.player.pos.x + self.player.vel.x
                        }
                    )
                    .onReceive(self.updateTimer, perform: {_ in
                        self.movePlayer(geometry: geometry)
                        self.checkOutOfBounds(geometry: geometry);
                        
                        if self.livesRemaining < 1 {
                            self.endGame()
                        } else if self.food.count < 1 {
                            self.endRound()
                        } else {
                            let now = Date()
                            self.elapsedSec = Double(now.timeIntervalSince(self.lastDate))
                            self.lastDate = now
                            
                            let livesLeft = self.food.filter{ $0.collide(to: self.player) }
                            self.food.removeAll(where: {livesLeft.contains($0)})
                            
                            var index = 0
                            
                            //Item.spawnbullet(pos: self.player.pos)
                            for bullet in (self.bullet) {
                                for bomb in (self.bomb) {
                                    if bomb.pos.y < (self.player.pos.y - 10) {
                                        let bulletCollision = self.bullet.filter{ $0.collide(to: bomb) }
                                        let bulletCollisionToBomb = self.bomb.filter{ $0.collide(to: bullet)}
                                        
                                        self.bomb.removeAll(where: {bulletCollisionToBomb.contains($0)})
                                        self.bullet.removeAll(where: {bulletCollision.contains($0)})
                                        
                                        self.bullet.append(contentsOf: bulletCollision.map({ _ in Item.spawnBullet(pos: self.player.pos)}))
                                    }
                                }
                            }
                            
                            //Item.spawnbullet(pos: self.player.pos)
                            for bullet in (self.bullet) {
                                for food in (self.food) {
                                    let bulletCollision = self.bullet.filter{ $0.collide(to: food) }
                                    let bulletCollisionTofood = self.food.filter{ $0.collide(to: bullet)}
                                    
                                    self.food.removeAll(where: {bulletCollisionTofood.contains($0)})
                                    self.bullet.removeAll(where: {bulletCollision.contains($0)})
                                    
                                    self.bullet.append(contentsOf: bulletCollision.map({ _ in Item.spawnBullet(pos: self.player.pos)}))
                                }
                            }
                            
                            let collisions = self.bomb.filter{ $0.collide(to: self.player) }
                            self.bomb.removeAll(where: {collisions.contains($0)})
                            self.bomb.append(contentsOf: collisions.map({ _ in Item.spawnBomb(within: geometry)}))
                            self.livesRemaining -= collisions.count
                            
                            index = 0
                            
                            //var index = 0
                            for _ in (self.bomb) {
                                if bomb[index].pos.y >= geometry.size.height - 10 {
                                    bomb[index].pos.y = geometry.size.height - 10
                                } else {
                                    bomb[index].pos.y += 0.2
                                }
                                
                                index += 1
                            }
                            
                            index = 0
                            
                            for item in self.bullet {
                                if item.pos.y < 0 {
                                    self.bullet[index].pos = self.player.pos
                                }
                                
                                bullet[index].pos.y -= 0.91// + (2 * (item.pos.y / geometry.size.height))
                                
                                index += 1
                            }
                            
                            index = 0
                            
                            for _ in self.food {
                                if food[index].pos.y >= geometry.size.height - 10 {
                                    food[index].pos.y = 0
                                    food[index].pos.x = CGFloat.random(in: 5..<(geometry.size.width - 5))
                                }
                                
                                food[index].pos.y += 0.3
                                
                                index += 1
                            }
                        }
                    })
                case PASSED_STATE:
                    VStack {
                        Text("Success on level: \(level.level)")
                            .font(.title)
                        
                        Group {
                            Button("Next") {
                                level.level += 1
                                self.spawn(geometry: geometry)
                                self.gameState = PLAYING_STATE
                            }
                            
                            Button("Exit") {
                                level.level += 0
                                viewRouter.currentPage = .homeView
                            }
                        }.font(.title)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case FAILED_STATE:
                    VStack {
                        Text("You have failed")
                            .font(.title)
                        
                        Button("Exit") {
                            level.level += 0
                            viewRouter.currentPage = .homeView
                        }
                        .font(.title)
                        .onAppear {
                            endGame()
                        }
                    }
                    .foregroundColor(.red)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                default:
                    Text("what")
                }
            }
            .font(.largeTitle)
            .edgesIgnoringSafeArea(.all)
            .padding(5)
        }
    }
    
    func movePlayer(geometry : GeometryProxy) {
        let x = Double(self.player.target.x - self.player.pos.x)
        let y = Double(self.player.target.y - self.player.pos.y)
        
        let distance = sqrt((x * x) + (y * y))
        let angleRad = atan2(y, x)
        
        let velocity = distance / 0.5
        self.player.vel.x = velocity * cos(angleRad);
        self.player.vel.y = velocity * sin(angleRad);
        
        self.player.vel.x = self.elapsedSec * self.player.vel.x
        self.player.vel.y = self.elapsedSec * self.player.vel.y
        
        self.player.pos.x += CGFloat(self.player.vel.x)
        self.player.pos.y = geometry.size.height - 20//+= CGFloat(self.player.vel.y)
    }
    
    func checkOutOfBounds(geometry : GeometryProxy) {
        if self.player.pos.x < 0 {
            self.player.target.x = geometry.size.width / 4
            
        } else if self.player.pos.x > geometry.size.width {
            self.player.target.x = geometry.size.width - (geometry.size.width / 4)
        }
    }
    
    func endRound() {
        self.gameState = PASSED_STATE
        
        withAnimation() {
            self.bullet.removeAll()
            self.bomb.removeAll()
            self.food.removeAll()
        }
    }
    
    func endGame() {
        self.gameState = FAILED_STATE
        
        withAnimation() {
            self.bullet.removeAll()
            self.bomb.removeAll()
            self.food.removeAll()
        }
    }
    
    func spawn(geometry: GeometryProxy) {
        self.player.pos = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        self.player.target = self.player.pos
        
        for _ in 1...10 {
            self.bullet.append(.spawn(within: geometry))
        }
        
        for _ in 1...level.bombScale {
            self.bomb.append(.spawnBomb(within: geometry))
        }
        
        for _ in 1...level.foodScale {
            self.food.append(.spawn(within: geometry))
        }
        
        var index = 0
        
        for _ in (self.food) {
            food[index].pos.y = -CGFloat.random(in: 0..<geometry.size.height)
            
            index += 1
        }
        
        index = 0
        
        for _ in (self.bullet) {
            bullet[index].pos.y = CGFloat.random(in: 0..<geometry.size.height)
            bullet[index].pos.x = -100
            
            index += 1
        }
    }
    
    func shieldSize() -> CGFloat {
        return CGFloat(self.livesRemaining)
    }
}
