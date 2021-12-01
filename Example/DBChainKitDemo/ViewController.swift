//
//  ViewController.swift
//  DBChainKitDemo
//
//  Created by iOS on 2021/10/22.
//

import UIKit
import DBChainKit
import Alamofire

//        /// 添加一条一对多的关系函数插入  function_name_freeze_mult
//        case addRelationFunction = "function_name_insert_relation_mult"
//        /// 添加一条简单的 关系函数插入
//        case addInsertRelationFunction = "function_name_insert_relation"
//        /// 一张表一次添加多条数据
//        case addInsertMoreFunction = "function_name_insert_mult"
//        /// 一张表一次冻结多条数据 ( 单表 多数据操作 )
//        case removeMoreFunction = "function_name_freeze_mult"
//        /// 修改一条数据
//        case updateOneDataFunction = "function_name_update"
//        /// 修改一条关联数据
//        /*
//         ${tableName},$id,tableName__${FilableTable.tableName},foreignKeyName__filabletype,foreignKeyName__filableid,tableName__${TaggableTable.tableName},foreignKeyName__taggabletype,foreignKeyName__taggableid
//         */
//        case updateRelationFunction = "function_name_update_relation"
//        /// 冻结一条关联数据 ( 结构化数据相关操作 )
//        /* ${tableName},$id,tableName__${FilableTable.tableName},foreignKeyName__filabletype,foreignKeyName__filableid,tableName__${TaggableTable.tableName},foreignKeyName__taggabletype,foreignKeyName__taggableid
//         */
//        case freezeOneDataFunction = "function_name_freeze_relation"

//        /// 根据 表名 -- 字段名 -- 字段名 , 参数  -- 参数  冻结多条数据,
//        格式 示例:["tableName__taggable","tag_id , field","[\"115\",\"125\"]",   "tableName__tag","id, taggabletype","[\"115\"]"]
//        case freezeMultDataWithFieldFunction = "function_name_freeze_by_mult"
//        /// 查询传承数据
//        case queryInheritListDataFunction = "query_inherit"
//        /// 查询是否为会员
//        case queryVipTypeFunction = "query_database_1_vip"
//        /// 冻结 回收桶 数据   [表名, 天数]   5 天过期就传 5
//        case frozenDataFunction = "function_name_freeze_expiration_mult"




//let dbchain = DBChainKit.init(appcode: "8BSMXFVQ5W",
//                              chainid: "ytbox",
//                              baseurl: "https://chain-ytbox.dbchain.cloud/relay/",
//                              encryptType: Secp256k1())


let dbchain = DBChainKit.init(appcode: "5APTSCPSF7",
                              chainid: "testnet",
                              baseurl: "https://controlpanel.dbchain.cloud/relay/",
                              encryptType: Secp256k1())

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        secp256k1Test()

//        sm2Test()
    }


    func secp256k1Test() {

//        let mnemonic = dbchain.createMnemonic()
//        let mnemonic = "ecology alpha fine disorder parade beach antenna slogan dial auto random chase"
        let mnemonic = "clown start angry enemy excite used boost mail caught glare insane biology"
        let privatekey = dbchain.generatePrivateByMenemonci(mnemonic)

        let publickey = dbchain.generatePublickey(privatekey)

         _ = dbchain.generateAddress(publickey)

         _ = dbchain.generateToken(privatekey, publickey)

        print("助记词: \(mnemonic)\n私钥:\(privatekey)\n公钥:\(publickey)\n地址:\(dbchain.address!)\ntoken:\(dbchain.token!)")

        print(dbchain.appcode,
              dbchain.chainid,
              dbchain.baseurl,
              dbchain.privateKey,
              dbchain.publicKey,
              dbchain.address,
              dbchain.token)

//      获取积分 --- 查询
//        dbchain.registerNewAccountNumber { (state, result) in
//            print(state,"\(result)")
//        }

//      整表查询

//        dbchain.queryDataByTablaName("user") { (tagResult) in
//            print(tagResult)
//        }

        /// ID 查询
//        dbchain.queryDataByID(tableName: "user", id: "28") { (result) in
//            print(result)
//        }


//         条件查询

//        let dic = ["created_by":dbchain.address!]
//        dbchain.queryDataByCondition("user", dic) { (result) in
//            print(result)
//        }

        /// 传承数据查询
//        dbchain.queryInheritListData("inherit", "query_inherit", fieldDic: nil) { (result) in
//            print(result)
//        }


        /// 新增一条数据
//        let dic = ["name":"测试DBChainSm2",
//                   "age":"18",
//                   "dbchain_key":dbchain.address!,
//                   "sex":"0",
//                   "status":"",
//                   "photo":"",
//                   "motto":""]
//        dbchain.insertRow(tableName: "user", fields: dic) { (result) in
//            print(result)
//        }



        /// 冻结一条数据
//        dbchain.trashcanRowData(tableName: "user", trashcanID: "35") { (result) in
//            print(result)
//        }



        /// 单条数据函数请求
//        var fileArgumentArr : [String] = ["tableName__file"]
//        let dataArr : [String] = ["我是测试的IMG_2381.PNG","QmUPh8qQg5GzZACLtrc2UrEq5QwP1NhTSSMfFHWA4ym9y7","194.34KB","","\(dbchain.address!)"]
//
//        let jsonDataArrStr = String().getJSONStringFromArray(dataArr as NSArray)
//        fileArgumentArr.append(jsonDataArrStr)
//        let file_function_jsonStr = String().getJSONStringFromArray(fileArgumentArr as NSArray)
//        print(file_function_jsonStr)
//
//        dbchain.functionInsertRow(signArgument: file_function_jsonStr, functionName: "function_name_insert_mult") { (result) in
//            print(result)
//        }

    }


//    func sm2Test() {
//        let mnemonic = "ecology alpha fine disorder parade beach antenna slogan dial auto random chase"
//
//        let privatekey = dbchain.generatePrivateByMenemonci(mnemonic)
//
//        let publickey = dbchain.generatePublickey(privatekey)
//
//         _ = dbchain.generateAddress(publickey)
//
//         _ = dbchain.generateToken(privatekey, publickey)
//
//        print("助记词: \(mnemonic)\n私钥:\(privatekey)\n公钥:\(publickey)\n地址:\(dbchain.address!)\ntoken:\(dbchain.token!)")
//
//
//    }

}


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



extension ViewController {


}
