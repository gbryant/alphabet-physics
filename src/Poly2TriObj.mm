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


#import "Poly2TriObj.h"
#include "poly2tri.h"


@implementation Poly2TriObj

std::vector<p2t::Triangle*> _triangles;
std::vector<p2t::Point*> _polyline;
std::vector<p2t::Point*> _hole1;
std::vector<p2t::Point*> _hole2;


- (id)initWithCGPoint:(CGPoint**)pointsIn pointCounts:(int*)pointCountsIn pathCount:(int)pathCountIn
{
    if ((self = [super init]))
    {
        _polyline.clear();
        _triangles.clear();
        _hole1.clear();
        _hole2.clear();
        points = pointsIn;
        pointCounts = pointCountsIn;
        pathCount = pathCountIn;
        polyLine = [NSMutableArray array];
        triangles = [NSMutableArray array];
        
        
        //[self triangulate];
    }
    return self;
}

- (void)triangulate
{
     int polySize=0;
     _polyline.push_back(new p2t::Point(points[0][0].x,points[0][0].y));
     polySize++;
     for(int i=1;i<pointCounts[0]-1;i++)
     {
         if(points[0][i].x!=_polyline[polySize-1]->x||points[0][i].y!=_polyline[polySize-1]->y)
         {_polyline.push_back(new p2t::Point(points[0][i].x,points[0][i].y));polySize++;}
     }
     p2t::CDT *cdt = new p2t::CDT(_polyline);
    
    if(holeCount==1)
    {
        
        polySize=0;
        _hole1.push_back(new p2t::Point(points[1][0].x,points[1][0].y));
        polySize++;
        for(int i=1;i<pointCounts[1]-1;i++)
        {
            if(points[1][i].x!=_hole1[polySize-1]->x||points[1][i].y!=_hole1[polySize-1]->y)
            {_hole1.push_back(new p2t::Point(points[1][i].x,points[1][i].y));polySize++;}
        }
        cdt->AddHole(_hole1);
    }
    else if(holeCount==2)
    {
        
        polySize=0;
        _hole1.push_back(new p2t::Point(points[1][0].x,points[1][0].y));
        polySize++;
        for(int i=1;i<pointCounts[1]-1;i++)
        {
            if(points[1][i].x!=_hole1[polySize-1]->x||points[1][i].y!=_hole1[polySize-1]->y)
            {_hole1.push_back(new p2t::Point(points[1][i].x,points[1][i].y));polySize++;}
        }
        cdt->AddHole(_hole1);
        
        polySize=0;
        _hole2.push_back(new p2t::Point(points[2][0].x,points[2][0].y));
        polySize++;
        for(int i=1;i<pointCounts[1]-1;i++)
        {
            if(points[2][i].x!=_hole2[polySize-1]->x||points[2][i].y!=_hole2[polySize-1]->y)
            {_hole2.push_back(new p2t::Point(points[2][i].x,points[2][i].y));polySize++;}
        }
        cdt->AddHole(_hole2);
    }
    
     cdt->Triangulate();
     _triangles = cdt->GetTriangles();
    
    vertexCount=_triangles.size()*3;
    triangleVertices = (GLfloat*)malloc(sizeof(GLfloat)*vertexCount*2);
    for(int i=0;i<_triangles.size();i++)
    {
        triangleVertices[i*6+0]=_triangles[i]->GetPoint(0)->x;
        triangleVertices[i*6+1]=_triangles[i]->GetPoint(0)->y;
        triangleVertices[i*6+2]=_triangles[i]->GetPoint(1)->x;
        triangleVertices[i*6+3]=_triangles[i]->GetPoint(1)->y;
        triangleVertices[i*6+4]=_triangles[i]->GetPoint(2)->x;
        triangleVertices[i*6+5]=_triangles[i]->GetPoint(2)->y;
    }
    delete cdt;
}

- (void) dealloc
{
    free(triangleVertices);
}


@end
