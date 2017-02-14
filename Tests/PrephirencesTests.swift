//
//  PrephirencesTests.swift
//  PrephirencesTests
//
//  Created by phimage on 05/06/15.
//  Copyright (c) 2017 phimage. All rights reserved.
//

import Foundation
import XCTest
@testable import Prephirences
#if os(iOS)
    import UIKit
#endif
#if os(OSX)
    import AppKit
#endif

class PrephirencesTests: XCTestCase {

    let mykey = "key"
    let myvalue = "value"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func printPreferences(_ preferences: PreferencesType) {
        for (key,value) in preferences.dictionary() {
            print("\(key)=\(value)")
        }
    }

    func printDictionaryPreferences(_ dictionaryPreferences: DictionaryPreferences) {
        printPreferences(dictionaryPreferences)
        for (key,value) in dictionaryPreferences {
            print("\(key)=\(value)")
        }
    }

    func testFromDictionary() {
        let preferences = DictionaryPreferences(dictionary: [mykey: myvalue, "key2": "value2"])
        printDictionaryPreferences(preferences)
    }

    func testFromDictionaryLiteral() {
        let preferences: DictionaryPreferences = [mykey: myvalue, "key2": "value2"]
        printDictionaryPreferences(preferences)
    }

    /*func testWriteDictionaryLiteral() {
        var preferences: DictionaryPreferences = [mykey: myvalue, "key2": "value2"]
        printDictionaryPreferences(preferences)

        preferences.writeToFile("/tmp/prephirence.test", atomically: true)

    }*/

    func testFromFile() {
        if let filePath = Bundle(for: type(of: self)).path(forResource: "Test", ofType: "plist") {
            if  let preference = DictionaryPreferences(filePath: filePath) {
                    for (key,value) in preference.dictionary() {
                        print("\(key)=\(value)")
                    }

            } else {
                XCTFail("Failed to read from file")
            }
        }else {
            XCTFail("Failed to get file url")
        }


        if  let  preference = DictionaryPreferences(filename: "Test", ofType: "plist", bundle: Bundle(for: type(of: self))) {
            for (key,value) in preference.dictionary() {
                print("\(key)=\(value)")
            }

        } else {
            XCTFail("Failed to read from file using shortcut init")
        }

    }

    func testUserDefaults() {
        let userDefaults = Foundation.UserDefaults.standard
        printPreferences(userDefaults)



        userDefaults[mykey] = myvalue
        XCTAssert(userDefaults[mykey] as! String == myvalue, "not affected")
        userDefaults[mykey] = nil
        XCTAssert(userDefaults[mykey] as? String ?? nil == nil, "not nil affected") // return a proxyPreferences


        userDefaults.set(myvalue, forKey:mykey)
        XCTAssert(userDefaults.object(forKey: mykey) as! String == myvalue, "not affected")
        userDefaults.set(nil, forKey:mykey)
        XCTAssert(userDefaults.object(forKey: mykey) as? String ?? nil == nil, "not nil affected") // return a proxyPreferences

        userDefaults.set(myvalue, forKey:mykey)
        XCTAssert(userDefaults.string(forKey: mykey) == myvalue, "not affected")
        userDefaults.set(nil, forKey:mykey)
        XCTAssert(userDefaults.string(forKey: mykey) == nil, "not nil affected")
    }

    func testUserDefaultsProxy() {
        let userDefaults = Foundation.UserDefaults.standard

        let appKey = "appname"
        let appDefaults = MutableProxyPreferences(preferences: userDefaults, key: appKey, separator: UserDefaultsKeySeparator)

        let fullKey = appKey + UserDefaultsKeySeparator + mykey

        appDefaults[mykey] = myvalue
        XCTAssert(appDefaults[mykey] as! String == myvalue, "not affected")
        XCTAssert(userDefaults[fullKey] as! String == myvalue, "not affected")
        appDefaults[mykey] = nil
        XCTAssert(appDefaults[mykey] as? String ?? nil == nil, "not nil affected")
        XCTAssert(userDefaults[fullKey] as? String ?? nil == nil, "not nil affected")

    }

    func testPreference() {
        let userDefaults = Foundation.UserDefaults.standard

        var intPref: MutablePreference<Int> = userDefaults <| "int"
        intPref.value = nil
        intPref.value = 0

        intPref = userDefaults <| "int"

        intPref += 1
        XCTAssert(intPref.value! == 1)
        intPref -= 1
        XCTAssert(intPref.value! == 0)
        intPref += 30
        XCTAssert(intPref.value! == 30)
        intPref -= 30
        XCTAssert(intPref.value! == 0)

        intPref.value = 1
        XCTAssert(intPref.value! == 1)

        intPref *= 20
        XCTAssert(intPref.value! == 20)
        intPref %= 7
        XCTAssert(intPref.value! == 6)
        intPref %= 2
        XCTAssert(intPref.value! == 0)

        intPref += 30
        intPref /= 3
        XCTAssert(intPref.value! == 10)

        switch(intPref) {
        case 1: XCTFail("not equal in switch")
        case 10: print("ok")
        default: XCTFail("not equal in switch")
        }

        switch(intPref) {
        case 0...9: XCTFail("not equal in switch")
        case 11...999: XCTFail("not equal in switch")
        case 9...11: print("ok")
        default: XCTFail("not equal in switch")
        }


        var boolPref: MutablePreference<Bool> = userDefaults.preference(forKey: "bool")
        boolPref.value = nil

        boolPref &&= false
        XCTAssert(boolPref.value! == false)
        boolPref &&= true
        XCTAssert(boolPref.value! == false)

        boolPref.value = true
        XCTAssert(boolPref.value! == true)
        boolPref &&= true
        XCTAssert(boolPref.value! == true)
        boolPref &&= false
        XCTAssert(boolPref.value! == false)

        boolPref != false
        XCTAssert(boolPref.value! == true)


        boolPref ||= true
        XCTAssert(boolPref.value! == true)
        boolPref ||= false
        XCTAssert(boolPref.value! == true)

        boolPref != true
        XCTAssert(boolPref.value! == false)

        boolPref ||= false
        XCTAssert(boolPref.value! == false)
        boolPref ||= true
        XCTAssert(boolPref.value! == true)

        switch(boolPref) {
        case true: print("ok")
        case false: XCTFail("not true")
        default: XCTFail("nil")
        }

        let anInt: Int = 10 // FIXME failed with 1 -> data is bool, not int
        let intFromBoolPref: MutablePreference<Int> = boolPref.transform { value in
            return (value ?? false) ? anInt : 0
        }
        guard let v = intFromBoolPref.value else {
            XCTFail("nil value")
            return
        }
        let expected = (boolPref.value ?? false) ? anInt : 0
        XCTAssertEqual(v, expected)



        var stringPref: MutablePreference<String> = userDefaults.preference(forKey: "string")
        stringPref.value = "pref"

        stringPref += "erence"
        XCTAssert(stringPref.value! == "preference")

        stringPref.apply { value in
            return value?.uppercased()
        }

        XCTAssert(stringPref.value! == "preference".uppercased())
    }


    func testArchive() {

        var preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]

        let value = UIColor.blue
        let key = "color"
        preferences[key, .archive] = value


        guard let unarchived = preferences[key, .archive] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        XCTAssertEqual(value, unarchived)

        guard let _ = preferences[key, .none] as? Data else {
            XCTFail("Cannot get data for \(key)")
            return
        }

        guard let _ = preferences[key] as? Data else {
            XCTFail("Cannot get data for \(key)")
            return
        }

        let colorPref: MutablePreference<UIColor> = preferences <| key
        colorPref.transformationKey = .archive

        guard let _ = colorPref.value else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        let value2 = UIColor.red
        colorPref.value = value2

        guard let unarchived2 = preferences[key, .archive] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        XCTAssertEqual(value2, unarchived2)


        let valueDefault = UIColor.yellow
        let whenNil = colorPref.whenNil(use: valueDefault)
        colorPref.value = nil
        XCTAssertEqual(valueDefault, whenNil.value)

    }

   func testClosure() {

        var preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]

        let colorDico: [String: UIColor] = ["blue": UIColor.blue, "red": UIColor.red]

        func transform(_ obj: Any?) -> Any? {
            if let color = obj as? UIColor {

                for (name, c) in colorDico {
                    if c == color {
                        return name
                    }
                }
            }
            return nil
        }
        func revert(_ obj: Any?) -> Any? {
            if let name = obj as? String {
                return colorDico[name]
            }
            return nil
        }

        let value = UIColor.blue
        let key = "color"
        preferences[key, .closureTuple(transform: transform, revert: revert)] = value


        guard let unarchived = preferences[key, .closureTuple(transform: transform, revert: revert)] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        XCTAssertEqual(value, unarchived)

        guard let _ = preferences[key, .none] as? String else {
            XCTFail("Cannot get string for \(key)")
            return
        }

        guard let _ = preferences[key] as? String else {
            XCTFail("Cannot get string for \(key)")
            return
        }

        let colorPref: MutablePreference<UIColor> = preferences <| key
        colorPref.transformationKey = .closureTuple(transform: transform, revert: revert)

        guard let _ = colorPref.value else {
            XCTFail("Cannot unarchive \(key)")
            return
        }

        let value2 = UIColor.red
        colorPref.value = value2

        guard let unarchived2 = preferences[key, .closureTuple(transform: transform, revert: revert)] as? UIColor else {
            XCTFail("Cannot unarchive \(key)")
            return
        }
        XCTAssertEqual(value2, unarchived2)

    }

    func testReflectingPreferences(){
        var pref = PrefStruc()

        XCTAssertEqual(pref.color, pref["color"] as? String)
        XCTAssertEqual(pref.age, pref["age"] as? Int)
        XCTAssertEqual(pref.enabled, pref["enabled"] as? Bool)

        pref.color = "blue"
        XCTAssertEqual(pref.color, pref["color"] as? String)

        let dico = pref.dictionary()
        XCTAssertEqual(dico.count, 3)
        for key in ["color","age","enabled"] {
            XCTAssertNotNil(dico[key])
        }
    }

    func testBundle() {
        let bundle = Bundle(for: PrephirencesTests.self)

        let applicationName = bundle[.CFBundleName] as? String

        XCTAssertNotNil(applicationName)
    }

    func testNSHTTPCookieStorage() {
        let storage = HTTPCookieStorage.shared
        let key = "name"
        let value = "value"

        var cookieProperties = [HTTPCookiePropertyKey: Any]()
        cookieProperties[HTTPCookiePropertyKey.name] = key
        cookieProperties[HTTPCookiePropertyKey.value] = value
        cookieProperties[HTTPCookiePropertyKey.domain] = "domain"
        cookieProperties[HTTPCookiePropertyKey.path] = "cookie.path"
        cookieProperties[HTTPCookiePropertyKey.version] = NSNumber(value: 1)
        cookieProperties[HTTPCookiePropertyKey.expires] = Date().addingTimeInterval(31536000)
        guard let newCookie = HTTPCookie(properties: cookieProperties) else {
            XCTFail("failed to create cookie")
            return
        }

        storage.setCookie(newCookie)

        let dico = storage.dictionary()
        XCTAssertFalse(dico.isEmpty)

        XCTAssertEqual(storage[key] as? String, value)
    }

    func testCollectionPreference () {
        struct KeyValue {
            var key: String
            var value: AnyObject
        }

        let collection = [
            KeyValue(key:"key", value: "value" as AnyObject),
            KeyValue(key:"key2", value: "value2" as AnyObject)
        ]

        let pref = CollectionPreferencesAdapter(collection: collection, mapKey: {$0.key}, mapValue: {$0.value})

        let dico = pref.dictionary()
        XCTAssertEqual(dico.count, collection.count)


        XCTAssertEqual(pref["key"] as? String, "value")
        XCTAssertEqual(pref["key2"] as? String, "value2")
        XCTAssertNil(pref["unusedkey"])
    }

    func testEnum() {
        let preferences: MutableDictionaryPreferences = [mykey: myvalue, "key2": "value2"]

        let key = "enumTest"
        let pref: MutablePreference<PrefEnum> = preferences <| key
        pref.value = nil
        var value = PrefEnum.Two
        pref.value = value

        pref.transformation = PrefEnum.preferenceTransformation
        pref.value = value
        XCTAssertEqual(pref.value, value)

        let fromPrefs: PrefEnum? = preferences.rawRepresentable(forKey: key)
        XCTAssertEqual(fromPrefs, value)

        value = PrefEnum.Three
        preferences.set(rawValue: value, forKey: key)
        XCTAssertEqual(pref.value, value)
    }

    func testEnsure() {
        let cent = 100
        let modeThan100: (Int?) -> Bool = {
            return $0.map { $0 > cent } ?? false
        }
        var cptDidSet = 0

        var intPref: MutablePreference<Int> = Foundation.UserDefaults.standard <| "intEnsure"
        intPref = intPref.whenNil(use: cent).ensure(when: modeThan100, use: cent).didSet({ (newValue, oldValue) in
            cptDidSet += 1
        })


        var modifCpt = 0
        let value = 80
        intPref.value = value
          modifCpt += 1
        XCTAssertEqual(value, intPref.value)
        intPref.value = nil
        modifCpt += 1
        XCTAssertEqual(intPref.value, cent)
        intPref.value = cent + 20
        modifCpt += 1
        XCTAssertEqual(intPref.value, cent)


        XCTAssertEqual(cptDidSet, modifCpt)
    }

    func testEnumKey() {
        enum TestKey: PreferenceKey {
            case color, age, enabled
        }

        var pref = PrefStruc()

        XCTAssertEqual(pref.color, pref.string(forKey: TestKey.color))
        XCTAssertEqual(pref.age, pref.integer(forKey: TestKey.age))
        XCTAssertEqual(pref.enabled, pref.bool(forKey: TestKey.enabled))

        pref.color = "blue"
        XCTAssertEqual(pref.color, pref.object(forKey: TestKey.color) as? String)
    }

}

struct PrefStruc {
    var color = "red"
    let age = 33
    let enabled = false
}

extension PrefStruc: ReflectingPreferences {}


enum PrefEnum0: Int {
    case one = 1
    case two = 2
    case three = 3
}
enum PrefEnum: String {
    case One, Two, Three
}

