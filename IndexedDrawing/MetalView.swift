//
//  MetalView.swift
//  SwiftIndex
//
//  Created by Riku Takano on 2018/11/19.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        // Make sure we are on a device that can run metal!
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        device = defaultDevice
        depthStencilPixelFormat = .depth32Float
        colorPixelFormat = .bgra8Unorm
        // Our clear color, can be set to any color
        clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        createRenderer(device: defaultDevice)
    }
    
    func createRenderer(device: MTLDevice){
        renderer = Renderer(device: device)
        delegate = renderer
    }
    
}
