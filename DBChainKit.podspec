
Pod::Spec.new do |spec|

  spec.name         = "DBChainKit"
  spec.version      = "1.0.0"
  spec.summary      = "DBChain 系列库,生成BIP39 助记词. 通过助记词生成私钥, 私钥生成公钥, 公钥得出链地址"

#  spec.description  = <<-DESC
#                  DESC

  spec.description  = 'DBChain 系列库,生成BIP39 助记词. 通过助记词生成私钥, 私钥生成公钥, 公钥得出链地址'
  spec.homepage     = "https://github.com/dbchaincloud/ios-client"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Ann-iOS" => "m18620345206@163.com" }

  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'

  spec.source       = { :git => "https://github.com/dbchaincloud/ios-client.git", :tag => spec.version.to_s }

  # spec.pod_target_xcconfig = { 'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)' }
  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 armv7s x86_64' }

  spec.source_files  = 'DBChainKit', 'DBChainKit/**/*.{swift}'

  # spec.public_header_files = "DBChainKit/**/*.h"
  # spec.source_files  = "DBChainKit/**/*.{h,m}"

  spec.exclude_files = "DBChainKit/**/*.h"


  spec.requires_arc     = true
  spec.static_framework = true
  spec.module_name   = "DBChainKit"

  spec.frameworks       = "Security"
  spec.dependency "SawtoothSigning"
  spec.dependency "Alamofire"
  spec.dependency "HDWalletSDK", '>= 1.1.0'

  if spec.respond_to? 'swift_version'
      spec.swift_version = "5.0"
  end

end
