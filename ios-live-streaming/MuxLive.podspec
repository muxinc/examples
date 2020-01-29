Pod::Spec.new do |s|
  s.name     = 'MuxLive'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'MuxLive SDK'
  s.authors  = { "Mux, Inc." => "info@mux.com" }
  s.homepage = 'http://mux.com'
  s.source   = { :git => 'https://github.com/muxinc/example-ios-live-streaming.git', :tag => s.version }
  s.ios.deployment_target = '11.0'
  s.source_files = 'Sources/*.swift'
  s.requires_arc = true
  s.swift_version = '4.0'
  s.dependency 'Alamofire', '~> 4.7'
  s.dependency 'LFLiveKit', '~> 2.6'
  s.dependency 'NextLevel', '~> 0.9'
end
