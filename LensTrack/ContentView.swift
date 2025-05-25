//
//  ContentView.swift
//  LensTrack
//
//  Created by Kumkum Choudhary on 2025-03-14.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var lensData: LensData
    @State private var showingSettings = false
    @State private var showingCalendar = false
    @State private var animatedProgress: CGFloat = 1.0
    @State private var showingExpiryAlert = false
    
    var ringColor: Color {
        let ratio = CGFloat(lensData.daysLeft) / CGFloat(lensData.replacementCycle)
        if ratio > 0.66 {
            return .green
        } else if ratio > 0.33 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // Circular Progress Ring
                ZStack {
                    ProgressRing(
                        progress: animatedProgress,
                        lineWidth: 20,
                        backgroundColor: Color(UIColor.secondarySystemFill),
                        foregroundColor: ringColor
                    )
                    .frame(width: 300, height: 300)
                    .shadow(radius: 4)

                    VStack(spacing: 4) {
                        Text("\(lensData.daysLeft)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                        Text("days left")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // "Used Today" Button
                Button(action: {
                    lensData.incrementDaysUsed()
                }) {
                    Text("Used Today")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(lensData.daysLeft == 0 || lensData.isDateCounter)

                Spacer()
                
                // Bottom Icon Row: Reset + Calendar
                HStack(spacing: 40) {
                    iconButton(systemName: "arrow.counterclockwise.circle", label: "Reset") {
                        lensData.resetUsage()
                    }
                    
                    iconButton(systemName: "calendar", label: "Calendar") {
                        showingCalendar = true
                    }
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle("LensTrack")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(lensData: lensData)
            }
            .navigationDestination(isPresented: $showingCalendar) {
                CalendarView(lensData: lensData)
            }
            .onChange(of: lensData.daysLeft) { oldValue, newValue in
                withAnimation(.easeInOut(duration: 0.6)) {
                    animatedProgress = CGFloat(newValue) / CGFloat(lensData.replacementCycle)
                }
                if newValue == 0 {
                    showingExpiryAlert = true
                }
            }
            .onAppear {
                animatedProgress = CGFloat(lensData.daysLeft) / CGFloat(lensData.replacementCycle)
                if lensData.daysLeft == 0 {
                    showingExpiryAlert = true
                }
            }
            .alert("Replace Your Lenses", isPresented: $showingExpiryAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("It's time to replace your lenses.")
            }
        }
    }
    
    func iconButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemName)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.primary)
            .frame(width: 60)
        }
    }
}

struct ProgressRing: View {
    var progress: CGFloat
    var lineWidth: CGFloat
    var backgroundColor: Color
    var foregroundColor: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(foregroundColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(lensData: LensData())
                .preferredColorScheme(.light)
            
            ContentView(lensData: LensData())
                .preferredColorScheme(.dark)
        }
    }
}
 
