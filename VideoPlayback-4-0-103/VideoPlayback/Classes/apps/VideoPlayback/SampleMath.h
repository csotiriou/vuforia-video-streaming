/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/


#ifndef _QCAR_SAMPLEMATH_H_
#define _QCAR_SAMPLEMATH_H_

// Includes:
#include <QCAR/Tool.h>
#include <QCAR/VideoBackgroundConfig.h>
#include <QCAR/Renderer.h>

/// A utility class used by the QCAR SDK samples.
class SampleMath
{
public:
    
    static QCAR::Vec2F Vec2FSub(QCAR::Vec2F v1, QCAR::Vec2F v2);
    
    static float Vec2FDist(QCAR::Vec2F v1, QCAR::Vec2F v2);
    
    static QCAR::Vec3F Vec3FAdd(QCAR::Vec3F v1, QCAR::Vec3F v2);
    
    static QCAR::Vec3F Vec3FSub(QCAR::Vec3F v1, QCAR::Vec3F v2);
    
    static QCAR::Vec3F Vec3FScale(QCAR::Vec3F v, float s);
    
    static float Vec3FDot(QCAR::Vec3F v1, QCAR::Vec3F v2);
    
    static QCAR::Vec3F Vec3FCross(QCAR::Vec3F v1, QCAR::Vec3F v2);
    
    static QCAR::Vec3F Vec3FNormalize(QCAR::Vec3F v);
    
    static QCAR::Vec3F Vec3FTransform(QCAR::Vec3F& v, QCAR::Matrix44F& m);
    
    static QCAR::Vec3F Vec3FTransformNormal(QCAR::Vec3F& v, QCAR::Matrix44F& m);
    
    static QCAR::Vec4F Vec4FTransform(QCAR::Vec4F& v, QCAR::Matrix44F& m);
    
    static QCAR::Vec4F Vec4FDiv(QCAR::Vec4F v1, float s);

    static QCAR::Matrix44F Matrix44FIdentity();
    
    static QCAR::Matrix44F Matrix44FTranspose(QCAR::Matrix44F m);
    
    static float Matrix44FDeterminate(QCAR::Matrix44F& m);
    
    static QCAR::Matrix44F Matrix44FInverse(QCAR::Matrix44F& m);

    static bool linePlaneIntersection(QCAR::Vec3F lineStart, QCAR::Vec3F lineEnd,
                      QCAR::Vec3F pointOnPlane, QCAR::Vec3F planeNormal,
                      QCAR::Vec3F &intersection);
                      
    static void projectScreenPointToPlane(QCAR::Matrix44F inverseProjMatrix, QCAR::Matrix44F modelViewMatrix,
                                          float screenWidth, float screenHeight, 
                                          QCAR::Vec2F point, QCAR::Vec3F planeCenter, QCAR::Vec3F planeNormal,
                                          QCAR::Vec3F &intersection, QCAR::Vec3F &lineStart, QCAR::Vec3F &lineEnd);
};

#endif // _QCAR_SAMPLEMATH_H_
