//
//  Player.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright (c) 2013 AdminMacLC04. All rights reserved.
//

#import "Player.h"
#import "Graph.h"
#import "GameLayer.h"

#define FRICTION 0.67f

@implementation Player

- (id)initWithLayer:(GameLayer *)layer {
    self = [super initWithFile:@"player.png"];
    
    if (self != nil) {
        _gameLayer = layer;
        _speed = 3000;
        _name = @"IlMarse";
        float playerMass = 10.0f;
        float playerRadius = 13.0f;
        
        self.chipmunkBody = [layer.space add:[ChipmunkBody bodyWithMass:playerMass andMoment:INFINITY]];
        ChipmunkShape *playerShape = [layer.space add:[ChipmunkCircleShape circleWithBody:self.chipmunkBody radius:playerRadius offset:cpvzero]];
        playerShape.friction = 0.1;
        playerShape.collisionType = [Player class];
        playerShape.layers = LAYER_UNITS | LAYER_TERRAIN;
        playerShape.data = self;
        
        
        
        // now create a control body. We'll move this around and use joints to do the actual player
        // motion based on the control body
        targetPointBody = [ChipmunkBody bodyWithMass:INFINITY andMoment:INFINITY];
        targetPointBody.pos = ccp(self.chipmunkBody.pos.x, self.chipmunkBody.pos.y); // make the player's target destination start at the same place the player.
        
        ChipmunkPivotJoint* joint = [_gameLayer.space add:[ChipmunkPivotJoint pivotJointWithBodyA:targetPointBody bodyB:self.chipmunkBody anchr1:cpvzero anchr2:cpvzero]];
        
        // max bias controls the maximum speed that a joint can be corrected at. So that means
        // the player body won't be forced towards the control at a speed higher than this.
        // Thus it's essentially the speed of the player's motion
        joint.maxBias = 200.0f;
        
        // limiting the force will prevent us from crazily pushing huge piles
        // of heavy things. and give us a sort of top-down friction.
        joint.maxForce = 3000.0f;
    }
    [self schedule:@selector(update:)];
    
    return self;
}

- (void)update:(ccTime)delta {
    [self.chipmunkBody resetForces];
    
    
    targetPointBody.pos = ccpAdd(self.chipmunkBody.pos, [_gameLayer getJoystickVelocity]);
    

    [_gameLayer setViewPointCenter:self.position];
    self.chipmunkBody.vel = ccpMult(self.chipmunkBody.vel, FRICTION);
}

-(void)setPath:(NSMutableArray*)path {
    _path = path;
}

@end
