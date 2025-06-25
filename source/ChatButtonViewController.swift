import UIKit
import WebKit

public class ChatButtonViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private var webView: WKWebView!
    private var button: UIButton!
    private var modalView: UIView!
    private let userId: String
    private let testMode: Bool
    private let clientId: String

    public init(
        userId: String = UUID().uuidString,
        clientId: String = "your_client_id",
        testMode: Bool = false
    ) {
        self.userId = userId
        self.clientId = clientId
        self.testMode = testMode
        super.init(nibName: nil, bundle: nil)
        
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }


    private func setupButton() {
        print("=====> LOADING BUTTON")
        button = UIButton(type: .system)
        button.setTitle("💬", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 24)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleModal), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func setupWebView() {
        print("=====> LOADING WEBVIEW 1")
        if modalView != nil { return }
        print("=====> LOADING WEBVIEW 2")
        modalView = UIView()
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 10
        modalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modalView)
        print("=====> LOADING WEBVIEW 3")
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(webView)
        print("=====> LOADING WEBVIEW 4")
        NSLayoutConstraint.activate([
            modalView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modalView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            modalView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            modalView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            webView.topAnchor.constraint(equalTo: modalView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: modalView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: modalView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: modalView.bottomAnchor)
        ])
        print("=====> LOADING WEBVIEW 5")
        let escapedUserId = userId.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let escapedClientId = clientId.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let testModeStr = testMode ? "true" : "false"
        
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
                "\"pro\"" +
                ");" +
                "console.log(\"DAIKOKUTEN CLASS CREATED FOR \(escapedUserId)\");" +
                "} else {" +
                "console.log(\"DAIKOKUTEN RETRYING - Daikokuten: \" + (typeof Daikokuten) + \", DOMPurify: \" + (typeof DOMPurify));" +
                "setTimeout(initDaikokuten, 1000);" +
                "}" +
                "}" +
                "console.log(\"DAIKOKUTEN INITIALIZING\");" +
                "initDaikokuten();" +
                "};" +
                "</script>" +
                "</head>" +
                "<body></body>" +
                "</html>"
        
        print("ChatButtonViewController: Loading HTML with userId: \(escapedUserId), clientId: \(escapedClientId), testMode: \(testModeStr)")
        webView.loadHTMLString(html, baseURL: nil)
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

    @objc private func toggleModal() {
        print("=====> TOGGLE MODAL")
        if modalView == nil {
            print("=====> SETTING UP WEBVIEW")
            setupWebView()
            print("=====> WEBVIEW SET UP")
        }
        modalView.isHidden = !modalView.isHidden
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
}