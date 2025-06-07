//
//  MainTabView.swift
//  DreamAI
//
//  Created by Shaxzod on 19/04/25
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DreamListView()
                .tabItem {
                    Label("Dreams", systemImage: "moon.stars.fill")
                }
                .tag(0)
            
            NewDreamView()
                .tabItem {
                    Label("New Dream", systemImage: "plus.circle.fill")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

struct DreamListView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Your Dreams")
                    .font(.largeTitle.bold())
                    .padding()
                
                Spacer()
                
                Text("No dreams recorded yet")
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Dreams")
        }
    }
}

struct NewDreamView: View {
    @State private var dreamText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $dreamText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding()
                
                Button(action: {
                    // Save dream
                }) {
                    Text("Save Dream")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("New Dream")
        }
    }
}

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                if let user = authManager.user {
                    VStack(spacing: 20) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.purple)
                        
                        Text(user.email ?? "No email")
                            .font(.title2)
                        
                        Button(action: {
                            Task {
                                try? await authManager.signOut()
                            }
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                } else {
                    Text("Not signed in")
                        .font(.title)
                }
                
                Spacer()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    MainTabView()
        .preferredColorScheme(.dark)
} 