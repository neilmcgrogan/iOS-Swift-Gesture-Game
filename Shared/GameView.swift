//
//  GameView.swift
//  game
//
//  Created by Neil McGrogan on 10/25/21.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var viewRouter: ViewModel
    @EnvironmentObject var level: LevelModel
    @EnvironmentObject var defaults: PropertiesModel
    
    @State var player = Player()
    @State var bullet = [Item]()
    @State var bomb = [Item]()
    @State var bombAlternate = [Item]()
    @State var point = [Item]()
    
    @State private var gameState = 0
    let INIT_STATE = 0, PLAYING_STATE = 1, PASSED_STATE = 2, FAILED_STATE = 3
    
    @State var timeRemaining = 3
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State var elapsedSec = 0.0
    @State var lastDate = Date()
    @State private var timeSince = 1
    let updateTimer = Timer.publish(every: 0.01, on: .current, in: .common).autoconnect()
    
    @State private var livesRemaining = 3
    @State private var pointsEarned = 0
    @State private var bulletSpeed = 0.5
    @State private var bulletRate = 2
    @State private var speedCost = 1
    @State private var rateCost = 1
    
    @State private var endRoundNow = false
    
    @State private var animationAmount: CGFloat = 1
    
    @State private var high = 0
    @State private var low = 0
    
    var body: some View {
        ZStack(alignment: .trailing) {
            GeometryReader { geometry in
                switch gameState {
                case INIT_STATE:
                    VStack {
                        Text("\(timeRemaining)")
                            .onReceive(timer) { _ in
                                if timeRemaining > 0 {
                                    timeRemaining -= 1
                                } else if timeRemaining == 0 {
                                    self.gameState = PLAYING_STATE
                                    spawn(geometry: geometry)
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
                            
                            ZStack {
                                ProgressBar()
                                
                                // bomb
                                ForEach(self.bomb, id: \.id) { item in
                                    Circle()
                                        .frame(width: item.radius * 1.6, height: item.radius * 1.6)
                                        .foregroundColor(Color.bomb)
                                        .cornerRadius(2)
                                        .position(item.pos)
                                }
                                
                                // bomb alternate
                                ForEach(self.bombAlternate, id: \.id) { item in
                                    Circle()
                                        .frame(width: item.radius * 1.6, height: item.radius * 1.6)
                                        .foregroundColor(Color.bombAlternate)
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
                        
                        Text("\(level.BOMB_SPAWN_COUNT) balloons popped")
                            .font(.title)
                        
                        Spacer()
                        
                        HStack {
                            Text("\(self.pointsEarned)")
                                .bold()
                                .font(.largeTitle)
                            
                            Circle().frame(width: player.radius, height: player.radius)
                        }
                        .foregroundColor(Color.point)
                        
                        if self.speedCost <= self.pointsEarned {
                            Button(action: {
                                self.bulletSpeed +=  defaults.SPEED_UPGRADE
                                self.pointsEarned -= speedCost
                                self.speedCost += 1
                            }) {
                                HStack {
                                    Text("speed upgrade, \(speedCost)")
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
                                Text("speed upgrade, \(speedCost)")
                                    .foregroundColor(Color.redTextColor)
                                    .font(.title)
                                
                                Circle().frame(width: player.radius, height: player.radius)
                            }
                            .padding()
                            .background(Color.backgroundColor)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                        
                        if self.rateCost <= self.pointsEarned {
                            Button(action: {
                                self.bulletRate += Int(defaults.RATE_UPGRADE(level: level.level))
                                self.pointsEarned -= rateCost
                                self.rateCost += 1
                            }) {
                                HStack {
                                    Text("reload upgrade, \(rateCost)")
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
                                Text("reload upgrade, \(rateCost)")
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
                            }) {
                                VStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.playButton)
                                        
                                        Image(systemName: "play.fill")
                                            .font(.largeTitle)
                                            .foregroundColor(Color.topColor)
                                    }
                                    .shadow(radius: 0.5)
                                    .font(.title)
                                }
                                .frame(width: CGFloat(defaults.PLAY_BUTTON_SIZE), height: CGFloat(defaults.PLAY_BUTTON_SIZE), alignment: .bottom)
                                .shadow(radius: 0.5)
                                .foregroundColor(Color.textColor)
                                .scaleEffect(animationAmount)
                                .animation(.linear(duration: 0.75).delay(0.2).repeatForever(autoreverses: true))
                                .onAppear {
                                    animationAmount = 1.1
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
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    Circle()
                                        .fill(Color.playButton)
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.largeTitle)
                                        .foregroundColor(Color.topColor)
                                }
                                .frame(width: CGFloat(defaults.PLAY_BUTTON_SIZE), height: CGFloat(defaults.PLAY_BUTTON_SIZE), alignment: .bottom)
                                .shadow(radius: 0.5)
                                .scaleEffect(animationAmount)
                                .animation(.linear(duration: 0.75).delay(0.2).repeatForever(autoreverses: true))
                                .onAppear {
                                    animationAmount = 1.1
                                }
                            }
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
        self.checkOutOfBounds(geometry: geometry)
        
        if self.livesRemaining < 1 {
            self.endGame()
        } else if level.bombsLeft == 0 || self.endRoundNow {
            self.endRound()
        } else {
            self.timeSince += 1
            
            if timeSince % Int(level.BOMB_ALTERNATE_SPAWN_RATE) == 0 && (level.bombAlternateSpawnsLeft - 1) > 0 {
                self.bombAlternate.append(.spawn(within: geometry, level: level.level))
                level.bombAlternateSpawnsLeft -= 1
            }
            
            if timeSince % Int(level.BOMB_SPAWN_RATE) == 0 && (level.bombSpawnsLeft - 1) > 0 {
                self.bomb.append(.spawn(within: geometry, level: level.level))
                level.bombSpawnsLeft -= 1
            }
            
            if timeSince % Int(Double(120.0 / Double(bulletRate))) == 0 && self.bullet.count < defaults.BULLET_COUNT {
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
                    }
                }
            }
            
            for bullet in (self.bullet) {
                for bomb in (self.bomb) {
                    if bomb.pos.y < (self.player.pos.y - 10) {
                        let bulletCollision = self.bullet.filter{ $0.collide(to: bomb) }
                        let bulletCollisionToBomb = self.bomb.filter{ $0.collide(to: bullet)}
                        
                        self.bomb.removeAll(where: {bulletCollisionToBomb.contains($0)})
                        level.bombsLeft -= bulletCollision.count
                        self.bullet.removeAll(where: {bulletCollision.contains($0)})
                    }
                }
            }
            
            for bullet in (self.bullet) {
                for bomb in (self.bombAlternate) {
                    if bomb.pos.y < (self.player.pos.y - 10) {
                        let bulletCollision = self.bullet.filter{ $0.collide(to: bomb) }
                        let bulletCollisionToBomb = self.bombAlternate.filter{ $0.collide(to: bullet)}
                        
                        self.bombAlternate.removeAll(where: {bulletCollisionToBomb.contains($0)})
                        level.bombsLeft -= bulletCollision.count
                        self.bullet.removeAll(where: {bulletCollision.contains($0)})
                    }
                }
            }
            
            var collisions = self.bomb.filter{ $0.collide(to: self.player) }
            self.bomb.removeAll(where: {collisions.contains($0)})
            self.livesRemaining -= collisions.count
            level.bombsLeft -= collisions.count
            
            collisions = self.bombAlternate.filter{ $0.collide(to: self.player) }
            self.bombAlternate.removeAll(where: {collisions.contains($0)})
            self.livesRemaining -= collisions.count
            level.bombsLeft -= collisions.count
            
            collisions = self.point.filter{ $0.collide(to: self.player) }
            self.point.removeAll(where: {collisions.contains($0)})
            self.pointsEarned += collisions.count
            
            objectMovement(geometry: geometry)
            
            if self.bomb.count == 0 && self.bombAlternate.count == 0 {
                self.endRoundNow = true
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
    
    func removeAll() {
        withAnimation() {
            self.bullet.removeAll()
            self.bomb.removeAll()
            self.bombAlternate.removeAll()
            self.point.removeAll()
        }
    }
    
    func endRound() {
        removeAll()
        self.gameState = PASSED_STATE
    }
    
    func endGame() {
        removeAll()
        self.gameState = FAILED_STATE
    }
    
    func spawn(geometry: GeometryProxy) {
        self.endRoundNow = false
        
        self.player.pos = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
        self.player.target = self.player.pos
        
        self.bomb.append(.spawn(within: geometry, level: level.level))
        self.bombAlternate.append(.spawn(within: geometry, level: level.level))
        
        for _ in 1...level.POINT_SPAWN_COUNT {
            self.point.append(.spawn(within: geometry, level: level.level))
        }
        
        level.bombsLeft = level.BOMB_SPAWN_COUNT + level.BOMB_ALTERNATE_SPAWN_COUNT
        level.bombSpawnsLeft = level.BOMB_SPAWN_COUNT
        level.bombAlternateSpawnsLeft = level.BOMB_ALTERNATE_SPAWN_COUNT
    }
    
    func shieldSize() -> CGFloat {
        return CGFloat(self.livesRemaining)
    }
    
    func objectMovement(geometry: GeometryProxy) {
        var index = 0
        
        for _ in (self.bomb) {
            if bomb[index].pos.y >= geometry.size.height - 10 {
                bomb[index].pos.y = geometry.size.height - 10
            } else {
                bomb[index].pos.y += level.BOMB_FALL_SPEED
            }
            
            index += 1
        }
        
        index = 0
        
        for _ in (self.bombAlternate) {
            if bombAlternate[index].pos.y >= geometry.size.height - 10 {
                bombAlternate[index].pos.y = geometry.size.height - 10
            } else {
                if bombAlternate[index].pos.x < 0 {
                    bombAlternate[index].pos.x = 1
                    bombAlternate[index].lastMovement = 0
                    bombAlternate[index].pos.x += level.BOMB_ALTERNATE_FALL_SPEED_X
                } else if bombAlternate[index].pos.x > geometry.size.width {
                    bombAlternate[index].pos.x = geometry.size.width - 1
                    bombAlternate[index].lastMovement = 1
                    bombAlternate[index].pos.x -= level.BOMB_ALTERNATE_FALL_SPEED_X
                } else {
                    if bombAlternate[index].lastMovement == 0 {
                        bombAlternate[index].pos.x += level.BOMB_ALTERNATE_FALL_SPEED_X
                    } else{
                        bombAlternate[index].pos.x -= level.BOMB_ALTERNATE_FALL_SPEED_X
                    }
                }
                
                bombAlternate[index].pos.y += level.BOMB_ALTERNATE_FALL_SPEED_Y
            }
            
            index += 1
        }
        
        index = 0
        
        for item in self.bullet {
            if item.pos.y > 0 {
                bullet[index].pos.y -= (Double(level.BULLET_SPEED_INIT) + self.bulletSpeed)
                
                index += 1
            } else {
                self.bullet.remove(at: index)
            }
        }
        
        index = 0
        
        for _ in self.point {
            point[index].pos.y += level.POINT_FALL_SPEED
            
            index += 1
        }
    }
}
