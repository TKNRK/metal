//
//  ArrayOperations.swift
//  190229-AGI
//
//  Created by Riku Takano on 2019/02/27.
//  Copyright © 2019 Riku Takano. All rights reserved.
//

import Cocoa


func gram_schmidt(e1: Array<Float>, e2: Array<Float>) -> Array<Float> {
    let E1 = normal(vec: e1)
    let mag = inner_product(vec1: E1, vec2: e2)
    let e2_mid = E1.map {mag * $0}
    let E2 = normal(vec: zip(e2, e2_mid).map {$0 - $1})
    return E1 + E2
}


func normal(vec: Array<Float>) -> Array<Float> {
    let vec_norm = sqrt(vec.map{$0 * $0}.reduce(0){$0 + $1})
    let Vec = vec.map{ $0 / vec_norm }
    return Vec
}


func inner_product(vec1: Array<Float>, vec2: Array<Float>) -> Float {
    if vec1.count != vec2.count { return 0 }
    return zip(vec1, vec2).map { $0 * $1 }.reduce(0) { $0 + $1 }
}
