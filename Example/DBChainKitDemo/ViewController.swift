//
//  ViewController.swift
//  DBChainKitDemo
//
//  Created by iOS on 2021/10/22.
//

import UIKit
import DBChainKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

//        let mnemonic = DBChain.mnemonicStr
//        print(mnemonic)
//        let mnemonic = "ecology alpha fine disorder parade beach antenna slogan dial auto random chase"

        let mnemonic = "ecology alpha fine disorder parade beach antenna slogan dial auto"
        let pristr = DBChain.privateKey(mnemonicStr: mnemonic)
        let pubstr = DBChain.publicKey(privateString: pristr)

        print(pristr)
        print(pubstr)

        let addressStr = DBChain.address(publickeyStr: pubstr)
        print(addressStr)

        print("--------")

        DBChain.mnemonicStr = mnemonic
        let pri = DBChain.privatekey
        let pub = DBChain.publickey
        print("\(pri) \n\(pub)")
        let address = DBChain.address
        print(address)

    }


}

