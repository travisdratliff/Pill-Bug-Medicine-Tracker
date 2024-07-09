//
//  SwiftUIView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/8/24.
//

import SwiftUI
import SwiftData

struct AddPatientView: View {
    @State private var patientName = ""
    @State private var doctorName = ""
    @State private var doctorPhone = ""
    @State private var pharmacy = ""
    @State private var pharmacyPhone = ""
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var context
    private var isValid: Bool {
        !patientName.isReallyEmpty && !doctorName.isReallyEmpty && !(doctorPhone.count != 10) && !pharmacy.isReallyEmpty && !(pharmacyPhone.count != 10)
    }
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Patient Name", text: $patientName)
                    TextField("Doctor Name", text: $doctorName)
                    TextField("Doctor 10 Digit Phone ", text: $doctorPhone)
                        .keyboardType(.decimalPad)
                    TextField("Pharmacy", text: $pharmacy)
                    HStack {
                        TextField("Pharmacy 10 Digit Phone", text: $pharmacyPhone)
                            .keyboardType(.decimalPad)
                        Divider()
                        Button {
                            context.insert(Patient(name: patientName.trimmingCharacters(in: .whitespacesAndNewlines), doctor: doctorName.trimmingCharacters(in: .whitespacesAndNewlines), doctorPhone: doctorPhone.trimmingCharacters(in: .whitespacesAndNewlines), pharmacy: pharmacy.trimmingCharacters(in: .whitespacesAndNewlines), pharmacyPhone: pharmacyPhone.trimmingCharacters(in: .whitespacesAndNewlines)))
                            do {
                                try context.save()
                            } catch {
                                print(error.localizedDescription)
                            }
                            dismiss()
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(isValid ? .primary : .secondary)
                        }
                        .disabled(!isValid)
                    }
                } header: {
                    Text("patient details")
                        .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .navigationTitle("Add Patient")
        }
    }
}

#Preview {
    AddPatientView()
        .modelContainer(for: [Patient.self, Dose.self, Medicine.self]) 
}
