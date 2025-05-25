//
//  SettingsView.swift
//  LensTrack
//
//  Created by Kumkum Choudhary on 2025-03-14.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var lensData: LensData
    @State private var selectedLensType: LensType
    @State private var selectedDate: Date
    @State private var notificationsEnabled: Bool = true
    @State private var navigateToContentView = false
    @State private var leftEyePower: String
    @State private var rightEyePower: String

    init(lensData: LensData) {
        self.lensData = lensData
        _selectedLensType = State(initialValue: lensData.lensType)
        _selectedDate = State(initialValue: lensData.lastReplacementDate)
        _leftEyePower = State(initialValue: lensData.leftEyePower)
        _rightEyePower = State(initialValue: lensData.rightEyePower)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Lens Type")) {
                    Picker("Select Lens Type", selection: $selectedLensType) {
                        ForEach(LensType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section(header: Text("Last Replacement Date")) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                Section(header: Text("Lens Power (Optional)")) {
                    HStack {
                        Image(systemName: "eye.left")
                            .foregroundColor(.secondary)
                        TextField("Left Eye", text: $leftEyePower)
                            .keyboardType(.decimalPad)
                    }
                    
                    HStack {
                        Image(systemName: "eye.right")
                            .foregroundColor(.secondary)
                        TextField("Right Eye", text: $rightEyePower)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveChanges()
                        navigateToContentView = true
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToContentView) {
                ContentView(lensData: lensData)
            }
        }
    }

    private func saveChanges() {
        if lensData.lensType != selectedLensType {
            lensData.lensType = selectedLensType
        }
        lensData.lastReplacementDate = selectedDate
        lensData.leftEyePower = leftEyePower
        lensData.rightEyePower = rightEyePower
        lensData.resetUsage()

        if notificationsEnabled {
            // Schedule reminder for the day before replacement
            if let reminderDate = Calendar.current.date(byAdding: .day, value: lensData.replacementCycle - 1, to: selectedDate) {
                lensData.scheduleLensNotification(
                    for: reminderDate,
                    message: "Time to replace your lenses tomorrow!"
                )
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SettingsView(lensData: LensData())
                .preferredColorScheme(.light)
            
            SettingsView(lensData: LensData())
                .preferredColorScheme(.dark)
        }
    }
}
