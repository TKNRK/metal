//
//  Shaders.metal
//  1-drawTriangle
//
//  Created by Riku Takano on 2018/12/08.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position;
    float4 color;
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float pointsize [[ point_size ]];
};

struct PickerOut {
    float4 position [[ position ]];
    float pointsize [[ point_size ]];
    uint vertexID;
};


vertex VertexOut basic_vertex_function(const device VertexIn *vertices [[ buffer(0) ]], uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color = vertices[vertexID].color;
    vOut.pointsize = 20;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}

vertex PickerOut picker_vs(device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    vertices[vertexID].color = float4(0, 1, 0, 1);
    PickerOut pOut;
    pOut.position = float4(vertices[vertexID].position,1);
    pOut.pointsize = 20;
    pOut.vertexID = vertexID;
    return pOut;
}

fragment void picker_fs(PickerOut vIn [[ stage_in ]],
                          device VertexIn *vertices [[ buffer(1) ]],
                          constant float2 &clicked [[ buffer(2) ]],
                          device uint *hitResult [[ buffer(3) ]]) {
    float2 xy = vIn.position.xy;
    if (xy.x / 2 < clicked.x - 1 || clicked.x + 1 < xy.x / 2 || xy.y / 2 < clicked.y - 1 || clicked.y + 1 < xy.y / 2) {
        return;
    } else {
        vertices[vIn.vertexID].color = float4(1, 0, 0, 1);
        hitResult[0] = vIn.vertexID;
        return;
    }
}

