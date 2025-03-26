import UIKit
import WebKit

public class ChatButtonViewController: UIViewController, WKNavigationDelegate {
    private var webView: WKWebView!
    private var button: UIButton!
    private var modalView: UIView!
    private let userId: String
    private let accessToken: String
    private let testMode: Bool

    // Public initializer for clients to configure the SDK
    public init(userId: String = "user123", accessToken: String = "token", testMode: Bool = false) {
        self.userId = userId
        self.accessToken = accessToken
        self.testMode = testMode
        super.init(nibName: nil, bundle: nil)
    }

    // Required for storyboard/NIB initialization (not used here)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup the view when loaded
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }

    // Create and position the floating chat button
    private func setupButton() {
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

    // Setup the WebView modal
    private func setupWebView() {
        if modalView != nil { return }
        
        modalView = UIView()
        modalView.backgroundColor = .white
        modalView.layer.cornerRadius = 10
        modalView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(modalView)
        
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        modalView.addSubview(webView)
        
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
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <script src="https://daikokuten-7c6ffc95ca37.herokuapp.com/sdk/web/index.js" async></script>
            <script>
            window.onload = function() {
                function initDaikokuten() {
                    if (typeof Daikokuten !== 'undefined') {
                        new Daikokuten("\(userId)", "\(accessToken)", \(testMode));
                    } else {
                        setTimeout(initDaikokuten, 100);
                    }
                }
                initDaikokuten();
            };
            </script>
        </head>
        <body></body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
        modalView.isHidden = true
    }

    // Toggle the modal visibility
    @objc private func toggleModal() {
        if modalView == nil {
            setupWebView()
        }
        modalView.isHidden = !modalView.isHidden
    }

    // Optional: Handle WebView navigation errors (for debugging)
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("WebView failed to load: \(error.localizedDescription)")
    }
}