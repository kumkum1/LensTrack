import SwiftUI

struct CalendarView: View {
    @ObservedObject var lensData: LensData
    @State private var selectedDate = Date()

    private var currentMonthDates: [Date] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            return []
        }

        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(monthYearString(from: selectedDate))
                .font(.title2)
                .fontWeight(.bold)

            // Weekday headers
            let symbols = Calendar.current.shortWeekdaySymbols
            HStack {
                ForEach(symbols, id: \.self) { day in
                    Text(day)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.secondary)
                }
            }

            // Dates grid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(currentMonthDates, id: \.self) { date in
                    Text("\(Calendar.current.component(.day, from: date))")
                        .frame(width: 36, height: 36)
                        .background(
                            Calendar.current.isDate(date, inSameDayAs: selectedDate) ?
                                Color.blue.opacity(0.2) :
                                (lensData.usageDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) ?
                                 Color.green.opacity(0.3) : Color.clear)
                        )
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }

            // Total days used
            VStack(spacing: 4) {
                Text("Total Days Used")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("\(lensData.usageDates.count)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.accentColor)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Calendar")
    }

    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    Group {
        CalendarView(lensData: LensData())
            .preferredColorScheme(.light)
        
        CalendarView(lensData: LensData())
            .preferredColorScheme(.dark)
    }
} 
