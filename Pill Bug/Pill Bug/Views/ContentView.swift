//
//  ContentView.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/3/24.
//

import SwiftUI
import SwiftData 
import UserNotifications

struct ContentView: View {
    @Query var patients: [Patient]
    @Environment(\.modelContext) var context
    @State private var showAddPatient = false
    @State private var showPatientView: Patient? = nil
    @State private var noPatients = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(patients) { patient in
                        NavigationLink(value: patient) {
                            Text(patient.name)
                        }
                    }
                    .onDelete(perform: deletePatient)
                } header: {
                    Text("patients")
                        .foregroundColor(.primary)
                }
            }
            .navigationDestination(for: Patient.self) { patient in
                PatientView(patient: patient)
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.53, green: 0.81, blue: 0.92))
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { 
                    Text("Pill Bug")
                        .font(.custom("ConcertOne-Regular", size: 35))
                        .foregroundColor(.primary)
                        .background {
                            Image("AntennaeLeft")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17)
                                .offset(x: 46, y: -7)
                            Image("AntennaeRight")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17)
                                .offset(x: 53, y: -7)
                        }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPatient.toggle()
                    } label: {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.title)
                            .foregroundColor(.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddPatient) {
                AddPatientView()
            }
        }
        .tint(.primary)
        .onAppear {
            if patients.count == 0 {
                noPatients = true
            }
        }
    }
    func deletePatient(at offsets: IndexSet) {
        for offset in offsets {
            let patient = patients[offset]
            context.delete(patient) 
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Patient.self, Dose.self, Medicine.self])
}
