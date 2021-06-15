//
//  UserSettings.swift
//  YourCurrency
//
//  Created by Екатерина Полупанова on 15.06.2021.
//

import UIKit

final class UserSettings {
    private enum SettingKeys: String {
        case userValue
        case dailyValue
    }
    static var userValue: Double! {
        get {
            return UserDefaults.standard.double(forKey: SettingKeys.userValue.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = SettingKeys.userValue.rawValue
            if let value = newValue{
                defaults.set(value,forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var dailyValue: Double! {
        get {
            return UserDefaults.standard.double(forKey: SettingKeys.dailyValue.rawValue)
        } set {
            let defaults = UserDefaults.standard
            let key = SettingKeys.dailyValue.rawValue
            if let value = newValue{
                defaults.set(value,forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    

}
