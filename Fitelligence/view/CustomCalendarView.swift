//
//  CustomCalendarView.swift
//  testing
//
//  Created by Robert Penate + Jake C on 11/5/25.
//

import SwiftUI

struct CustomCalendarView: View {
    
    @State private var selectedDate = Date()
    @State private var currentMonthOffset = 0
    
    @State private var workoutVM = WorkoutViewModel()
    
    private let calendar = Calendar.current
    
    @EnvironmentObject var authVM: AuthenticationViewModel

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
                    Menu {
                        Button("Sign Out", role: .destructive) {
                            authVM.logout()
                        }
                    } label: {
                        HStack {
                            Text("Hello, \(authVM.firstName)!")
                                .font(.title).bold()
                            Image(systemName: "chevron.down")
                                .font(.headline)
                        }
                        .padding()
                    }

                    Spacer()
                    
                    NavigationLink(destination: CreateWorkoutView(
                        workoutVM: workoutVM,
                        selectedDate: selectedDate
                    )) {
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
                        
                        DayCell(
                            date: date,
                            isSelected: isSelected,
                            isToday: isToday,
                            hasWorkout: hasWorkout(on: date),
                            isPast: isPast
                        ) {
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
                            VStack(spacing: 12) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No workouts scheduled")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Tap + to create a workout")
                                    .font(.subheadline)
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(workoutVM.workoutsForSelectedDate, id: \.objectId) { workout in
                                NavigationLink(destination: workoutDetail(for: workout)){
                                    HStack {
                                        Circle().fill(.blue).frame(width: 8, height: 8)
                                        Text(workout.name ?? "Unnamed Workout")
                                            .font(.system(size: 24, weight: .medium))
                                        Spacer()
                                        if workout.isCompleted == true {
                                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                                Divider()
                            }
                            
                        }
                    }
                    .padding()
                }
                .refreshable {
                    workoutVM.loadWorkouts(for: selectedDate)
                }
                .padding(.top)
            }
            .onAppear {
                    workoutVM.loadWorkouts(for: selectedDate)
                }
        }
    }
    
    private func workoutDetail(for workout: Workout) -> some View {
        WorkoutDetailView(
            workout: workout,
            workoutVM: workoutVM,
            selectedDate: selectedDate
        )
    }
}
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasWorkout: Bool
    let isPast: Bool
    let onTap: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .frame(maxWidth: .infinity, minHeight: 36)
                .foregroundColor(
                    isSelected ? .white : (isPast ? .gray : .primary)
                )
                .background(
                    isSelected ? Color.blue :
                        (isToday ? Color.blue.opacity(0.3) : Color.clear)
                )
                .clipShape(Circle())

            Circle()
                .fill(hasWorkout ? Color.blue : Color.clear)
                .frame(width: 4, height: 4)
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}


#Preview {
    CustomCalendarView()
}
