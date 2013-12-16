//
//  HelloWorldLayer.m
//  Tale
//
//  Created by AdminMacLC04 on 10/24/13.
//  Copyright AdminMacLC04 2013. All rights reserved.
//

#import "GameLayer.h"
#import "GameOverLayer.h"
#import "AppDelegate.h"
#import "GameObject.h"
#import "Player.h"
#import "Graph.h"
#import "MyDebugRenderer.h"
#import "SimpleAudioEngine.h"
#import "ObjectiveChipmunk.h"
#import "ChipmunkAutoGeometry.h"
#import "Enemy.h"
#import "HudLayer.h"
#import "LevelManager.h"

@implementation GameLayer

+ (CCScene *)scene {
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    
    [scene addChild: layer];

    HudLayer *hud = [HudLayer node];
    [scene addChild:hud];
    layer->_hud = hud;
    
    hud.gameLayer = layer;
    
    return scene;
}

- (id)init {
    self = [super initWithColor:ccc4(255,255,255,255)];
    
    if (self != nil) {
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.caf"];
//        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"TileMap.caf"];
        
        _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"TileMap.tmx"];
        [self addChild:_tileMap];
        _background = [_tileMap layerNamed:@"Background"];
        _foreground = [_tileMap layerNamed:@"Foreground"];
        
        _meta = [_tileMap layerNamed:@"Meta"];
        _meta.visible = NO;
        
        _space = [[ChipmunkSpace alloc] init];
        _borderType = @"borderType";
        
        CGRectMake(0, 0, _tileMap.mapSize.width, _tileMap.mapSize.height);
        [_space addBounds:CGRectMake(0, 0, _tileMap.mapSize.width*_tileMap.tileSize.width-15, _tileMap.mapSize.height*_tileMap.tileSize.height-15)
               thickness:10.0f
              elasticity:1.0f friction:1.0f
                  layers:LAYER_UNITS | LAYER_TERRAIN | LAYER_TERRAIN_ONLY group:CP_NO_GROUP
           collisionType:_borderType
         ];
        
        [_space addCollisionHandler:self
                             typeA:[Player class] typeB:_borderType
                             begin:@selector(beginCollision:space:)
                          preSolve:nil
                         postSolve:@selector(postSolveCollision:space:)
                          separate:@selector(separateCollision:space:)
         ];
        
        [_space addCollisionHandler:self
                              typeA:[Player class] typeB:[Enemy class]
                              begin:@selector(beginCollision:space:)
                           preSolve:nil
                          postSolve:@selector(postSolveCollision:space:)
                           separate:@selector(separateCollision:space:)
         ];
        
        // Add a CCPhysicsDebugNode to draw the space.
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        [self addChild:debugNode];
        
        _player = [[Player alloc] initWithLayer:self];
        _stillAlive = true;
        [self addChild:_player];
        _enemies = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];

        [self schedule:@selector(update:)];
        [self schedule:@selector(testCollisions:)];
        [self setTouchEnabled:YES];
        
        CCTMXObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objectGroup != nil, @"tile map has no objects object layer");
        
        NSDictionary *spawnPoint = [objectGroup objectNamed:@"SpawnPoint"];
        int x = [spawnPoint[@"x"] integerValue];
        int y = [spawnPoint[@"y"] integerValue];
        
        uint32_t tileGID = [_background tileGIDAt:CGPointMake(3, 0)];
        NSDictionary* properties = [_tileMap propertiesForGID:tileGID];
        
        NSLog(@"%@", properties);
        
        _player.chipmunkBody.pos = ccp(x,y);
        [self setViewPointCenter:_player.position];
        _graph = [[Graph alloc] initWithMap:_tileMap];
        CCLOG(@"%f,%f", _player.position.x, _player.position.y);

        
//        MyDebugRenderer* renderer = [[MyDebugRenderer alloc] initWithGraph:_graph tileSize:_tileMap.tileSize];
//        [self addChild:renderer];
        self.touchEnabled = YES;
        
        [self createTerrainGeometry];
//        for(int i=0; i<16; i++){
//            float dist = 50.0f;
//            [self makeBoxAtX: x + (i % 4) * dist + 200 y: y + ( i / 4) * dist - 200];
//        }
        
        for (spawnPoint in [objectGroup objects]) {
            if ([[spawnPoint valueForKey:@"Enemy"] intValue] == 1){
                x = [[spawnPoint valueForKey:@"x"] intValue];
                y = [[spawnPoint valueForKey:@"y"] intValue];
                [self addEnemyAtX:x y:y];
            }
        }
        
        _nextWaveTime = 0;
    }
    
    return self;
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = YES;
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _mousePos = [self convertTouchToNodeSpace:touch];
    _mouseDown = NO;
    
    CGPoint touchLocation = [touch locationInView:touch.view];
    touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    if (_mode == 0) {
        [self movePlayer:touchLocation];
    } else {
        [self shoot:touchLocation];
    }    
}

- (void)update:(ccTime)dt {
    _time += dt;
    
    NSMutableArray *inactive = [[NSMutableArray alloc] init];
    
    // update enemies
    for (GameObject *enemy in _enemies) {
        [enemy update:dt];
        
        if (!enemy.active) {
            [inactive addObject:enemy];
        }
    }
    
    // remove inactive game objects
    for (GameObject *gameObject in inactive) {
        if ([gameObject isKindOfClass:[GameObject class]]) {
            [_enemies removeObject:gameObject];
            [self removeChild:gameObject cleanup:YES];
        }
    }
    _nextWaveTime +=dt;
    
    if (_nextWaveTime >= [LevelManager sharedManager].curLevel.secsPerSpawn && [LevelManager sharedManager].curLevel.enemiesSpawned < [LevelManager sharedManager].curLevel.enemiesNum) {
        int x;
        int y;
        CCTMXObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
        for (NSDictionary* spawnPoint in [objectGroup objects]) {
            if ([[spawnPoint valueForKey:@"Enemy"] intValue] == 1){
                x = [[spawnPoint valueForKey:@"x"] intValue];
                y = [[spawnPoint valueForKey:@"y"] intValue];
                [self addEnemyAtX:x y:y];
            }
        }
        _nextWaveTime = 0;
    }
    
    [_space step:dt];
}

-(NSMutableArray*) findPathFrom:(CGPoint)fromPos to:(CGPoint)toPos {
    
    Node* from  = [self nodeForPosition:fromPos];
    Node* to =  [self nodeForPosition:toPos];
    
//    CCLOG(@"fromCoord %@",CGPointCreateDictionaryRepresentation([self tileCoordForPosition:fromPos]));
    if (to == nil || to == (id)[NSNull null]) {
        CGPoint destCoordinate = [self tileCoordForPosition:toPos];
//        CCLOG(@"destCoordinate %@",CGPointCreateDictionaryRepresentation(destCoordinate));
        to = [[Node alloc] initWith:destCoordinate];
    }
    NSArray* path = [_graph findPathFrom:from to:to];
    NSMutableArray* betterPath = [NSMutableArray array];
    
    Node* start = path[0];
    Node* prev = path[0];
    Node* current;
    for (Node *node in path) {
        
        current = node;
        CGPoint from = [self positionForTileCoord:[start getCoordinates]];
        CGPoint to =[self positionForTileCoord:[current getCoordinates]];
        NSArray* hitObjects = [_space segmentQueryAllFrom:from to:to layers:LAYER_TERRAIN_ONLY group:CP_NO_GROUP];
        
        if ([hitObjects count] > 0) {
            [betterPath addObject:prev];
            start = prev;
        }
        prev = current;
    }
    [betterPath addObject:current];
    return betterPath;
}


/* Private methods */

-(void) movePlayer:(CGPoint) touchLocation {
    CGPoint playerPos = _player.position;
    NSMutableArray* path = [self findPathFrom:playerPos to:touchLocation];
    
    //[_graph printPath:path];
    [_player setPath:path];
    
    //    CCLOG(@"playerPos %@",CGPointCreateDictionaryRepresentation(playerPos));
    [self setViewPointCenter:_player.position];
}

-(void) shoot:(CGPoint) touchLocation {
    CCSprite *projectile = [CCSprite spriteWithFile:@"Projectile.png"];
    projectile.position = _player.position;
    [self addChild:projectile];
    
    int width = _tileMap.mapSize.width * _tileMap.tileSize.width;
    int height = _tileMap.mapSize.height * _tileMap.tileSize.height;
    int realX;
    
    // Are we shooting to the left or right?
    CGPoint diff = ccpSub(touchLocation, _player.position);
    if (diff.x > 0) {
        realX = (_tileMap.mapSize.width * _tileMap.tileSize.width) -
        (projectile.contentSize.width/2);
    } else {
        realX = (projectile.contentSize.width/2);
    }
    float ratio = (float) diff.y / (float) diff.x;
    int realY = ((realX - projectile.position.x) * ratio) + projectile.position.y;

    CCLOG(@"ratio %f - abd %f", ratio, fabs(ratio));
    if (realY > height) {
        float a = realY - height;
        float b = a / fabs(ratio);
        if (diff.x > 0) {
            realX -= b;
        } else {
            realX += b;
        }
        realY = height - (projectile.contentSize.width/2);
    } else if (realY < 0){
        float a = fabs(realY);
        float b = a / fabs(ratio);
        if (diff.x > 0) {
            realX -= b;
        } else {
            realX += b;
        }
        realY = (projectile.contentSize.width/2);
    }
    
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far we're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX) + (offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    CCLOG(@"world size %d,%d", width, height);
    if (realDest.x < 0 || realDest.x >= width || realDest.y < 0 || realDest.y >= height) {
        CCLOG(@"AND ITS A HOMERUNM!!!!");
    }
    
    CCLOG(@"realdest %f,%f", realDest.x, realDest.y);
    CGPoint realDest2 = [self tileCoordForPosition:realDest];
    CCLOG(@"realdest %f,%f", realDest2.x, realDest2.y);
    
    id actionMoveDone = [CCCallFuncN actionWithTarget:self
                                             selector:@selector(projectileMoveFinished:)];
    [projectile runAction:
     [CCSequence actionOne:
      [CCMoveTo actionWithDuration: realMoveDuration
                          position: realDest]
                       two: actionMoveDone]];
    [_projectiles addObject:projectile];
}

-(void)setPlayerPosition:(CGPoint)position {
	
    CGPoint tileCoord = [self tileCoordForPosition:position];
    tileCoord = ccp(tileCoord.x, _tileMap.mapSize.height - 1 - tileCoord.y);
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            
            NSString *collision = properties[@"Collidable"];
            if (collision && [collision isEqualToString:@"True"]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                return;
            }
            
            NSString *collectible = properties[@"Collectable"];
            if (collectible && [collectible isEqualToString:@"True"]) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"pickup.caf"];
                _numCollected++;
                [_hud numCollectedChanged:_numCollected];
                
                [_meta removeTileAt:tileCoord];
                [_foreground removeTileAt:tileCoord];
            }
        }
    }
//    [[SimpleAudioEngine sharedEngine] playEffect:@"move.caf"];
    _player.position = position;
}

-(Node*)nodeForPosition:(CGPoint)position {
    int col = position.x/_tileMap.tileSize.width;
    int row = position.y/_tileMap.tileSize.height;
    return [_graph nodeForIndex:col*_tileMap.mapSize.height + row];
}

-(Node*)nodeForTile:(CGPoint)tilePosition {
    int col = tilePosition.x;
    int row = tilePosition.y;
    return [_graph nodeForIndex:col*_tileMap.mapSize.height + row];
}

-(CGPoint)tileCoordForPosition:(CGPoint)position {
    return ccp(floor(position.x/_tileMap.tileSize.width), floor(position.y/_tileMap.tileSize.height));
}

-(CGPoint) positionForTileCoord:(CGPoint)tileCoord {
    return ccp(tileCoord.x * _tileMap.tileSize.width+_tileMap.tileSize.width/2, tileCoord.y * _tileMap.tileSize.height+_tileMap.tileSize.height/2);
}

- (void)setViewPointCenter:(CGPoint) position {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    int x = MAX(position.x, winSize.width/2);
    int y = MAX(position.y, winSize.height/2);
    x = MIN(x, (_tileMap.mapSize.width * _tileMap.tileSize.width) - winSize.width / 2);
    y = MIN(y, (_tileMap.mapSize.height * _tileMap.tileSize.height) - winSize.height/2);
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

- (void)testCollisions:(ccTime)dt {
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    
    for (CCSprite *projectile in _projectiles) {
        CGRect projectileRect = CGRectMake(
                                           projectile.position.x - (projectile.contentSize.width/2),
                                           projectile.position.y - (projectile.contentSize.height/2),
                                           projectile.contentSize.width,
                                           projectile.contentSize.height);
        
        NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
        
        for (Enemy *target in _enemies) {
            CGRect targetRect = CGRectMake(
                                           target.position.x - (target.contentSize.width/2),
                                           target.position.y - (target.contentSize.height/2),
                                           target.contentSize.width,
                                           target.contentSize.height);
            
            if (CGRectIntersectsRect(projectileRect, targetRect)) {
                [targetsToDelete addObject:target];
                [LevelManager sharedManager].curLevel.enemiesKilled++;
                [_hud updateEnemyCounter:[LevelManager sharedManager].curLevel.enemiesKilled];
                if ([LevelManager sharedManager].curLevel.enemiesKilled >= [LevelManager sharedManager].curLevel.enemiesNum) {
                    [self gameOver:true];
                }
            }
        }
        
        for (Enemy *target in targetsToDelete) {
            [_enemies removeObject:target];
            [_space remove:target.chipmunkBody];
            [_space remove:target.shape];
            [self removeChild:target cleanup:YES];
        }
        
        bool wallHit = false;
        
        CGPoint tileCoord = [self tileCoordForPosition:projectile.position];
        tileCoord = ccp(tileCoord.x, _tileMap.mapSize.height - 1 - tileCoord.y);
        int tileGid = [_meta tileGIDAt:tileCoord];
        if (tileGid) {
            NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
            if (properties) {
                NSString *collision = properties[@"Collidable"];
                if (collision && [collision isEqualToString:@"True"]) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                    wallHit = true;
                }
            }
        }
        if (targetsToDelete.count > 0 || wallHit) {
            [projectilesToDelete addObject:projectile];
        }
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
}

- (void)createTerrainGeometry
{
    int tileCountW = _meta.layerSize.width;
    int tileCountH = _meta.layerSize.height;
    
    cpBB sampleRect = cpBBNew(-0.5, -0.5, tileCountW + 0.5, tileCountH + 0.5);
    
    ChipmunkBlockSampler *sampler = [[ChipmunkBlockSampler alloc] initWithBlock:^(cpVect point){
        
        point = cpBBClampVect(cpBBNew(0.5, 0.5, tileCountW - 0.5, tileCountH - 0.5), point);
        int x = point.x;
        int y = point.y;
        
        y = tileCountH - 1 - y;
        
        NSDictionary *properties = [_tileMap propertiesForGID:[_meta tileGIDAt:ccp(x, y)]];
        BOOL collidable = [[properties valueForKey:@"Collidable"] isEqualToString:@"True"];
        return (collidable ? 1.0f : 0.0f);
    }];
    
    ChipmunkPolylineSet * polylines = [sampler march:sampleRect xSamples:tileCountW + 2 ySamples:tileCountH + 2 hard:TRUE];
    
    cpFloat tileSize = _tileMap.tileSize.height;
    
    for(ChipmunkPolyline * line in polylines){
        ChipmunkPolyline * simplified = [line simplifyCurves:0.0f];
        
        for(int i=0; i<simplified.count-1; i++){
            
            cpVect a = cpvmult(simplified.verts[  i], tileSize);
            cpVect b = cpvmult(simplified.verts[i+1], tileSize);
            
            ChipmunkShape *seg = [_space add:[ChipmunkSegmentShape segmentWithBody:_space.staticBody from:a to:b radius:1.0f]];
            seg.friction = 1.0;
            seg.layers = LAYER_TERRAIN_ONLY | LAYER_TERRAIN;
        }
    }
    
    // add left wall
    ChipmunkShape *segLeft = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(0, 0) to:cpv(0, tileCountH * tileSize) radius:1.0f];
    segLeft.layers = LAYER_TERRAIN_ONLY | LAYER_TERRAIN;
    [_space add:segLeft];
    
    // add top wall
    ChipmunkShape *segTop = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(0, tileCountH * tileSize) to:cpv(tileCountW * tileSize, tileCountH * tileSize) radius:1.0f];
    segLeft.layers = LAYER_TERRAIN_ONLY | LAYER_TERRAIN;
    [_space add:segTop];
    
    // add right wall
    ChipmunkShape *segRight = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(tileCountW * tileSize, tileCountH * tileSize) to:cpv(tileCountW * tileSize, 0) radius:1.0f];
    segLeft.layers = LAYER_TERRAIN_ONLY | LAYER_TERRAIN;
    [_space add:segRight];
    
    // add bottom wall
    ChipmunkShape *segBottom = [ChipmunkSegmentShape segmentWithBody:_space.staticBody from:cpv(tileCountW * tileSize, 0) to:cpv(0, 0) radius:1.0f];
    segLeft.layers = LAYER_TERRAIN_ONLY | LAYER_TERRAIN;
    [_space add:segBottom];
}

- (ChipmunkBody*)makeBoxAtX:(int)x y:(int)y
{
    float mass = 0.3f;
    float size = 27.0f;
    
    ChipmunkBody* body = [ChipmunkBody bodyWithMass:mass andMoment:cpMomentForBox(mass, size, size)];
    
    CCPhysicsSprite * boxSprite = [CCPhysicsSprite spriteWithFile:@"crate.png"];
    boxSprite.chipmunkBody = body;
    boxSprite.position = cpv(x,y);
    
    ChipmunkShape* boxShape = [ChipmunkPolyShape boxWithBody:body width: size height: size];
    boxShape.friction = 1.0f;
    
    [_space add:boxShape];
    [_space add:body];
    [self addChild:boxSprite];

    ChipmunkPivotJoint* pj = [_space add: [ChipmunkPivotJoint pivotJointWithBodyA:
                                          [_space staticBody] bodyB:body anchr1:cpvzero anchr2:cpvzero]];
    
    pj.maxForce = 1000.0f; // emulate linear friction
    pj.maxBias = 0; // disable joint correction, don't pull it towards the anchor.
    
    // Then use a gear to fake an angular friction (slow rotating boxes)
    ChipmunkGearJoint* gj = [_space add: [ChipmunkGearJoint gearJointWithBodyA:[_space staticBody] bodyB:body phase:0.0f ratio:1.0f]];
    
    gj.maxForce = 5000.0f;
    gj.maxBias = 0.0f;
    return body;
}

-(void)addEnemyAtX:(int)x y:(int)y {

    if ([LevelManager sharedManager].curLevel.enemiesSpawned < [LevelManager sharedManager].curLevel.enemiesNum) {
        Enemy *enemy = [[Enemy alloc ] initWithLayer:self];
        enemy.position = ccp(x, y);
    
        [_enemies addObject:enemy];
        [LevelManager sharedManager].curLevel.enemiesSpawned++;
        [self addChild:enemy];
    }
}

- (bool)beginCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
    CHIPMUNK_ARBITER_GET_SHAPES(arbiter, playerShape, otherShape);
    
    if (_stillAlive) {
        Player* player = playerShape.data;
    
        if ([otherShape.data isMemberOfClass:[Enemy class]]) {
            if (![LevelManager sharedManager].godMode) {
                _stillAlive = false;
                [[SimpleAudioEngine sharedEngine] playEffect:@"Sound Effects - Death Screams.mp3"];
                [self gameOver:false];
            }
        }
        CCLOG(@"collision!!! %@", player.name);
        [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
        return TRUE;
    } else {
        return false;
    }
}

- (void)separateCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
    CHIPMUNK_ARBITER_GET_SHAPES(arbiter, buttonShape, border);
}

- (void)postSolveCollision:(cpArbiter*)arbiter space:(ChipmunkSpace*)space {
    if(!cpArbiterIsFirstContact(arbiter)) return;
    
    cpFloat impulse = cpvlength(cpArbiterTotalImpulse(arbiter));
    
    float volume = MIN(impulse/500.0f, 1.0f);
    if(volume > 0.05f){
//        [SimpleSound playSoundWithVolume:volume];
    }
}

- (void) projectileMoveFinished:(id)sender {
    CCSprite *sprite = (CCSprite *)sender;
    [self removeChild:sprite cleanup:YES];
    [_projectiles removeObject:sprite];
}

- (void) gameOver:(bool)won {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[GameOverLayer sceneWithWon:won caller:self]]];
}

- (CGPoint)getJoystickVelocity{
    return _hud.leftJoystick.velocity;
}

@end
