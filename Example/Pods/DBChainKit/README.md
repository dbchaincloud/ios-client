# DBChainKit

## 结合椭圆曲线 Secp256k1 与 国密 Sm2 签名, 基于 区块链 DBChain 开发的应用包.           Application package based on block chain DBChain developed by combining elliptic curve Secp256k1 with national Sm2 signature

国密 Sm2 与 椭圆曲线 Secp256k1 与区块链的结合, 包含生成助记词,私钥公钥,签名与验签等, 支持通过公钥生成不同链的地址.


# 集成
使用 Cocoapods 方式进行引入:
* 最低支持 10.0
* 根据不同的加密方式, 引入不同库的子路径. 二者选其一即可!
* 在Podfile中添加以下选项后执行 pod install 即可, 参照如下:
```
platform :ios, '10.0'

# 使用国密Sm2 签名与验证时导入:
pod 'DBChainKit/sm2'

# 使用椭圆曲线 secp256k1 签名与验签时导入:
pod 'DBChainKit/secp256k1'
```
### 可能遇到的编译错误
* 不支持 `armv7` 架构, 请在 `Build Settings` - `Excluded Architectures` 下添加 `Any SDK` 输入 `armv7`, 将其排除.
* `Multiple commands produce`错误 : 请在终端执行`pod repo update --verbose` 更新 `Cocoapods `源, 或手动将 `Pods` 文件夹下 `DBChainSm2` 中的重复头文件删除. 


# 环境要求
* iOS 10.0 以上系统
* Swift 5.0 以上
* Xcode 12 以上

# 使用示例
### 初始化 
* 切换两种不同的签名方式, 只需要修改`podfile` 并重新`pod install`, 并且在初始化时传递不同的`encryptType`参数即可.
* 建议将 `DBChainKit` 初始化放在 `class` 外部, 作为全局通用.
```
/// 参数说明:
/// appcode: 结合DBChain控制台生成的数据库的唯一标识
/// chainid: 在DBChain控制台创建数据库时的 chainid
/// baseurl: 在DBChain控制台创建数据库时的 Baseurl
/// encryptType:  加密方式. 需与podfile里下载子库名统一.  下载 'DBChainKit/sm2' 时, 传入 'Sm2()', secp256k1 同理

let dbchain = DBChainKit.init(appcode: "5APTSCPFG4",
                              chainid: "testnet",
                              baseurl: "https://controlpanel.dbchain.cloud/relay/",
                              encryptType: Secp256k1())
```


## 以下为公共方法, 即使切换加密方式, 方法名同样不变, 内部实现将跟随之变化


### 生成助记词
```
let mnemonicStr = dbchain.createMnemonic()
print("随机生成助记词: \(mnemonicStr)")
```
```
打印结果:
随机生成助记词: rule humble hen stock clarify emerge book wealth material carbon wrong december
```

### 通过助记词得出私钥
```
/// 可传入自定义助记词, 助记词必须由12个英文单词组成, 每两个助记词之间以空格分隔的字符串
let privatekey = dbchain.generatePrivateByMenemonci(mnemonicStr)
```

### 通过私钥得出公钥
```
let publickey = dbchain.generatePublickey(privatekey)
```

### 通过公钥得出地址
```
let address = dbchain.generateAddress(publickey)
```

### 获取验证交易所需的Token 即对当前时间戳进行签名以及Base58编码后的字符串
```
let token = dbchain.generateToken(privatekey, publickey)
```

**以上数据初始化完毕后, 除助记词外, 均可通过 `点语法` 获取 **
```
print(dbchain.appcode,
      dbchain.chainid,
      dbchain.baseurl,
      dbchain.privateKey,
      dbchain.publicKey,
      dbchain.address,
      dbchain.token)
```