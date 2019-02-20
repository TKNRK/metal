//
//  Shaders.metal
//  1-drawTriangle
//
//  Created by Riku Takano on 2018/12/08.
//  Copyright © 2018 Riku Takano. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct PickerIn {
    float mouse_x;
    float mouse_y;
    uint pick_id;
};

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


// Drawing subroutine
vertex VertexOut basic_vertex_function(const device VertexIn *vertices [[ buffer(0) ]],
                                       uint vertexID [[ vertex_id  ]]) {
    VertexOut vOut;
    vOut.position = float4(vertices[vertexID].position,1);
    vOut.color = vertices[vertexID].color;
    vOut.pointsize = 20;
    return vOut;
}

fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]]) {
    return vIn.color;
}


// Picker subroutine
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
                          device PickerIn *picker [[ buffer(2) ]]) {
    float2 xy = vIn.position.xy;
    //if (xy.x / 2 < clicked.x - 1 || clicked.x + 1 < xy.x / 2 || xy.y / 2 < clicked.y - 1 || clicked.y + 1 < xy.y / 2) {
    if (xy.x / 2 < picker[0].mouse_x - 1 || picker[0].mouse_x + 1 < xy.x / 2 || xy.y / 2 < picker[0].mouse_y - 1 || picker[0].mouse_y + 1 < xy.y / 2) {
        return;
    } else {
        vertices[vIn.vertexID].color = float4(1, 0, 0, 1);
        picker[0].pick_id = vIn.vertexID;
        return;
    }
}


// Computation subroutine
kernel void compute(device PickerIn *picker [[ buffer(0) ]],
                    constant float2 &newpos [[ buffer(1) ]],
                    device VertexIn *vertices [[ buffer(2) ]],
                    uint gid [[ thread_position_in_grid ]]) {
    if (gid == picker[0].pick_id) {
        vertices[gid].position = float3(newpos, 0);
    }
}


