//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

/// A content view that can make HTTP requests to the GreetingService
/// running on localhost to fetch customized greetings.
///
/// By default, it makes live network calls, but it can be provided
/// with `MockClient` to make mocked in-memory calls only, which is more
/// appropriate in previews and tests.

struct PerformJSONBackup: View {
  @State private var greeting: String = "Hello, Stranger!"
  @State private var name: String = "Stranger"
  @State private var greet: String = "Hi there"
  
  let client: any APIProtocol
  init(client: any APIProtocol) { self.client = client }
  init() {
    // By default, make live network calls.
    self.init(
      client: Client(serverURL: URL(string: "http://192.168.68.84:8080/api")!,
                     transport: URLSessionTransport())
    )
  }
}

extension PerformJSONBackup {
  var body: some View {
    VStack {
      Image(systemName: "globe").imageScale(.large)
      Text(greeting).accessibilityIdentifier("greeting-label")
      Spacer()
      Text("Enter a greeting:").fontWeight(.bold)
      TextField("Greet", text: $greet)
        .padding(.horizontal)
        .multilineTextAlignment(.center)
      Spacer()
      Text("Enter your name:").fontWeight(.bold)
      TextField("Name", text: $name)
        .padding(.horizontal)
        .multilineTextAlignment(.center)
      Spacer()
      Button("Refresh greeting") { Task { await updateGreeting() } }
    }
    .padding().buttonStyle(.borderedProminent).font(.system(size: 20))
  }
}

extension PerformJSONBackup {
  func updateGreeting() async {
    do {
      let response = try await client.getGreeting(
        query: .init(name: greet + ":" + name))
      greeting = try response.ok.body.json.message
    } catch { greeting = "Error: \(error.localizedDescription)" }
  }
}
