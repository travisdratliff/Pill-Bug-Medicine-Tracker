//
//  SettingsView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/24/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    var patient: Patient
    @Environment(\.modelContext) var context
    @State private var pickedColor = Color(red: 1.0, green: 0.41, blue: 0.38)
    @State private var showAlert = false
    @FocusState private var keyboardFocused: Bool
    @State private var patientName = ""
    @State private var doctorName = ""
    @State private var doctorPhone = ""
    @State private var pharmacy = ""
    @State private var pharmacyPhone = ""
    private var isEditPatientValid: Bool {
        !patientName.isReallyEmpty && !doctorName.isReallyEmpty && !(doctorPhone.count != 10) && !pharmacy.isReallyEmpty && !(pharmacyPhone.count != 10)
    }
    @State private var medicineName = ""
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ColorPicker("Choose Medicine Color", selection: $pickedColor)
                    HStack {
                        TextField("Medicine Name", text: $medicineName)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            let color = pickedColor.convertedToCGFloat()
                            let red = color[0]
                            let green = color[1]
                            let blue = color[2]
                            let medicine = Medicine(name: medicineName.trimmingCharacters(in: .whitespacesAndNewlines), red: red, green: green, blue: blue)
                            patient.medicines.append(medicine)
                            context.insert(medicine)
                            medicineName = ""
                            do {
                                try context.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(medicineName.isReallyEmpty ? .secondary : .primary)
                        }
                        .disabled(medicineName.isReallyEmpty)
                    }
                } header: {
                    Text("add new medicine")
                        .foregroundColor(.primary)
                }
                Section {
                    HStack {
                        TextField("Patient Name", text: $patientName)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            patient.name = patientName
                            patientName = ""
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                        }
                        .disabled(patientName.isReallyEmpty)
                    }
                    HStack {
                        TextField("Doctor Name", text: $doctorName)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            patient.doctor = doctorName
                            doctorName = ""
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                        }
                        .disabled(doctorName.isReallyEmpty)
                    }
                    HStack {
                        TextField("Doctor 10 Digit Phone ", text: $doctorPhone)
                            .keyboardType(.decimalPad)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            patient.doctorPhone = doctorPhone
                            doctorPhone = ""
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                        }
                        .disabled(doctorPhone.isReallyEmpty)
                    }
                    HStack {
                        TextField("Pharmacy", text: $pharmacy)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            patient.pharmacy = pharmacy
                            pharmacy = ""
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                        }
                        .disabled(pharmacy.isReallyEmpty)
                    }
                    HStack {
                        TextField("Pharmacy 10 Digit Phone", text: $pharmacyPhone)
                            .keyboardType(.decimalPad)
                            .focused($keyboardFocused)
                        Divider()
                        Button {
                            patient.pharmacyPhone = pharmacyPhone
                            pharmacyPhone = ""
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.title2)
                        }
                        .disabled(pharmacyPhone.isReallyEmpty)
                    }
                } header: {
                    Text("edit patient details")
                        .foregroundColor(.primary)
                }
            }
            .onTapGesture(count: 2) {
                keyboardFocused = false
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .navigationTitle("Add / Edit")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Patient.self, Dose.self, Medicine.self,  configurations: config)
        let patientExample = Patient(name: "james", doctor: "who", doctorPhone: "1234567890", pharmacy: "Cvs", pharmacyPhone: "1234567890", medicines: [], doses: [])
        return SettingsView(patient: patientExample)
            .modelContainer(container)
    } catch {
        fatalError()
    }
}
