//
//  ContentView.swift
//  MyRecallAppClient
//
//  Created by Robert Goedman on 9/18/25.
//

import SwiftUI

struct ContentView {
  @State private var jsonFiles: [String] = []
  @State private var selection: Set<String> = []
  
  @State private var result: String = "No result yet!"
  @State private var user: String = "Test"
  @State private var content: String = testString
  
  @State private var showSettingsSheet = false
  private var remoteJson = RemoteJson()
}

extension ContentView: View {
  var body: some View {
    NavigationStack {
      List(jsonFiles, id: \.self, selection: $selection) { rstr in
        Text(String(rstr.replacingOccurrences(of: "_", with: " ")).description)
      }
      .task {
        print("Fetching JSON files...")
        (jsonFiles, result) = await remoteJson.getJSONFileNames()
        print(jsonFiles)
      }
      Spacer()
      Text("\(String(describing: remoteJson.splitJSONFileName(sel: selection)))")
      Button("Store") {
        Task { await result = remoteJson.putJson(selection: selection,
                                                 user: user)
        }
      }
      
      Text(result)
        .glassEffect(.regular.tint(.gray).interactive())
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          EditButton()
        }
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            showSettingsSheet = true
          } label: {
            Label("Settings", systemImage: "person.crop.circle")
          }
        }
      }
    }
    .padding()
    .buttonStyle(.borderedProminent)
    .font(.system(size: 20))
  }
}

#Preview {
    ContentView()
}
