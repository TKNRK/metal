//
//  ViewController.swift
//  MonteCarlo
//
//  Created by Riku Takano on 2018/12/01.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import MetalKit

class MetalView: MTKView {
    var renderer: Renderer!
    var computer: MonteCarlo!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        // Make sure we are on a device that can run metal!
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            fatalError("Device loading error")
        }
        device = defaultDevice
        colorPixelFormat = .bgra8Unorm
        // Our clear color, can be set to any color
        clearColor = MTLClearColor(red: 0.1, green: 0.57, blue: 0.25, alpha: 1)
        // createRenderer(device: defaultDevice)
        createComputer(device: defaultDevice)
    }
    
    func createRenderer(device: MTLDevice){
        renderer = Renderer(device: device)
        delegate = renderer
    }
    
    func createComputer(device: MTLDevice){
        computer = MonteCarlo(device: device)
    }
    
}

