//
//  CustomCalendarView.swift
//  testing
//
//  Created by Robert Penate on 11/5/25.
//

import SwiftUI

struct CustomCalendarView: View {
    
    
    
    @State private var selectedDate = Date()
    @State private var currentMonthOffset = 0
    private let calendar = Calendar.current
    
    
    //sets up calendar
    private var currentMonth: Date {
        calendar.date(byAdding: .month, value: currentMonthOffset, to: Date()) ?? Date()
    }
    
    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))
        else { return [] }
        return range.compactMap { calendar.date(byAdding: .day, value: $0 - 1, to: monthStart) }
    }
    
    private var startingWeekdayOffset: Int {
        let weekday = calendar.component(.weekday, from: daysInMonth.first ?? Date())
        // Makes Monday the first day
        return (weekday + 5) % 7
    }
    
    
    
    var body: some View {
        VStack(spacing: 16) {
            //user profile/name WIP
            HStack{
                Text("Hello user!").font(.title).bold()
                    .frame(alignment: .leading)
                    .padding()
                Spacer()
            }
            
            // Month Header
            HStack {
                Button(action: { withAnimation { currentMonthOffset -= 1 } }) {
                    Image(systemName: "chevron.left")
                }
                
                Spacer()
                
                Text(currentMonth, format: Date.FormatStyle().month(.wide).year())
                    .font(.title2).bold()
                
                Spacer()
                
                Button(action: { withAnimation { currentMonthOffset += 1 } }) {
                    Image(systemName: "chevron.right")
                }
            }
            .padding(.horizontal)
            .foregroundColor(.primary)
            
            // Weekday Labels
            let weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            
            
            //calendar maker
            LazyVGrid(columns: columns, spacing: 8) {
                // Weekday labels
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity, minHeight: 20)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                // Empty slots before first day
                ForEach(0..<startingWeekdayOffset, id: \.self) { _ in
                    Text("")
                        .frame(height: 36)
                }
                
                // Days in month
                ForEach(daysInMonth, id: \.self) { date in
                    let isPast = date < calendar.startOfDay(for: Date())
                    let isToday = calendar.isDateInToday(date)
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .foregroundColor(
                            isSelected ? .white :
                                (isPast ? .gray : .primary)
                        )//colors number based on date
                        .background(
                            isSelected ? Color.orange :
                                (isToday ? Color.orange.opacity(0.3) : Color.clear)
                        )
                        .clipShape(Circle())
                        .contentShape(Rectangle()) // ensures full tap area
                        .onTapGesture { selectedDate = date }
                }
            }
            .padding(.horizontal)
            
            Divider().padding(.horizontal)
            
            //lists workouts
            ScrollView(){
                LazyVStack(){
                    ForEach(1...10, id: \.self) { item in
                        HStack {
                            
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 8, height: 8)
                            Text("Excercise \(item)")
                                .font(.system(size:30))
                        }
                        .padding(.horizontal)
                        Divider()
                    }
                }
            }
            .padding()
            HStack(spacing: 20) {
                ZStack{
                    Circle()
                        .cornerRadius(20)
                        .frame(width: 75)
                        .foregroundColor(.blue)
                    Image(systemName : "calendar")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                ZStack{
                    Circle()
                        .cornerRadius(20)
                        .frame(width: 75)
                        .foregroundColor(.purple)
                    Image(systemName: "sun.max.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                ZStack{
                    Circle()
                        .cornerRadius(20)
                        .frame(width: 75)
                        .foregroundColor(.orange)
                    Image(systemName : "dumbbell.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
            }
            .padding(.top)
        }
    }
}
#Preview{
    CustomCalendarView()
}
