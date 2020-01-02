//
//  MapViewController.swift
//  InstagramFirebase
//
//  Created by Thai Nguyen on 1/2/20.
//  Copyright © 2020 Thai Nguyen. All rights reserved.
//

import UIKit
import MapKit
import LBTATools

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var posts = [Post]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        
        setupViews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
//
//        guard let mainTabBarController =  window?.rootViewController as? MainTabBarController else { return }
//
//        guard let location = mainTabBarController.locationFetcher.lastKnownLocation else { return }
//
        let userLocation = mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000 * 60 / 1.6 , longitudinalMeters: 1000 * 60 / 1.6)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    private func setupViews() {
        
        view.addSubview(mapView)
        mapView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 18, left: 12, bottom: 0, right: 0), size: .init(width: 50, height: 50))
    }
    
    
    lazy var mapView: MKMapView = {
       let map = MKMapView()
        map.showsUserLocation = true
        map.delegate = self
        
        return map
    }()
    
    
    lazy var dismissButton: UIButton = {
        let dismissButton = UIButton()
        dismissButton.setImage(#imageLiteral(resourceName: "cancel_shadow").withRenderingMode(.alwaysOriginal), for: .normal)
        dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        return dismissButton
    }()
    
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
}
