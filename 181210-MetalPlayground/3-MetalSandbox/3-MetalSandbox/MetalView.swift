//
//  MetalView.swift
//  MetalSwift
//
//  Created by Riku Takano on 2018/11/14.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        device = defaultDevice
        colorPixelFormat = .bgra8Unorm
        clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1)
        
        createRenderer(device: defaultDevice)
    }
    
    func createRenderer(device: MTLDevice){
        renderer = Renderer(device: device)
        renderer.setFrameSize(size: frame.size)
        delegate = renderer
    }
}
