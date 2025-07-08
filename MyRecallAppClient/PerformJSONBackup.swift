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
  @State private var result: String = "No result yet!"
  @State private var user: String = "Rob"
  @State private var topic: String = "BioChemistry"
  @State private var content: String = testString
  
  let client: any APIProtocol
  init(client: any APIProtocol) { self.client = client }
  init() {
    self.init(
      client: Client(serverURL: URL(string: "http://192.168.68.85:8080/api")!,
                     transport: URLSessionTransport())
    )
  }
}

extension PerformJSONBackup {
  var body: some View {
    VStack {
      Image(systemName: "globe").imageScale(.large)
      Text(result)
        .accessibilityIdentifier("result-label")
      Spacer()
      Text("Enter a topic:").fontWeight(.bold)
      TextField("Topic", text: $topic)
        .padding(.horizontal)
        .multilineTextAlignment(.center)
      Spacer()
      Text("Enter your name:").fontWeight(.bold)
      TextField("Name", text: $user)
        .padding(.horizontal)
        .multilineTextAlignment(.center)
      Spacer()
      Button("Store topic") { Task { await putJson() } }
    }
    .padding().buttonStyle(.borderedProminent).font(.system(size: 20))
  }
}

extension PerformJSONBackup {
  func putJson() async {
    do {
      let response = try await client.putJson(
        query: .init(user: user,
                     topic: topic,
                     content: testString))
      result = try response.ok.body.json.message
    } catch {
      result = "Error: \(error.localizedDescription)"
    }
  }
}

let testString = "{\"noOfRecallCycles\":0,\"subTopics\":[{\"timeStamps\":[{\"date\":\"2025-02-12T19:38:05Z\"}],\"lastRecallCycle\":\"2025-02-12T19:38:05Z\",\"title\":\"Crisper\",\"questions\":[],\"links\":[],\"includedInRecall\":true,\"noOfRecallCycles\":0},{\"timeStamps\":[{\"date\":\"2025-02-13T14:49:42Z\"}],\"lastRecallCycle\":\"2025-02-13T14:49:42Z\",\"title\":\"Gene therapy\",\"questions\":[],\"links\":[],\"includedInRecall\":true,\"noOfRecallCycles\":0},{\"lastRecallCycle\":\"2025-02-12T19:37:54Z\",\"includedInRecall\":true,\"questions\":[],\"timeStamps\":[{\"date\":\"2025-02-12T19:37:54Z\"}],\"links\":[],\"noOfRecallCycles\":0,\"title\":\"RNA\"},{\"questions\":[{\"noOfRecallCycles\":0,\"lastRecallCycle\":\"2025-02-14T23:27:10Z\",\"title\":\"What is a chromosome?\",\"userAnswer\":\"\",\"answer\":\"A …\",\"links\":[],\"timeStamps\":[{\"date\":\"2025-02-14T23:27:10Z\"}],\"includedInRecall\":true}],\"links\":[],\"title\":\"DNA\",\"noOfRecallCycles\":0,\"timeStamps\":[{\"date\":\"2025-02-12T19:38:13Z\"}],\"includedInRecall\":true,\"lastRecallCycle\":\"2025-02-12T19:38:13Z\"}],\"lastRecallCycle\":\"2025-02-11T21:29:02Z\",\"title\":\"Biochemistry\",\"includedInRecall\":true}"

