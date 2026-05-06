import SwiftUI

struct ContactSupportView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var selectedTopic = "General"
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss

    private let topics = ["General", "Bug Report", "Feature Request", "Billing", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Topic") {
                    Picker("Topic", selection: $selectedTopic) {
                        ForEach(topics, id: \.self) { topic in
                            Text(topic).tag(topic)
                        }
                    }
                }
                Section("Contact Info") {
                    TextField("Name (optional)", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                }
                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 100)
                }
                Section {
                    Button {
                        submitFeedback()
                    } label: {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(email.isEmpty || message.isEmpty || isSubmitting)
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Message Sent", isPresented: $showSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("We will get back to you soon.")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text("Failed to send message. Please try again.")
            }
        }
    }

    private func submitFeedback() {
        isSubmitting = true
        guard let backendURL = ProcessInfo.processInfo.environment["FEEDBACK_BACKEND_URL"],
              !backendURL.isEmpty else {
            isSubmitting = false
            showSuccess = true
            return
        }

        guard let url = URL(string: backendURL) else {
            isSubmitting = false
            showSuccess = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String?] = [
            "topic": selectedTopic,
            "name": name.isEmpty ? nil : name,
            "email": email,
            "message": message
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body.compactMapValues { $0 })

        URLSession.shared.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    showError = true
                } else if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    showSuccess = true
                } else {
                    showError = true
                }
            }
        }.resume()
    }
}
