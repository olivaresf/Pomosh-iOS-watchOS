//
//  ContentView.swift
//  Pomosh Watch Extension
//
//  Created by Steven J. Selcuk on 3.06.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI

let settings = UserDefaults.standard

struct ContentView: View {
    
    // MARK: - Properties
    @ObservedObject var ThePomoshTimer: PomoshTimer = PomoshTimer()
    @State private var currentPage = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Main Component
    var body: some View {
        VStack {
            PagerView(pageCount: 2, currentIndex: $currentPage) {
                VStack(alignment: .center) {
                    if self.ThePomoshTimer.isActive == true {
                        VStack {
							Text(self.ThePomoshTimer.isBreakActive ? NSLocalizedString("☕️ Break time", comment: "") : String(format: NSLocalizedString("🔥 X %d", comment: ""), self.ThePomoshTimer.round))
                                .font(.body)
                                 .foregroundColor(Color.gray)
                            Text("\(self.ThePomoshTimer.textForPlaybackTime(time: TimeInterval(self.ThePomoshTimer.timeRemaining)))")
                                .font(Font.system(.largeTitle).monospacedDigit())
                                .fontWeight(.bold)
                                .animation(nil)
                            
                        }
                        .onTapGesture {
                            self.ThePomoshTimer.isActive.toggle()
                            WKInterfaceDevice.current().play(.stop)
                        }
                    } else {
                        Text(self.ThePomoshTimer.round > 0 ? self.ThePomoshTimer.isBreakActive ? "Break stopped" : "Paused" : "Create New Session")
                            .font(.body)
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                if self.ThePomoshTimer.round == 0 {
                                    self.ThePomoshTimer.round = UserDefaults.standard.optionalInt(forKey: "fullround") ?? 5
                                    self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                                    WKInterfaceDevice.current().play(.success)
                                }
                                
                                self.ThePomoshTimer.isActive.toggle()
                        }
                    }
                }.navigationBarTitle("🍅")
                    .onReceive(timer) { time in
                        guard self.ThePomoshTimer.isActive else { return }
                        
                        if self.ThePomoshTimer.timeRemaining > 0 {
                            
                            self.ThePomoshTimer.timeRemaining -= 1
                            
                            
                        }
                        
                        //  if self.ThePomoshTimer.playSound && self.ThePomoshTimer.timeRemaining == 7 && self.ThePomoshTimer.round > 0 {
                        //      NSSound(named: "before")?.play()
                        //  }
                        if self.ThePomoshTimer.timeRemaining == 1 && self.ThePomoshTimer.round > 0 {
                            
                            WKInterfaceDevice.current().play(.success)
                            
                            // Break time or working time switcher 🎛
                            self.ThePomoshTimer.isBreakActive.toggle()
                            
                            if self.ThePomoshTimer.isBreakActive == true {
                                if self.ThePomoshTimer.round == 1 {
                                    self.ThePomoshTimer.timeRemaining = 0
                                    self.ThePomoshTimer.isBreakActive = false
                                } else {
                                    // Adds time for break
                                    //        print("It's break time 😴")
                                    self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
                                    self.ThePomoshTimer.fulltime = UserDefaults.standard.optionalInt(forKey: "fullBreakTime") ?? 600
                                }
                                // Removes 1 from total remaining round
                                
                                self.ThePomoshTimer.round -= 1
                                //       print("🔥Remaining round: \(self.ThePomoshTimer.round)")
                            } else {
                                //      print("It's working time 💪")
                                self.ThePomoshTimer.fulltime = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                                self.ThePomoshTimer.timeRemaining = UserDefaults.standard.optionalInt(forKey: "time") ?? 1200
                            }
                            
                        } else if self.ThePomoshTimer.timeRemaining == 0 {
                            //      print("Streak! 🔥 Session has ended.")
                            
                            WKInterfaceDevice.current().play(.notification)
                            self.ThePomoshTimer.isActive = false
                        }
                        
                }
                
                VStack {
                    ScrollView {
                        Spacer()
						Text(String(format: NSLocalizedString("Working Time: %d minute", comment: ""), self.ThePomoshTimer.fulltime / 60))
                        .font(Font.system(size: 12).monospacedDigit())
                        .animation(nil)
                        
                        
                        Slider(value: Binding(
                            get: {
                                Double(UserDefaults.standard.integer(forKey: "time"))
                        },
                            set: {(newValue) in
                                settings.set(newValue, forKey: "time")
                                self.ThePomoshTimer.fulltime = Int(newValue)
                        }
                            //    ),in: 10...3600, step: 10)
                        ),in: 1200...3600, step: 300)
                        
                        
                        
						Text(String(format: NSLocalizedString("Break Time: %d minute", comment:""), self.ThePomoshTimer.fullBreakTime / 60))
                        .font(Font.system(size: 12).monospacedDigit())
                        .animation(nil)
                        
                        
                        Slider(value: Binding(
                            get: {
                                Double(self.ThePomoshTimer.fullBreakTime)
                        },
                            set: {(newValue) in
                                settings.set(newValue, forKey: "fullBreakTime")
                                self.ThePomoshTimer.fullBreakTime = Int(newValue)
                        }
                        ) ,in: 300...600, step: 60)
                        
                        
						Text(NSLocalizedString("Total cycles in a session", comment: ""))
                        .font(Font.system(size: 12).monospacedDigit())
                        .animation(nil)
                        HStack {
                            
                            ForEach(0..<self.ThePomoshTimer.fullround, id: \.self) { index in
                                
                                Text("🔥")
                                .font(.system(size: 12))
                                
                            }
                        }
                        Slider(value: Binding(
                            get: {
                                Double(UserDefaults.standard.integer(forKey: "fullround"))
                        },
                            set: {(newValue) in
                                settings.set(newValue, forKey: "fullround")
                                print(newValue)
                                self.ThePomoshTimer.fullround = Int(newValue)
                        }
                        ),in: 1...6, step: 1)
                        
                        Spacer()
                    }
                }
                
                
            }
            
            HStack{
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(currentPage==1 ? Color.gray:Color.white)
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(currentPage==1 ? Color.white:Color.gray)
            }
            
        }
    }
}



