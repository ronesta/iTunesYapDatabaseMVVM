//
//  YapDatabaseError.swift
//  iTunesYapDatabaseMVVM
//
//  Created by Ибрагим Габибли on 26.01.2025.
//

import Foundation

enum YapDatabaseError: Error {
    case databaseInitializationFailed
    case encodingFailed(Error)
    case decodingFailed(Error)
}
