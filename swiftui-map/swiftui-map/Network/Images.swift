//
//  Images.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation

import Foundation
import UIKit
import Combine

class Images: ObservableObject {
    private var cache: Dictionary<String, UIImage> = [:]
    private var cancellables: Set<AnyCancellable> = []
    private var inProgress: Set<String> = []
    let imageLoadSubject = PassthroughSubject<(String, UIImage), Never>()

    func getImage(for category: Venue.Category) -> UIImage? {
        if let img = cache[category.id] {
            return img
        } else if inProgress.contains(category.id) == false {
            loadImage(for: category)
        }

        return nil
    }

    private func loadImage(for category: Venue.Category) {
        loadImage(prefix: category.iconPrefix, suffix: category.iconSuffix, id: category.id)
    }

    private func constructPath(p: String, s: String) -> String {
        "\(p)88\(s)"
    }

    private func loadImage(prefix p: String, suffix s: String, id: String) {
        guard let url = URL(string: constructPath(p: p, s: s)) else { return }

        URLSession
            .shared
            .dataTaskPublisher(for: URLRequest(url: url))
            .map(\.data)
            .compactMap(UIImage.init)
            .map(Result.success)
            .catch({ Just(.failure(NError.URLError($0))).eraseToAnyPublisher() })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                switch result {
                case .success(let img):
                    self?.cache[id] = img
                    self?.inProgress.remove(id)
                    self?.imageLoadSubject.send((id, img))
                case .failure(_):
                    break
                }
            })
            .store(in: &cancellables)

        inProgress.insert(id)
    }
}
