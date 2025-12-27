#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint cache_network_media.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'cache_network_media'
  s.version          = '0.0.2'
  s.summary          = 'Efficient network media caching for Flutter'
  s.description      = <<-DESC
A Flutter plugin for caching network images, SVG graphics, and Lottie animations with disk persistence.
                       DESC
  s.homepage         = 'https://github.com/D-extremity/cache_network_media'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'D-extremity' => 'https://github.com/D-extremity' }
  s.source           = { :path => '.' }
  s.source_files = 'cache_network_media/Sources/cache_network_media/**/*'
  s.resource_bundles = {'cache_network_media_privacy' => ['cache_network_media/Sources/cache_network_media/PrivacyInfo.xcprivacy']}
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES', 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES' => 'YES'
  }
  s.swift_version = '5.0'
  
  # This is needed for the plugin to find the Flutter.framework
  s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(TOOLCHAIN_DIR)/usr/lib/swift/$(PLATFORM_NAME)/ $(SDKROOT)/usr/lib/swift' }
end
