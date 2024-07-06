//
//  Models.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/8/24.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Patient {
    var name: String
    var doctor: String
    var doctorPhone: String
    var pharmacy: String
    var pharmacyPhone: String
    var medicines = [Medicine]()
    var doses = [Dose]()
    init(name: String, doctor: String, doctorPhone: String, pharmacy: String, pharmacyPhone: String, medicines: [Medicine] = [Medicine](), doses: [Dose] = [Dose]()) {
        self.name = name
        self.doctor = doctor
        self.doctorPhone = doctorPhone
        self.pharmacy = pharmacy
        self.pharmacyPhone = pharmacyPhone
        self.medicines = medicines
        self.doses = doses
    }
}

@Model
class Medicine {
    var name: String
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    init(name: String, red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
    }
}

@Model
class Dose: Comparable {
    static func < (lhs: Dose, rhs: Dose) -> Bool {
        lhs.time < rhs.time
    }
    var date: String
    var time: String
    var name: String
    var temp: String
    var dose: String
    var doseMeasurement: String
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    init(date: String, time: String, name: String, temp: String, dose: String, doseMeasurement: String, red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.date = date
        self.time = time
        self.name = name
        self.temp = temp
        self.dose = dose
        self.doseMeasurement = doseMeasurement
        self.red = red
        self.green = green
        self.blue = blue
    }
}

struct CalendarDate: Identifiable, Equatable {
    var id = UUID()
    var day: Int
    var date: Date
}
