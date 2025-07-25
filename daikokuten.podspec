Pod::Spec.new do |spec|
  spec.name         = "daikokuten"
  spec.version      = "0.2.2"
  spec.summary      = "A simple chat SDK for iOS with WebSocket support."
  spec.description  = <<-DESC
                      daikokuten provides a chat button view with WebView integration and WebSocket capabilities for iOS apps.
                    DESC
  spec.homepage     = "https://github.com/keai-org/daikokuten-sdk-ios"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "KeAi" => "s.correa@equipo-ia.com" }
  spec.platform     = :ios, "14.0"
  spec.source       = { :git => "https://github.com/keai-org/daikokuten-sdk-ios.git", :tag => "0.2.2" }
  spec.source_files = "source/*.{swift,h,m}"
  spec.swift_version = "5.0"
end

# pod spec lint DaikokutenSDK.podspec
# pod trunk register your.email@example.com "Your Name" --description="DaikokutenSDK publisher"
# pod trunk push DaikokutenSDK.podspec
# pod spec lint DaikokutenSDK.podspec --verbose