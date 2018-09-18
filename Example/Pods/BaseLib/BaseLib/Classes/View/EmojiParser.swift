//
//  EmojiParser.swift
//  Alamofire
//
//  Created by yaxun on 2018/7/27.
//

import UIKit


public enum ThemeColor {
    case theme           // 主色偏黑 (导航条)
    case gray_bg         // 背景色 (背景色 分割线颜色)
    case sky_blue        // 天蓝色 (辅助蓝色主色)
    case font_black      // 纯黑色
    case font_less_black // 字体黑 (#333333)
    case font_light_Gray // 淡灰色 (#666666)
    case font_gray       // 字体灰 (#999999灰色字体)
    
}

public extension ThemeColor {
    var color: UIColor {
        get {
            switch self {
            case .theme:
                return UIColor.getColor(hex: "292933")!
            case .gray_bg:
                return UIColor.getColor(hex: "f2f2f2")!
            case .sky_blue:
                return UIColor.getColor(hex: "368efb")!
            case .font_less_black:
                return UIColor.getColor(hex: "333333")!
            case .font_light_Gray:
                return UIColor.getColor(hex: "666666")!
            case .font_gray:
                return UIColor.getColor(hex: "999999")!
            case .font_black:
                return UIColor.getColor(hex: "000000")!
            }
        }
    }
}

public enum ThemeString: String {
    case appName = "慧选股"
    case homeModule = "智投"
    case javis = "JARVIS"
    case market = "市场"
    case dynamic = "动态"
    case profile = "我的"
}


class EmojiParser { }

public var emojiParseDict: [String : UIImage] = {
    
    let bundle = Bundle.init(path: Bundle.init(for: EmojiParser.self).bundlePath + "/BaseLib.bundle")
    
    print("path = >", Bundle.init(for: EmojiParser.self).bundlePath + "/BaseLib.bundle" )
    
    return ["[微笑]" :UIImage.init(named: "Expression_1@2x", in: bundle, compatibleWith: nil)!,
        "[撇嘴]":UIImage.init(named: "Expression_2@2x", in: bundle, compatibleWith: nil)!,
        "[色]":UIImage.init(named: "Expression_3@2x", in: bundle, compatibleWith: nil)!,
        "[发呆]":UIImage.init(named: "Expression_4@2x", in: bundle, compatibleWith: nil)!,
        "[得意]":UIImage.init(named: "Expression_5@2x", in: bundle, compatibleWith: nil)!,
        "[流泪]":UIImage.init(named: "Expression_6@2x", in: bundle, compatibleWith: nil)!,
        "[害羞]":UIImage.init(named: "Expression_7@2x", in: bundle, compatibleWith: nil)!,
        "[闭嘴]":UIImage.init(named: "Expression_8@2x", in: bundle, compatibleWith: nil)!,
        "[睡]":UIImage.init(named: "Expression_9@2x", in: bundle, compatibleWith: nil)!,
        "[大哭]":UIImage.init(named: "Expression_10@2x", in: bundle, compatibleWith: nil)!,
        "[尴尬]":UIImage.init(named: "Expression_11@2x", in: bundle, compatibleWith: nil)!,
        "[调皮]":UIImage.init(named: "Expression_13@2x", in: bundle, compatibleWith: nil)!,
        "[呲牙]":UIImage.init(named: "Expression_14@2x", in: bundle, compatibleWith: nil)!,
        "[惊讶]":UIImage.init(named: "Expression_15@2x", in: bundle, compatibleWith: nil)!,
        "[难过]":UIImage.init(named: "Expression_16@2x", in: bundle, compatibleWith: nil)!,
        "[冷汗]":UIImage.init(named: "Expression_18@2x", in: bundle, compatibleWith: nil)!,
        "[偷笑]":UIImage.init(named: "Expression_21@2x", in: bundle, compatibleWith: nil)!,
        "[可爱]":UIImage.init(named: "Expression_22@2x", in: bundle, compatibleWith: nil)!,
        "[白眼]":UIImage.init(named: "Expression_23@2x", in: bundle, compatibleWith: nil)!,
        "[傲慢]":UIImage.init(named: "Expression_24@2x", in: bundle, compatibleWith: nil)!,
        "[饥饿]":UIImage.init(named: "Expression_25@2x", in: bundle, compatibleWith: nil)!,
        "[困]":UIImage.init(named: "Expression_26@2x", in: bundle, compatibleWith: nil)!,
        "[惊恐]":UIImage.init(named: "Expression_27@2x", in: bundle, compatibleWith: nil)!,
        "[流汗]":UIImage.init(named: "Expression_28@2x", in: bundle, compatibleWith: nil)!,
        "[憨笑]":UIImage.init(named: "Expression_29@2x", in: bundle, compatibleWith: nil)!,
        "[大兵]":UIImage.init(named: "Expression_30@2x", in: bundle, compatibleWith: nil)!,
        "[奋斗]":UIImage.init(named: "Expression_31@2x", in: bundle, compatibleWith: nil)!,
        "[疑问]":UIImage.init(named: "Expression_33@2x", in: bundle, compatibleWith: nil)!,
        "[嘘]":UIImage.init(named: "Expression_34@2x", in: bundle, compatibleWith: nil)!,
        "[晕]":UIImage.init(named: "Expression_35@2x", in: bundle, compatibleWith: nil)!,
        "[激动]":UIImage.init(named: "Expression_36@2x", in: bundle, compatibleWith: nil)!,
        "[衰]":UIImage.init(named: "Expression_37@2x", in: bundle, compatibleWith: nil)!,
        "[再见]":UIImage.init(named: "Expression_40@2x", in: bundle, compatibleWith: nil)!,
        "[擦汗]":UIImage.init(named: "Expression_41@2x", in: bundle, compatibleWith: nil)!,
        "[抠鼻]":UIImage.init(named: "Expression_42@2x", in: bundle, compatibleWith: nil)!,
        "[鼓掌]":UIImage.init(named: "Expression_43@2x", in: bundle, compatibleWith: nil)!,
        "[糗大了]":UIImage.init(named: "Expression_44@2x", in: bundle, compatibleWith: nil)!,
        "[坏笑]":UIImage.init(named: "Expression_45@2x", in: bundle, compatibleWith: nil)!,
        "[左哼哼]":UIImage.init(named: "Expression_46@2x", in: bundle, compatibleWith: nil)!,
        "[右哼哼]":UIImage.init(named: "Expression_47@2x", in: bundle, compatibleWith: nil)!,
        "[哈欠]":UIImage.init(named: "Expression_48@2x", in: bundle, compatibleWith: nil)!,
        "[鄙视]":UIImage.init(named: "Expression_49@2x", in: bundle, compatibleWith: nil)!,
        "[委屈]":UIImage.init(named: "Expression_50@2x", in: bundle, compatibleWith: nil)!,
        "[快哭了]":UIImage.init(named: "Expression_51@2x", in: bundle, compatibleWith: nil)!,
        "[阴笑]":UIImage.init(named: "Expression_52@2x", in: bundle, compatibleWith: nil)!,
        "[亲亲]":UIImage.init(named: "Expression_53@2x", in: bundle, compatibleWith: nil)!,
        "[吓]":UIImage.init(named: "Expression_54@2x", in: bundle, compatibleWith: nil)!,
        "[可怜]":UIImage.init(named: "Expression_55@2x", in: bundle, compatibleWith: nil)!,
        "[西瓜]":UIImage.init(named: "Expression_57@2x", in: bundle, compatibleWith: nil)!,
        "[啤酒]":UIImage.init(named: "Expression_58@2x", in: bundle, compatibleWith: nil)!,
        "[咖啡]":UIImage.init(named: "Expression_61@2x", in: bundle, compatibleWith: nil)!,
        "[猪头]":UIImage.init(named: "Expression_63@2x", in: bundle, compatibleWith: nil)!,
        "[心碎]":UIImage.init(named: "Expression_68@2x", in: bundle, compatibleWith: nil)!,
        "[拥抱]":UIImage.init(named: "Expression_79@2x", in: bundle, compatibleWith: nil)!,
        "[胜利]":UIImage.init(named: "Expression_83@2x", in: bundle, compatibleWith: nil)!,
        "[勾引]":UIImage.init(named: "Expression_85@2x", in: bundle, compatibleWith: nil)!,
        "[拳头]":UIImage.init(named: "Expression_86@2x", in: bundle, compatibleWith: nil)!,
        "[爱你]":UIImage.init(named: "Expression_88@2x", in: bundle, compatibleWith: nil)!,
        "[no]":UIImage.init(named: "Expression_89@2x", in: bundle, compatibleWith: nil)!,
        "[ok]":UIImage.init(named: "Expression_90@2x", in: bundle, compatibleWith: nil)!]
    
    
    
    
}()

public var emojiList = [["[微笑]":"Expression_1"],["[撇嘴]":"Expression_2"],["[色]":"Expression_3"],["[发呆]":"Expression_4"],["[得意]":"Expression_5"],["[流泪]":"Expression_6"],["[害羞]":"Expression_7"],["[闭嘴]":"Expression_8"],["[睡]":"Expression_9"],["[大哭]":"Expression_10"],["[尴尬]":"Expression_11"],["[调皮]":"Expression_13"],["[呲牙]":"Expression_14"],["[惊讶]":"Expression_15"],["[难过]":"Expression_16"],["[冷汗]":"Expression_18"],["[偷笑]":"Expression_21"],["[可爱]":"Expression_22"],["[白眼]":"Expression_23"],["[傲慢]":"Expression_24"],["[饥饿]":"Expression_25"],["[困]":"Expression_26"],["[惊恐]":"Expression_27"],["[流汗]":"Expression_28"],["[憨笑]":"Expression_29"],["[大兵]":"Expression_30"],["[奋斗]":"Expression_31"],["[疑问]":"Expression_33"],["[嘘]":"Expression_34"],["[晕]":"Expression_35"],["[激动]":"Expression_36"],["[衰]":"Expression_37"],["[再见]":"Expression_40"],["[擦汗]":"Expression_41"],["[抠鼻]":"Expression_42"],["[鼓掌]":"Expression_43"],["[糗大了]":"Expression_44"],["[坏笑]":"Expression_45"],["[左哼哼]":"Expression_46"],["[右哼哼]":"Expression_47"],["[哈欠]":"Expression_48"],["[鄙视]":"Expression_49"],["[委屈]":"Expression_50"],["[快哭了]":"Expression_51"],["[阴笑]":"Expression_52"],["[亲亲]":"Expression_53"],["[吓]":"Expression_54"],["[可怜]":"Expression_55"],["[西瓜]":"Expression_57"],["[啤酒]":"Expression_58"],["[咖啡]":"Expression_61"],["[猪头]":"Expression_63"],["[心碎]":"Expression_68"],["[拥抱]":"Expression_79"],["[胜利]":"Expression_83"],["[勾引]":"Expression_85"],["[拳头]":"Expression_86"],["[爱你]":"Expression_88"],["[no]":"Expression_89"],["[ok]":"Expression_90"]]
