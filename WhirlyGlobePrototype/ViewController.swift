//
//  ViewController.swift
//  WhirlyGlobePrototype
//
//  Created by Reid Conner on 9/20/16.
//  Copyright © 2016 reid. All rights reserved.
//

import UIKit

class ViewController: WhirlyGlobeViewController {
    
    private let useLocalTiles: Bool = true
    private let doOverlay: Bool = false
    private let addCountryVectors: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        frameInterval = 2
        
        setupTiles()
        addOfficeMarkers()
        
        if addCountryVectors {
            setupCountryVectors()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animateToPosition(MaplyCoordinateMakeWithDegrees(-122.4192, 37.7793), time: 1)
    }

    private func setupTiles() {
        let layer: MaplyQuadImageTilesLayer
        
        if useLocalTiles {
            let tileSource = MaplyMBTileSource(MBTiles: "geography-class_medres")
            layer = MaplyQuadImageTilesLayer(coordSystem: tileSource.coordSys, tileSource: tileSource)
        } else {
            //setup a cache directory
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
            let aerialTilesCacheDir = "\(baseCacheDir)/nasatiles/"
            
            //let url = "https://stamen-tiles.a.ssl.fastly.net/toner/{z}/{x}/{y}"
            let url = "http://gibs.earthdata.nasa.gov/wmts/epsg3857/best/VIIRS_CityLights_2012/default/2015-07-01/GoogleMapsCompatible_Level8/{z}/{y}/{x}"
            
            let remoteTileSource = MaplyRemoteTileSource(baseURL: url, ext: "jpg", minZoom: 0, maxZoom: 8)
            remoteTileSource.cacheDir = aerialTilesCacheDir
            
            layer = MaplyQuadImageTilesLayer(coordSystem: remoteTileSource.coordSys, tileSource: remoteTileSource)
        }
        
        layer.handleEdges = true
        layer.coverPoles = true
        layer.requireElev = false
        layer.waitLoad = false
        layer.drawPriority = 0
        layer.singleLevelLoading = false
        
        addLayer(layer)
        
        if doOverlay {
            //setup a cache directory
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first!
            let seaTilesCacheDir = "\(baseCacheDir)/sea_temp/"
            
            let seaTileSource = MaplyRemoteTileSource(baseURL: "http://gibs.earthdata.nasa.gov/wmts/epsg3857/best/GHRSST_L4_G1SST_Sea_Surface_Temperature/default/2016-09-10/GoogleMapsCompatible_Level7/{z}/{y}/{x}", ext: "png", minZoom: 0, maxZoom: 7)
            seaTileSource.cacheDir = seaTilesCacheDir
            
            let tempLayer = MaplyQuadImageTilesLayer(coordSystem: seaTileSource.coordSys, tileSource: seaTileSource)
            tempLayer.coverPoles = true
            tempLayer.handleEdges = true
            
            addLayer(tempLayer)
        }
    }
    
    private func addOfficeMarkers() {
        var offices = [MaplyCoordinate]()
        
        offices.append(MaplyCoordinateMakeWithDegrees(-79.964496, 40.425591))
        offices.append(MaplyCoordinateMakeWithDegrees(9.166050, 48.817978))
        offices.append(MaplyCoordinateMakeWithDegrees(6.884854, 50.943640))
        offices.append(MaplyCoordinateMakeWithDegrees(139.572518, 35.567989))
        offices.append(MaplyCoordinateMakeWithDegrees(-87.863954, 41.852063))
        
        var markers = [MaplyScreenMarker]()
        
        for office in offices {
            let marker = MaplyScreenMarker()
            marker.color = UIColor.blueColor()
            marker.loc = office
            marker.size = CGSize(width: 10, height: 10)
            
            markers.append(marker)
        }
        
        addScreenMarkers(markers, desc: nil)
    }
    
    private func setupCountryVectors() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let vectorStyle = [kMaplyColor : UIColor.yellowColor(), kMaplySelectable : true, kMaplyVecWidth : 3.0, kMaplyFilled : true, kMaplySubdivType : kMaplySubdivGrid, kMaplySubdivEpsilon : 0.05, kMaplyDrawPriority : 1000]
            //let outlines = NSBundle.mainBundle().pathForResource("northamerica", ofType: "geojson")!
            let outlines = NSBundle.mainBundle().pathsForResourcesOfType("geojson2", inDirectory: nil)
            
            for outline in outlines {
                if let data = NSData(contentsOfFile: outline), vector = MaplyVectorObject(fromGeoJSON: data) {
                    if let attrs = vector.attributes, name = attrs["ADMIN"] as? String {
                        vector.userObject = name
                    }
                    
                    self.addVectors([vector], desc: vectorStyle)
                }
            }
        }
    }

}

