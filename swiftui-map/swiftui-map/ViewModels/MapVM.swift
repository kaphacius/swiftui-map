//
//  MapVM.swift
//  SwiftUI-Map
//
//  Created by Yurii Zadoianchuk on 24/01/2021.
//

import Foundation
import CoreLocation
import MapKit
import Combine

struct VenueAnnotationVM: Identifiable {
    let id: String
    let name: String
    let loc: CLLocationCoordinate2D
    let image: UIImage
    let address: [String]
    let categoryName: String

    init(venue: Venue, image: UIImage) {
        self.id = venue.id
        self.name = venue.name
        self.loc = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lon)
        self.image = image
        self.categoryName = venue.category.pluralName
        self.address = venue.formattedAddress
    }
}

class MapVM: NSObject, ObservableObject {
    @Published var venues: Array<VenueAnnotationVM> = []
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var radius: Int = 200
    @Published var showingAlert: Bool = false
    @Published var errorMessage: String = String()
    @Published var showingSheet: Bool = false
    @Published var selectedAnnotation: VenueAnnotationVM? = nil

    private let queue = DispatchQueue(label: "queue", qos: .userInitiated)
    private let lm = CLLocationManager()
    private let network: Network
    private let images: Images
    private let statusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let locationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var waitingVenues: Set<Venue> = []

    init(network: Network, images: Images) {
        self.network = network
        self.images = images
        super.init()

        setUpErrors()
        setUpImages()
        setUpLocation()
    }

    private func setUpErrors() {
        errorSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.handleError(error: $0) })
            .store(in: &cancellables)
    }

    private func setUpImages() {
        images.imageLoadSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.categoryImageLoaded($0) })
            .store(in: &cancellables)
    }

    private func setUpLocation() {
        statusSubject
            .receive(on: queue)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] status in
                self?.locAuthStatusChanged(status)
            }).store(in: &cancellables)

        locationSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loc in
                self?.userLocationUpdated(loc)
            }).store(in: &cancellables)

        $radius
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] new in
                self?.lm.location.map(\.coordinate).map({ self?.userLocationUpdated($0) })
            }).store(in: &cancellables)

        lm.delegate = self
        statusSubject.send(lm.authorizationStatus)
    }

    private func loadVenues(location loc: CLLocationCoordinate2D) {
        let r = VenueExploreResource(
            lat: loc.latitude,
            lon: loc.longitude,
            radius: radius
        )

        network
            .load(resource: r)
            .subscribe(on: queue)
            .receive(on: queue)
            .map({ (r: NResult<FSResponse<VenueExploreResponse>>) -> NResult<[Venue]> in
                if let items = try? r.map(\.response.groups.first).get().map(\.items)  {
                    return .success(items.map(\.venue))
                } else {
                    return .failure(Errors.noVenuesFound)
                }
            })
            .map({ (r: NResult<[Venue]>) -> NResult<[VenueAnnotationVM]> in
                r.map({ self.convertModelsToVMs(models: $0) })
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.venuesLoaded(result)
            }).store(in: &cancellables)
    }

    private func convertModelsToVMs(models: [Venue]) -> [VenueAnnotationVM] {
        models.compactMap({ model in
            if let img = images.getImage(for: model.category) {
                return VenueAnnotationVM(venue: model, image: img)
            } else {
                waitingVenues.insert(model)
                return nil
            }
        })
    }

    private func venuesLoaded(_ result: NResult<[VenueAnnotationVM]>) {
        switch result {
        case .success(let new):
            venues.removeAll()
            DispatchQueue.main.async { self.venues = new }
        case .failure(let error):
            errorSubject.send(error)
        }
    }

    private func userLocationUpdated(_ loc: CLLocationCoordinate2D) {
        waitingVenues.removeAll()
        loadVenues(location: loc)

        mapRegion = MKCoordinateRegion(
            center: loc,
            latitudinalMeters: CLLocationDistance(radius * 3),
            longitudinalMeters: CLLocationDistance(radius * 3)
        )
    }

    private func locAuthStatusChanged(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            lm.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            lm.location.map(\.coordinate).map(locationSubject.send)
        case .restricted:
            errorSubject.send(Errors.locationRestricted)
        case .denied:
            errorSubject.send(Errors.locationDenied)
        @unknown default:
            break
        }
    }

    private func handleError(error: Error) {
        errorMessage = error.localizedDescription
        showingAlert = true
    }

    private func categoryImageLoaded(_ result: (id: String, img: UIImage)) {
        venues.append(
            contentsOf: waitingVenues
                .filter({ $0.category.id == result.id })
                .map({ VenueAnnotationVM(venue: $0, image: result.img) })
        )
    }
}

extension MapVM: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        statusSubject.send(manager.authorizationStatus)
    }
}

extension MapVM {
    enum Errors: Error, LocalizedError {
        case noVenuesFound
        case locationDenied
        case locationRestricted

        public var errorDescription: String? {
            switch self {
            case .noVenuesFound: return "No venues found around your location. Try adjusting your search radius"
            case .locationDenied: return "Location access has been denied. This can be adjusted in settings"
            case .locationRestricted: return "No location access on this device."
            }
        }
    }
}
