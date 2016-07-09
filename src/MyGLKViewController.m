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


#import "MyGLKViewController.h"


static NSString *borderType = @"borderType";

@implementation MyGLKViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpView];
    [self setUpWorld];
    [self updateProjectionMatrix];
}

- (void)setUpView
{
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    ((GLKView*)self.view).context=context;
    [EAGLContext setCurrentContext:context];
    effect = [[GLKBaseEffect alloc] init];
    //effect.useConstantColor=true;
    //effect.constantColor = GLKVector4Make(0,0,0,1.0);
}

- (void)setUpWorld
{
    sprites = [NSMutableArray array];
    letters = [NSMutableArray array];
    camera.scale=1;
    space = [[ChipmunkSpace alloc] init];
    [space addBounds:self.view.bounds thickness:10 elasticity:.5 friction:.3 layers:CP_ALL_LAYERS group:CP_NO_GROUP collisionType:borderType];
    space.gravity = cpv(0,-250);
    cpEnableSegmentToSegmentCollisions();
    
    multiGrab = [[ChipmunkMultiGrab alloc] initForSpace:space withSmoothing:cpfpow(0.8, 60.0) withGrabForce:8000];
    multiGrab.grabRadius = 20.0;
    multiGrab.grabRotaryFriction = 0;
    multiGrab.pushMode = TRUE;
    multiGrab.pushFriction = 0.7f;
    multiGrab.pushMass = 1.0;
    
    
    WordObject *wo = [[WordObject alloc]initWithNSString:@"Word" effect:effect];
    [letters addObjectsFromArray:wo->letters];
    [wo addToSpace:space];
    
    /*
    LetterObject *lo = [letters firstObject];
    [space removeBody:lo->body];
    cpSpaceConvertBodyToStatic(space.space, lo->body.body);
    
    lo = [letters lastObject];
    [space removeBody:lo->body];
    cpSpaceConvertBodyToStatic(space.space, lo->body.body);
    */
}

- (void)updateProjectionMatrix
{
    effect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.bounds.size.width/camera.scale, 0, self.view.bounds.size.height/camera.scale, -1024, 1024);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(135.0/255.0, 206.0/255.0, 250.0/255.0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    for (Sprite *sprite in sprites)
    {
        [sprite render:&camera];
    }
    
    
    for (LetterObject *letter in letters)
    {
        [letter render:&camera];
    }
    
    
    effect.texture2d0.enabled = NO;
    effect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(camera.pos.x,camera.pos.y,1,camera.pos.x,camera.pos.y,0,0,1,0);
    [effect prepareToDraw];
    
    GLfloat vertices[]={0,0,0,self.view.bounds.size.height,self.view.bounds.size.width,self.view.bounds.size.height,self.view.bounds.size.width,0};
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, vertices);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glDisableVertexAttribArray(GLKVertexAttribPosition);
}

- (void)update
{
    [space step:1.0/(float)[self preferredFramesPerSecond]];
    
    for (Sprite *sprite in sprites)
    {
        [sprite update];
    }
    
    for (LetterObject *letter in letters)
    {
        [letter update];
    }
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        panStart = camera.pos;
        camera.pos.x=panStart.x-[sender translationInView:[self view]].x/camera.scale;
        camera.pos.y=panStart.y-[sender translationInView:[self view]].y*-1/camera.scale;
    }
    else
    {
        camera.pos.x=panStart.x-[sender translationInView:[self view]].x/camera.scale;
        camera.pos.y=panStart.y-[sender translationInView:[self view]].y*-1/camera.scale;
    }
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:[self view]];
    location.y=self.view.bounds.size.height-location.y;

    
    float prevScale=camera.scale;
    
    if(sender.state == UIGestureRecognizerStateBegan)
    {
        scaleStart = camera.scale;
        camera.scale = scaleStart*sender.scale;
    }
    else
    {
        camera.scale = scaleStart*sender.scale;
    }
    
    if(camera.scale>prevScale)
    {
        camera.pos.x-=location.x/camera.scale-location.x/prevScale;
        camera.pos.y-=location.y/camera.scale-location.y/prevScale;
    }
    else
    {
        camera.pos.x+=location.x/prevScale-location.x/camera.scale;
        camera.pos.y+=location.y/prevScale-location.y/camera.scale;
    }
    
    
    [self updateProjectionMatrix];
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender
{
    unichar characters[] = {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S',
                            'T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l',
                            'm','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9'};
    int characterCount = 62;
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:self.view];
        location.y=self.view.bounds.size.height-location.y;
        location.x/=camera.scale;
        location.y/=camera.scale;
        location.x+=camera.pos.x;
        location.y+=camera.pos.y;
        
        //Sprite *s = [[Sprite alloc] initCircleWithFile:@"tire_86.png" effect:effect];
        //[s setPosition:location];
        //[sprites addObject:s];
        //[space add:s];
        
        LetterObject *lo = [[LetterObject alloc] initWithUniChar:characters[currCharacter] effect:effect];
        [lo setPosition:location];
        [letters addObject:lo];
        [space add:lo];
        currCharacter++;
        if(currCharacter>=characterCount){currCharacter=0;}
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{//NSLog(@"touchesBegan");
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:self.view];
        location.y=self.view.bounds.size.height-location.y;
        location.x/=camera.scale;
        location.y/=camera.scale;
        location.x+=camera.pos.x;
        location.y+=camera.pos.y;
        [multiGrab beginLocation:location];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{//NSLog(@"touchesMoved");
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:self.view];
        location.y=self.view.bounds.size.height-location.y;
        location.x/=camera.scale;
        location.y/=camera.scale;
        location.x+=camera.pos.x;
        location.y+=camera.pos.y;
        [multiGrab updateLocation:location];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{//NSLog(@"touchesEnded");
    for(UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView:self.view];
        location.y=self.view.bounds.size.height-location.y;
        location.x/=camera.scale;
        location.y/=camera.scale;
        location.x+=camera.pos.x;
        location.y+=camera.pos.y;
        [multiGrab endLocation:location];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{//NSLog(@"touchesCancelled");
}


@end
