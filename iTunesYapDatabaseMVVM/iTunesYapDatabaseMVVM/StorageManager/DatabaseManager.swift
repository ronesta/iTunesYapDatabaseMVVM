//
//  DatabaseManager.swift
//  iTunesYapDatabaseMVVM
//
//  Created by Ибрагим Габибли on 26.01.2025.
//

import Foundation
import UIKit
import YapDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()

    private let albumsCollection = "albums"
    private let imagesCollection = "images"
    private let albumsOrderCollection = "albumsOrder"
    private let historyKey = "searchHistory"
    private let searchHistoryOrderCollection = "searchHistoryOrder"
    private let database: YapDatabase
    private let connection: YapDatabaseConnection

    private init() {
        do {
            database = try DatabaseManager.setupDatabase()
            database.registerCodableSerialization(Album.self, forCollection: albumsCollection)
            connection = database.newConnection()
        } catch {
            fatalError("Failed to initialize YapDatabase with error: \(error)")
        }
    }

    private static func setupDatabase() throws -> YapDatabase {
        guard let baseDir = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask).first else {
            throw YapDatabaseError.databaseInitializationFailed
        }

        let databasePath = baseDir.appendingPathComponent("database.sqlite")

        guard let database = YapDatabase(url: databasePath) else {
            throw YapDatabaseError.databaseInitializationFailed
        }

        return database
    }

    func saveAlbums(_ albums: [Album]) {
        for album in albums {
            connection.readWrite { transaction in
                transaction.setObject(
                    album,
                    forKey: "\(album.collectionName + album.artistName)",
                    inCollection: albumsCollection
                )
            }
        }
    }

    func saveAlbumsForSearchQuery(albums: [Album], _ searchQuery: String) {
        for album in albums {
            connection.readWrite { transaction in
                var albumsKeys = transaction.object(
                    forKey: searchQuery,
                    inCollection: albumsOrderCollection) as? [String] ?? []

                if !albumsKeys.contains("\(album.collectionName + album.artistName)") {
                    albumsKeys.append("\(album.collectionName + album.artistName)")
                    transaction.setObject(albumsKeys, forKey: searchQuery, inCollection: albumsOrderCollection)
                }
            }
        }
    }

    func loadAlbum(key: String) -> Album? {
        var album: Album?

        connection.read { transaction in
            album = transaction.object(forKey: key, inCollection: albumsCollection) as? Album
        }

        return album
    }

    func loadAllAlbums(forTerm term: String) -> [Album] {
        var albums = [Album]()

        connection.read { transaction in
            if let order = transaction.object(
                forKey: term,
                inCollection: albumsOrderCollection) as? [String] {

                for key in order {
                    if let album = transaction.object(forKey: key, inCollection: albumsCollection) as? Album {
                        albums.append(album)
                    }
                }
            }
        }

        return albums
    }

    func saveImage(_ image: Data, key: String) {
        connection.readWrite { transaction in
            transaction.setObject(image, forKey: key, inCollection: imagesCollection)
        }
    }

    func loadImage(key: String) -> Data? {
        var result: Data?

        connection.read { transaction in
            if let data = transaction.object(forKey: key, inCollection: imagesCollection) as? Data {
                result = data
            } else {
                result = nil
            }
        }

        return result
    }

    func saveSearchTerm(_ term: String) {
        connection.readWrite { transaction in
            var order = transaction.object(
                forKey: historyKey,
                inCollection: searchHistoryOrderCollection
            ) as? [String] ?? []

            if !order.contains(term) {
                order.insert(term, at: 0)
                transaction.setObject(order, forKey: historyKey, inCollection: searchHistoryOrderCollection)
            }
        }
    }

    func getSearchHistory() -> [String] {
        var history = [String]()

        connection.read { transaction in
            history = transaction.object(
                forKey: historyKey,
                inCollection: searchHistoryOrderCollection
            ) as? [String] ?? []
        }

        return history
    }
}

// MARK: extension DatabaseManager
extension DatabaseManager {
    func clearAlbums() {
        connection.readWrite { transaction in
            let history = getSearchHistory()

            for term in history {
                transaction.removeObject(forKey: term, inCollection: albumsCollection)
            }
        }
    }

    func clearImage(key: String) {
        connection.readWrite { transaction in
            transaction.removeObject(forKey: key, inCollection: imagesCollection)
        }
    }
}
