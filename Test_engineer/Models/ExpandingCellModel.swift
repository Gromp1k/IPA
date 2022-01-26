//
//  ExpandingCellModel.swift
//  Test_engineer
//
//  Created by Kacper on 19/01/2022.
//

import Foundation



class ExpandingCellModel{
    
    private let label:String
    private var isExpanded:Bool
    private let operations:[OperationCellModel]
    
    init(label: String, operations:[OperationCellModel]){
        self.label = label
        self.operations = operations
        self.isExpanded = false
    }

    public var Label: String{
        get{return self.label}
    }
    public var IsExpanded:Bool{
        get{return self.isExpanded}
        set{self.isExpanded = newValue}
    }
    public var Operations:[OperationCellModel]{
        get{return self.operations}
    }
    
}


