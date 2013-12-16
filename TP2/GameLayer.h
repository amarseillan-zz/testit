//
//  HelloWorldLayer.h
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "cocos2d.h"
#import "Graph.h"
#import "ObjectiveChipmunk.h"

@class Player;
@class HudLayer;

#define LAYER_TERRAIN_ONLY  1
#define LAYER_TERRAIN       2
#define LAYER_UNITS         4

@interface GameLayer : CCLayerColor {

    CCTMXLayer *_background;
    CCTMXLayer *_meta;
    CCTMXLayer *_foreground;
    
    Graph* _graph;
    
    NSMutableArray *_enemies;
    NSMutableArray *_projectiles;

    CCSpriteBatchNode *_enemyBatch;

    HudLayer *_hud;
    int _numCollected;

    BOOL _mouseDown;
    CGPoint _mousePos;
    
    float _nextWaveTime;
}

@property float time;
@property (strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) ChipmunkSpace *space;
@property (nonatomic, strong) Player *player;
@property (assign) int mode;
@property (strong) NSString *borderType;
@property bool stillAlive;

+ (CCScene *)scene;

- (CGPoint)tileCoordForPosition:(CGPoint)position;

- (void)setPlayerPosition:(CGPoint) position;
- (void)setViewPointCenter:(CGPoint) position;

- (CGPoint)getJoystickVelocity;

-(NSMutableArray*) findPathFrom:(CGPoint)fromPos to:(CGPoint)toPos;
@end
