//
//  Project.swift
//  Wearvelop
//
//  Created by Philip Kluz on 2018-12-15.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import Foundation

public final class Project: Codable {
    
    // MARK: - Project
    
    public let id: String
    public let title: String
    public let color: Color
    
    public init(id: String?, title: String, color: Color = .random()) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.color = color
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case color
    }
    
    // MARK: - Decodable
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try values.decode(String.self, forKey: .id)
        let title = try values.decode(String.self, forKey: .title)
        let color = try values.decode(Color.self, forKey: .color)
        
        self.id = id
        self.title = title
        self.color = color
    }
    
    // MARK: - Encodable
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(color, forKey: .color)
    }
}
