//
//  MapViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 01/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import GoogleMaps
var region:GMSVisibleRegion? = nil
class MapViewController: UIViewController,GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: UIView!
    var mapView1:GMSMapView!
    var lat:String!
    var long:String!
    var hosiptalName:String!
     let marker = GMSMarker()

    override func viewDidLoad() {
        super.viewDidLoad()

        let camera = GMSCameraPosition.camera(withLatitude: Double(lat)!, longitude: Double(long)!, zoom: 15.0)
        mapView1 = GMSMapView.map(withFrame: mapView.bounds, camera: camera)
        mapView1.mapType = .terrain
    
        mapView.addSubview(mapView1)
        
        mapView1.delegate = self
        region = mapView1.projection.visibleRegion()
        
        marker.position = CLLocationCoordinate2D(latitude: Double(lat)!, longitude: Double(long)!)
        marker.title = hosiptalName
        marker.map = mapView1
        
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        {
            UIApplication.shared.openURL(NSURL(string:
                "comgooglemaps://?saddr=&daddr=\(Float(lat)!),\(Float(long)!)&directionsmode=driving")! as URL)
        } else
        {
            NSLog("Can't use com.google.maps://");
        }
        
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
