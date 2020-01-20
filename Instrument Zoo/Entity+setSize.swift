//
//  Entity+setSize.swift
//  Instrument Zoo
//
//  Created by Ethan Saadia on 1/16/20.
//  Copyright © 2020 Ethan Saadia. All rights reserved.
//

import RealityKit

extension Entity {
    func setSize(_ size: Float, relativeTo entity: Entity?) {
        let currentSize = self.visualBounds(recursive: true, relativeTo: entity, excludeInactive: false).extents.max()
        let scaleFactor = size / currentSize
        setScale([scaleFactor, scaleFactor, scaleFactor], relativeTo: nil)
    }
}
