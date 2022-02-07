//
//  OperationCellModel.swift
//  Test_engineer
//
//  Created by Kacper on 19/01/2022.
//
class OperationCellModel{
    private var label:String
    private var operation:OperationTypes
    
    init(label:String, operation:OperationTypes){
        self.label = label
        self.operation = operation
    }

    public var Label: String{
        get{ return self.label }
    }

    public var Operation: OperationTypes{
        get{ return self.operation }
    }
}

enum OperationTypes{
    case presentController(_ controllerType: ControllerTypes)
    case modifyImage(_ modificationType: ModificationTypes)
   
    enum ControllerTypes{
        case IMAGE_PICKER_VC, HISTROGRAM_VC, FACE_DETECTION_VC, CELLS_DETECTION_VC, LOOKUP_TABLE_VC, NORMALIZE_HISTOGRAM_DETAILS_VC
           
        case BITWISE_VC(_ bitwise: BitwiseTypes)
        enum BitwiseTypes{ case AND,NOR,XOR,OR }
        
        case KERNEL_VC(_ blur: BlurTypes)
        enum BlurTypes{ case BLUR, GAUSSIAN,SOBEL,LAPLASSIAN,CANNY}
        
        case TRESHOLD_ADAPTIVE_VC(_ treshold: TresholdAdaptiveTypes)
        enum TresholdAdaptiveTypes{ case ADAPTIVE_MEAN, ADAPTIVE_GAUSE }
        
        case TRESHOLD_VC(_ treshold: TresholdTypes)
        enum TresholdTypes{ case OTSU, STANDARD }
    }
    
    enum ModificationTypes{
        case SAVE_IMAGE_TO_FILE, DELETE_PRESENTED_IMAGE
        case GRAYSCALE, BINARY,NEGATE
        case ERODE,DILATE, OPEN,CLOSE,SKELETONIZE,WATERSHED
        
        case EQUALIZE
    }
}

