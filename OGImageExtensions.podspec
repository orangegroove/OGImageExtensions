Pod::Spec.new do |s|
  s.name         = "OrangeGroove Image Extensions"
  s.version      = "0.1.0"
  s.summary      = "UIImage extensions and tools"
  s.homepage     = "https://github.com/jksk/OGImageExtensions"
  s.license      = :type => "MIT"
  s.authors      = "Jesper" => "jesper@orangegroove.net"
  s.source       = :git => "https://github.com/jksk/OGImageExtensions.git", :tag => s.version.to_s
  s.platform     = :ios, "7.0"
  s.source_files = "OGImageExtensions/"
  s.framework    = "CoreImage"
  s.requires_arc = true
end
