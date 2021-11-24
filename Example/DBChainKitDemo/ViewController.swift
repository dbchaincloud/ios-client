//
//  ViewController.swift
//  DBChainKitDemo
//
//  Created by iOS on 2021/10/22.
//

import UIKit
import DBChainKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

//        let mnemonic = DBChain.mnemonicStr
//        print(mnemonic)
//        let mnemonic = "ecology alpha fine disorder parade beach antenna slogan dial auto random chase"

        let mnemonic = "ecology alpha fine disorder parade beach antenna slogan dial auto random chase"
//        let pristr = DBChain.privateKey(mnemonicStr: mnemonic)
//        let pubstr = DBChain.publicKey(privateString: pristr)
//
//        print(pristr)
//        print(pubstr)
//
//        let addressStr = DBChain.address(publickeyStr: pubstr)
//        print(addressStr)

        print("--------")

        DBChain.mnemonicStr = mnemonic

        let pri = DBChain.privatekey
        let pub = DBChain.publickey
//        print("\(pri) \n\(pub)")

//        let address = DBChain.address 
//        print(address)
//
//        let token = DBChain.token
//        print("token:\(token)")
//        print("token:\(DBChain.token)")


        print("address:\(DBChain.address)")


        DBChain.appinfo = AppInfo("8BSMXFVQ5W", "ytbox", "https://chain-ytbox.dbchain.cloud/relay/")

//        self.trashcanData()
//        self.queryDataByTab()
//        self.queryDataByid()
        self.getRegisterNewAccountNumber()
    }


    /**
        插入数据请求测试
     */

    func insertData() {
        let field = ["name":"测试标签"]
        DBChain.insertRow(appinfo: DBChain.appinfo, tableName: "tag", fields: field) { (state) in
            print("添加标签的最终结果:\(state)")
        }
    }

    
    func trashcanData() {
        DBChain.trashcanRowData(appinfo: DBChain.appinfo,
                                tableName: "tag",
                                trashcanID: "117") { (state) in
            print("冻结数据结果: \(state)")
        }
    }



    func functionInsertArr() {

//        let dic = [""]
//        DBChain.functionInsertMessageArr(appinfo: DBChain.appinfo,
//                                         messageArr: [[String : Any]]) { (state) in
//            print("打包多条数据 插入: \(state)")
//        }
    }



    /**
        查询数据请求测试
     */

    func queryDataByTab() {
        DBChain.queryDataByTablaName(DBChain.appinfo, "tag") { (str) in
            print("查询结果: \(str)")
        }
    }

    func queryDataByid () {
        DBChain.queryDataByID(DBChain.appinfo, "tag", "117") { (str) in
            print("查询id的信息:\(str)")
        }
    }

    func queryDataByCondition() {
        let field = ["id":"117","created_by":DBChain.address,"name":"测试标签"]
        DBChain.queryDataByCondition(DBChain.appinfo, "tag", field) { (str) in
            print("多条件查询结果: \(str)")
        }
    }

    /**
        新用户获取积分
     */
    func getRegisterNewAccountNumber() {
        DBChain.registerNewAccountNumber(appinfo: DBChain.appinfo) { (state,error) in
            print(state)
        }
    }

}

