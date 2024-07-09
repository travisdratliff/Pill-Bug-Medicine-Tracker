//
//  DayView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/17/24.
//

import SwiftUI
import SwiftData

struct DayView: View {
    var calendarDate: CalendarDate
    var patient: Patient
    @State private var doses = [Dose]()
    var time = Date.now
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var temp = ""
    @State private var doseAmount = ""
    var measurements = ["ml", "mg", "pill"]
    @State private var pickedMeasurement = "ml"
    @State private var pickedMedicine = ""
    @State private var medicines = [String]()
    @State private var pickedColor = Color(red: 1.0, green: 0.41, blue: 0.38)
    @FocusState private var keyboardFocused: Bool
    @State private var showAlert = false
    @State private var showDosesFullAlert = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Choose Medicine", selection: $pickedMedicine) { 
                        ForEach(medicines, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Temperature (optional)", text: $temp)
                        .keyboardType(.decimalPad)
                        .focused($keyboardFocused)
                    TextField("Dose", text: $doseAmount)
                        .keyboardType(.decimalPad)
                        .focused($keyboardFocused)
                    HStack {
                        Picker("", selection: $pickedMeasurement) {
                            ForEach(measurements, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        Divider()
                        Button {
                            if patient.doses.count == 8 {
                                showDosesFullAlert = true
                            } else if patient.medicines.count == 0 {
                                showAlert = true
                            } else {
                                for med in patient.medicines {
                                    if med.name == pickedMedicine {
                                        let date = Date.now
                                        let time = date.formatted(date: .omitted, time: .shortened)
                                        let dose = Dose(date: calendarDate.date.string(), time: time, name: pickedMedicine, temp: (temp.isReallyEmpty ? "N/A" : temp), dose: doseAmount, doseMeasurement: pickedMeasurement, red: med.red, green: med.green, blue: med.blue)
                                        patient.doses.append(dose)
                                        context.insert(dose)
                                        do {
                                            try context.save()
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                        doseAmount = ""
                                        temp = ""
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .disabled(doseAmount.isReallyEmpty)
                    }
                } header: {
                    Text("take dose")
                        .foregroundColor(.primary)
                }
                Section {
                    ForEach(patient.doses.sorted()) { dose in
                        if dose.date == calendarDate.date.string() {
                            HStack {
                                Circle()
                                    .fill(Color(red: dose.red, green: dose.green, blue: dose.blue))
                                    .frame(width: 40, height: 40)
                                VStack(alignment: .leading) {
                                    Text(dose.name)
                                        .bold()
                                    Text("\(dose.temp)°")
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(dose.time)
                                    Text("\(dose.dose) \(dose.doseMeasurement)")
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteDose)
                } header: {
                    Text("doses taken")
                        .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .navigationTitle(calendarDate.date.string())
            .onAppear {
                for medicine in patient.medicines {
                    medicines.append(medicine.name)
                }
                if patient.medicines.count == 0 {
                    pickedMedicine = ""
                } else {
                    pickedMedicine = medicines[0]
                }
            }
            .onTapGesture(count: 2) {
                keyboardFocused = false
            }
            .alert("You need to add a medicine first! Tap the pencil on \(patient.name)'s main page.", isPresented: $showAlert) {
                Button {
                    dismiss()
                } label: {
                    Text("Ok")
                }
            }
            .alert("Only 8 doses per day please.", isPresented: $showDosesFullAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    func deleteDose(at offsets: IndexSet) {
        for offset in offsets {
            let dose = patient.doses[offset]
            context.delete(dose)
            if let index = patient.doses.firstIndex(of: dose) {
                patient.doses.remove(at: index)
            }
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: Patient.self, Dose.self, Medicine.self, configurations: config)
        let patientExample = Patient(name: "james", doctor: "who", doctorPhone: "1234567890", pharmacy: "Cvs", pharmacyPhone: "1234567890", medicines: [], doses: [])
        let calendarExample = CalendarDate(day: 0, date: Date.now)
        return DayView(calendarDate: calendarExample, patient: patientExample)
            .modelContainer(container)
    } catch {
        fatalError()
    }
}
