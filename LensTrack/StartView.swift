import SwiftUI

struct StartView: View {
    @StateObject private var lensData = LensData()
    @State private var isStarted = false
    @State private var newStart = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "eye.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)
                
                Text("LensTrack")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Start Button
                Button(action: {
                    isStarted = true
                }) {
                    Text("Start")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(lensData.isSetupComplete ? Color.blue : Color.gray)
                        .cornerRadius(10)
                }
                .disabled(!lensData.isSetupComplete)

                
                // New Lens Button
                Button(action: {
                    newStart = true
                }) {
                    Text("Set Up Lens")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding()
            .navigationDestination(isPresented: $isStarted) {
                ContentView(lensData: lensData)
            }
            .navigationDestination(isPresented: $newStart) {
                SettingsView(lensData: lensData)
            }
        }
    }
}

#Preview {
    StartView()
} 
