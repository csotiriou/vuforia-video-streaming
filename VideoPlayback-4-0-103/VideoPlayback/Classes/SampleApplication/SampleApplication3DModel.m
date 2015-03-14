/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
Confidential and Proprietary - Qualcomm Connected Experiences, Inc.
Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/


#import "SampleApplication3DModel.h"

@implementation SampleApplication3DModel

- (id)initWithTxtResourceName:(NSString *) name
{
    self = [super init];
    if (self) {
        
        m_path = [[[NSBundle mainBundle] pathForResource:name ofType:@"txt"] retain];
    }
    return self;
}

- (void)dealloc
{
    [m_path release];
    free (m_vertices);
    free (m_normals);
    free (m_textcoords);
    [super dealloc];
}

- (long) numVertices {
    return m_nbVertices;
}

- (float *)vertices {
    return m_vertices;
}

- (float *)normals {
    return m_normals;
}

- (float *)texCoords {
    return m_textcoords;
}


- (void) read {
    char buffer[132];
    long nbItems = 0;
    long index = 0;
    float * data;
    
    FILE * fd = fopen([m_path UTF8String], "r");
    
    int state = 0;
    
    while(true) {
        if (fgets(buffer, sizeof(buffer), fd) == NULL) {
            break;
        }
        if (buffer[0] == ':') {
            if ((state > 0) && (index != nbItems)) {
                // check that we got all the data we needed
                NSLog(@"buffer underflow!");
            }
            state++;
            nbItems = atol(&buffer[1]);
            index  = 0;
            
            switch(state) {
                case 1:
                    m_nbVertices = nbItems / 3;
                    m_vertices = malloc( nbItems * sizeof(float));
                    data = m_vertices;
                    break;
                case 2:
                    m_normals = malloc( nbItems * sizeof(float));
                    data = m_normals;
                    break;
                case 3:
                    m_textcoords = malloc( nbItems * sizeof(float));
                    data = m_textcoords;
                    break;
            }
        } else {
            if (index >= nbItems) {
                // check that we don't get too many data
                NSLog(@"buffer overflow!");
            } else {
                data[index++] = atof(buffer);
            }
        }
    }
    fclose(fd);
}
@end
