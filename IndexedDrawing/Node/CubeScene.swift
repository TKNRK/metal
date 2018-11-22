//
//  CubeScene.swift
//  SwiftIndex
//
//  Created by Riku Takano on 2018/11/19.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class CubeScene: Scene {
    override init(device: MTLDevice) {
        
        super.init(device: device)
        
        let c = Cube(withDevice: device)
        objects.append(c)
        c.translate(direction: float3(0,0,-6))
        add(child: c)
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        // objects.forEach{ $0.rotate(angle: deltaTime, axis: float3(1,1,0)) }
        super.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
    }
}
