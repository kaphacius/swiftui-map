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

    init(venue: Venue) {
        self.id = venue.id
        self.name = venue.name
        self.loc = CLLocationCoordinate2D(latitude: venue.lat, longitude: venue.lon)
    }
}

class MapVM: NSObject, ObservableObject {
    @Published var venues: Array<VenueAnnotationVM> = []
    @Published var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    @Published var radius: Int = 200
    @Published var showingAlert: Bool = false
    @Published var errorMessage: String = String()

    private let lm = CLLocationManager()
    private let network: Network
    private let statusSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let locationSubject = PassthroughSubject<CLLocationCoordinate2D, Never>()
    private let errorSubject = PassthroughSubject<Error, Never>()
    private var cancellables = Set<AnyCancellable>()

    init(network: Network) {
        self.network = network
        super.init()

        setUpErrors()
        setUpLocation()
    }

    private func setUpErrors() {
        errorSubject
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.handleError(error: $0) })
            .store(in: &cancellables)
    }

    private func setUpLocation() {
        statusSubject
            .receive(on: DispatchQueue.global())
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
            .receive(on: DispatchQueue.global())
            .map({ (r: NResult<FSResponse<VenueExploreResponse>>) -> NResult<[Venue]> in
                if let items = try? r.map(\.response.groups.first).get().map(\.items)  {
                    return .success(items.map(\.venue))
                } else {
                    return .failure(Errors.noVenuesFound)
                }
            })
            .map({ (r: NResult<[Venue]>) -> NResult<[VenueAnnotationVM]> in
                r.map({ $0.map(VenueAnnotationVM.init) })
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] result in
                self?.venuesLoaded(result)
            }).store(in: &cancellables)
    }

    private func venuesLoaded(_ result: NResult<[VenueAnnotationVM]>) {
        switch result {
        case .success(let new):
            venues = new
        case .failure(let error):
            errorSubject.send(error)
        }
    }

    private func userLocationUpdated(_ loc: CLLocationCoordinate2D) {
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
