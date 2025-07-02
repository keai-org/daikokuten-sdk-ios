import UIKit
import WebKit
import DeviceCheck
import CryptoKit

public class ChatButtonViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private var button: UIButton!
    private var modalView: UIView!
    private let userId: String
    private let testMode: Bool
    private let clientId: String
    private let authToken: String?
    private var currentAuthToken: String?
    private let customButton: UIButton?

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
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        print("=====> VIEW DID LOAD")
        setupButton()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("=====> VIEW DID APPEAR")
        print("=====> VIEW FRAME: \(view.frame)")
        print("=====> BUTTON FRAME AFTER APPEAR: \(button.frame)")
        
        // Verify button is properly positioned and visible
        verifyButtonSetup()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("=====> VIEW DID LAYOUT SUBVIEWS")
        print("=====> BUTTON FRAME AFTER LAYOUT: \(button.frame)")
        print("=====> VIEW SUBVIEWS COUNT: \(view.subviews.count)")
        print("=====> BUTTON IS IN SUBVIEWS: \(view.subviews.contains(button))")
    }

    private func verifyButtonSetup() {
        print("=====> VERIFYING BUTTON SETUP")
        print("=====> BUTTON TYPE: \(customButton != nil ? "CUSTOM" : "DEFAULT")")
        print("=====> BUTTON FRAME: \(button.frame)")
        print("=====> BUTTON BOUNDS: \(button.bounds)")
        print("=====> BUTTON CENTER: \(button.center)")
        print("=====> BUTTON IS HIDDEN: \(button.isHidden)")
        print("=====> BUTTON ALPHA: \(button.alpha)")
        print("=====> BUTTON IS USER INTERACTION ENABLED: \(button.isUserInteractionEnabled)")
        print("=====> BUTTON WINDOW: \(button.window?.description ?? "nil")")
        print("=====> BUTTON SUPERVIEW: \(button.superview?.description ?? "nil")")
        
        // Check if button is within view bounds
        let buttonFrameInWindow = button.convert(button.bounds, to: nil)
        print("=====> BUTTON FRAME IN WINDOW: \(buttonFrameInWindow)")
        
        // Add a visual indicator to see if button is where we expect (only for default button)
        if customButton == nil {
            button.layer.borderWidth = 2.0
            button.layer.borderColor = UIColor.red.cgColor
            print("=====> ADDED RED BORDER TO DEFAULT BUTTON FOR VISUAL DEBUGGING")
        } else {
            print("=====> CUSTOM BUTTON - NO VISUAL DEBUGGING BORDER ADDED")
        }
    }

    private func setupButton() {
        print("=====> LOADING BUTTON 1")
        
        if let customButton = customButton {
            // Use custom button provided by third party
            print("=====> USING CUSTOM BUTTON")
            button = customButton
            
            // Ensure custom button can receive touches
            button.isUserInteractionEnabled = true
            button.isMultipleTouchEnabled = false
            button.isExclusiveTouch = true
            
            // Add custom button to view hierarchy if not already added
            if button.superview == nil {
                view.addSubview(button)
                print("=====> CUSTOM BUTTON ADDED TO VIEW HIERARCHY")
            } else {
                print("=====> CUSTOM BUTTON ALREADY IN VIEW HIERARCHY")
            }
            
            // CRITICAL: Add target actions to custom button
            print("=====> ADDING ACTIONS TO CUSTOM BUTTON")
            button.addAction(UIAction(title: "Click Me", handler: { [unowned self] _ in
                print("=====> CUSTOM BUTTON CLICKED - Action triggered!")
                self.toggleModal()
            }), for: .touchUpInside)
            
        } else {
            // Use default button implementation
            print("=====> USING DEFAULT BUTTON")
            button = UIButton(type: .system)
            button.setTitle("💬", for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 24)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 25
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Ensure button can receive touches
            button.isUserInteractionEnabled = true
            button.isMultipleTouchEnabled = false
            button.isExclusiveTouch = true
            
            // Add to view hierarchy first
            view.addSubview(button)
            print("=====> LOADING BUTTON 2")
            
            // Set constraints for default button
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 50),
                button.heightAnchor.constraint(equalToConstant: 50),
                button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            ])
            print("=====> LOADING BUTTON 3")
            
            // CRITICAL: Add target actions AFTER adding to view hierarchy
            // This is the key to ensuring button clicking works properly
            print("=====> BUTTON TARGETS ADDED")
            button.addAction(UIAction(title: "Click Me", handler: { [unowned self] _ in
                print("=====> BUTTON CLICKED - Action triggered!")
                print("=====> BUTTON IN 1")
                self.toggleModal()
            }), for: .touchUpInside)
        }
        
        // Verify button is properly configured
        print("=====> BUTTON FRAME: \(button.frame)")
        print("=====> BUTTON IS USER INTERACTION ENABLED: \(button.isUserInteractionEnabled)")
        print("=====> BUTTON ALPHA: \(button.alpha)")
        print("=====> BUTTON SUPERVIEW: \(button.superview?.description ?? "nil")")
        
        // Force layout to get proper frame
        view.layoutIfNeeded()
        print("=====> BUTTON FRAME AFTER LAYOUT: \(button.frame)")
    }
    
    // Alternative method using traditional target-action (for reference)
    // @objc private func buttonTapped() {
    //     print("=====> BUTTON CLICKED - Traditional method!")
    //     toggleModal()
    // }

    func toggleModal() {
        print("=====> TOGGLE MODAL CALLED!")
        print("=====> TOGGLE MODAL - Thread: \(Thread.current)")
        print("=====> TOGGLE MODAL - Main thread: \(Thread.isMainThread)")
        print("=====> MODAL VIEW EXISTS: \(modalView != nil)")
        
        if modalView == nil {
            print("=====> SETTING UP WEBVIEW")
            setupWebView()
            print("=====> WEBVIEW SET UP")
        }
        
        let wasHidden = modalView.isHidden
        
        if wasHidden {
            // Opening modal - perform attestation and get auth token
            print("=====> OPENING MODAL")
            performAttestationAndAuth { [weak self] token in
                DispatchQueue.main.async {
                    if let token = token {
                        print("=====> Received auth token from backend: \(token)")
                        self?.currentAuthToken = token
                        self?.loadWebViewContent(token: token)
                        self?.modalView.isHidden = false
                        self?.button.isHidden = true // Hide button when modal is open
                        print("=====> BUTTON HIDDEN: \(self?.button.isHidden ?? false)")
                    } else {
                        print("=====> Failed to get auth token from backend")
                        // Fallback: show modal without auth token
                        self?.modalView.isHidden = false
                        self?.button.isHidden = true
                        print("=====> BUTTON HIDDEN (fallback): \(self?.button.isHidden ?? false)")
                    }
                }
            }
        } else {
            // Closing modal
            print("=====> CLOSING MODAL")
            modalView.isHidden = true
            button.isHidden = false // Show button when modal is closed
            print("=====> BUTTON VISIBLE: \(!button.isHidden)")
        }
        
        print("=====> MODAL VISIBILITY CHANGED FROM \(wasHidden) TO \(modalView.isHidden)")
    }

    private func setupWebView() {
        print("=====> LOADING WEBVIEW 1")
        if modalView != nil { return }
        print("=====> LOADING WEBVIEW 2")
        modalView = UIView()
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 0 // Full screen, no rounded corners (like Android)
        modalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modalView)
        print("=====> LOADING WEBVIEW 3")
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        
        // Add message handler for close button
        let contentController = WKUserContentController()
        contentController.add(self, name: "closeModal")
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(webView)
        print("=====> LOADING WEBVIEW 4")
        
        // Use full-screen modal constraints (like Android version)
        NSLayoutConstraint.activate([
            // Make modal view full screen
            modalView.topAnchor.constraint(equalTo: view.topAnchor),
            modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Make webView fill the modal view
            webView.topAnchor.constraint(equalTo: modalView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: modalView.bottomAnchor)
        ])
        print("=====> LOADING WEBVIEW 5")
        
        // Load initial HTML content with auth token (if available)
        loadWebViewContent(token: authToken)
        modalView.isHidden = true
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WKWebView error: \(error.localizedDescription)")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WKWebView: Page loaded successfully")
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("WKWebView navigation failed: \(error.localizedDescription)")
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("WKWebView authentication challenge: \(challenge.protectionSpace.host)")
        completionHandler(.performDefaultHandling, nil)
    }

    // MARK: - WKUIDelegate
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("WKWebView JavaScript Alert: \(message)")
        completionHandler()
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("WKWebView JavaScript Confirm: \(message)")
        completionHandler(true)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("WKWebView JavaScript Prompt: \(prompt)")
        completionHandler(defaultText)
    }

    // MARK: - App Attestation
    
    private func performAttestationAndAuth(completion: @escaping (String?) -> Void) {
        if #available(iOS 14.0, *) {
            // Use App Attest for iOS 14+
            performAppAttest(completion: completion)
        } else {
            // Fallback to DeviceCheck for older iOS versions
            performDeviceCheck(completion: completion)
        }
    }
    
    @available(iOS 14.0, *)
    private func performAppAttest(completion: @escaping (String?) -> Void) {
        let attestationService = DCAppAttestService.shared
        let nonce = UUID().uuidString
        
        attestationService.generateKey { [weak self] keyId, error in
            if let error = error {
                print("=====> App Attest key generation failed: \(error)")
                // Fallback to debug mode
                self?.sendAttestationToBackend(attestationToken: nil, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
                return
            }
            
            attestationService.attestKey(keyId, clientDataHash: Data()) { attestation, error in
                if let error = error {
                    print("=====> App Attest failed: \(error)")
                    // Fallback to debug mode
                    self?.sendAttestationToBackend(attestationToken: nil, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
                    return
                }
                
                // Convert attestation to base64 string
                let attestationString = attestation.base64EncodedString()
                self?.sendAttestationToBackend(attestationToken: attestationString, packageName: nil, signingCert: nil, completion: completion)
            }
        }
    }
    
    private func performDeviceCheck(completion: @escaping (String?) -> Void) {
        let device = DCDevice.current
        if device.isSupported {
            device.generateToken { [weak self] token, error in
                if let error = error {
                    print("=====> DeviceCheck failed: \(error)")
                    // Fallback to debug mode
                    self?.sendAttestationToBackend(attestationToken: nil, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
                    return
                }
                
                // Convert token to base64 string
                let tokenString = token.base64EncodedString()
                self?.sendAttestationToBackend(attestationToken: tokenString, packageName: nil, signingCert: nil, completion: completion)
            }
        } else {
            print("=====> DeviceCheck not supported")
            // Fallback to debug mode
            sendAttestationToBackend(attestationToken: nil, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
        }
    }
    
    private func sendAttestationToBackend(attestationToken: String?, packageName: String?, signingCert: String?, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://daikokuten-7c6ffc95ca37.herokuapp.com/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var json: [String: Any] = [
            "platform": "ios",
            "userId": userId,
            "clientId": clientId
        ]
        
        if let attestationToken = attestationToken {
            json["attestationToken"] = attestationToken
        }
        if let packageName = packageName {
            json["packageName"] = packageName
        }
        if let signingCert = signingCert {
            json["signingCert"] = signingCert
        }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: json)
        } catch {
            print("=====> JSON serialization failed: \(error)")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("=====> Network error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("=====> No data received")
                completion(nil)
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let token = jsonResponse["token"] as? String {
                    completion(token)
                } else {
                    print("=====> Invalid response format")
                    completion(nil)
                }
            } catch {
                print("=====> JSON parsing failed: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    private func loadWebViewContent(token: String?) {
        let escapedUserId = userId.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let escapedClientId = clientId.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let testModeStr = testMode ? "true" : "false"
        let authTokenStr = token != nil ? "\"\(token!)\"" : "null"
        
        let html = "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
                "<meta http-equiv=\"Content-Security-Policy\" content=\"default-src 'self' https://daikokuten-7c6ffc95ca37.herokuapp.com; script-src 'self' 'unsafe-inline' https://daikokuten-7c6ffc95ca37.herokuapp.com https://cdn.jsdelivr.net https://cdn.socket.io; style-src 'self' 'unsafe-inline'; connect-src 'self' https://daikokuten-7c6ffc95ca37.herokuapp.com wss://daikokuten-7c6ffc95ca37.herokuapp.com;\">" +
                "<script src=\"https://daikokuten-7c6ffc95ca37.herokuapp.com/sdk/web/index.js\" async></script>" +
                "<script src=\"https://cdn.jsdelivr.net/npm/dompurify@2.4.1/dist/purify.min.js\" async></script>" +
                "<style>" +
                "html, body {" +
                "margin: 0;" +
                "padding: 0;" +
                "width: 100%;" +
                "height: 100%;" +
                "overflow: hidden;" +
                "}" +
                "</style>" +
                "<script>" +
                "window.onload = function() {" +
                "console.log(\"WebView loaded successfully\");" +
                "function initDaikokuten() {" +
                "console.log(\"Checking for Daikokuten and DOMPurify...\");" +
                "if (typeof Daikokuten !== 'undefined' && typeof DOMPurify !== 'undefined') {" +
                "console.log(\"DAIKOKUTEN CLASS INSTANCE\");" +
                "const daikokuten = new Daikokuten(" +
                "\"\(escapedUserId)\"," +
                "\"\(escapedClientId)\"," +
                "\(testModeStr)," +
                "\"ios\"," +
                "\"pro\"," +
                "null," +
                authTokenStr +
                ");" +
                "console.log(\"DAIKOKUTEN CLASS CREATED FOR \(escapedUserId)\");" +
                "} else {" +
                "console.log(\"DAIKOKUTEN RETRYING - Daikokuten: \" + (typeof Daikokuten) + \", DOMPurify: \" + (typeof DOMPurify));" +
                "setTimeout(initDaikuten, 1000);" +
                "}" +
                "}" +
                "console.log(\"DAIKOKUTEN INITIALIZING\");" +
                "initDaikokuten();" +
                "};" +
                "</script>" +
                "</head>" +
                "<body></body>" +
                "</html>"
        
        print("ChatButtonViewController: Loading HTML with userId: \(escapedUserId), clientId: \(escapedClientId), testMode: \(testModeStr), token: \(token ?? "nil")")
        webView.loadHTMLString(html, baseURL: nil)
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "closeModal" {
            print("=====> CLOSE BUTTON CLICKED")
            toggleModal()
        }
    }
}
