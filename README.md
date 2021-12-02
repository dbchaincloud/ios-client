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
* 切换两种不同的签名方式, 只需要修改 `podfile` 并重新`pod install`, 并且在初始化时传递不同的 `encryptType` 参数即可.
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
```swift
let mnemonicStr = dbchain.createMnemonic()
print("随机生成助记词: \(mnemonicStr)")
打印结果:
随机生成助记词: rule humble hen stock clarify emerge book wealth material carbon wrong december
```
### 通过助记词得出私钥
```swift
/// 可传入自定义助记词, 助记词必须由12个英文单词组成, 每两个助记词之间以空格分隔的字符串
let privatekey = dbchain.generatePrivateByMenemonci(mnemonicStr)
```

### 通过私钥得出公钥
```swift
let publickey = dbchain.generatePublickey(privatekey)
```

### 通过公钥得出地址
```swift
let address = dbchain.generateAddress(publickey)
```

### 获取验证交易所需的Token 即对当前时间戳进行签名以及Base58编码后的字符串
```swift
let token = dbchain.generateToken(privatekey, publickey)
```

**以上数据初始化完毕后, 除助记词外, 均可通过 `点语法` 获取**
```swift
print(dbchain.appcode,
      dbchain.chainid,
      dbchain.baseurl,
      dbchain.privateKey,
      dbchain.publicKey,
      dbchain.address,
      dbchain.token)
```

### 新注册账号必须先申请积分,一个账号申请一次即可
```swift
//  获取积分 
//  state: 状态, true为积分申请成功, 否则返回false
//  result: 成功时返回可选的 success, 失败时返回失败信息

dbchain.registerNewAccountNumber { (state, result) in
    print(state,result)
}

//  打印结果
 true , Optional("success")
```

### 查询:  整张表数据
```swift
//      整表查询, 传入需要查询数据的表名
dbchain.queryDataByTablaName("user") { (result) in
    print(result)
}
```

### 查询:  根据表名与ID
```swift
/// ID 查询
dbchain.queryDataByID(tableName: "user", id: "28") { (result) in
      print(result)
}
```

### 查询:  条件查询
```swift
//  条件查询

//  key字段与控制台数据表(user表)字段匹配,value 字段填写希望查询的数据结果
let dic = ["created_by":dbchain.address!,"name":"小明"]

dbchain.queryDataByCondition("user", dic) { (result) in
      print(result)
}

```

### 新增:  单独新增一条数据
```swift
/// 新增一条数据到 user 表中
let dic = ["name":"小明",
            "age":"18",
            "dbchain_key":dbchain.address!,
            "sex":"0",
            "status":"",
            "photo":"",
            "motto":""]

dbchain.insertRow(tableName: "user", fields: dic) { (result) in
      print(result)
}

```

### 函数操作:  单条数据新增函数请求, 也可以实现单表多数据插入

**<u>使用函数进行数据操作时, 必须先保证函数名称与实现在控制台进行过注册,否则函数操作无法正常进行!</u>**

**<u>数据组装格式由注册在控制台时的函数决定, 数据组装形式千变万化,以下只为示例,具体以实际注册函数时设定的格式为准!</u>**

单条数据新增函数请求:

```swift
/// 字符串数组 固定格式开头 tableName__`表名`
var fileArgumentArr : [String] = ["tableName__user"]

/// 参数拼接, 按照上面表名在控制台中的字段排序成字符串数组, 如有字段可为空并且没有数据时, 需要保留一个空字符串的位置
let dataArr : [String] = ["小明","18","\(dbchain.address!)","0","","",""]

/// 将一条数据组装完毕的字符串数组转换成JSON字符串格式, 每多增加一条即需要转换一次
/// getJSONStringFromArray 将字符串数据转换JSON字符串方法, 具体实现在最后
let jsonDataArrStr = String().getJSONStringFromArray(dataArr as NSArray)

/// 拼接到表名的数组
fileArgumentArr.append(jsonDataArrStr)

/// 所有数据准备完毕之后再次转换JSON字符串进行提交
let file_function_jsonStr = String().getJSONStringFromArray(fileArgumentArr as NSArray)
      
print("待提交的新增数据函数方法内容: \(file_function_jsonStr)")

/// functionName:  填写在控制台已正常注册的函数名称, 该函数名称的实现为新增一条数据. 函数名应与控制台注册时相匹配!
dbchain.functionInsertRow(signArgument: file_function_jsonStr, functionName: "function_name_insert_mult") { (result) in
      print(result)
}

```

单表多数据插入:

假设` tag ` 表设计如下:

| id   | tagname  | userid |
| ---- | -------- | ------ |
| 1    | 吃货一枚 | 20     |
| 2    | 活泼可爱 | 20     |
| 3    | 调皮捣蛋 | 20     |


```swift
/// 一次性将数组里的数据添加到表名为 tag (标签) 的表中, 为 userid 为 20 的用户打上标签
let tagArr = ["吃货一枚","活泼可爱","调皮捣蛋"]

/// 首先 按照固定标准 准备表名字符串数组
var function_str_arr :[String] = [tableName__tag]

/// 循环拼接字符串
for tag in tagArr {
    ///	按照表字段顺序填写数据, 忽视 id 字段, 
    let tagStrArr : [String] = [ tag, "20" ]

    /// 将字符串数组转换成 JSON 字符串, 每添加一条数据转换一次
    let jsonTagArrStr = String().getJSONStringFromArray(tagStrArr as NSArray)

    /// 将 JSON 字符串 添加到含有表名的数据中.
    function_str_arr.append(jsonTagArrStr)
}

/// 最后, 内部数据已转换完毕, 需将所有数据再次转换成JSON字符串提交
let file_function_jsonStr = String().getJSONStringFromArray(function_str_arr as NSArray)

/// 调用函数插入操作, 即可将多条数据一次性新增到 tag 表
dbchain.functionInsertRow(signArgument: file_function_jsonStr, functionName: "function_name_insert_mult") { (result) in
      print(result)
}
```

### 函数操作:  多条函数请求	

由单条函数请求延伸, 将多条单条函数请求操作与函数名 组合成字典形式调用, 数据组装方式与单条函数请求处理方式一致. 可同时向不同表进行不同操作, 示例:

```swift
/// function_str_arr_1: 表示第一条按照数据表顺序组装完毕的字符串数组
/// function_str_arr_2: 表示第二条按照数据表顺序组装完毕的字符串数组
let jsonStr_1 = String().getJSONStringFromArray(function_str_arr_1 as NSArray)
let jsonStr_2 = String().getJSONStringFromArray(function_str_arr_2 as NSArray)
/// 第一条字符串对应的函数名称, 可以是新增或冻结. 组装的字符串格式应与函数名在控制台上注册时一致
let jsonStrFunctionName_1 = "function_name_insert_mult"
let jsonStrFunctionName_2 = "function_name_freeze_relation"

let jsonStrArr :[String: String] = [ jsonStr_1 : jsonStrFunctionName_1 ,
                                   	 jsonStr_2 : jsonStrFunctionName_2 ]
/// 调用发送多条函数请求
dbchain.functionInsertDic(argumentsAndFunctionNames: jsonStrArr ) { (result) in
    print(result)
}
```

### 函数操作: 自由组合签名消息体

该函数在外部处理待签名消息体, 可一次性组合多个不同类型的消息体进行处理, 不同类型的消息体参数不同, 以下只作为部分示例:

```swift
// 准备一个最终组合提交的字典数组
var objectArr :[[String: Any]] = []

/// 组装一条普通新增数据, 自由组合签名体的函数操作可以混合单数据与函数操作
let dataDic = ["name":"小明", "age":"18", "dbchain_key":dbchain.address!, "sex":"0",
                "status":"", "photo":"", "motto":""]

// 直接插入数据处理. dicValueString: 将字典按照key的首字母进行排序
let fieldsStr = dataDic.dicValueString(dataDic)
let fieldsData = Data(fieldsStr!.utf8)
let fieldBase = fieldsData.base64EncodedString()
/// 单条数据组合时的固定模式. 
// type:说明该条数据的请求是插入一条数据
// owner: 插入该条数据的地址
// table_name:  插入数据的表名
let objectDic :[String:Any] = ["type":"dbchain/InsertRow",
                               "value":["app_code":dbchain.appcode,
                                        "fields":fieldBase,
                                        "owner":dbchain.address!,
                                        "table_name":"user"]]
// 第一条自由组合数据准备完毕
objectArr.append(objectDic)

// 冻结数据, 冻结一条数据的固定参数
let trashcanMsgDic: [String:Any] = ["type":"dbchain/FreezeRow",
                                   "value":["app_code":dbchain.appcode,
                                    				"owner":dbchain.address!,
                                    				"id":"15",
                                    				"table_name":"tag"]]
// 第二条自由组合数据准备完毕
objectArr.append(trashcanMsgDic)

/// 将组合完毕的函数请求数据转换成JSON字符串
let functionStr = String().getJSONStringFromArray(dataArr as NSArray)

/// 自由组合请求体时函数请求固定参数格式
/// type: dbchain/CallFunction 该消息体为函数请求
/// function_name:  该条函数请求的函数名称
let funcDic:[String:Any] = ["type":"dbchain/CallFunction",
                            "value":["app_code":dbchain.appcode,
                                     "owner":dbchain.address!,
                                     "argument":functionStr,
                                     "function_name":"function_name_freeze_by_mult"]]
/// 第三条自由组合数据准备完毕
objectArr.append(funcDic)

/// 调用 DBChainKit 自由组合消息体发起网络请求
dbchain.functionInsertMessageArr(messageArr: objectArr ) { (result) in
    print(result)
}
```

### 字符串数组转换 JSON 字符串 参考:

```swift
extension String {
    //数组(Array)转换为JSON字符串
   public func getJSONStringFromArray(_ array:NSArray) -> String {
        if (!JSONSerialization.isValidJSONObject(array)) {
            return String()
        }
        let data : NSData! = try? JSONSerialization.data(withJSONObject: array, options: []) as NSData?
        let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue)
        return JSONString! as String
    }
}
```

