//
//  UserModel.swift
//  TinderDemo
//
//  Created by Thanh Pham on 9/24/20.
//

import Foundation

struct UserModelResponse: Decodable {
    let userModels: [UserModel]
    
    enum CodingKeys: String, CodingKey {
        case results = "results"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        userModels = try values.decode([UserModel].self, forKey: .results)
    }
    
    init(userModels: [UserModel]) {
        self.userModels = userModels
    }
}

struct UserModel: Codable {
    let id: String?
    let name: Name
    let picture: Picture
    let email: String
    let dob: DOB
    let address: Address
    let phone: String
    let login: Login
    
    struct Name: Codable {
        let firstName: String
        let lastName: String
        
        var fullName: String {
            return firstName + " " + lastName
        }
        
        enum CodingKeys: String, CodingKey {
            case firstName = "first"
            case lastName = "last"
        }
    }
    
    struct Address: Codable {
        let street: Location
        
        var fullAddress: String {
            return "\(street.number) \(street.name)"
        }
        
        struct Location: Codable {
            let number: Int
            let name: String
        }
        
        enum CodingKeys: String, CodingKey {
            case street
        }
        
        init() {
            street = Location(number: 0, name: "")
        }
    
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            street = try values.decode(Location.self, forKey: .street)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(street, forKey: .street)
        }
    }
    
    struct Picture: Codable {
        let large: String
        let medium: String
        let thumbnail: String
    }
    
    struct Login: Codable {
        let username: String
        let password: String
    }
    
    struct DOB: Codable {
        let date: Date?
        
        enum CodingKeys: String, CodingKey {
            case date
        }
        
        init() {
            self.date = Date()
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            let dobStr = try values.decode(String.self, forKey: .date)
            date = dateFormatter.date(from: dobStr)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            if let date = date {
                let dobStr = self.dateFormatter.string(from: date)
                try container.encode(dobStr, forKey: .date)
            }
        }
        
        private var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            return formatter
        }()
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case picture = "picture"
        case address = "location"
        case email = "email"
        case dob = "dob"
        case phone = "phone"
        case login = "login"
    }
    
    enum IdKeys: String, CodingKey {
        case name
        case value
    }
    
    
    static func userStub() -> UserModel {
        let userModel = UserModel()
        return userModel
    }
    
    private init() {
        self.id = nil
        self.name = Name(firstName: "", lastName: "")
        self.picture = Picture(large: "", medium: "", thumbnail: "")
        self.email = ""
        self.dob = DOB()
        self.address = Address()
        self.phone = ""
        self.login = Login(username: "", password: "")
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var idContainer = container.nestedContainer(keyedBy: IdKeys.self, forKey: .id)
        try idContainer.encode(id, forKey: .value)
        try container.encode(name, forKey: .name)
        try container.encode(picture, forKey: .picture)
        try container.encode(email, forKey: .email)
        try container.encode(dob, forKey: .dob)
        try container.encode(address, forKey: .address)
        try container.encode(phone, forKey: .phone)
        try container.encode(login, forKey: .login)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try values.nestedContainer(keyedBy: IdKeys.self, forKey: .id)
        id = try? idContainer.decode(String.self, forKey: .value)
        
        name = try values.decode(Name.self, forKey: .name)
        picture = try values.decode(Picture.self, forKey: .picture)
        email = try values.decode(String.self, forKey: .email)
        dob = try values.decode(DOB.self, forKey: .dob)
        address = try values.decode(Address.self, forKey: .address)
        phone = try values.decode(String.self, forKey: .phone)
        login = try values.decode(Login.self, forKey: .login)
    }
}
