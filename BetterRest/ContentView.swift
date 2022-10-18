//
//  ContentView.swift
//  BetterRest
//
//  Created by DJ on 9/7/22.
//
import CoreML
import SwiftUI

struct Blue: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.purple)
            .padding(.vertical, 10)
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(Blue())
    }
}
struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeCups = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var alertShowing = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.hour = 0
        return Calendar.current.date(from:components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("When do you want to wake up?")
                            .titleStyle()
                        DatePicker("Please enter a time:", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                Section {
                        VStack(alignment: .leading, spacing: 0) {
                        Text("How long do you want to sleep?")
                            .titleStyle()
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                    }
                }
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("How much coffee do you drink?")
                            .titleStyle()
                        Stepper(coffeeCups == 1 ? "\(coffeeCups) Cup": "\(coffeeCups) Cups", value: $coffeeCups, in: 1...15)
                    }
                }
                Section {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Your bedtime should be:")
                            .titleStyle()
                        Text(alertMessage)
                    }
                }
            }
            .navigationTitle("Better Rest")
           
            .toolbar {
                Button("Calculate", action: calculateBedtime)
            }
            .alert(alertTitle, isPresented: $alertShowing) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeCups))
            
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime. You must stay up forever"
        }
        alertShowing = true
    }
  // Challenge: "Change the user interface so that it always shows their recommended bedtime using a nice and large font. You should be able to remove the “Calculate” button entirely."
    // attempt
    //var beddy: String {
    //    calculateBedtime()
    //    return alertMessage
    //}
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
