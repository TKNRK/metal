//
//  ViewControllerDelegate.swift
//  5-PickAndHit
//
//  Created by Riku Takano on 2018/12/08.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

import Foundation
import MetalKit

class ViewControllerDelegate: NSObject {
    var view: MTKView!
    var renderer: Renderer!
    
    init(view: MTKView) {
        self.view = view
    }
    
    func viewDidLoad() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("The device does not support Metal technology")
            return
        }
        
        view.device = device
        renderer = Renderer(device: device)
        view.delegate = renderer
    }
}

