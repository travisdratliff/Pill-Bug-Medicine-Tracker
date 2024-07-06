//
//  Models.swift
//  Project 17
//
//  Created by Travis Domenic Ratliff on 6/8/24.
//

import Foundation
import SwiftData
import SwiftUI
import NotificationCenter
import Observation

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
    var takeEveryDay: Bool? // this is new property, delete if not ok
    init(name: String, red: CGFloat, green: CGFloat, blue: CGFloat, takeEveryDay: Bool? = nil) {
        self.name = name
        self.red = red
        self.green = green
        self.blue = blue
        self.takeEveryDay = takeEveryDay
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

@Observable class LocalNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    let notificationCenter = UNUserNotificationCenter.current()
    var isGranted = false
    var pendingRequests = [UNNotificationRequest]()
    override init () {
        super.init()
        notificationCenter.delegate = self
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await getPendingRequests()
        return [.sound, .banner]
    }
    func requestAuthorization() async throws {
        try await notificationCenter.requestAuthorization(options: [.sound, .badge, .alert])
        await getCurrentSettings()
    }
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        isGranted = (currentSettings.authorizationStatus == .authorized)
        print(isGranted)
    }
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    func schedule(localNotification: LocalNotification) async {
        let content = UNMutableNotificationContent()
        content.title = localNotification.title
        content.body = localNotification.body
        content.sound = .default
        if localNotification.scheduleType == .time {
            guard let timeInterval = localNotification.timeInterval else { return }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: localNotification.repeats)
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
            try? await notificationCenter.add(request)
        } else {
            guard let dateComponents = localNotification.dateComponents else { return }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: localNotification.repeats)
            let request = UNNotificationRequest(identifier: localNotification.identifier, content: content, trigger: trigger)
            try? await notificationCenter.add(request)
        }
        await getPendingRequests()
    }
    func getPendingRequests() async {
        pendingRequests = await notificationCenter.pendingNotificationRequests()
        print("Pending: \(pendingRequests.count)")
    }
    func removeRequest(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        if let index = pendingRequests.firstIndex(where: {$0.identifier == identifier}) {
            pendingRequests.remove(at: index)
        }
    }
    func clearRequests() {
        notificationCenter.removeAllPendingNotificationRequests()
        pendingRequests.removeAll()
    }
}

struct LocalNotification {
    internal init(identifier: String, title: String, body: String, timeInterval: Double, repeats: Bool) {
        self.identifier = identifier
        self.scheduleType = .time
        self.title = title
        self.body = body
        self.timeInterval = timeInterval
        self.dateComponents = nil
        self.repeats = repeats
    }
    internal init(identifier: String, title: String, body: String, dateComponents: DateComponents, repeats: Bool) {
        self.identifier = identifier
        self.scheduleType = .calendar
        self.title = title
        self.body = body
        self.timeInterval = nil
        self.dateComponents = dateComponents
        self.repeats = repeats
    }
    enum ScheduleType {
        case time, calendar
    }
    var identifier: String
    var scheduleType: ScheduleType
    var title: String
    var body: String
    var timeInterval: Double?
    var dateComponents: DateComponents?
    var repeats: Bool
    
}

struct CalendarDate: Identifiable, Equatable {
    var id = UUID()
    var day: Int
    var date: Date
}
