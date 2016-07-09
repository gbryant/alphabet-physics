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


#import "WordObject.h"

@implementation WordObject

@synthesize chipmunkObjects;

- (id)initWithNSString:(NSString*)str effect:(GLKBaseEffect*)effect
{
    LetterObject *lo;
    
    if ((self = [super init]))
    {
        chipmunkObjects = [NSMutableArray array];
        constraints = [NSMutableArray array];
        word = str;
        letters = [NSMutableArray array];
        float maxHeight=0;
        for(int i=0;i<[word length];i++)
        {
            if([word characterAtIndex:i]!=' ')
            {
                lo = [[LetterObject alloc] initWithUniChar:[word characterAtIndex:i] effect:effect];
                lo->body.angVelLimit=0;
                [lo setPosition:cpv(i*50+200,800)];
                [letters addObject:lo];
                if(lo->height>maxHeight){maxHeight=lo->height;}
            }
        }
        ChipmunkConstraint *constraint;
        
        for(int i=0;i<letters.count-1;i++)
        {
            cpVect anchorA = cpv(0,-((LetterObject*)[letters objectAtIndex:i])->height/2);
            cpVect anchorB = cpv(0,-((LetterObject*)[letters objectAtIndex:i+1])->height/2);
            //constraint = [ChipmunkPinJoint pinJointWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body anchr1:anchorA anchr2:anchorB];
            //constraint = [ChipmunkPivotJoint pivotJointWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body anchr1:anchorA anchr2:anchorB];
            constraint = [ChipmunkDampedSpring dampedSpringWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body anchr1:anchorA anchr2:anchorB restLength:50 stiffness:70 damping:30];
            //constraint.maxForce=250;
            //constraint.maxBias=100;
            [constraints addObject:constraint];
            
            anchorA = cpv(0,maxHeight/2);
            anchorB = cpv(0,maxHeight/2);
            //constraint = [ChipmunkPinJoint pinJointWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body anchr1:anchorA anchr2:anchorB];
            //constraint = [ChipmunkPivotJoint pivotJointWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body anchr1:anchorA anchr2:anchorB];
            constraint = [ChipmunkDampedSpring dampedSpringWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body anchr1:anchorA anchr2:anchorB restLength:50 stiffness:70 damping:30];
            //constraint.maxForce=250;
            //constraint.maxBias=100;
            [constraints addObject:constraint];
            
            //constraint = [ChipmunkRotaryLimitJoint rotaryLimitJointWithBodyA:((LetterObject*)[letters objectAtIndex:i])->body bodyB:((LetterObject*)[letters objectAtIndex:i+1])->body min:0 max:1];
            //[constraints addObject:constraint];
        }
        
    }
    return self;
}

- (void)addToSpace:(ChipmunkSpace*)space
{
    for (LetterObject *lo in letters)
    {
        [space add:lo];
    }
    for (ChipmunkConstraint *co in constraints)
    {
        [space add:co];
    }
}

@end
