require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-change-bundle"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-change-bundle
                   DESC
  s.homepage     = "https://github.com/digitalFrontend/react-native-change-bundle"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "digitalFrontend" => "digitalFrontend@tele2.ru" }
  s.platforms    = { :ios => "13.0" }
  s.source       = { :git => "https://github.com/digitalFrontend/react-native-change-bundle.git", :tag => "#{s.version}" }

 
  s.source_files = "ios/**/*.{h,c,m,swift}"

  s.dependency "React"
end


