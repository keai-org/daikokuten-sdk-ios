import SwiftUI
import UIKit

/// SwiftUI wrapper for ChatButtonViewController
public struct ChatButtonView: UIViewControllerRepresentable {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    private let customButton: UIButton?
    
    /// Initialize the SwiftUI ChatButtonView
    /// - Parameters:
    ///   - userId: Unique identifier for the user (defaults to UUID)
    ///   - clientId: Client ID for your application (defaults to "your_client_id")
    ///   - testMode: Enable test mode for development (defaults to false)
    ///   - authToken: Optional authentication token (defaults to nil)
    ///   - customButton: Optional custom UIButton to use instead of the default one (defaults to nil)
    public init(
        userId: String = UUID().uuidString,
        clientId: String = "your_client_id",
        testMode: Bool = false,
        authToken: String? = nil,
        customButton: UIButton? = nil
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        self.authToken = authToken
        self.customButton = customButton
    }
    
    public func makeUIViewController(context: Context) -> ChatButtonViewController {
        return ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
    }
    
    public func updateUIViewController(_ uiViewController: ChatButtonViewController, context: Context) {
        // Update the view controller if needed
        // This is called when SwiftUI state changes
    }
}

/// SwiftUI wrapper for ChatButtonViewController with custom button support
public struct ChatButtonViewWithCustomButton: UIViewControllerRepresentable {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    private let customButtonBuilder: () -> UIButton
    
    /// Initialize the SwiftUI ChatButtonView with a custom button builder
    /// - Parameters:
    ///   - userId: Unique identifier for the user (defaults to UUID)
    ///   - clientId: Client ID for your application (defaults to "your_client_id")
    ///   - testMode: Enable test mode for development (defaults to false)
    ///   - authToken: Optional authentication token (defaults to nil)
    ///   - customButtonBuilder: Closure that creates and returns a custom UIButton
    public init(
        userId: String = UUID().uuidString,
        clientId: String = "your_client_id",
        testMode: Bool = false,
        authToken: String? = nil,
        customButtonBuilder: @escaping () -> UIButton
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        self.authToken = authToken
        self.customButtonBuilder = customButtonBuilder
    }
    
    public func makeUIViewController(context: Context) -> ChatButtonViewController {
        let customButton = customButtonBuilder()
        return ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
    }
    
    public func updateUIViewController(_ uiViewController: ChatButtonViewController, context: Context) {
        // Update the view controller if needed
        // This is called when SwiftUI state changes
    }
}

/// SwiftUI wrapper for ChatButtonViewController with coordinator for callbacks
public struct ChatButtonViewWithCoordinator: UIViewControllerRepresentable {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    private let customButton: UIButton?
    private let onModalOpened: (() -> Void)?
    private let onModalClosed: (() -> Void)?
    
    /// Initialize the SwiftUI ChatButtonView with coordinator for callbacks
    /// - Parameters:
    ///   - userId: Unique identifier for the user (defaults to UUID)
    ///   - clientId: Client ID for your application (defaults to "your_client_id")
    ///   - testMode: Enable test mode for development (defaults to false)
    ///   - authToken: Optional authentication token (defaults to nil)
    ///   - customButton: Optional custom UIButton to use instead of the default one (defaults to nil)
    ///   - onModalOpened: Optional callback when modal is opened
    ///   - onModalClosed: Optional callback when modal is closed
    public init(
        userId: String = UUID().uuidString,
        clientId: String = "your_client_id",
        testMode: Bool = false,
        authToken: String? = nil,
        customButton: UIButton? = nil,
        onModalOpened: (() -> Void)? = nil,
        onModalClosed: (() -> Void)? = nil
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        self.authToken = authToken
        self.customButton = customButton
        self.onModalOpened = onModalOpened
        self.onModalClosed = onModalClosed
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onModalOpened: onModalOpened, onModalClosed: onModalClosed)
    }
    
    public func makeUIViewController(context: Context) -> ChatButtonViewController {
        let viewController = ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
        
        // Set the coordinator to handle callbacks
        context.coordinator.viewController = viewController
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ChatButtonViewController, context: Context) {
        // Update the view controller if needed
        // This is called when SwiftUI state changes
    }
    
    public class Coordinator: NSObject {
        private let onModalOpened: (() -> Void)?
        private let onModalClosed: (() -> Void)?
        weak var viewController: ChatButtonViewController?
        
        init(onModalOpened: (() -> Void)?, onModalClosed: (() -> Void)?) {
            self.onModalOpened = onModalOpened
            self.onModalClosed = onModalClosed
        }
        
        func modalOpened() {
            onModalOpened?()
        }
        
        func modalClosed() {
            onModalClosed?()
        }
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
struct ChatButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Chat Button Demo")
                .font(.title)
                .padding()
            
            // Default chat button
            ChatButtonView(
                userId: "preview_user_123",
                clientId: "preview_client",
                testMode: true
            )
            .frame(height: 100)
            
            // Custom chat button
            ChatButtonViewWithCustomButton(
                userId: "preview_user_456",
                clientId: "preview_client",
                testMode: true
            ) {
                let button = UIButton(type: .system)
                button.setTitle("💬 Custom Chat", for: .normal)
                button.setTitleColor(.white, for: .normal)
                button.backgroundColor = .systemPurple
                button.layer.cornerRadius = 20
                button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
                return button
            }
            .frame(height: 100)
            
            // Chat button with callbacks
            ChatButtonViewWithCoordinator(
                userId: "preview_user_789",
                clientId: "preview_client",
                testMode: true,
                onModalOpened: {
                    print("Modal opened!")
                },
                onModalClosed: {
                    print("Modal closed!")
                }
            )
            .frame(height: 100)
        }
        .padding()
    }
}
#endif 