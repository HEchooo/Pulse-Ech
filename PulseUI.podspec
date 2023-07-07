Pod::Spec.new do |s|

s.name = "PulseUI"
s.module_name = "PulseUI"
s.version = "3.7.3"
s.summary = "Logging system for Apple platforms"
s.swift_version = "5.6"

s.description = <<-DESC
Pulse is a powerful logging system for Apple Platforms. Native. Built with SwiftUI.
DESC

s.homepage = "https://github.com/kean/Pulse"
s.license = "MIT"
s.author = { "kean" => "https://github.com/kean" }
s.authors = { "kean" => "https://github.com/kean" }
s.source = { :git => "https://github.com/kean/Pulse.git", :tag => "#{s.version}" }
s.social_media_url = "https://kean.blog/"

s.dependency "PulseCore", '~> 3.0'
s.source_files = "Sources/PulseUI/**/*.swift"

end
