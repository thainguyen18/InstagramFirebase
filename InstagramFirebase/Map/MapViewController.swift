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


class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var thumbnailUrl: String
    
    var thumbnailImage: UIImage?
    
    var caption: String
    
    init(coordinate: CLLocationCoordinate2D, thumbnailUrl: String, caption: String) {
        self.coordinate = coordinate
        self.thumbnailUrl = thumbnailUrl
        self.caption = caption
    }
    
    // required for annotation view canShowCallout
    var title: String? = " "
}


class CustomAnnotationView: MKPinAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            canShowCallout = true
            
            guard let customAnnotation = annotation as? CustomAnnotation else { return }
            
            guard let width = customAnnotation.thumbnailImage?.size.width else { return }
            guard let height = customAnnotation.thumbnailImage?.size.height else { return }
            
            let ratio = width / height
            let desiredHeight: CGFloat = 100
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: desiredHeight * ratio, height: desiredHeight))
            imageView.image = customAnnotation.thumbnailImage
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
            
            detailCalloutAccessoryView = imageView
            
            
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        guard let customAnnotation = annotation as? CustomAnnotation else { return }
        
        guard let width = customAnnotation.thumbnailImage?.size.width else { return }
        guard let height = customAnnotation.thumbnailImage?.size.height else { return }
        
        let ratio = width / height
        let desiredHeight: CGFloat = 100
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: desiredHeight * ratio, height: desiredHeight))
        imageView.image = customAnnotation.thumbnailImage
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        
        detailCalloutAccessoryView = imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var posts = [Post]() 
    
    private var annotations = [CustomAnnotation]()
    
    let identifier = "PostMapIdentifier"
    
    let thumbnailReady = Notification.Name("Thumbnails ready")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        
        print("Listening to notification for thumbnails...")
        NotificationCenter.default.addObserver(self, selector: #selector(handleThumbnails), name: thumbnailReady, object: nil)
        
        
        print("Registed for custom annotation view...")
        mapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: identifier)
        
        loadAnnotations()
    }
    
    
    func loadAnnotations() {
        print("posts count: \(posts.count)")
        
        var index = 0
        
        posts.forEach { post in
            let latitude = CLLocationDegrees(post.latitude)
            let longitude = CLLocationDegrees(post.longitude)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let annotation = CustomAnnotation(coordinate: coordinate, thumbnailUrl: post.thumbnailUrl, caption: post.caption)
            annotation.title = post.user.username
            
            guard let url = URL(string: post.thumbnailUrl) else { return }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let err = error {
                    print("Failed to fetch post image: ", err)
                    return
                }
                
                guard let data = data else { return }
                
                DispatchQueue.main.async {
                    annotation.thumbnailImage = UIImage(data: data)
                    print("got thumbnail")
                    self.annotations.append(annotation)
                    
                    print(index)
                    
                    if index == self.posts.count - 1 {
                        print("Posting notification to map...")
                        NotificationCenter.default.post(name: self.thumbnailReady, object: nil)
                    } else {
                        index += 1
                    }
                }
            }.resume()
        }
        
        print("annotations count: \(annotations.count)")
    }
    
    
    @objc func handleThumbnails() {
        
        // Thumbnails ready, pass them to mapview to display
        print("Adding annotations...count: \(annotations.count)")
        mapView.addAnnotations(annotations)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let userLocation = mapView.userLocation.coordinate
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000 * 60 / 1.6 , longitudinalMeters: 1000 * 60 / 1.6)
        mapView.setRegion(region, animated: true)
        
    }
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isKind(of: MKUserLocation.self) {
            
            print("User annotation")

            return nil
        }

        guard let customAnnotation = annotation as? CustomAnnotation else { return nil }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {

            print("creating new annotation view...")
            
            annotationView = MKPinAnnotationView(annotation: customAnnotation, reuseIdentifier: identifier)

        } else {
            print("reusing existing annotation view...")
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let customAnnotation = view.annotation as? CustomAnnotation else { return }
        
        guard let username = customAnnotation.title else { return }
        
        let alert = UIAlertController(title: "Content", message: "\(username): \(customAnnotation.caption)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(alert, animated: true)
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
