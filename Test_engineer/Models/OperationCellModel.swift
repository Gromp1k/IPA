//
//  OperationCellModel.swift
//  Test_engineer
//
//  Created by Kacper on 19/01/2022.
//

import Foundation

class OperationCellModel{
    private var label:String
    private var operation:OperationType
    
    init(label:String, operation:OperationType){
        self.label = label
        self.operation = operation
    }

    public var Label: String{
        get{return self.label}
    }

    public var Operation: OperationType{
        get{return self.operation}
    }
}

enum OperationType{
    case presentController(_ controllerType: ControllerType)
    case modifyImage(_ modificationType: ModificationType)
   
    
    enum ControllerType{case imagePickerVC, histogramVC, faceDetectionVC, cellDetectionVC, none}
    enum ModificationType{ case saveImage, deleteImage,none}
}

