Copyright 2016 Gregory Bryant

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
/***********************************************************************/


#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "ObjectiveChipmunk.h"
#include "structs.h"

typedef struct
{
    CGPoint geometryVertex;
    CGPoint textureVertex;
} TexturedVertex;

typedef struct
{
    TexturedVertex bl;
    TexturedVertex br;
    TexturedVertex tl;
    TexturedVertex tr;
} TexturedQuad;

@interface Sprite : NSObject <ChipmunkObject>
{
@public
    GLKBaseEffect *effect;
    TexturedQuad quad;
    GLKTextureInfo * textureInfo;
    
    CGPoint position;
    CGSize contentSize;
    float scale;
    float rotation;
    
    ChipmunkBody *body;
    NSArray *chipmunkObjects;
    
    GLKMatrix4 modelMatrix;
}

@property (readonly) NSArray *chipmunkObjects;

- (id)initWithFile:(NSString*)fileName effect:(GLKBaseEffect*)effectIn;
- (id)initCircleWithFile:(NSString*)fileName effect:(GLKBaseEffect*)effectIn;
- (void)render:(Camera*) camera;
- (void)update;
- (void)setPosition:(CGPoint) pos;
@end
