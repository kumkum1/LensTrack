import Foundation
import UserNotifications

enum LensType: String, CaseIterable, Identifiable {
    case daily = "Daily", monthly = "Monthly", yearly = "Yearly"
    var id: String { self.rawValue }

    var replacementDays: Int {
        switch self {
        case .daily: return 1
        case .monthly: return 30
        case .yearly: return 365
        }
    }
}

class LensData: ObservableObject {
    @Published var replacementCycle: Int = 30
    @Published var lastReplacementDate: Date = Date()
    @Published var currentDate: Date = Date()
    @Published var isDateCounter: Bool = false  // Changed from true to false
    @Published var lensType: LensType = .monthly {
        didSet {
            replacementCycle = lensType.replacementDays
        }
    }
    @Published var usageDates: [Date] = []
    @Published var leftEyePower: String = ""
    @Published var rightEyePower: String = ""
    
    private var timer: Timer?
    
    init() {
        // Start the timer for automatic date counting
        startDateCounterIfNeeded()
    }
    
    var daysLeft: Int {
        let calendar = Calendar.current
        let daysSinceReplacement = calendar.dateComponents([.day], from: lastReplacementDate, to: currentDate).day ?? 0
        return max(0, replacementCycle - daysSinceReplacement)
    }
    
    var daysInUse: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: lastReplacementDate, to: currentDate).day ?? 0
    }
    
    var nextReplacementDate: Date {
        Calendar.current.date(byAdding: .day, value: replacementCycle, to: lastReplacementDate) ?? Date()
    }
    
    var sinceDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: lastReplacementDate)
    }
    
    var untilDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: nextReplacementDate)
    }
    
    var isSetupComplete: Bool {
        replacementCycle > 0
    }
    
    func incrementDaysUsed() {
        if daysLeft > 0 {
            // Only add the date if it's not already in the array
            let today = Date()
            if !usageDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                usageDates.append(today)
            }
        }
    }
    
    func resetUsage() {
        lastReplacementDate = Date()
        currentDate = Date()
        usageDates = []
        startDateCounterIfNeeded()
    }
    
    func setCounterType(isDate: Bool) {
        isDateCounter = isDate
        if isDate {
            startDateCounterIfNeeded()
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startDateCounterIfNeeded() {
        guard isDateCounter else { return }
        
        // Invalidate existing timer if any
        timer?.invalidate()
        
        // Update current date to match actual current date
        currentDate = Date()
        
        // Create a timer that fires at midnight
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
           let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) {
            
            let timer = Timer(fire: midnight, interval: 86400, repeats: true) { [weak self] _ in
                self?.currentDate = Date()
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func scheduleLensNotification(for date: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "LensTrack Reminder"
        content.body = message
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
} 
