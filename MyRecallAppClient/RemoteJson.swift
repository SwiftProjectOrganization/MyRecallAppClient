import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct RemoteJson {
  let client: any APIProtocol
  init(client: any APIProtocol) { self.client = client }
  init() {
    self.init(
      client: Client(serverURL: URL(string: "http://Rob-Work-M3.local:8080/api")!,
                     transport: URLSessionTransport())
    )
  }
}

extension RemoteJson {
  func splitJSONFileName(sel: Set<String>) -> String {
    let topic: String
    if sel.first != nil {
      topic = String(describing: sel.first!.split(separator: ".").first!)
    } else {
      topic = "No file selected"
    }
    return topic
  }
}

extension RemoteJson {
  func putJson(selection: Set<String>,
               user: String) async -> String {
    do {
      let response = try await client.putJson(
        query: .init(user: user,
                     topic: splitJSONFileName(sel: selection),
                     content: testString))
      return try response.ok.body.json.message
    } catch {
      return "Returned error: \(error.localizedDescription)"
    }
  }
}

extension RemoteJson {
  func getJSONFileNames() async -> ([String], String) {
    var jsonFiles: [String] = []
    var result: String = "No result yet!"
    print("In getJSONFileNames")
    do {
      let response = try await client.listTopics(
        query: .init(user: "Rob"))
      result = try response.ok.body.json.message
      jsonFiles = splitJSONFileNames(str: result)
      print(jsonFiles)
      return (jsonFiles, result)
    } catch {
      result = "Error: \(error.localizedDescription)"
      print(result)
      return ([], result)
    }
  }
}

extension RemoteJson {
  func splitJSONFileNames(str: String) -> [String] {
    var cleanedString = str
    cleanedString.remove(at: cleanedString.startIndex)
    cleanedString.remove(at: cleanedString.index(before: cleanedString.endIndex))
    let splitSubString = cleanedString.split(separator: ",")
    var splitString: [String] = []
    for subString in splitSubString {
      var sString = subString.trimmingCharacters(in: .whitespacesAndNewlines)
      sString.remove(at: sString.startIndex)
      sString.remove(at: sString.index(before: sString.endIndex))
      splitString.append(String(sString))
    }
    return splitString.filter { $0.hasSuffix(".json") }.map { $0 }
  }
}


let testString = "{\"noOfRecallCycles\":0,\"subTopics\":[{\"timeStamps\":[{\"date\":\"2025-02-12T19:38:05Z\"}],\"lastRecallCycle\":\"2025-02-12T19:38:05Z\",\"title\":\"Crisper\",\"questions\":[],\"links\":[],\"includedInRecall\":true,\"noOfRecallCycles\":0},{\"timeStamps\":[{\"date\":\"2025-02-13T14:49:42Z\"}],\"lastRecallCycle\":\"2025-02-13T14:49:42Z\",\"title\":\"Gene therapy\",\"questions\":[],\"links\":[],\"includedInRecall\":true,\"noOfRecallCycles\":0},{\"lastRecallCycle\":\"2025-02-12T19:37:54Z\",\"includedInRecall\":true,\"questions\":[],\"timeStamps\":[{\"date\":\"2025-02-12T19:37:54Z\"}],\"links\":[],\"noOfRecallCycles\":0,\"title\":\"RNA\"},{\"questions\":[{\"noOfRecallCycles\":0,\"lastRecallCycle\":\"2025-02-14T23:27:10Z\",\"title\":\"What is a chromosome?\",\"userAnswer\":\"\",\"answer\":\"A …\",\"links\":[],\"timeStamps\":[{\"date\":\"2025-02-14T23:27:10Z\"}],\"includedInRecall\":true}],\"links\":[],\"title\":\"DNA\",\"noOfRecallCycles\":0,\"timeStamps\":[{\"date\":\"2025-02-12T19:38:13Z\"}],\"includedInRecall\":true,\"lastRecallCycle\":\"2025-02-12T19:38:13Z\"}],\"lastRecallCycle\":\"2025-02-11T21:29:02Z\",\"title\":\"Biochemistry\",\"includedInRecall\":true}"
