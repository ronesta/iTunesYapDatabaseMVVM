//
//  AlbumAssembly.swift
//  iTunesYapDatabaseMVVM
//
//  Created by Ибрагим Габибли on 02.02.2025.
//

import Foundation
import UIKit

struct AlbumAssembly {
    func build(with album: Album) -> UIViewController {
        let storageManager = DatabaseManager.shared
        let networkManager = NetworkManager(storageManager: storageManager)

        let albumViewModel = AlbumViewModel(networkManager: networkManager,
                                            album: album
        )
        let albumViewController = AlbumViewController(viewModel: albumViewModel)

        return albumViewController
    }
}
