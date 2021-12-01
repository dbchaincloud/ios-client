
Pod::Spec.new do |spec|

  spec.name         = "DBChainKit"
  spec.version      = "2.0.1"
  spec.summary      = "DBChain 系列库,生成BIP39 助记词. 通过助记词生成私钥, 私钥生成公钥, 公钥得出链地址"
  spec.description  = 'DBChain 系列库,生成BIP39 助记词. 通过助记词生成私钥, 私钥生成公钥, 公钥得出链地址'
  spec.homepage     = "https://github.com/dbchaincloud/ios-client"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author             = { "Ann-iOS" => "m18620345206@163.com" }
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.source       = { :git => "https://github.com/dbchaincloud/ios-client.git", :tag => spec.version.to_s }



  # spec.pod_target_xcconfig = { 'ARCHS[sdk=iphonesimulator*]' => '$(ARCHS_STANDARD_64_BIT)' }
    spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 armv7s x86_64' }



  # spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  # spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }


  spec.subspec 'sm2' do |ss|
    ss.source_files = 'DBChainKit/DBChainKit.swift','DBChainKit/main/*.{swift}','DBChainKit/sm2/*.{swift}'
    ss.dependency "Alamofire"
    ss.dependency "HDWalletSDK"
    ss.dependency "DBChainSm2"
  end


  spec.subspec 'secp256k1' do |ss|
    ss.source_files = 'DBChainKit/DBChainKit.swift','DBChainKit/main/*.{swift}', 'DBChainKit/secp256k1/*.{swift}'
    ss.dependency "Alamofire"
    ss.dependency "HDWalletSDK"
    ss.dependency "Secp256k1Signing"
  end


  spec.requires_arc     = true
  spec.static_framework = true
  spec.module_name   = "DBChainKit"
  spec.frameworks       = "Security"


  if spec.respond_to? 'swift_version'
      spec.swift_version = "5.0"
  end



  # spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'arm64 armv7 armv7s x86_64' }
  # spec.source_files  = 'DBChainKit', 'DBChainKit/**/*.{swift}'
  # spec.exclude_files = "DBChainKit/**/*.h"
  # spec.source_files  = 'DBChainKit/**/*.{swift}'
  # spec.public_header_files = 'DBChainKit/**/DBChainKit.swift'



end
