Pod::Spec.new do |spec|
  spec.name = "sdk_luckycycle_ios"
  spec.version = "1.0.0"
  spec.summary = "Luckycycle SDL to make poke and show game"
  spec.homepage = "https://github.com/LuckyCycle/ios-sdk-swift"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "jm goemaere" => 'jm@luckycycle.com' }
  spec.social_media_url = "http://twitter.com/luckycycle"

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/LuckyCycle/ios-sdk-swift.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "RGB/**/*.{h,swift}"

  spec.dependency "AlamoFire", "~> 4.5"
end