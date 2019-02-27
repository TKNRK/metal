//
//  AGI.swift
//  190229-AGI
//
//  Created by Riku Takano on 2019/02/27.
//  Copyright © 2019 Riku Takano. All rights reserved.
//

import Cocoa


func initAGI(dataset: String) -> AGI_static {
    let layoutHD_npy = loadData(fileName: dataset + "layout/layout_hd")
    let N = layoutHD_npy.0[0]
    let h_dim = layoutHD_npy.0[1]
    let layoutHD = layoutHD_npy.1
    let projection = loadData(fileName: dataset + "layout/eigenvalues").1
    let agi = AGI_static(N: N, h_dim: h_dim, layoutHD: layoutHD, projection: projection)
    return agi
}


private func loadData(fileName: String) -> (Array<Int>, Array<Float>) {
    var shape: Array<Int>!
    var resource: Array<Float>!
    guard let filePath = Bundle.main.url(forResource: fileName, withExtension: "npy") else {
        fatalError("Failed to open " + fileName)
    }
    do {
        let contents = try Npy(contentsOf: filePath)
        shape = contents.shape
        let data: [Double] = contents.elements()
        resource = data.map{ Float($0) }
    } catch {}

    return (shape, resource)
}


private func gen_projection(eigen_values: Array<Float>, h_dim: Int) -> Array<Float> {
    var e1 = Array<Float>(repeating: 0, count: eigen_values.count)
    var e2 = Array<Float>(repeating: 0, count: eigen_values.count)
    // generate the initial projection vectors
    for i in 0..<eigen_values.count{
        if i % 2 == 0 {
            e1[i] = eigen_values[i]
        } else {
            e2[i] = eigen_values[i]
        }
    }
    // normalize the projection vectors
    let proj = gram_schmidt(e1: e1, e2: e2)
    // apply default projection factor a = 0.5
    return proj.map { sqrt($0) }
}

