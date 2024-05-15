import SwiftUI

// Custom type to represent count and date
struct HistoryEntry: Codable {
    let count: Int
    let date: Date
}

struct ContentView: View {
    @State private var count = 0
    @State private var history: [HistoryEntry] = []
    @State private var isShowingHistory = false
    @State private var isSaving = false
    
    // Initialize UserDefaults
    let historyKey = "HistoryKey"
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isShowingHistory.toggle()
                }) {
                    Text("History")
                }
                .disabled(history.isEmpty)
                
                Spacer()
                
                Button(action: {
                    undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .disabled(count == 0)
            }
            
            Spacer()
            
            Text("\(count)")
                .font(.system(size: 50))
                .onTapGesture {
                    incrementCount()
                }
                .onLongPressGesture {
                    saveToHistory()
                }
        }
        .onTapGesture {
            // Tapping outside the count will also increment the count
            incrementCount()
        }

        .sheet(isPresented: $isShowingHistory) {
            HistoryView(history: history)
        }
        // Load history data when ContentView appears
        .onAppear {
            loadHistory()
        }
        // Save history data when ContentView disappears
        .onDisappear {
            saveHistory()
        }
        .background(isSaving ? Color.red : Color.black)
    }
    
    func incrementCount() {
        withAnimation {
            count += 1
        }
    }
    
    func saveToHistory() {
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {isSaving = false})
        let currentDate = Date()
        let entry = HistoryEntry(count: count, date: currentDate)
        history.append(entry)
        
        count = 0
    }
    
    func undo() {
        if count > 0 {
            count -= 1
        }
    }
    
    func saveHistory() {
        // Use UserDefaults to save history data
        if let encodedData = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedData, forKey: historyKey)
        }
    }
    
    func loadHistory() {
        // Use UserDefaults to load history data
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let loadedHistory = try? JSONDecoder().decode([HistoryEntry].self, from: data) {
            history = loadedHistory
        }
    }
}

struct HistoryView: View {
    let history: [HistoryEntry]
    
    var body: some View {
        NavigationView {
            List(history, id: \.date) { entry in
                HStack {
                    Text("Count: \(entry.count)")
                    Spacer()
                    Text(formatDate(entry.date))
                        .font(.caption)
                }
            }
            .navigationTitle("History")
        }
    }
    
    // Function to format Date nicely
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
