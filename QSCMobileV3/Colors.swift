//
//  Colors.swift
//  QSCMobileV3
//
//  Created by afan on 2019/9/5.
//  Copyright © 2019 QSC Tech. All rights reserved.
//

import Foundation

enum ColorCompatibility {
    static var curriculaLabel: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        return .white
    }
    static var label: UIColor {
        if #available(iOS 13, *) {
            return .label
        }
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    static var secondaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .secondaryLabel
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.6)
    }
    static var tertiaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .tertiaryLabel
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.3)
    }
    static var quaternaryLabel: UIColor {
        if #available(iOS 13, *) {
            return .quaternaryLabel
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.18)
    }
    static var systemFill: UIColor {
        if #available(iOS 13, *) {
            return .systemFill
        }
        return UIColor(red: 0.47058823529411764, green: 0.47058823529411764, blue: 0.5019607843137255, alpha: 0.2)
    }
    static var secondarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemFill
        }
        return UIColor(red: 0.47058823529411764, green: 0.47058823529411764, blue: 0.5019607843137255, alpha: 0.16)
    }
    static var tertiarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemFill
        }
        return UIColor(red: 0.4627450980392157, green: 0.4627450980392157, blue: 0.5019607843137255, alpha: 0.12)
    }
    static var quaternarySystemFill: UIColor {
        if #available(iOS 13, *) {
            return .quaternarySystemFill
        }
        return UIColor(red: 0.4549019607843137, green: 0.4549019607843137, blue: 0.5019607843137255, alpha: 0.08)
    }
    static var placeholderText: UIColor {
        if #available(iOS 13, *) {
            return .placeholderText
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.3)
    }
    static var systemBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemBackground
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    static var secondarySystemBackground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemBackground
        }
        return UIColor(red: 0.9490196078431372, green: 0.9490196078431372, blue: 0.9686274509803922, alpha: 1.0)
    }
    static var tertiarySystemBackground: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemBackground
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    static var systemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .systemGroupedBackground
        }
        return UIColor(red: 0.9490196078431372, green: 0.9490196078431372, blue: 0.9686274509803922, alpha: 1.0)
    }
    static var secondarySystemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .secondarySystemGroupedBackground
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    static var tertiarySystemGroupedBackground: UIColor {
        if #available(iOS 13, *) {
            return .tertiarySystemGroupedBackground
        }
        return UIColor(red: 0.9490196078431372, green: 0.9490196078431372, blue: 0.9686274509803922, alpha: 1.0)
    }
    static var separator: UIColor {
        if #available(iOS 13, *) {
            return .separator
        }
        return UIColor(red: 0.23529411764705882, green: 0.23529411764705882, blue: 0.2627450980392157, alpha: 0.29)
    }
    static var opaqueSeparator: UIColor {
        if #available(iOS 13, *) {
            return .opaqueSeparator
        }
        return UIColor(red: 0.7764705882352941, green: 0.7764705882352941, blue: 0.7843137254901961, alpha: 1.0)
    }
    static var link: UIColor {
        if #available(iOS 13, *) {
            return .link
        }
        return UIColor(red: 0.0, green: 0.47843137254901963, blue: 1.0, alpha: 1.0)
    }
    static var darkText: UIColor {
        if #available(iOS 13, *) {
            return .darkText
        }
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
    static var lightText: UIColor {
        if #available(iOS 13, *) {
            return .lightText
        }
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
    }
    static var systemBlue: UIColor {
        if #available(iOS 13, *) {
            return .systemBlue
        }
        return UIColor(red: 0.0, green: 0.47843137254901963, blue: 1.0, alpha: 1.0)
    }
    static var systemGreen: UIColor {
        if #available(iOS 13, *) {
            return .systemGreen
        }
        return UIColor(red: 0.20392156862745098, green: 0.7803921568627451, blue: 0.34901960784313724, alpha: 1.0)
    }
    static var systemIndigo: UIColor {
        if #available(iOS 13, *) {
            return .systemIndigo
        }
        return UIColor(red: 0.34509803921568627, green: 0.33725490196078434, blue: 0.8392156862745098, alpha: 1.0)
    }
    static var systemOrange: UIColor {
        if #available(iOS 13, *) {
            return .systemOrange
        }
        return UIColor(red: 1.0, green: 0.5843137254901961, blue: 0.0, alpha: 1.0)
    }
    static var systemPink: UIColor {
        if #available(iOS 13, *) {
            return .systemPink
        }
        return UIColor(red: 1.0, green: 0.17647058823529413, blue: 0.3333333333333333, alpha: 1.0)
    }
    static var systemPurple: UIColor {
        if #available(iOS 13, *) {
            return .systemPurple
        }
        return UIColor(red: 0.6862745098039216, green: 0.3215686274509804, blue: 0.8705882352941177, alpha: 1.0)
    }
    static var systemRed: UIColor {
        if #available(iOS 13, *) {
            return .systemRed
        }
        return UIColor(red: 1.0, green: 0.23137254901960785, blue: 0.18823529411764706, alpha: 1.0)
    }
    static var systemTeal: UIColor {
        if #available(iOS 13, *) {
            return .systemTeal
        }
        return UIColor(red: 0.35294117647058826, green: 0.7843137254901961, blue: 0.9803921568627451, alpha: 1.0)
    }
    static var systemYellow: UIColor {
        if #available(iOS 13, *) {
            return .systemYellow
        }
        return UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
    }
    static var systemGray: UIColor {
        if #available(iOS 13, *) {
            return .systemGray
        }
        return UIColor(red: 0.5568627450980392, green: 0.5568627450980392, blue: 0.5764705882352941, alpha: 1.0)
    }
    static var systemGray2: UIColor {
        if #available(iOS 13, *) {
            return .systemGray2
        }
        return UIColor(red: 0.6823529411764706, green: 0.6823529411764706, blue: 0.6980392156862745, alpha: 1.0)
    }
    static var systemGray3: UIColor {
        if #available(iOS 13, *) {
            return .systemGray3
        }
        return UIColor(red: 0.7803921568627451, green: 0.7803921568627451, blue: 0.8, alpha: 1.0)
    }
    static var systemGray4: UIColor {
        if #available(iOS 13, *) {
            return .systemGray4
        }
        return UIColor(red: 0.8196078431372549, green: 0.8196078431372549, blue: 0.8392156862745098, alpha: 1.0)
    }
    static var systemGray5: UIColor {
        if #available(iOS 13, *) {
            return .systemGray5
        }
        return UIColor(red: 0.8980392156862745, green: 0.8980392156862745, blue: 0.9176470588235294, alpha: 1.0)
    }
    static var systemGray6: UIColor {
        if #available(iOS 13, *) {
            return .systemGray6
        }
        return UIColor(red: 0.9490196078431372, green: 0.9490196078431372, blue: 0.9686274509803922, alpha: 1.0)
    }
    static var QSCGray: UIColor {
        if #available(iOS 13, *) {
            return UIColor { (trainCollection) -> UIColor in
                if trainCollection.userInterfaceStyle == .dark {
                    return UIColor.lightGray
                } else {
                    return UIColor.darkGray
                }
            }
        }
        return UIColor.darkGray
    }
}
