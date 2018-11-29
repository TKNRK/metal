//
//  Shaders.metal
//  MetalMesh
//
//  Created by Riku Takano on 2018/11/15.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

// Basic Struct to match our Swift type
// This is what is passed into the Vertex Shader
struct VertexIn {
    float3 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

// What is returned by the Vertex Shader
// This is what is passed into the Fragment Shader
struct VertexOut {
    float4 position [[ position ]];
    float4 color;
};

struct ModelConstraints {
    float4x4 modelMatrix;
};

struct SceneConstraints {
    float4x4 projectionMatrix;
};

vertex VertexOut basic_vertex_function(VertexIn vIn [[ stage_in ]],
                                       constant ModelConstraints &modelConstants [[ buffer(1) ]],
                                       constant SceneConstraints &sceneConstants [[buffer(2)]]) {
    VertexOut vOut;
    vOut.position = sceneConstants.projectionMatrix * modelConstants.modelMatrix * float4(vIn.position,1);
    vOut.color = vIn.color;
    return vOut;
}

float4 identity(float4 h) {
    return h;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    float4 col = vIn.color;
    float4 colo = identity(col);
    return colo;
}
