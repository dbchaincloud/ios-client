//
//  Extension.swift
//  DBChain
//
//  Created by iOS on 2020/10/24.
//

import Foundation

// MARK: 字典转字符串

extension Dictionary{

    public func convertDictionaryToJSONString(dict:NSDictionary?)->String {
        let data = try? JSONSerialization.data(withJSONObject: dict!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
        let jsonStr = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
        return jsonStr! as String
    }

    public func dicValueString(_ dic:[String : Any]) -> String?{
        var jsonData = Data()
        var jsonStr = String()
        do {
            if #available(iOS 11.0, *) {
                jsonData = try JSONSerialization.data(withJSONObject: dic, options: .sortedKeys)
            } else {
                // Fallback on earlier versions
            }
            jsonStr = String(data: jsonData, encoding: .utf8)!
        } catch {
            return nil;
        }
        return jsonStr
       }

    // MARK: 字典转字符串 无序
    public func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: []) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }

    // MARK: 打印时
    public func jsonPrint() {
        let ff = try! JSONSerialization.data(withJSONObject:self, options: [])
        let str = String(data:ff, encoding: .utf8)
        print(str!)
    }

    // MARK: 字典转字符串  有序
    public func creatJsonString(dict: [String:Any]) ->String{

        if(!JSONSerialization.isValidJSONObject(dict)) {
            return ""
        }
        var namedPaird = [String]()
        let sortedKeysAndValues = dict.sorted{$0.0 < $1.0}
        for(key, value) in sortedKeysAndValues {
            if value is [String:Any] {
                namedPaird.append("\"\(key)\":\(self.creatJsonString(dict: value as! [String:Any]))")
            } else if value is [Any] {
                let arr = value as! Array<Any>
                if arr.isEmpty {
                    namedPaird.append("\"\(key)\":\(value)")
                } else if arr.first is [String : Any]{
                    let dic : [String : Any] = arr.first as! [String : Any]
                    namedPaird.append("\"\(key)\":[\(self.creatJsonString(dict: dic ))]")
                } else {
                    namedPaird.append("\"\(key)\":\(value)")
                }
            } else {
                namedPaird.append("\"\(key)\":\"\(value)\"")
            }
        }
        let returnString = namedPaird.joined(separator:",")

        return "{\(returnString)}"
    }


    public func dictionaryToData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
        }
        return nil
    }
}


extension StringProtocol {
    internal var hexaData: Data { .init(hexa) }
    internal var hexaBytes: [UInt8] { .init(hexa) }
    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { start in
            guard start < self.endIndex else { return nil }
            let end = self.index(start, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { start = end }
            return UInt8(self[start..<end], radix: 16)
        }
    }
}


// 二进制数据
extension Data {

    internal func toHex() -> String {
        return map { String(format: "%02x", UInt8($0)) }.joined()
    }

    public func dataToDictionary() -> [String: Any]? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: []) as? [String : Any]
        } catch {
        }
        return nil
    }
}

// 时间
extension Date {

    /// 获取当前 秒级 时间戳 - 10位
    public var timeStamp : String {
         let timeInterval: TimeInterval = self.timeIntervalSince1970
         let timeStamp = Int(timeInterval)
         return "\(timeStamp)"
     }

    /// 获取当前 毫秒级 时间戳 - 13位
    public var milliStamp : String {
          let timeInterval: TimeInterval = self.timeIntervalSince1970
          let millisecond = CLongLong(round(timeInterval*1000))
          return "\(millisecond)"
      }

    //日期 -> 字符串
    public func dateToString(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }

    //字符串 -> 日期
    public func stringToDate(_ string:String, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.date(from: string)
        if date == nil {
            return Date.init()
        }
        return date!
    }


    /// 是否为几天前的日期
    /// - Parameter time: <#time description#>
    /// - dayNum :  天数
    /// - Returns:
    public func callTimeAfewDaysago(timeStamp: Double,dayNum:Int) -> Bool {

        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        //时间差
        let reduceTime : TimeInterval = currentTime - timeSta

        /// 测试用  大于 30 分钟
//        let mins = Int(reduceTime / 60)
//        if mins > 30 {
//            return true
//        }

        let days = Int(reduceTime / 3600 / 24)
        if days > dayNum {
            return true
        }
        return false
    }

    // MARK: 4.1、取得与当前时间的间隔差
    /// 取得与当前时间的间隔差
    /// - Returns: 时间差
    public func callTimeAfterNow() -> String {
        let timeInterval = Date().timeIntervalSince(self)
        if timeInterval < 0 {
            return "刚刚"
        }

        let interval = fabs(timeInterval)

        let i60 = interval/60
        let i3600 = interval/3600
        let i86400 = interval/86400
        let i2592000 = interval/2592000
        let i31104000 = interval/31104000

        var time:String!

        if i3600 < 1 {
            let s = NSNumber(value: i60 as Double).intValue
            if s == 0 {
                time = "刚刚"
            } else {
                time = "\(s)分钟前"
            }
        } else if i86400 < 1 {
            let s = NSNumber(value: i3600 as Double).intValue
            time = "\(s)小时前"
        } else if i2592000 < 1 {
            let s = NSNumber(value: i86400 as Double).intValue
            time = "\(s)天前"
        } else if i31104000 < 1 {
            let s = NSNumber(value: i2592000 as Double).intValue
            time = "\(s)个月前"
        } else {
            let s = NSNumber(value: i31104000 as Double).intValue
            time = "\(s)年前"
        }
        return time
    }
}

extension String {
    //  字符串是否为空
    public var isBlank: Bool {
         let trimmedStr = self.trimmingCharacters(in: .whitespacesAndNewlines)
         return trimmedStr.isEmpty
     }
}



//extension UIColor {
//    //MARK: - RGB
//      class func RGBColor(red : CGFloat, green : CGFloat, blue :CGFloat ) -> UIColor {
//          return UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha:1)
//      }
//      class func RGBColor(_ RGB:CGFloat) -> UIColor {
//          return RGBColor(red: RGB, green: RGB, blue: RGB)
//      }
//      //MARK: - 16进制字符串转UIColor
//      class func colorWithHexString(_ hex:String) ->UIColor {
//          return colorWithHexString(hex, alpha:1)
//      }
//      class func colorWithHexString (_ hex:String, alpha:CGFloat) -> UIColor {
//          var cString:String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
//          if (cString.hasPrefix("#")) {
//              cString = (cString as NSString).substring(from:1)
//          } else if (cString.hasPrefix("0X") || cString.hasPrefix("0x")) {
//              cString = (cString as NSString).substring(to: 2)
//          }
//          if ((cString as NSString).length != 6) {
//              return gray
//          }
//          let rString = (cString as NSString).substring(to:2)
//          let gString = ((cString as NSString).substring(from:2) as NSString).substring(to: 2)
//          let bString = ((cString as NSString).substring(from:4) as NSString).substring(to: 2)
//          var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
//          Scanner(string: rString).scanHexInt32(&r)
//          Scanner(string: gString).scanHexInt32(&g)
//          Scanner(string: bString).scanHexInt32(&b)
//          return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
//      }
//
//    /// 随机颜色
//        class var randomColor:UIColor{
//           get{
//               let red = CGFloat(arc4random()%256)/255.0
//               let green = CGFloat(arc4random()%256)/255.0
//               let blue = CGFloat(arc4random()%256)/255.0
//               return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
//           }
//       }
//}


//extension UIView {
//    func leadingConstraint(_ item: UIView, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint(
//            item: item,
//            attribute: attribute,
//            relatedBy: .equal,
//            toItem: self,
//            attribute: .leading,
//            multiplier: 1,
//            constant: -constant
//        )
//    }
//
//    func trailingConstraint(_ item: UIView, constant: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint(
//            item: item,
//            attribute: .trailing,
//            relatedBy: .greaterThanOrEqual,
//            toItem: self,
//            attribute: .trailing,
//            multiplier: 1,
//            constant: constant
//        )
//    }
//
//    func topConstraint(_ item: UIView, attribute: NSLayoutConstraint.Attribute, constant: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint(
//            item: item,
//            attribute: attribute,
//            relatedBy: .equal,
//            toItem: self,
//            attribute: .top,
//            multiplier: 1,
//            constant: -constant
//        )
//    }
//
//    func bottomConstraint(_ item: UIView, constant: CGFloat) -> NSLayoutConstraint {
//        return NSLayoutConstraint(
//            item: item,
//            attribute: .bottom,
//            relatedBy: .equal,
//            toItem: self,
//            attribute: .bottom,
//            multiplier: 1,
//            constant: constant
//        ).priority(990)
//    }
//}

//extension NSLayoutConstraint {
//    func priority(_ value: CGFloat) -> NSLayoutConstraint {
//        self.priority = UILayoutPriority(Float(value))
//        return self
//    }
//}


//extension Double {
//
//    /// Rounds the double to decimal places value
//    /// 输入要保留的小数个数
//    func roundTo(places:Int) -> Double {
//
//        let divisor = pow(10.0, Double(places))
//
//        return (self * divisor).rounded() / divisor
//
//    }
//
//}
