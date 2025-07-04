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
            // Opening modal - perform attestation and get auth token only if we don't have one
            print("=====> OPENING MODAL")
            if currentAuthToken == nil {
                performAttestationAndAuth { [weak self] token in
                    DispatchQueue.main.async {
                        if let token = token {
                            print("=====> Received auth token from backend: \(token)")
                            self?.currentAuthToken = token
                            // Update the auth token in the WebView via JavaScript
                            self?.updateAuthTokenInWebView(token: token)
                        } else {
                            print("=====> Failed to get auth token from backend")
                        }
                        // Show modal regardless of token status
                        self?.modalView.isHidden = false
                        self?.button.isHidden = true // Hide button when modal is open
                        print("=====> BUTTON HIDDEN: \(self?.button.isHidden ?? false)")
                    }
                }
            } else {
                // We already have an auth token, just show the modal
                print("=====> USING EXISTING AUTH TOKEN")
                modalView.isHidden = false
                button.isHidden = true
                print("=====> BUTTON HIDDEN: \(button.isHidden)")
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
        modalView.layer.cornerRadius = 0
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
        
        // CRITICAL: Set WebView background and appearance
        webView.backgroundColor = .white
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .white
        webView.scrollView.isOpaque = false
        
        modalView.addSubview(webView)
        print("=====> LOADING WEBVIEW 4")
        
        // Make modalView and webView full screen
        NSLayoutConstraint.activate([
            modalView.topAnchor.constraint(equalTo: view.topAnchor),
            modalView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            modalView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            modalView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.topAnchor.constraint(equalTo: modalView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: modalView.bottomAnchor)
        ])
        print("=====> LOADING WEBVIEW 5")
        
        // Force layout to ensure constraints are applied
        view.layoutIfNeeded()
        print("=====> WEBVIEW FRAME AFTER LAYOUT: \(webView.frame)")
        print("=====> MODAL VIEW FRAME AFTER LAYOUT: \(modalView.frame)")
        
        // Load initial HTML content with auth token (if available)
        loadWebViewContent(token: authToken)
        modalView.isHidden = true
    }

    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("=====> WKWebView error: \(error.localizedDescription)")
        print("=====> WKWebView error domain: \(error._domain)")
        print("=====> WKWebView error code: \(error._code)")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("=====> WKWebView: Page loaded successfully")
        print("=====> WKWebView frame: \(webView.frame)")
        print("=====> WKWebView bounds: \(webView.bounds)")
        print("=====> WKWebView is hidden: \(webView.isHidden)")
        print("=====> WKWebView alpha: \(webView.alpha)")
        
        // Inject debugging JavaScript to check content
        webView.evaluateJavaScript("document.body.innerHTML") { result, error in
            if let error = error {
                print("=====> JavaScript evaluation error: \(error)")
            } else if let html = result as? String {
                print("=====> WebView HTML content length: \(html.count)")
                print("=====> WebView HTML preview: \(String(html.prefix(200)))")
            }
        }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("=====> WKWebView navigation failed: \(error.localizedDescription)")
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("=====> WKWebView: Started loading")
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("=====> WKWebView authentication challenge: \(challenge.protectionSpace.host)")
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
                self?.sendAttestationToBackend(attestationToken: nil, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
                return
            }
            
            let clientDataHash = Data(nonce.utf8)
            
            attestationService.attestKey(keyId ?? "", clientDataHash: clientDataHash) { attestation, error in
                if let error = error {
                    print("=====> App Attest failed: \(error)")
                    self?.sendAttestationToBackend(attestationToken: nil, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
                    return
                }
                
                let attestationString = attestation?.base64EncodedString()
                self?.sendAttestationToBackend(attestationToken: attestationString, packageName: Bundle.main.bundleIdentifier, signingCert: nil, completion: completion)
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
                let tokenString = token?.base64EncodedString()
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
    
    private func updateAuthTokenInWebView(token: String) {
        let escapedToken = token.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let jsCode = """
        if (window.daikokutenInstance && window.daikokutenInstance.updateAuthToken) {
            window.daikokutenInstance.updateAuthToken("\(escapedToken)");
        } else {
            console.log("Daikokuten instance not ready for token update");
        }
        """
        webView.evaluateJavaScript(jsCode) { result, error in
            if let error = error {
                print("=====> Failed to update auth token in WebView: \(error)")
            } else {
                print("=====> Successfully updated auth token in WebView")
            }
        }
    }

    private func loadWebViewContent(token: String?) {
        let escapedUserId = userId.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let escapedClientId = clientId.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let testModeStr = testMode ? "true" : "false"
        let authTokenStr = token != nil ? "\"\(token!)\"" : "null"
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
            <meta name="format-detection" content="telephone=no">
            <meta http-equiv="Content-Security-Policy" content="default-src 'self' https://daikokuten-7c6ffc95ca37.herokuapp.com; script-src 'self' 'unsafe-inline' https://daikokuten-7c6ffc95ca37.herokuapp.com https://cdn.jsdelivr.net https://cdn.socket.io; style-src 'self' 'unsafe-inline'; connect-src 'self' https://daikokuten-7c6ffc95ca37.herokuapp.com wss://daikokuten-7c6ffc95ca37.herokuapp.com;">
            <script src="https://daikokuten-7c6ffc95ca37.herokuapp.com/sdk/web/index.js" async></script>
            <script src="https://cdn.jsdelivr.net/npm/dompurify@2.4.1/dist/purify.min.js" async></script>
            <style>
                html, body {
                    margin: 0;
                    padding: 0;
                    width: 100%;
                    height: 100vh;
                    background-color: #ffffff;
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    overflow: hidden;
                }
                #daikokuten-container {
                    width: 100%;
                    height: 100vh;
                    background-color: #f0f0f0;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                }
                #loading-message {
                    color: #333;
                    font-size: 18px;
                    text-align: center;
                    padding: 20px;
                }
                #debug-info {
                    position: fixed;
                    top: 10px;
                    left: 10px;
                    background: rgba(0,0,0,0.8);
                    color: white;
                    padding: 10px;
                    border-radius: 5px;
                    font-size: 12px;
                    z-index: 1000;
                }
            </style>
            <script>
                window.onload = function() {
                    console.log("WebView loaded successfully");
                    document.body.style.backgroundColor = '#ffffff';
                    
                    // Add debug info
                    const debugInfo = document.createElement('div');
                    debugInfo.id = 'debug-info';
                    debugInfo.innerHTML = 'WebView Loaded<br>UserID: \(escapedUserId)<br>ClientID: \(escapedClientId)<br>TestMode: \(testModeStr)';
                    document.body.appendChild(debugInfo);
                    
                    function initDaikokuten() {
                        console.log("Checking for Daikokuten and DOMPurify...");
                        if (typeotoed aikokuten !== 'undefined' && typeof DOMPurify !== 'undefined') {
                            console.log("DAIKOKUTEN CLASS INSTANCE");
                            window.daikokutenInstance = new Daikokuten(
                                "\(escapedUserId)",
                                "\(escapedClientId)",
                                \(testModeStr),
                                "ios",
                                "pro",
                                null,
                                \(authTokenStr)
                            );
                            
                            // Add updateAuthToken method to the instance
                            window.daikokutenInstance.updateAuthToken = function(newToken) {
                                console.log("Updating auth token in Daikokuten instance");
                                if (this.socket && this.socket.connected) {
                                    this.socket.emit('updateAuthToken', { token: newToken });
                                }
                                this.authToken = newToken;
                            };
                            
                            console.log("DAIKOKUTEN CLASS CREATED FOR \(escapedUserId)");
                            
                            // Update debug info
                            debugInfo.innerHTML += '<br>Daikokuten: Loaded';
                        } else {
                            console.log("DAIKOKUTEN RETRYING - Daikokuten: " + (typeof Daikokuten) + ", DOMPurify: " + (typeof DOMPurify));
                            debugInfo.innerHTML = 'Loading...<br>Daikokuten: ' + (typeof Daikokuten) + '<br>DOMPurify: ' + (typeof DOMPurify);
                            setTimeout(initDaikokuten, 1000);
                        }
                    }
                    console.log("DAIKOKUTEN INITIALIZING");
                    initDaikokuten();
                };
            </script>
        </head>
        <body>
            <div id="daikokuten-container">
                <div id="loading-message">
                    Loading Daikokuten Chat...
                </div>
            </div>
        </body>
        </html>
        """
        
        print("ChatButtonViewController: Loading HTML with userId: \(escapedUserId), clientId: \(escapedClientId), testMode: \(testModeStr), token: \(token ?? "nil")")
        webView.loadHTMLString(html, baseURL: nil)
    }

    // MARK: - WKScriptMessageHandler
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "closeModal" {
            print("=====> CLOSE BUTTON CLICKED")
            toggleModal()
        }
    }
}