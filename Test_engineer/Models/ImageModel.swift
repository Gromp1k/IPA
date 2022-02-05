//
//  MainViewModel.swift
//  Test_engineer
//
//  Created by Kacper on 01/02/2022.
//

class ImageModel {
    
     private var image: UIImage
     private var isImageLoaded: Bool
     private var lookupTable: [UIColor: [Int]]
    
    init(){
        self.image = UIImage()
        self.isImageLoaded = false
        self.lookupTable = [:]
    }
    
    public var Image: UIImage {
        get{ return self.image }
        set(newImage){ self.image = newImage }
    }
    
    public var IsImageLoaded: Bool {
        get{return self.isImageLoaded}
        set(flag){ self.isImageLoaded = flag}
    }
    
    public var LookupTable: [UIColor: [Int]]{
        get {return self.lookupTable}
        set(newLookup){self.lookupTable = newLookup}
    }
    
}


