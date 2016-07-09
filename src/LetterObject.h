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
#import "Poly2TriObj.h"



@interface LetterObject : NSObject <ChipmunkObject>
{
    @public
    
    NSMutableArray *letterPoints;
    NSMutableArray *currArray;
    CGPoint **points;
    int *pointCounts;
    int pathCount;
    unichar character;
    
    float width;
    float height;
    
    
    
    NSMutableArray *polyLineArray;
    
    CGPoint **chipmunkPoints;
    int *chipmunkPointCounts;
    int chipmunkLineCount;
    
    Poly2TriObj *p2tObj;
    
    GLKBaseEffect *effect;
    GLKVector4 color;
    GLKMatrix4 modelMatrix;
    
    float rotation;
    ChipmunkBody *body;
    NSMutableArray *chipmunkObjects;
    
    @private
    CGPoint position;
}


@property (readonly) NSMutableArray *chipmunkObjects;

- (id)initWithUniChar:(UniChar)character effect:(GLKBaseEffect*)effectIn;
- (void)render:(Camera*) camera;
- (void)update;
- (void)setPosition:(CGPoint) pos;

@end
