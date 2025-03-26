Pod::Spec.new do |s|
  s.name             = 'Daikokuten'
  s.version          = '0.1.0'
  s.summary          = 'Kapi SDK for iOS with WebView integration.'
  s.homepage         = 'https://github.com/yourusername/DaikokutenSDK' # Update this
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/yourusername/DaikokutenSDK.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.source_files     = 'source/**/*.{swift}'
end