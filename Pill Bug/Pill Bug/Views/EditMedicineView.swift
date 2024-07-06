//
//  EditMedicineView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/24/24.
//

import SwiftUI
import SwiftData
import Foundation
import UserNotifications

struct EditMedicineView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(LocalNotificationManager.self) private var localNotificationManager
    @Environment(\.scenePhase) var scenePhase
    var medicine: Medicine
    var patient: Patient
    @State private var medicineName = ""
    @State private var pickedColor = Color(red: 1, green: 0.41, blue: 0.38)
    @FocusState private var keyboardFocused: Bool
    @State private var timeToWait = ""
    let hours = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24"]
    @State private var chosenHour = "1"
    @AppStorage("takeEveryDay") var takeEveryDay = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var scheduleDate = Date()
    private var pluralHr: String {
        if chosenHour == "1" {
            return "hour"
        } else {
            return "hours"
        }
    }
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ColorPicker("Edit color", selection: $pickedColor)
                    HStack {
                        TextField("\(medicine.name)", text: $medicineName)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            let medicineColor = pickedColor.convertedToCGFloat()
                            let red = medicineColor[0]
                            let green = medicineColor[1]
                            let blue = medicineColor[2]
                            medicine.red = red
                            medicine.green = green
                            medicine.blue = blue
                            medicine.name = medicineName
                            for dose in patient.doses {
                                if dose.name == medicine.name {
                                    dose.name = medicineName
                                    dose.red = red
                                    dose.green = green
                                    dose.blue = blue
                                }
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                    }
                } header: {
                    Text("Edit \(medicine.name)")
                        .foregroundColor(.primary)
                }
                Section {
                    HStack {
                        Picker("Notify next dose in:", selection: $chosenHour) {
                            ForEach(hours, id: \.self) {
                                Text($0 + ($0 == "1" ? " Hr" : " Hrs"))
                            }
                        }
                        Divider()
                        Button {
                            if localNotificationManager.isGranted {
                                Task {
                                    let localNotification = LocalNotification(identifier: UUID().uuidString, title: "\(chosenHour) hour \(medicine.name) notification", body: "Time to take \(medicine.name)", timeInterval: 10, repeats: false)
                                    await localNotificationManager.schedule(localNotification: localNotification)
                                    showAlert = true
                                    alertMessage = "Your \(chosenHour) hour notification is set!"
                                }
                            } else {
                                localNotificationManager.openSettings()
                            }
                        } label: {
                            Image(systemName: localNotificationManager.isGranted ? "plus" : "bell")
                                .font(.title2)
                                .foregroundColor(.primary)
                            
                        }
                        .buttonStyle(.plain)
                    }
                    Toggle("Take every day", isOn: $takeEveryDay)
                    if takeEveryDay {
                        HStack {
                            DatePicker("Choose time", selection: $scheduleDate, displayedComponents: .hourAndMinute)
                            Divider()
                            Button {
                                Task {
                                    let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: scheduleDate)
                                    let localNotification = LocalNotification(identifier: UUID().uuidString, title: "Daily \(medicine.name) Reminder", body: "Time for the next dose", dateComponents: dateComponents, repeats: true)
                                    await localNotificationManager.schedule(localNotification: localNotification)
                                    showAlert = true
                                    alertMessage = "Your \(medicine.name) Daily Reminder notification is set!"
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                } header: {
                    Text("schedule notifications")
                        .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .navigationTitle(medicine.name)
            .alert(alertMessage, isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                pickedColor = Color(red: medicine.red, green: medicine.green, blue: medicine.blue)
                medicineName = medicine.name
            }
            .onTapGesture(count: 2) {
                keyboardFocused = false
            }
            .task {
                try? await localNotificationManager.requestAuthorization()
            }
            .onChange(of: scenePhase) { _, newValue in
                if newValue == .active {
                    Task {
                        await localNotificationManager.getCurrentSettings()
                        await localNotificationManager.getPendingRequests()
                    }
                }
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Patient.self, Dose.self, Medicine.self, configurations: config)
        let patientExample = Patient(name: "james", doctor: "who", doctorPhone: "1234567890", pharmacy: "Cvs", pharmacyPhone: "1234567890", medicines: [], doses: [])
        let medicineExample = Medicine(name: "Tylenol", red: 1, green: 0.5, blue: 0.5)
        return EditMedicineView(medicine: medicineExample, patient: patientExample)
            .modelContainer(container)
    } catch {
        fatalError()
    }
}
