/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <Foundation/Foundation.h>

// this class reads a text file describing a 3d Model

@interface SampleApplication3DModel : NSObject
{
@private
    long m_nbVertices;
    NSString * m_path;
    float * m_vertices;
    float * m_normals;
    float * m_textcoords;
}

- (id)initWithTxtResourceName:(NSString *) name;

- (void) read ;

- (long) numVertices;
- (float *)vertices;
- (float *)normals;
- (float *)texCoords;

@end
