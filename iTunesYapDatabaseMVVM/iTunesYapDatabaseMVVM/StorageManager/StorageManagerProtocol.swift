//
//  StorageManagerProtocol.swift
//  iTunesYapDatabaseMVVM
//
//  Created by Ибрагим Габибли on 02.02.2025.
//

import Foundation

protocol StorageManagerProtocol: AnyObject {
    func saveAlbums(_ albums: [Album])

    func saveAlbumsForSearchQuery(albums: [Album], _ searchQuery: String)

    func loadAlbum(key: String) -> Album?

    func loadAlbums(forTerm term: String) -> [Album]

    func saveImage(_ image: Data, key: String)

    func loadImage(key: String) -> Data?

    func saveSearchTerm(_ term: String)

    func getSearchHistory() -> [String]
}
