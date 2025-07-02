import UIKit
import daikokuten

/**
 * Comprehensive Example: ChatButtonViewController Integration
 * 
 * This example demonstrates the proper setup to guarantee the chat button
 * is clickable and functional. Follow these steps carefully to ensure
 * the button responds to user interactions.
 */
class ExampleViewController: UIViewController {
    
    // MARK: - Properties
    private var chatViewController: ChatButtonViewController!
    private var isChatButtonSetup = false
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ExampleViewController: viewDidLoad called")
        setupUI()
        setupChatButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ExampleViewController: viewWillAppear called")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ExampleViewController: viewDidAppear called")
        
        // Ensure chat button is properly positioned after view appears
        if isChatButtonSetup {
            verifyChatButtonSetup()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("ExampleViewController: viewDidLayoutSubviews called")
        
        // Force layout to ensure button constraints are applied
        if isChatButtonSetup {
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add a label to show the example is working
        let label = UILabel()
        label.text = "Chat Button Example"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupChatButton() {
        print("ExampleViewController: Setting up chat button...")
        
        // Create chat button view controller with proper configuration
        chatViewController = ChatButtonViewController(
            userId: "example_user_\(UUID().uuidString)", // Unique user ID
            clientId: "example_client_id",
            testMode: true, // Enable debug mode to see logs
            authToken: nil
        )
        
        // CRITICAL: Add as child view controller for proper lifecycle management
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        chatViewController.didMove(toParent: self)
        
        // CRITICAL: Set up constraints to ensure the chat view controller fills the parent view
        chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            chatViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Force immediate layout to ensure button is positioned correctly
        view.layoutIfNeeded()
        
        isChatButtonSetup = true
        print("ExampleViewController: Chat button setup completed")
    }
    
    // MARK: - Verification Methods
    
    private func verifyChatButtonSetup() {
        print("ExampleViewController: Verifying chat button setup...")
        
        // Check if chat view controller is properly added
        guard let chatView = chatViewController.view else {
            print("❌ ERROR: Chat view controller view is nil")
            return
        }
        
        // Check if chat view is in the view hierarchy
        guard chatView.superview != nil else {
            print("❌ ERROR: Chat view is not in view hierarchy")
            return
        }
        
        // Check if chat view is visible
        guard !chatView.isHidden else {
            print("❌ ERROR: Chat view is hidden")
            return
        }
        
        // Check if chat view has proper frame
        guard chatView.frame.width > 0 && chatView.frame.height > 0 else {
            print("❌ ERROR: Chat view has zero frame: \(chatView.frame)")
            return
        }
        
        print("✅ Chat button setup verification passed")
        print("   - Chat view frame: \(chatView.frame)")
        print("   - Chat view is hidden: \(chatView.isHidden)")
        print("   - Chat view alpha: \(chatView.alpha)")
        print("   - Chat view user interaction enabled: \(chatView.isUserInteractionEnabled)")
    }
    
    // MARK: - Context API Example
    
    /**
     * Example of using the Context API to send user interest
     * Call this method when user shows interest in an event
     */
    private func sendUserInterest() {
        let userId = "example_user_123"
        let eventId = "event_456"
        
        // Send interest action
        Daikokuten.context(userId: userId, eventId: eventId, action: "interest")
        print("ExampleViewController: Sent interest action for user \(userId), event \(eventId)")
        
        // Send subscribe action (for betting or detailed info)
        Daikokuten.context(userId: userId, eventId: eventId, action: "subscribe")
        print("ExampleViewController: Sent subscribe action for user \(userId), event \(eventId)")
    }
}

// MARK: - Alternative Implementation (Minimal Setup)

/**
 * Minimal implementation for simple use cases
 * Use this if you want the most basic setup
 */
class MinimalExampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create and add chat button view controller
        let chatView = ChatButtonViewController(
            userId: "minimal_user_123",
            testMode: true
        )
        
        // Add as child view controller (IMPORTANT!)
        addChild(chatView)
        view.addSubview(chatView.view)
        chatView.didMove(toParent: self)
        
        // Set up basic constraints
        chatView.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatView.view.topAnchor.constraint(equalTo: view.topAnchor),
            chatView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - Troubleshooting Helper

/**
 * Helper class to diagnose common issues
 */
class ChatButtonTroubleshooter {
    
    static func diagnoseIssues(in viewController: UIViewController) {
        print("🔍 Chat Button Troubleshooting Report")
        print("=====================================")
        
        // Check view controller hierarchy
        if viewController.children.isEmpty {
            print("❌ No child view controllers found")
        } else {
            print("✅ Found \(viewController.children.count) child view controller(s)")
        }
        
        // Check for ChatButtonViewController
        let chatControllers = viewController.children.compactMap { $0 as? ChatButtonViewController }
        if chatControllers.isEmpty {
            print("❌ No ChatButtonViewController found in children")
        } else {
            print("✅ Found \(chatControllers.count) ChatButtonViewController(s)")
            
            for (index, chatController) in chatControllers.enumerated() {
                print("   ChatController \(index + 1):")
                print("   - View frame: \(chatController.view.frame)")
                print("   - View is hidden: \(chatController.view.isHidden)")
                print("   - View alpha: \(chatController.view.alpha)")
                print("   - View user interaction enabled: \(chatController.view.isUserInteractionEnabled)")
            }
        }
        
        // Check view hierarchy
        print("📱 View hierarchy check:")
        print("   - Main view frame: \(viewController.view.frame)")
        print("   - Main view is hidden: \(viewController.view.isHidden)")
        print("   - Main view alpha: \(viewController.view.alpha)")
        print("   - Main view user interaction enabled: \(viewController.view.isUserInteractionEnabled)")
        
        print("=====================================")
    }
}

// MARK: - Usage Instructions

/*
 * HOW TO USE THIS EXAMPLE:
 * 
 * 1. Copy the ExampleViewController class into your project
 * 2. Present it modally or push it in your navigation stack
 * 3. The chat button should appear in the bottom-right corner
 * 4. Tap the button to open the chat modal
 * 
 * TROUBLESHOOTING:
 * 
 * If the button doesn't respond to touches:
 * 1. Ensure you're using the child view controller pattern
 * 2. Check that constraints are set up properly
 * 3. Verify the view lifecycle methods are called
 * 4. Enable testMode to see debug logs
 * 5. Use ChatButtonTroubleshooter.diagnoseIssues() to check setup
 * 
 * COMMON MISTAKES TO AVOID:
 * 
 * ❌ Don't just add the view without using addChild()
 * ❌ Don't forget to call didMove(toParent:)
 * ❌ Don't set up constraints before adding to view hierarchy
 * ❌ Don't forget to call layoutIfNeeded() after setting constraints
 * ❌ Don't hide the parent view controller's view
 */ 