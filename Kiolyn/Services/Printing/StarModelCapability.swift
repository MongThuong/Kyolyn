//
//  ModelCapability.swift
//  Swift SDK
//
//  Created by Yuji on 2015/**/**.
//  Copyright © 2015年 Star Micronics. All rights reserved.
//

import Foundation

/// The model of printting 
/// Don't insert(Only addition)
enum ModelIndex: Int {
    case None = 0
    case MPOP
    case FVP10
    case TSP100
    case TSP650II
    case TSP700II
    case TSP800II
    case SM_S210I
    case SM_S220I
    case SM_S230I
    case SM_T300I
    case SM_T400I
    case BSC10
    case SM_S210I_StarPRNT
    case SM_S220I_StarPRNT
    case SM_S230I_StarPRNT
    case SM_T300I_StarPRNT
    case SM_T400I_StarPRNT
    case SM_L200
    case SP700
}

/// Class to declade the model of printting
class StarModelCapability : NSObject {
    
    // The model capability index of printting
    enum ModelCapabilityIndex: Int {
        case Title = 0
        case Emulation
        case CashDrawerOpenActive
        case PortSettings
        case ModelNameArray
    }
    
    static let modelIndexArray: [ModelIndex] = [
        ModelIndex.MPOP,
        ModelIndex.FVP10,
        ModelIndex.TSP100,
        ModelIndex.TSP650II,
        ModelIndex.TSP700II,
        ModelIndex.TSP800II,
        ModelIndex.SP700,
        ModelIndex.SM_S210I,
        ModelIndex.SM_S220I,
        ModelIndex.SM_S230I,
        ModelIndex.SM_T300I,
        ModelIndex.SM_T400I,
        ModelIndex.SM_L200,
        ModelIndex.BSC10,
        ModelIndex.SM_S210I_StarPRNT,
        ModelIndex.SM_S220I_StarPRNT,
        ModelIndex.SM_S230I_StarPRNT,
        ModelIndex.SM_T300I_StarPRNT,
        ModelIndex.SM_T400I_StarPRNT
//      ModelIndex.SM_L200,
//      ModelIndex.SP700
    ]
    
    static var modelCapabilityDictionary: [ModelIndex: [Any]] = [
        ModelIndex.MPOP: ["mPOP", StarIoExtEmulation.starPRNT.rawValue,
                           false, "", ["POP10"]],
        
        ModelIndex.FVP10: ["FVP10", StarIoExtEmulation.starLine.rawValue,
                           true, "", ["FVP10 (STR_T-001)"]],
        
        ModelIndex.TSP100: ["TSP100", StarIoExtEmulation.starGraphic.rawValue,
                            true,  "", ["TSP113", "TSP143"]],
        
        ModelIndex.TSP650II: ["TSP650II", StarIoExtEmulation.starLine.rawValue, true, "",         ["TSP654II (STR_T-001)", "TSP654 (STR_T-001)", "TSP651 (STR_T-001)"]],
        
        ModelIndex.TSP700II: ["TSP700II", StarIoExtEmulation.starLine.rawValue, true,  "",         ["TSP743II (STR_T-001)", "TSP743 (STR_T-001)"]],
        
        ModelIndex.TSP800II: ["TSP800II", StarIoExtEmulation.starLine.rawValue, true,  "",         ["TSP847II (STR_T-001)", "TSP847 (STR_T-001)"]],
        
        ModelIndex.SM_S210I: ["SM-S210i", StarIoExtEmulation.escPosMobile.rawValue,
                              false, "mini",     ["SM-S210i"]],
        
        ModelIndex.SM_S220I: ["SM-S220i", StarIoExtEmulation.escPosMobile.rawValue,
                              false, "mini",     ["SM-S220i"]],
        
        ModelIndex.SM_S230I: ["SM-S230i", StarIoExtEmulation.escPosMobile.rawValue,
                              false, "mini", ["SM-S230i"]],
        
        ModelIndex.SM_T300I: ["SM-T300i", StarIoExtEmulation.escPosMobile .rawValue,
                              false, "mini", ["SM-T300i"]],
        
        ModelIndex.SM_T400I: ["SM-T400i", StarIoExtEmulation.escPosMobile .rawValue,
                                        false, "mini", ["SM-T400i"]],
        
        ModelIndex.BSC10: ["BSC10", StarIoExtEmulation.escPos.rawValue, true, "escpos", ["BSC10"]],
        
        ModelIndex.SM_S210I_StarPRNT: ["SM-S210i StarPRNT", StarIoExtEmulation.starPRNT.rawValue,
                                        false, "Portable", ["SM-S210i StarPRNT"]],
        
        ModelIndex.SM_S220I_StarPRNT: ["SM-S220i StarPRNT", StarIoExtEmulation.starPRNT.rawValue,
                                        false, "Portable", ["SM-S220i StarPRNT"]],
        
        ModelIndex.SM_S230I_StarPRNT: ["SM-S230i StarPRNT", StarIoExtEmulation.starPRNT.rawValue,
                                        false, "Portable", ["SM-S230i StarPRNT"]],
        
        ModelIndex.SM_T300I_StarPRNT: ["SM-T300i StarPRNT", StarIoExtEmulation.starPRNT.rawValue,
                                        false, "Portable", ["SM-T300i StarPRNT"]],
        
        ModelIndex.SM_T400I_StarPRNT: ["SM-T400i StarPRNT", StarIoExtEmulation.starPRNT.rawValue,
                                        false, "Portable", ["SM-T400i StarPRNT"]],
        
        ModelIndex.SM_L200: ["SM-L200", StarIoExtEmulation.starPRNT.rawValue,
                             false, "Portable", ["SM-L200"]],
        
        ModelIndex.SP700: ["SP700", StarIoExtEmulation.starDotImpact.rawValue,
                           true, "", ["SP712 (STR-001)", "SP717 (STR-001)", "SP742 (STR-001)", "SP747 (STR-001)"]]
    ]
    
    static func modelIndexCount() -> Int {
        return StarModelCapability.modelIndexArray.count
    }
    
    static func modelIndexAtIndex(index: Int) -> ModelIndex {
        return StarModelCapability.modelIndexArray[index]
    }
    
    static func titleAtModelIndex(modelIndex: ModelIndex) -> String! {
        return StarModelCapability.modelCapabilityDictionary[modelIndex]![ModelCapabilityIndex.Title.rawValue] as! String
    }
    
    static func emulationAtModelIndex(modelIndex: ModelIndex) -> StarIoExtEmulation {
        return StarIoExtEmulation(rawValue: StarModelCapability.modelCapabilityDictionary[modelIndex]![ModelCapabilityIndex.Emulation.rawValue] as! Int)!
    }
    
    static func cashDrawerOpenActiveAtModelIndex(modelIndex: ModelIndex) -> Bool {
        return StarModelCapability.modelCapabilityDictionary[modelIndex]![ModelCapabilityIndex.CashDrawerOpenActive.rawValue] as! Bool
    }
    
    static func portSettingsAtModelIndex(modelIndex: ModelIndex) -> String! {
        return StarModelCapability.modelCapabilityDictionary[modelIndex]![ModelCapabilityIndex.PortSettings.rawValue] as! String
    }
    
    static func modelIndexAtModelName(modelName: String!) -> ModelIndex {
        for (modelIndex, anyObject) in StarModelCapability.modelCapabilityDictionary {
            let modelNameArray: [String] = anyObject[ModelCapabilityIndex.ModelNameArray.rawValue] as! [String]
            
            for i: Int in 0 ..< modelNameArray.count {
                if modelName.hasPrefix(modelNameArray[i]) == true {
                    return modelIndex
                }
            }
        }
        
        return ModelIndex.None
    }
}
