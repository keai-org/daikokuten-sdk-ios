import SwiftUI
import UIKit

/// SwiftUI View component that only contains the WebView from ChatButtonViewController
/// This view renders the chat interface directly without a floating button
public struct ChatWebView: View {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    
    /// Initialize the SwiftUI ChatWebView for direct chat interface embedding
    /// - Parameters:
    ///   - userId: Unique identifier for the user (defaults to UUID)
    ///   - clientId: Client ID for your application (defaults to "your_client_id")
    ///   - testMode: Enable test mode for development (defaults to false)
    ///   - authToken: Optional authentication token (defaults to nil)
    public init(
        userId: String = UUID().uuidString,
        clientId: String = "your_client_id",
        testMode: Bool = false,
        authToken: String? = nil
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        self.authToken = authToken
    }
    
    public var body: some View {
        ChatWebViewControllerRepresentable(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped() // Ensure content doesn't overflow
    }
}

/// Internal UIViewControllerRepresentable for the ChatWebView
private struct ChatWebViewControllerRepresentable: UIViewControllerRepresentable {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    
    init(
        userId: String,
        clientId: String,
        testMode: Bool,
        authToken: String?
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        self.authToken = authToken
    }
    
    public func makeUIViewController(context: Context) -> ChatWebViewController {
        let viewController = ChatWebViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken
        )
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ChatWebViewController, context: Context) {
        // Update the view controller if needed
        // This is called when SwiftUI state changes
    }
}

/// SwiftUI View component that can be easily integrated into VStack by third-party developers
/// This view "appends" the chat functionality to any existing SwiftUI content
public struct ChatButtonView: View {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    private let customButton: UIButton?
    
    /// Initialize the SwiftUI ChatButtonView for easy integration
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
    
    public var body: some View {
        ChatButtonViewControllerRepresentable(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(true)
    }
}

/// Internal UIViewControllerRepresentable for the ChatButtonView
private struct ChatButtonViewControllerRepresentable: UIViewControllerRepresentable {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    private let customButton: UIButton?
    
    init(
        userId: String,
        clientId: String,
        testMode: Bool,
        authToken: String?,
        customButton: UIButton?
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        self.authToken = authToken
        self.customButton = customButton
    }
    
    public func makeUIViewController(context: Context) -> ChatButtonViewController {
        let viewController = ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
        
        // Ensure the view controller's view is transparent and takes full space
        viewController.view.backgroundColor = .clear
        viewController.view.isOpaque = false
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ChatButtonViewController, context: Context) {
        // Update the view controller if needed
        // This is called when SwiftUI state changes
    }
}

/// SwiftUI wrapper for ChatButtonViewController
public struct ChatButtonViewLegacy: UIViewControllerRepresentable {
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
        let viewController = ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
        
        // CRITICAL: Ensure the view controller's view takes full space
        viewController.view.backgroundColor = .clear
        return viewController
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
        let viewController = ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
        
        // CRITICAL: Ensure the view controller's view takes full space
        viewController.view.backgroundColor = .clear
        return viewController
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
        
        // CRITICAL: Ensure the view controller's view takes full space
        viewController.view.backgroundColor = .clear
        
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

/// SwiftUI wrapper that ensures proper floating button behavior
public struct FloatingChatButtonView: UIViewControllerRepresentable {
    private let userId: String
    private let clientId: String
    private let testMode: Bool
    private let authToken: String?
    private let customButton: UIButton?
    
    /// Initialize the SwiftUI FloatingChatButtonView
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
        let viewController = ChatButtonViewController(
            userId: userId,
            clientId: clientId,
            testMode: testMode,
            authToken: authToken,
            customButton: customButton
        )
        
        // CRITICAL: Ensure the view controller's view takes full space and is transparent
        viewController.view.backgroundColor = .clear
        viewController.view.isOpaque = false
        
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ChatButtonViewController, context: Context) {
        // Update the view controller if needed
        // This is called when SwiftUI state changes
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
struct ChatWebView_Previews: PreviewProvider {
    static var previews: some View {
        // Example of how third-party developers can use ChatWebView directly
        VStack {
            // Third-party app header
            Text("My App")
                .font(.title)
                .padding()
            
            // ChatWebView renders the chat interface directly
            // It will take all available height space in the VStack
            ChatWebView(
                userId: "preview_user_123",
                clientId: "preview_client",
                testMode: true
            )
            // No need to set frame height - it will fill available space automatically
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct ChatButtonView_Previews: PreviewProvider {
    static var previews: some View {
        // Example of how third-party developers can use ChatButtonView in their VStack
        VStack {
            // Third-party app content
            Text("Your App Content")
                .font(.title)
                .padding()
            
            Text("This is your app's main content")
                .font(.body)
                .padding()
            
            Spacer()
            
            // ChatButtonView "appends" the chat functionality
            // It will overlay the chat button on top of existing content
            ChatButtonView(
                userId: "preview_user_123",
                clientId: "preview_client",
                testMode: true
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

// Additional preview showing the legacy wrapper
struct ChatButtonViewLegacy_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Background content
            VStack {
                Text("Your App Content")
                    .font(.title)
                    .padding()
                
                Text("The chat button should float above this content")
                    .font(.body)
                    .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
            
            // Floating chat button - positioned to take full space
            FloatingChatButtonView(
                userId: "preview_user_123",
                clientId: "preview_client",
                testMode: true
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .allowsHitTesting(true)
        }
        .padding()
    }
}
#endif 