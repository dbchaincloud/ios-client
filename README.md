# DBChainKit
iOS client for DBChain
DBChainKit 依赖且包含 `HDWalletKit`,`Alamofire`,`CryptoSwift`,`SawtoothSigning`,`secp256k1`

- [特征](#特征)
- [要求](#要求)
- [安装](#安装)
- [用法](#用法)
    - [**生成助记词**](生成助记词)
    - [**生成公钥与私钥**](公钥与私钥的生成)
    - [**生成地址**](地址的生成)
- [常见问题](#问题)

## 特征

- [x] 创建和使用HD钱包
- [x] BIP39 中的助记词恢复短语
- [x] 可生成32个(64位)字节的私钥与33个(66位)字节的公钥
- [x] 支持生成不同类型的地址
- [x] 签名与验证交易
- [x] 可自定义发送交易的网络请求

## 要求

- iOS 10.0 或更高版本
- Swift 5.3.1 或更高版本

## 安装

### [Swift Package Manager](https://swift.org/package-manager/)
- Xcode - File - Swift Packages - Add Package Dependencies
```
https://github.com/dbchaincloud/ios-client.git
```
或者尝试
```
git@github.com:dbchaincloud/ios-client.git
```
- 选择 Branch 选项, 输入 `main`, 点击确定

## 用法
DBChainKit 包含生成助记词(Bip39), 助记词生成公私钥和地址, 对交易进行签名与验证.

### 生成助记词

```
#import DBChainKit

let mnemonicBip39 = Mnemonic.create()
```
或者:

```
let mnemonicBip39 = DBChainKit().createMnemonic()
```
### 公钥与私钥的生成

```
/// 将助记词分割成字符串数组
let bipArr = mnemonicBip39.components(separatedBy: ",")
/// 返回公钥私钥地址
let manager = DBMnemonicManager().MnemonicGetPrivateKeyStrAndPublickStrWithMnemonicArr(bipArr)
/// 获取公钥的字符串形式
let publickeyStr = manager.publicKeyString
/// 获取私钥的字符串形式
let privateKeyStr = manager.privateKeyString
/// 获取私钥的 Uint8 数组形式
let privateKeyUint = manager.privateKeyUint
/// 获取地址 (默认是 cosmos 格式 )
let address = manager.address

```

#### 公私钥派生参数和过程 (可参考源码进行自定义)

```
/// mnemonicStr 助记词以空格分割的字符串 (注意大小写不同生成的公私钥完全不一样)
let seedBip39 = Mnemonic.createSeed(mnemonic: mnemonicStr)
/// 生成私钥
let privateKey = PrivateKey(seed: seedBip39, coin: .bitcoin)

//私钥和密钥派生（BIP39）
let purpose = privateKey.derived(at: .hardened(44))
let coinType = purpose.derived(at: .hardened(118))
let account = coinType.derived(at: .hardened(0))
let change = account.derived(at: .notHardened(0))
let dbPrivateKey = change.derived(at: .notHardened(0))
// ************  公钥  *************
let publikey = PublicKey(privateKey: dbPrivateKey.raw, coin: .bitcoin)
// ************  地址  *************
let address = getPubToDpAddress(publikey.data, ChainType.COSMOS_MAIN)

```


### 地址的生成
支持不同类型的 ChainType, DBChainKit 使用 COSMOS, 可自定义获取不同类型的地址
```
// 生成地址支持的 ChainType 类型有:
public enum ChainType: String {
    case COSMOS_MAIN
    case IRIS_MAIN
    case BINANCE_MAIN
    case KAVA_MAIN
    case IOV_MAIN
    case BAND_MAIN
    case SECRET_MAIN

    case BINANCE_TEST
    case KAVA_TEST
    case IOV_TEST
    case OKEX_TEST
    case CERTIK_TEST

    static func SUPPRT_CHAIN() -> Array<ChainType> {
        var result = [ChainType]()
        result.append(COSMOS_MAIN)
        result.append(IRIS_MAIN)
        result.append(BINANCE_MAIN)
        result.append(IOV_MAIN)
        result.append(KAVA_MAIN)
        result.append(BAND_MAIN)
        result.append(SECRET_MAIN)
        result.append(OKEX_TEST)
        result.append(CERTIK_TEST)
        return result
    }
}

``` 
#### 生成自定义类型的地址
```
#import DBChainKit
/// 需要传入公钥的哈希与类型
let address = getPubToDpAddress(<#T##pubHex: Data##Data#>, <#T##chain: ChainType##ChainType#>)
```

## 常见问题

- 由于 `DBChainKit` 包含 `Alamofire`, `CryptoSwift` 等库依赖, 使用 `Swift Packages` 拉取会出现超时情况, 需要反复多次尝试, 或下载 `DBChainKit`的 `Zip`包, 将 `Sources`文件夹下的   `DBChainKit` 文件夹手动添加到项目中, 其他依赖通过其他方式拉取
- 注意:   
- `HDWalletKit` 的源代码已转移到 `DBChainKit`, 因此不需要另外拉取,
- `Alamofire` 与  `CryptoSwift` 可通过 `cocoaPods`,
- `SawtoothSigning`  只支持 `Swift Packages`, 并且依赖于 `secp256k1`,   因此只需要通过 `Swift Packages` 拉取 `SawtoothSigning` 即可.
