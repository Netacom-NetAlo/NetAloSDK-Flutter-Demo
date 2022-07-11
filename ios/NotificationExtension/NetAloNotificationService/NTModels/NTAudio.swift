//
//  IMAudio.swift
//  NetaloSDK
//
//  Created by Nguyên Duy on 6/11/20.
//  Copyright © 2020 'Netalo'. All rights reserved.
//

import UIKit

public struct NTAudioResponse: Codable {
    public let audio: NTAudio
}

public struct NTAudio: Codable {
    public let url: String
    public let duration: UInt
    
    public init(url: String, duration: UInt) {
        self.url = url
        self.duration = duration
    }
}

public struct NTImage: Codable {
    public let url: String
    public let width: UInt?
    public let height: UInt?
    public let subIndex: UInt?
    
    enum CodingKeys: String, CodingKey {
        case url, width, height
        case subIndex = "sub_index"
    }
    
    public init(url: String, width: UInt?, height: UInt?, subIndex: UInt?) {
        self.url = url
        self.width = width
        self.height = height
        self.subIndex = subIndex
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = container.decodex(key: .url, defaultValue: "")
        width = container.decodex(key: .width, defaultValue: 0)
        height = container.decodex(key: .height, defaultValue: 0)
        subIndex = container.decodex(key: .subIndex, defaultValue: 0)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try? container.encode(width, forKey: .width)
        try? container.encode(height, forKey: .height)
        try? container.encode(subIndex, forKey: .subIndex)
    }
}

public struct NTVideoResponse: Codable {
    public let video: NTVideo
}

public struct NTVideo: Codable {
    public let url: String
    public let thumbnailUrl: String
    public let duration: UInt
    public let width: UInt
    public let height: UInt
    
    enum CodingKeys: String, CodingKey {
        case url, duration, width, height
        case thumbnailUrl = "thumbnail_url"
    }
    
    public init(url: String, thumbnailUrl: String, duration: UInt, width: UInt, height: UInt) {
        self.url = url
        self.thumbnailUrl = thumbnailUrl
        self.duration = duration
        self.width = width
        self.height = height
    }
}

public struct NTImageResponse: Codable {
    public let images: [NTImage]
    
    enum CodingKeys: String, CodingKey {
        case images = "images"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        images = container.decodex(key: .images, defaultValue: [])
    }
}

public struct NTImageURLsResponse: Codable {
    public let urls: [String]
    enum CodingKeys: String, CodingKey {
        case urls = "images"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        urls = container.decodex(key: .urls, defaultValue: [])
    }
}

public struct NTFileResponse: Codable {
    public let file: NTFile
}

public struct NTSticker: Codable {
    let sticker: String
}

public struct NTStickerResponse: Codable {
    let sticker: NTSticker
}

public struct NTFile: Codable {
    let url: String
    let fileName: String
    let fileExtension: String
    let size: Double
    
    enum CodingKeys: String, CodingKey {
        case url, size
        case fileName = "file_name"
        case fileExtension = "file_extension"
    }

    init(url: String, fileName: String, fileExtension: String, size: Double) {
        self.url = url
        self.fileName = fileName
        self.fileExtension = fileExtension
        self.size = size
    }

    func toString() -> String {
        let encoder = JSONEncoder()
        if let tempData = try? encoder.encode(self) {
            return String.init(data: tempData, encoding: .utf8) ?? ""
        }
        return ""
    }
}
