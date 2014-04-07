//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//


#import "MainScene.h"
#import "Obstacle.h"


static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 180.f;

typedef NS_ENUM(NSInteger, DrawingOrder) {
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrderProcedure
};
@implementation MainScene {
    CCSprite *_procedure;
    CCPhysicsNode *_physicsNode;
    
    CCNode *_background1;
    CCNode *_background2;
    NSArray *_backgrounds;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    CCLabelTTF *_score;
    
    
    NSMutableArray *_obstacles;
    
    CCButton *_restartButton;
    
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    
    NSInteger _points;
}

-(void) didLoadFromCCB {
    _grounds = @[_ground1, _ground2];
    _backgrounds = @[_background1, _background2];
    self.userInteractionEnabled = TRUE;
    
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
    for (CCNode *ground in _grounds) {
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    _physicsNode.collisionDelegate = self;
    
    _procedure.zOrder = DrawingOrderProcedure;
    
    _procedure.physicsBody.collisionType = @"hero";
    _procedure.zOrder = DrawingOrderProcedure;
    
    _scrollSpeed = 200.f;
    
    _points = 0;
}
-(void)update:(CCTime)delta {
    _procedure.position = ccp(_procedure.position.x +delta *_scrollSpeed, _procedure.position.y);
    _physicsNode.position = ccp(_physicsNode.position.x -delta *_scrollSpeed, _physicsNode.position.y);
    
    
    
    for (int i=0; i<2;i++) {
        CCNode *ground = [_grounds objectAtIndex:i];
        CCNode *background = [_backgrounds objectAtIndex:i];
        
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];

        
        CGPoint backgroundWorldPosition = [_physicsNode convertToWorldSpace:background.position];
        CGPoint backgroundScreenPosition = [self convertToNodeSpace:backgroundWorldPosition];
        
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)){
            ground.position = ccp(ground.position.x + 2* ground.contentSize.width, ground.position.y);
        }
        if (backgroundScreenPosition.x <= (-1 * background.contentSize.width)){
            background.position = ccp(background.position.x + 2*background.contentSize.width, background.position.y);
        }

    }
    
    float yVelocity = clampf(_procedure.physicsBody.velocity.y, -1 *MAXFLOAT, 200.f);
    _procedure.physicsBody.velocity = ccp(0, yVelocity);
    
    
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles ){
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        
        if (obstacleScreenPosition.x < -obstacle.contentSize.width){
            if(!offScreenObstacles){
                offScreenObstacles = [NSMutableArray array];
                
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        [self spawnNewObstacle];
    }
    
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    if (!_gameOver) {
        CGPoint procedureWorldPosition = [_physicsNode convertToWorldSpace:_procedure.position];
        CGPoint procedureScreenPosition = [self convertToNodeSpace:procedureWorldPosition];
        
        if (procedureScreenPosition.y < screenHeight ){
            [_procedure.physicsBody applyImpulse:ccp(0, 400.f)];
        }
    }
   
}

-(void)spawnNewObstacle {
    CCNode * previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    if(!previousObstacle){
        previousObstacleXPosition = firstObstaclePosition;
    }
    
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles, 0);
    [obstacle setupRandomPosition];
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    
    obstacle.zOrder = DrawingOrderPipes;
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)procedure level:(CCNode *)level {
    NSLog(@"GAME OVER");
    
    [self gameOver];
    _restartButton.visible = TRUE;
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)procedure goal:(CCNode *)goal {
    _points++;
    NSLog(@"GOOOL %d", _points);
    [goal removeFromParent];
    _score.string = [NSString stringWithFormat:@"%d",_points];
    
    return TRUE;
    
    
}
-(void)restart {
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}


-(void)gameOver {
    _scrollSpeed = 0.f;
    _gameOver = TRUE;
    _restartButton.visible = TRUE;
    [_procedure stopAllActions];
    CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2,2)];
    CCActionInterval *reverseMovement = [moveBy reverse];
    CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
    CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
    [self runAction:bounce];
}

@end
