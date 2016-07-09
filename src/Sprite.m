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


#import "Sprite.h"


@implementation Sprite

@synthesize chipmunkObjects;

- (void)initData:(NSString*)fileName effect:(GLKBaseEffect*)effectIn
{
    effect = effectIn;
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,nil];
    NSError * error;
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    if (textureInfo == nil)
    {
        NSLog(@"Error loading file: %@", [error localizedDescription]);
        //return nil;
    }
    
    contentSize = CGSizeMake(textureInfo.width, textureInfo.height);
    
    quad.bl.geometryVertex = CGPointMake(-(float)textureInfo.width/2, (float)textureInfo.height/2);
    quad.br.geometryVertex = CGPointMake((float)textureInfo.width/2, (float)textureInfo.height/2);
    quad.tl.geometryVertex = CGPointMake(-(float)textureInfo.width/2, -(float)textureInfo.height/2);
    quad.tr.geometryVertex = CGPointMake((float)textureInfo.width/2, -(float)textureInfo.height/2);
    
    quad.bl.textureVertex = CGPointMake(0, 0);
    quad.br.textureVertex = CGPointMake(1, 0);
    quad.tl.textureVertex = CGPointMake(0, 1);
    quad.tr.textureVertex = CGPointMake(1, 1);
}

- (id)initWithFile:(NSString*)fileName effect:(GLKBaseEffect*)effectIn
{
    if ((self = [super init]))
    {
        [self initData:fileName effect:effectIn];
        
        cpFloat mass = 1;
        cpFloat moment = cpMomentForBox(mass,textureInfo.width-2,textureInfo.height-2);
        body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
        body.pos = cpv(0,0);
        
        ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:textureInfo.width-2 height:textureInfo.height-2];
        shape.elasticity = .5;
        shape.friction = .5;
        
        chipmunkObjects = [[NSArray alloc] initWithObjects:body, shape, nil];
    }
    return self;
}

- (id)initCircleWithFile:(NSString*)fileName effect:(GLKBaseEffect*)effectIn;
{
    if ((self = [super init]))
    {
        [self initData:fileName effect:effectIn];
        
        cpFloat radius = textureInfo.width/2;
        cpFloat mass = 1;
        cpFloat moment = cpMomentForCircle(mass, 0, radius, cpvzero);
        body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
        body.pos = cpv(0,0);
        
        ChipmunkShape *shape = [ChipmunkCircleShape circleWithBody:body radius:radius offset:cpvzero];
        shape.elasticity = .5;
        shape.friction = .5;
        
        chipmunkObjects = [[NSArray alloc] initWithObjects:body, shape, nil];
    }
    return self;
}

- (GLKMatrix4) modelMatrix
{
    modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, 0);
    //float radians = GLKMathDegreesToRadians(rotation);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, rotation, 0, 0, 1);
    //modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, 0);
    return modelMatrix;
    
}

- (void)render:(Camera*) camera;
{
    //effect.useConstantColor=false;
    effect.texture2d0.name = textureInfo.name;
    effect.texture2d0.enabled = YES;
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeLookAt(camera->pos.x,camera->pos.y,1,camera->pos.x,camera->pos.y,0,0,1,0),[self modelMatrix]);
    [effect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    long offset = (long)&quad;
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, geometryVertex)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(TexturedVertex), (void *) (offset + offsetof(TexturedVertex, textureVertex)));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
    //effect.useConstantColor=true;
}

- (void)update
{
    position = body.pos;
    rotation = cpvtoangle(body.rot);
}

- (void)setPosition:(CGPoint) pos
{
    position = pos;
    body.pos = position;
}

@end
