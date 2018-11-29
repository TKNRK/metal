//
//  CubeScene.swift
//  MetalMesh
//
//  Created by Riku Takano on 2018/11/15.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class CubeScene: Scene {
    override init(device: MTLDevice) {
        super.init(device: device)
        // Create the Cube
        let c = Cube(withDevice: device)
        objects.append(c)
        // Move the Cube away from the camera
        c.translate(direction: float3(0,0,-6))
        // Add the Cube to the Scene
        add(child: c)
    }
    
    override func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
        // Rotate the objects in the Scene
        objects.forEach{ $0.rotate(angle: deltaTime, axis: float3(1,1,0)) }
        super.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
    }
}
