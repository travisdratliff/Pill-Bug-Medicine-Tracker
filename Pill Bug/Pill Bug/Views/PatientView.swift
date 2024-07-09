//
//  PatientView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/8/24.
//

import SwiftUI
import SwiftData
import Foundation

struct PatientView: View {
    var patient: Patient
    let calendar = Calendar.current
    @Environment(LocalNotificationManager.self) private var localNotificationManager
    @State private var selectedDate = Date()
    @State private var selectedMonth = 0
    @State private var showAddMedicine = false
    @State private var showSettings = false
    @State private var showDay: CalendarDate? = nil
    @State private var editMedicine: Medicine? = nil
    @Environment(\.modelContext) var context
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    @State private var chosenMonth = 0
    @State private var medicineName = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var keyboardFocused: Bool
    @State private var showNotifications = false
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack {
                        HStack {
                            Button {
                                selectedMonth -= 1
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                            Text(selectedDate.monthAndYear())
                            Spacer()
                            Button {
                                selectedMonth += 1
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title2)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top)
                        Spacer()
                        HStack {
                            ForEach(days, id: \.self) { day in
                                HStack {
                                    Text(day)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(fetchDates()) { value in
                                ZStack {
                                    if value.day != -1 {
                                        Button {
                                            showDay = value
                                        } label: {
                                            Text("\(value.day)")
                                                .foregroundColor(.primary)
                                                .background {
                                                    ZStack {
                                                        if value.date.string() == Date().string() {
                                                            ZStack {
                                                                RoundedRectangle(cornerRadius: 5)
                                                                    .fill(.primary)
                                                                    .frame(width: 36, height: 45)
                                                                RoundedRectangle(cornerRadius: 3)
                                                                    .fill(.white)
                                                                    .frame(width: 33, height: 42)
                                                            }
                                                        }
                                                        DoseDotsView(patient: patient, value: value)
                                                            .offset(x: 0, y: -14)
                                                    }
                                                    .frame(width: 35, height: 35)
                                                }
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(value.date.string() > Date().string())
                                    } else {
                                        Text("")
                                    }
                                }
                                .frame(width: 32, height: 32)
                                .sheet(item: $showDay) { value in
                                    DayView(calendarDate: value, patient: patient)
                                }
                            }
                        }
                        .padding(.bottom)
                        .onChange(of: selectedMonth) {
                            selectedDate = fetchSelectedMonth()
                        }
                    }
                } header: {
                    Text("calendar")
                        .foregroundColor(.primary)
                }
                Section {
                    ForEach(patient.medicines) { medicine in
                        HStack {
                            Text(medicine.name)
                            Spacer()
                            Button {
                                editMedicine = medicine
                            } label: {
                                HStack {
                                    Text("Options")
                                    Circle()
                                        .fill(Color(red: medicine.red, green: medicine.green, blue: medicine.blue))
                                        .frame(width: 30, height: 30)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .onDelete(perform: deleteMedicine)
                    
                } header: {
                    Text("\(patient.name)'s medications")
                        .foregroundColor(.primary)
                }
                
            }
            .sheet(item: $editMedicine) { medicine in
                EditMedicineView(medicine: medicine, patient: patient)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsView(patient: patient)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings.toggle()
                    } label: {
                        Image(systemName: "pencil.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNotifications.toggle()
                    } label: {
                        Image(systemName: "bell")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            let tel = "tel://"
                            let formattedString = tel + "1" + patient.doctorPhone
                            guard let url = URL(string: formattedString) else { return }
                            UIApplication.shared.open(url)
                        } label: {
                            Text("Call Dr. \(patient.doctor)")
                        }
                        Button {
                            let tel = "tel://"
                            let formattedString = tel + "1" + patient.pharmacyPhone
                            guard let url = URL(string: formattedString) else { return }
                            UIApplication.shared.open(url)
                        } label: {
                            Text("Call \(patient.pharmacy)")
                        }
                    } label: {
                        Image(systemName: "phone")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .navigationTitle(patient.name)
            .preferredColorScheme(.light)
            .onTapGesture(count: 2) {
                keyboardFocused = false
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(patient: patient)
            }
        }
    }
    func fetchDates() -> [CalendarDate] {
        let calendar = Calendar.current
        let currentMonth = fetchSelectedMonth()
        var dates = currentMonth.datesOfMonth().map({ CalendarDate(day: calendar.component(.day, from: $0), date: $0) })
        let firstDayOfWeek = calendar.component(.weekday, from: dates.first?.date ?? Date())
        for _ in 0..<firstDayOfWeek - 1 {
            dates.insert(CalendarDate(day: -1, date: Date()), at: 0)
        }
        return dates
    }
    func fetchSelectedMonth() -> Date {
        let calendar = Calendar.current
        let month = calendar.date(byAdding: .month, value: selectedMonth, to: Date())
        return month!
    }
    func deleteMedicine(at offsets: IndexSet) {
        for offset in offsets {
            let medicine = patient.medicines[offset]
            context.delete(medicine)
            if let index = patient.medicines.firstIndex(of: medicine) {
                patient.medicines.remove(at: index)
            }
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
            for request in localNotificationManager.pendingRequests {
                if request.identifier.contains(medicine.name) {
                    localNotificationManager.removeRequest(withIdentifier: request.identifier)
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Patient.self, Dose.self, Medicine.self,  configurations: config)
        let patientExample = Patient(name: "james", doctor: "who", doctorPhone: "1234567890", pharmacy: "Cvs", pharmacyPhone: "1234567890", medicines: [], doses: [])
        return PatientView(patient: patientExample)
            .modelContainer(container)
    } catch {
        fatalError()
    }
}
