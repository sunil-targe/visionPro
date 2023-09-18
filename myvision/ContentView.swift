//
//  ContentView.swift
//  myvision
//
//  Created by Sunil Targe on 2023/6/25.
//

import SwiftUI

struct ContentView: View {    
    @State private var followers: [Follower] = []
    @State private var userText = ""
    
    let gridLayout = [GridItem(.flexible()),
                      GridItem(.flexible()),
                      GridItem(.flexible()),
                      GridItem(.flexible())]
    
    
    var body: some View {
        NavigationSplitView {
            VStack {
                TextField("Enter user", text: $userText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: userText) { oldValue, newValue in
                        Task {
                                do {
                                    followers = try await getFollowers(newValue)
                                } catch {
                                    debugPrint("unexpected error")
                                }
                            }
                    }
                Spacer()
            }.padding()
            .navigationTitle("Github")
            } detail: {
                ScrollView {
                    LazyVGrid(columns: gridLayout, spacing: 20) {
                        ForEach(followers, id: \.self) { follower in
                            AsyncImage(url: URL(string: follower.avatarUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
    //                                .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Followers")
                .padding()
                .task {
                    do {
                        followers = try await getFollowers()
                    } catch GHError.invalidURL {
                        debugPrint("invalid URLs")
                    } catch GHError.invalidResponse {
                        debugPrint("invalid response")
                    } catch GHError.invalidData {
                        debugPrint("invalid data")
                    } catch {
                        debugPrint("unexpected error")
                    }
                }
            }
        
    }
        
    func getFollowers(_ user: String = "steve") async throws -> [Follower] {
        let endpoint = "https://api.github.com/users/\(user)/followers"
        
        guard let url = URL(string: endpoint) else {
            throw GHError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([Follower].self, from: data)
        } catch {
            throw GHError.invalidData
        }
        
    }
}

#Preview {
    ContentView()
}


// rebase test
