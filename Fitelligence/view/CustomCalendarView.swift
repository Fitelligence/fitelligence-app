//
//  CustomCalendarView.swift
//  testing
//
//  Created by Robert Penate + Jake C on 11/5/25.
//

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
    
    @State private var workoutVM = WorkoutViewModel()
    
    private let calendar = Calendar.current
    
    // Sets up calendar
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
    
    // Check if a date has workouts (for blue dots)
    private func hasWorkout(on date: Date) -> Bool {
        return workoutVM.workoutsForSelectedDate.contains { workout in
            guard let scheduleDate = workout.scheduleDate else { return false }
            return calendar.isDate(scheduleDate, inSameDayAs: date)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // User profile/name WIP
                HStack {
                    Text("Hello user!").font(.title).bold()
                        .frame(alignment: .leading)
                        .padding()
                    Spacer()
                    
                    NavigationLink(destination: CreateWorkoutView()) {
                        Image(systemName: "plus.circle")
                            .padding(.trailing)
                    }
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
                
                // Calendar maker
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
                        
                        VStack(spacing: 2) {
                            Text("\(calendar.component(.day, from: date))")
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .foregroundColor(
                                    isSelected ? .white :
                                        (isPast ? .gray : .primary)
                                ) // Colors number based on date
                                .background(
                                    isSelected ? Color.orange :
                                        (isToday ? Color.orange.opacity(0.3) : Color.clear)
                                )
                                .clipShape(Circle())
                            
                            // Workout indicator dot (blue dot if workout exists)
                            if hasWorkout(on: date) {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 4, height: 4)
                            } else {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 4, height: 4)
                            }
                        }
                        .contentShape(Rectangle()) // Ensures full tap area
                        .onTapGesture {
                            selectedDate = date
                            workoutVM.loadWorkouts(for: date)
                        }
                    }
                }
                .padding(.horizontal)
                
                Divider().padding(.horizontal)
                
                // Lists workouts
                ScrollView {
                    LazyVStack {
                        if workoutVM.workoutsForSelectedDate.isEmpty {
                            VStack {
                                Spacer()
                                Text("No workouts scheduled today")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .padding()
                        } else {
                            ForEach(workoutVM.workoutsForSelectedDate, id: \.objectId) { workout in
                                HStack {
                                    Circle().fill(.orange).frame(width: 8, height: 8)
                                    Text(workout.name ?? "Unnamed Workout")
                                        .font(.system(size: 24, weight: .medium))
                                    Spacer()
                                    if workout.isCompleted == true {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    }
                                }
                                .padding(.horizontal)
                                Divider()
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    workoutVM.loadWorkouts(for: selectedDate)
                }
                
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .cornerRadius(20)
                            .frame(width: 75)
                            .foregroundColor(.blue)
                        Image(systemName: "calendar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                    }
                    ZStack {
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
                    ZStack {
                        Circle()
                            .cornerRadius(20)
                            .frame(width: 75)
                            .foregroundColor(.orange)
                        Image(systemName: "dumbbell.fill")
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
}

#Preview {
    CustomCalendarView()
}
