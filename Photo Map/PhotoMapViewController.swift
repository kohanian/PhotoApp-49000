//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

extension CGRect {
    init(_ x:CGFloat, _ y:CGFloat, _ w:CGFloat, _ h:CGFloat) {
        self.init(x:x, y:y, width:w, height:h)
    }
}

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    init(coordinate1: CLLocationCoordinate2D, photo1: UIImage) {
        coordinate = coordinate1
        photo = photo1
    }
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
    
    var leftCalloutAccessoryView: UIView? {
        let resizeRenderImageView = UIImageView(frame: CGRect(0,0,45,45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeRenderImageView.image = (self).photo
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        _ = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeRenderImageView
    }
}

class PhotoMapViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, LocationsViewControllerDelegate {
    
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber, image: UIImage) {
        var locationCoordinate = CLLocationCoordinate2D()
        locationCoordinate.latitude = CLLocationDegrees(latitude)
        locationCoordinate.longitude = CLLocationDegrees(longitude)
        let annotation = PhotoAnnotation(coordinate1: locationCoordinate, photo1: image)
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
        self.navigationController?.popToViewController(self, animated: true)

    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width: 50, height:50))
        }
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        imageView.image = UIImage(named: "camera")
        
        return annotationView
    }
    
    
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var tempImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        choosePhotoButton.layer.shadowColor = UIColor.black.cgColor
        choosePhotoButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        choosePhotoButton.layer.masksToBounds = false
        choosePhotoButton.layer.shadowRadius = 1.0
        choosePhotoButton.layer.shadowOpacity = 0.5
        choosePhotoButton.layer.cornerRadius = choosePhotoButton.frame.width / 2
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func chooseButton(_ sender: Any) {
        if !UIImagePickerController.isSourceTypeAvailable(.camera){
            
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(vc, animated: true, completion: {
                self.performSegue(withIdentifier: "tagSegue", sender: nil)
            })
            
        }
        else{
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.allowsEditing = true
            vc.sourceType = UIImagePickerControllerSourceType.camera
            
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        tempImage = editedImage
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "tagSegue", sender: nil)
        })
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! LocationsViewController
        dest.image = tempImage
        tempImage = nil
        dest.delegate = self
    }
    

}
