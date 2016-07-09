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


#import <CoreText/CoreText.h>
#import "LetterObject.h"
#include "cpPolyline.h"
//#include "poly2tri.h"

@implementation LetterObject

//std::vector<p2t::Triangle*> triangles;
//std::vector<p2t::Point*> polyline;

@synthesize chipmunkObjects;

- (id)initWithUniChar:(UniChar)characterIn effect:(GLKBaseEffect*)effectIn
{
    if ((self = [super init]))
    {
        character = characterIn;
        effect=effectIn;
        color = GLKVector4Make((float)(arc4random()%256)/255.0,(float)(arc4random()%256)/255.0,(float)(arc4random()%256)/255.0,1);
        letterPoints = [NSMutableArray array];
        currArray=0;
        //CTFontRef font = CTFontCreateWithName(CFSTR("GhoulishFrightAOE"), 64, NULL);
        CTFontRef font = CTFontCreateWithName(CFSTR("ChunkFive-Roman"), 64, NULL);
        //CTFontRef font = CTFontCreateWithName(CFSTR("NeoRetroDraw"), 64, NULL);
        //CTFontRef font = CTFontCreateWithName(CFSTR("MarkerFelt-Thin"), 64, NULL);
        //NSLog(@"Creating glyph: %c",characterIn);
        //NSLog(@"%@", font);
        CGGlyph glyph;
        if(CTFontGetGlyphsForCharacters(font,&character,&glyph,1)!=FALSE)
        {
            CGAffineTransform transform = CGAffineTransformIdentity;
            CGPathRef path = CTFontCreatePathForGlyph(font, glyph, &transform);
            CGPathApply(path, (void*)self, MyCGPathApplierFunc);
            CGPathRelease(path);
            CFRelease(font);
            pathCount = [letterPoints count];
            //NSLog(@"sub paths: %d",pathCount);
            points = (CGPoint**)malloc(sizeof(CGPoint*)*pathCount);
            pointCounts = (int*)malloc(sizeof(int)*pathCount);
            int i=0;
            for (NSMutableArray* array in letterPoints)
            {
                pointCounts[i]=[array count];
                //NSLog(@"points: %d",pointCounts[i]);
                points[i]=(CGPoint*)malloc(sizeof(CGPoint)*pointCounts[i]);
                for(int j=0;j<pointCounts[i];j++)
                {
                    NSValue *val = [array objectAtIndex:j];
                    points[i][j]=[val CGPointValue];
                }
                i++;
            }
        }
        else {return self=nil;}
        
        [self centerPoints];
        
        p2tObj = [[Poly2TriObj alloc] initWithCGPoint:points pointCounts:pointCounts pathCount:pathCount];
        if(characterIn=='A'){p2tObj->holeCount=1;}
        else if(characterIn=='B'){p2tObj->holeCount=2;}
        else if(characterIn=='D'){p2tObj->holeCount=1;}
        else if(characterIn=='O'){p2tObj->holeCount=1;}
        else if(characterIn=='P'){p2tObj->holeCount=1;}
        else if(characterIn=='Q'){p2tObj->holeCount=1;}
        else if(characterIn=='R'){p2tObj->holeCount=1;}
        else if(characterIn=='a'){p2tObj->holeCount=1;}
        else if(characterIn=='b'){p2tObj->holeCount=1;}
        else if(characterIn=='d'){p2tObj->holeCount=1;}
        else if(characterIn=='e'){p2tObj->holeCount=1;}
        else if(characterIn=='g'){p2tObj->holeCount=1;}
        else if(characterIn=='o'){p2tObj->holeCount=1;}
        else if(characterIn=='p'){p2tObj->holeCount=1;}
        else if(characterIn=='q'){p2tObj->holeCount=1;}
        else if(characterIn=='4'){p2tObj->holeCount=1;}
        else if(characterIn=='6'){p2tObj->holeCount=1;}
        else if(characterIn=='8'){p2tObj->holeCount=2;}
        else if(characterIn=='9'){p2tObj->holeCount=1;}
        else if(characterIn=='0'){p2tObj->holeCount=1;}
        [p2tObj triangulate];
        
        
        
        //NSLog(@"p2tObj created: %d triangles",p2tObj->vertexCount/3);
        
        
        
        polyLineArray = [NSMutableArray array];
        int polySize=0;
        [polyLineArray addObject:[NSValue valueWithCGPoint:points[0][0]]];
        polySize++;
        for(int i=1;i<pointCounts[0]-1;i++)
        {
            NSValue *val = [polyLineArray objectAtIndex:polySize-1];
            CGPoint pt = [val CGPointValue];
            
            if(points[0][i].x!=pt.x||points[0][i].y!=pt.y)
            {[polyLineArray addObject:[NSValue valueWithCGPoint:points[0][i]]];polySize++;}
        }
        
        /*
        int polySize=0;
        polyline.push_back(new p2t::Point(points[0][0].x,points[0][0].y));
        polySize++;
        for(int i=1;i<pointCounts[0]-1;i++)
        {
            if(points[0][i].x!=polyline[polySize-1]->x||points[0][i].y!=polyline[polySize-1]->y)
            {polyline.push_back(new p2t::Point(points[0][i].x,points[0][i].y));polySize++;}
        }
        p2t::CDT *cdt = new p2t::CDT(polyline);
        cdt->Triangulate();
        triangles = cdt->GetTriangles();
        */
        
        //[self initPhysics];
        [self initPhysicsPolyLine];
    }
    return self;
}


- (void)initPhysicsPolyLine
{
    chipmunkObjects = [NSMutableArray array];
    
    body = [[ChipmunkBody alloc] initWithMass:1 andMoment:5];
    body.pos = cpv(0,0);
    [chipmunkObjects addObject:body];
    
    
    /*
    // Your array of vertexes and it's length:
    //cpVect verts[] = {...};
    //int length = ...;

    points[0];
    pointCounts[0];
    */
    
    //int polyPointCount = polyline.size();
    int polyPointCount = [polyLineArray count];

    cpFloat tolerance = 0.0;

    // Now we need to make a looped cpPolyline struct.
    // It's considered looped if the first and last vertex are the same.
    //int capacity = pointCounts[0] + 1;
    int capacity = polyPointCount + 1;
    cpVect polyline_verts[polyPointCount];
    cpPolyline line = {capacity, capacity, polyline_verts};
    //memcpy(line.verts, points[0], pointCounts[0]*sizeof(cpVect));
    
    
    
    /*
    //need to reverse the winding to make these points work with Chipmunk
    for(int i=0;i<pointCounts[0];i++)
    {
        line.verts[i] = points[0][pointCounts[0]-1-i];
    }
    line.verts[pointCounts[0]] = points[0][0];
    */
    
    //reverse the winding of the duplicate removed polyline set
    
    if(true)
    {
        for(int i=0;i<polyPointCount;i++)
        {
            NSValue *val = [polyLineArray objectAtIndex:polyPointCount-1-i];
            CGPoint pt = [val CGPointValue];
            line.verts[i] = pt;
        }
    }
    line.verts[polyPointCount] = line.verts[0];


    

    // That was annoying, but the rest is simple enough...

    // Optional step. Simplify the user data.
    // 'tolerance' is the maximum distance the simplified curve can deviate from the original.
    // A pixel or two of tolerance can greatly simplify the data without noticeably changing it.
    //cpPolyline simplified = cpPolylineSimplifyCurves(line, tolerance);

    
    // Break the polyline into convex regions. 'tolerance' works similarly here.
    
    cpPolylineSet *set = cpPolylineConvexDecomposition_BETA(line, tolerance);
    
    //NSLog(@"Chipmunk created: %d polyshapes.",set->count);
    
    chipmunkLineCount=set->count;
    chipmunkPointCounts = malloc(sizeof(int)*set->count);
    chipmunkPoints = malloc(sizeof(CGPoint*)*set->count);
    for(int i=0;i<set->count;i++)
    {
        chipmunkPointCounts[i] = set->lines[i].count;
        chipmunkPoints[i] = malloc(sizeof(CGPoint)*chipmunkPointCounts[i]);
        for(int j=0;j<chipmunkPointCounts[i];j++)
        {
            chipmunkPoints[i][j] = set->lines[i].verts[j];
        }
    }
    
    /*
    chipmunkPointCount=set->lines[0].count;
    chipmunkPoints = malloc(sizeof(CGPoint)*chipmunkPointCount);
    for(int i=0;i<chipmunkPointCount;i++)
    {
        chipmunkPoints[i] = set->lines[0].verts[i];
    }
    */
    
    
    
    
    ChipmunkPolyShape *shape;
    cpFloat moment=0;
    // Loop over the polylines in the set and do something with them.
    for(int i=0; i<set->count; i++)
    {
        cpPolyline convex_chunk = set->lines[i];
        // convex_chunk.count - 1 for the length because the last vertex is a duplicate when looped.
        //cpShape *shape = cpPolyShapeNew(body, convex_chunk.count - 1, convex_chunk.verts, cpvzero);
        shape =[ChipmunkPolyShape polyWithBody:body count:convex_chunk.count - 1 verts:convex_chunk.verts offset:cpvzero radius:0];
        shape.elasticity = .5;
        shape.friction = .5;
        [chipmunkObjects addObject:shape];
        moment += cpMomentForPoly(1, convex_chunk.count - 1, convex_chunk.verts, cpvzero);
    }
    
    body.moment = moment;
     
    
}

- (void)initPhysics
{
    cpFloat radius=10;
    cpFloat mass=1;
    cpFloat moment=0;
    for(int i=0;i<pointCounts[0]-1;i+=2)
    {moment+=cpMomentForSegment(mass, points[0][i], points[0][i+1]);}
    moment+=cpMomentForSegment(mass, points[0][pointCounts[0]-1], points[0][0]);
    body = [[ChipmunkBody alloc] initWithMass:mass andMoment:moment];
    body.pos = cpv(0,0);
    
    
    chipmunkObjects = [NSMutableArray array];
    
    [chipmunkObjects addObject:body];
    
    ChipmunkSegmentShape *shape;
    
    shape = [ChipmunkSegmentShape segmentWithBody:body from:points[0][0] to:points[0][1] radius:radius];
    shape.elasticity = .5;
    shape.friction = .5;
    [chipmunkObjects addObject:shape];
    [shape setPrevNeighbor:points[0][pointCounts[0]-1] nextNeighbor:points[0][2]];
    
    for(int i=2;i<pointCounts[0]-1;i+=2)
    {
        shape = [ChipmunkSegmentShape segmentWithBody:body from:points[0][i] to:points[0][i+1] radius:radius];
        shape.elasticity = .5;
        shape.friction = .5;
        [chipmunkObjects addObject:shape];
        [shape setPrevNeighbor:points[0][i-1] nextNeighbor:points[0][i+2]];
       
    }
    
    shape = [ChipmunkSegmentShape segmentWithBody:body from:points[0][pointCounts[0]-1] to:points[0][0] radius:radius];
    shape.elasticity = .5;
    shape.friction = .5;
    [chipmunkObjects addObject:shape];
    [shape setPrevNeighbor:points[0][pointCounts[0]-2] nextNeighbor:points[0][1]];
}

- (void)centerPoints
{
    float minX,minY,maxX,maxY;
    float xOff,yOff;
 
    minX=maxX=points[0][0].x;
    minY=maxY=points[0][0].y;
    
    for(int i=0;i<pathCount;i++)
    {
        for(int j=0;j<pointCounts[i];j++)
        {
            if(points[i][j].x>maxX){maxX=points[i][j].x;}
            if(points[i][j].x<minX){minX=points[i][j].x;}
            if(points[i][j].y>maxY){maxY=points[i][j].y;}
            if(points[i][j].y<minY){minY=points[i][j].y;}
        }
    }
    
    xOff=(maxX-minX)/2;
    yOff=(maxY-minY)/2;
    
    for(int i=0;i<pathCount;i++)
    {
        for(int j=0;j<pointCounts[i];j++)
        {
            points[i][j].x-=xOff;
            points[i][j].y-=yOff;
        }
    }
    
    width = maxX-minX;
    height = maxY-minY;
}

CGFloat bezierInterpolation(CGFloat t, CGFloat p1, CGFloat p2, CGFloat p3, CGFloat p4)
{
    CGFloat a = pow((1.0 - t), 3.0);
    CGFloat b = 3.0 * t * pow((1.0 - t), 2.0);
    CGFloat c = 3.0 * pow(t, 2.0) * (1.0 - t);
    CGFloat d = pow(t, 3.0);
    
    return a * p1 + b * p2 + c * p3 + d * p4;
}

CGFloat bezierQuadInterpolation(CGFloat t, CGFloat p1, CGFloat p2, CGFloat p3)
{
    CGFloat a = pow((1.0 - t), 2.0);
    CGFloat b = 2.0 * t * (1.0 - t);
    CGFloat c = pow(t, 2.0);
    
    return a * p1 + b * p2 + c * p3;
}

void MyCGPathApplierFunc(void *data,const CGPathElement *element)
{
    LetterObject *mySelf = (__bridge LetterObject*)data;
    
    switch(element->type)
    {
        case kCGPathElementMoveToPoint:
        {
            //NSLog(@"kCGPathElementMoveToPoint");
            mySelf->currArray = [NSMutableArray array];
            [mySelf->letterPoints addObject:mySelf->currArray];
            [mySelf->currArray addObject:[NSValue valueWithCGPoint:element->points[0]]];
        }
            break;
        case kCGPathElementAddLineToPoint:
        {
            //NSLog(@"kCGPathElementAddLineToPoint");
            [mySelf->currArray addObject:[NSValue valueWithCGPoint:element->points[0]]];
        }
            break;
        case kCGPathElementAddQuadCurveToPoint:
        {
            //NSLog(@"kCGPathElementAddQuadCurveToPoint");
            NSValue *val = [mySelf->currArray lastObject];
            CGPoint startPoint = [val CGPointValue];
            for(CGFloat t = 0.0; t <= 1.00001; t += 1.0/6.0)
            {
                CGPoint point = CGPointMake(bezierQuadInterpolation(t, startPoint.x, element->points[0].x, element->points[1].x), bezierQuadInterpolation(t, startPoint.y, element->points[0].y, element->points[1].y));
                [mySelf->currArray addObject:[NSValue valueWithCGPoint:point]];
            }
        }
            break;
        case kCGPathElementAddCurveToPoint:
        {
            //NSLog(@"kCGPathElementAddCurveToPoint");
            NSValue *val = [mySelf->currArray lastObject];
            CGPoint startPoint = [val CGPointValue];
            for(CGFloat t = 0.0; t <= 1.00001; t += 1.0/6.0)
            {
                CGPoint point = CGPointMake(bezierInterpolation(t, startPoint.x, element->points[0].x, element->points[1].x, element->points[2].x), bezierInterpolation(t, startPoint.y, element->points[0].y, element->points[1].y, element->points[2].y));
                [mySelf->currArray addObject:[NSValue valueWithCGPoint:point]];
            }
        }
            break;
        case kCGPathElementCloseSubpath:
        {
            //NSLog(@"kCGPathElementCloseSubpath");
        }
            break;
    }
}

- (void)dealloc
{
    for(int i=0;i<pathCount;i++){free(points[i]);}
    free(points);
    free(pointCounts);
    
    for(int i=0;i<chipmunkLineCount;i++){free(chipmunkPoints[i]);}
    free(chipmunkPoints);
    free(chipmunkPointCounts);
}

- (GLKMatrix4) modelMatrix
{
    modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, position.x, position.y, 0);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, rotation, 0, 0, 1);
    //modelMatrix = GLKMatrix4Scale(modelMatrix, scale, scale, 0);
    return modelMatrix;
    
}

- (void)render:(Camera*) camera
{
    effect.texture2d0.enabled = NO;
    effect.constantColor=color;
    effect.useConstantColor=true;
    //effect.useConstantColor=true;
    effect.transform.modelviewMatrix = GLKMatrix4Multiply(GLKMatrix4MakeLookAt(camera->pos.x,camera->pos.y,1,camera->pos.x,camera->pos.y,0,0,1,0),[self modelMatrix]);
    [effect prepareToDraw];
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    //draw the triangulated triangles
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, p2tObj->triangleVertices);
    glDrawArrays(GL_TRIANGLES, 0, p2tObj->vertexCount);
    
    
    effect.constantColor=GLKVector4Make(0,0,0,1);
    //glLineWidth(3*camera->scale);
    [effect prepareToDraw];
    
    //draw the glyph
    
    for(int i=0;i<pathCount;i++)
    {
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, points[i]);
        glDrawArrays(GL_LINE_LOOP, 0, pointCounts[i]);
    }
    
    
    //draw chipmunk shapes
    
    for(int i=0;i<chipmunkLineCount;i++)
    {
        glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, chipmunkPoints[i]);
        glDrawArrays(GL_LINE_STRIP, 0, chipmunkPointCounts[i]);
    }
    
    
    //draw the triangulated triangle outlines
    //glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE, 0, p2tObj->triangleVertices);
    //glDrawArrays(GL_LINE_STRIP, 0, p2tObj->vertexCount);
    
    

  
    
    
    glDisableVertexAttribArray(GLKVertexAttribPosition);
    effect.useConstantColor=false;
}
- (void)update
{
    position = body.pos;
    rotation = cpvtoangle(body.rot);
}

- (void)setPosition:(CGPoint) pos
{
    position = pos;
    body.pos = pos;
}

@end
