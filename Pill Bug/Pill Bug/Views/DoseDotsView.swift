//
//  DoseDotsView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/25/24.
//

import SwiftUI
import SwiftData

struct DoseDotsView: View {
    var patient: Patient
    var value: CalendarDate
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(0.35)), count: 4), spacing: 2) {
            ForEach(patient.doses) { dose in
                if dose.date == value.date.string() {
                    Circle()
                        .frame(width: 5, height: 5)
                        .foregroundColor(Color(red: dose.red, green: dose.green, blue: dose.blue))
                }
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Patient.self, Dose.self, Medicine.self,  configurations: config)
        let patientExample = Patient(name: "james", doctor: "who", doctorPhone: "1234567890", pharmacy: "Cvs", pharmacyPhone: "1234567890", medicines: [], doses: [])
        let valueExample = CalendarDate(day: 0, date: Date.now)
        return DoseDotsView(patient: patientExample, value: valueExample)
            .modelContainer(container)
    } catch {
        fatalError()
    }
}
