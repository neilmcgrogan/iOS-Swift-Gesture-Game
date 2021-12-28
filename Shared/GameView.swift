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
    @State var bomb = [Item]()
    @State var point = [Item]()
    
    @State var elapsedSec = 0.0
    @State var lastDate = Date()
    @State var updateTimer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    
    @State private var livesRemaining = 3
    @State private var gameState = 0
    @State private var timeSince = 1
    @State private var pointsEarned = 0//UserDefaults.standard.integer(forKey: "pointsEanred")
    @State private var bombsLeft = 0
    @State private var bulletSpeed = 0.5
    @State private var bulletRate = 1
    @State private var speedCost = 1
    @State private var rateCost = 1
    
    let INIT_STATE = 0, PLAYING_STATE = 1, PASSED_STATE = 2, FAILED_STATE = 3
    let BULLET_COUNT = 20, BULLET_PER_SECOND = 1, COUNT_UPGRADE = 0.15, RATE_UPGRADE = 1
    let BOMB_FALL_RATE = 0.8
    //let POINTS_EARNED_KEY = "pointsEanred"
    
    @State var timeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack(alignment: .trailing) {
            GeometryReader { geometry in
                switch gameState {
                case INIT_STATE:
                    VStack {
                        Button("20") {
                            self.bulletRate += 5
                            self.bulletSpeed += 3
                            self.level.level = 20
                            self.gameState = PLAYING_STATE
                            spawn(geometry: geometry)
                            self.bombsLeft = level.bombScale
                            gameState = PLAYING_STATE
                        }
                        
                        Text("\(timeRemaining)")
                            .onReceive(timer) { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                } else if timeRemaining == 0 {
                                    self.gameState = PLAYING_STATE
                                    spawn(geometry: geometry)
                                    self.bombsLeft = level.bombScale
                                    gameState = PLAYING_STATE
                                }
                            }
                            
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case PLAYING_STATE:
                    VStack {
                        ZStack {
                            VStack {
                                HStack {
                                    HStack {
                                        if self.livesRemaining > 0 {
                                            if self.livesRemaining == 3 {
                                                Circle().frame(width: player.radius, height: player.radius)
                                                Circle().frame(width: player.radius, height: player.radius)
                                                Circle().frame(width: player.radius, height: player.radius)
                                            } else if self.livesRemaining == 2 {
                                                Circle().frame(width: player.radius, height: player.radius)
                                                Circle().frame(width: player.radius, height: player.radius)
                                            } else if self.livesRemaining == 1 {
                                                Circle().frame(width: player.radius, height: player.radius)
                                            }
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    HStack {
                                        Text("\(self.pointsEarned) ")
                                            .bold()
                                            .font(.title)
                                        
                                        Circle().frame(width: player.radius, height: player.radius)
                                    }
                                    .foregroundColor(Color.point)
                                }
                                .foregroundColor(Color.bomb)
                                .opacity(0.7)
                                
                                Spacer()
                                
                                Color.white
                                    .frame(width: geometry.size.width, height: 1, alignment: .center)
                                    .opacity(0.6)
                            }
                            
                            if self.bomb.count >= 0 {
                                HStack(spacing: 0) {
                                    Text("\(self.bombsLeft)")
                                        .bold()
                                        .opacity(0.7)
                                        .foregroundColor(Color.redTextColor)
                                        .font(.largeTitle)
                                }
                            }
                            
                            ZStack {
                                // bomb
                                ForEach(self.bomb, id: \.id) { item in
                                    Circle()
                                        .frame(width: item.radius * 1.6, height: item.radius * 1.6)
                                        .foregroundColor(Color.bomb)
                                        .cornerRadius(2)
                                        .position(item.pos)
                                }
                                
                                // bullet
                                ForEach(self.bullet, id: \.id) { item in
                                    Rectangle()
                                        .frame(width: item.radius / 3, height: item.radius * 1.5)
                                        .foregroundColor(Color.bullet)
                                        .shadow(radius: 3)
                                        .position(item.pos)
                                        
                                }
                                
                                // player
                                Rectangle()
                                    .frame(width: self.player.radius, height: self.player.radius)
                                    .foregroundColor(Color.textColor)
                                    .cornerRadius(10)
                                    .position(self.player.pos)
                                
                                // point
                                ForEach(self.point, id: \.id) { item in
                                    Circle()
                                        .frame(width: item.radius, height: item.radius)
                                        .foregroundColor(Color.point)
                                        .cornerRadius(2)
                                        .position(item.pos)
                                }
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.top)
                    .background(Color.backgroundColor)
                    .gesture(
                        DragGesture(minimumDistance: 20)
                            .onEnded { v in
                                self.player.vel.x = (v.location.x - v.startLocation.x) * 1.5
                                self.player.target.x = self.player.pos.x + self.player.vel.x
                        }
                    )
                    .onReceive(self.updateTimer, perform: {_ in
                        didRecievetimer(geometry: geometry)
                    })
                case PASSED_STATE:
                    VStack {
                        Text("you beat level \(level.level)")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("\(level.bombScale) balloons popped")
                            .font(.title)
                        
                        Spacer()
                        
                        HStack {
                            Text("\(self.pointsEarned)")
                                .bold()
                                .font(.largeTitle)
                            
                            Circle().frame(width: player.radius, height: player.radius)
                        }
                        .foregroundColor(Color.point)
                        
                        if self.rateCost <= self.pointsEarned {
                            Button(action: {
                                self.bulletRate += RATE_UPGRADE
                                self.pointsEarned -= rateCost
                                self.rateCost += 1
                                //UserDefaults.standard.set(self.pointsEarned, forKey: POINTS_EARNED_KEY)
                            }) {
                                HStack {
                                    Text("dart rate, \(rateCost)")
                                        .font(.title)
                                    
                                    Circle().frame(width: player.radius, height: player.radius)
                                }
                                .padding()
                                .background(Color.backgroundColor)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                        } else {
                            HStack {
                                Text("dart rate, \(rateCost)")
                                    .foregroundColor(Color.redTextColor)
                                    .font(.title)
                                
                                Circle().frame(width: player.radius, height: player.radius)
                            }
                            .padding()
                            .background(Color.backgroundColor)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                            
                        }
                        
                        if self.speedCost <= self.pointsEarned {
                            Button(action: {
                                self.bulletSpeed +=  COUNT_UPGRADE
                                self.pointsEarned -= speedCost
                                self.speedCost += 1
                                //UserDefaults.standard.set(self.pointsEarned, forKey: POINTS_EARNED_KEY)
                            }) {
                                HStack {
                                    Text("dart speed, \(speedCost)")
                                        .font(.title)
                                    
                                    Circle().frame(width: player.radius, height: player.radius)
                                }
                                .padding()
                                .background(Color.backgroundColor)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                            }
                        } else {
                            HStack {
                                Text("dart speed, \(speedCost)")
                                    .foregroundColor(Color.redTextColor)
                                    .font(.title)
                                
                                Circle().frame(width: player.radius, height: player.radius)
                            }
                            .padding()
                            .background(Color.backgroundColor)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                        
                        HStack {
                            Text("up next level \(level.level + 1)")
                            
                            Spacer()
                            
                            Button(action: {
                                level.level += 1
                                self.spawn(geometry: geometry)
                                self.gameState = PLAYING_STATE
                                self.bombsLeft = level.bombScale
                            }) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.backgroundColor)
                                        
                                        Image(systemName: "play.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.textColor)
                                    }
                                    .frame(width: 100, height: 100, alignment: .bottom)
                                    .shadow(radius: 0.5)
                                    .font(.title)
                                }
                            }.frame(width: 100, height: 100, alignment: .bottom)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                case FAILED_STATE:
                    VStack {
                        Text("Game over")
                            .font(.largeTitle)
                            .bold()
                        
                        Text("you made it to level \(level.level)")
                            .font(.title2)
                        
                        Spacer()
                        
                        Button(action: {
                            level.level += 0
                            viewRouter.currentPage = .homeView
                        }) {
                            Text("Exit")
                                .bold()
                                .frame(width: UIScreen.main.bounds.size.width - 50, height: 100, alignment: .center)
                                .background(Color.backgroundColor)
                                .cornerRadius(15)
                                .shadow(radius: 5)
                                .font(.title)
                        }
                        .onAppear {
                            endGame()
                        }
                    }
                    .foregroundColor(Color.redTextColor)
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
    
    func didRecievetimer(geometry: GeometryProxy) {
        self.movePlayer(geometry: geometry)
        self.checkOutOfBounds(geometry: geometry);
        
        if self.livesRemaining < 1 {
            self.endGame()
        } else if self.bomb.count < 1 {
            self.endRound()
        } else {
            self.timeSince += 1
            print(timeSince)
            
            if timeSince % (120 / bulletRate) == 0 && self.bullet.count < BULLET_COUNT {
                self.bullet.append(.spawnBullet(pos: self.player.pos))
            }
            
            let now = Date()
            self.elapsedSec = Double(now.timeIntervalSince(self.lastDate))
            self.lastDate = now
            
            for bullet in (self.bullet) {
                for point in (self.point) {
                    if point.pos.y < (self.player.pos.y - 10) {
                        let bulletCollision = self.bullet.filter{ $0.collide(to: point) }
                        let bulletCollisionToPoint = self.point.filter{ $0.collide(to: bullet)}
                        
                        self.point.removeAll(where: {bulletCollisionToPoint.contains($0)})
                        self.bullet.removeAll(where: {bulletCollision.contains($0)})
                        
                        self.pointsEarned += bulletCollisionToPoint.count
                        //UserDefaults.standard.set(self.pointsEarned, forKey: POINTS_EARNED_KEY)
                    }
                }
            }
            
            var index = 0
            
            for bullet in (self.bullet) {
                for bomb in (self.bomb) {
                    if bomb.pos.y < (self.player.pos.y - 10) {
                        let bulletCollision = self.bullet.filter{ $0.collide(to: bomb) }
                        let bulletCollisionToBomb = self.bomb.filter{ $0.collide(to: bullet)}
                        
                        self.bomb.removeAll(where: {bulletCollisionToBomb.contains($0)})
                        self.bombsLeft -= bulletCollision.count
                        self.bullet.removeAll(where: {bulletCollision.contains($0)})
                    }
                }
            }
            
            var collisions = self.bomb.filter{ $0.collide(to: self.player) }
            self.bomb.removeAll(where: {collisions.contains($0)})
            self.livesRemaining -= collisions.count
            self.bombsLeft -= collisions.count
            
            collisions = self.point.filter{ $0.collide(to: self.player) }
            self.point.removeAll(where: {collisions.contains($0)})
            self.pointsEarned += collisions.count
            
            index = 0
            
            for _ in (self.bomb) {
                if bomb[index].pos.y >= geometry.size.height - 10 {
                    bomb[index].pos.y = geometry.size.height - 10
                } else {
                    bomb[index].pos.y += bombFallRate()
                }
                
                index += 1
            }
            
            index = 0
            
            for item in self.bullet {
                if item.pos.y > 0 {
                    bullet[index].pos.y -= self.bulletSpeed + 2 + (1 * (item.pos.y / geometry.size.height))
                    
                    index += 1
                } else {
                    self.bullet.remove(at: index)
                }
            }
            
            index = 0
            
            for _ in self.point {
                point[index].pos.y += 1
                
                index += 1
            }
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
        self.player.pos.y = geometry.size.height - 20
    }
    
    func checkOutOfBounds(geometry : GeometryProxy) {
        if self.player.pos.x < 0 {
            self.player.target.x = geometry.size.width / 6
        } else if self.player.pos.x > geometry.size.width {
            self.player.target.x = geometry.size.width - (geometry.size.width / 6)
        }
    }
    
    func endRound() {
        self.gameState = PASSED_STATE
        
        withAnimation() {
            self.bullet.removeAll()
            self.bomb.removeAll()
            self.point.removeAll()
        }
    }
    
    func endGame() {
        self.gameState = FAILED_STATE
        
        withAnimation() {
            self.bullet.removeAll()
            self.bomb.removeAll()
            self.point.removeAll()
        }
    }
    
    func spawn(geometry: GeometryProxy) {
        self.player.pos = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        self.player.target = self.player.pos
        
        for _ in 1...level.bombScale {
            self.bomb.append(.spawn(within: geometry))
        }
        
        for _ in 1...level.pointScale {
            self.point.append(.spawn(within: geometry))
        }
    }
    
    func shieldSize() -> CGFloat {
        return CGFloat(self.livesRemaining)
    }
    
    func progressBar() -> Double {
        return Double(self.bombsLeft) / Double(level.bombScale)
    }
    
    func bombFallRate() -> Double {
        return self.BOMB_FALL_RATE + Double((level.level / 30))
    }
}
