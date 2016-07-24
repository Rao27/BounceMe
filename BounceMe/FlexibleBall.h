#import "cocos2d.h"
#import "CCNode.h"
#import "Box2D.h"

typedef struct{
    GLfloat x;
    GLfloat y;
}Vertex2D;

static inline Vertex2D Vertex2DMake(GLfloat inX,GLfloat inY){
    Vertex2D ret;
    ret.x = inX;
    ret.y = inY;
    return ret;
}
#define NUM_SEGMENT 13
@interface FlexibleBall : CCNode {
    NSMutableArray *bodies;
    Vertex2D triangleFanPos[NUM_SEGMENT+2];
    Vertex2D textCoords[NUM_SEGMENT+2];
    CCSprite *spr;
    float deltaAngle;
    bool flag;
@public bool rotateOnPosition;
    @public bool volume;
@public BOOL invisible;
@public int numOfBalls;
@public CCTexture2D *texture;
@public CCTexture2D *bubble;
@public b2BodyDef innerCircleBodyDef;
@public b2Fixture *innerCircleBodyFixture;
@public b2Body *innerCircleBody;    
@public b2Fixture *outerBodyFixture[NUM_SEGMENT];
@public CCSprite *ball;
@public b2Body *body[NUM_SEGMENT];
@public b2FixtureDef fixtureDef;
@public BOOL showBubble;
}
@property (nonatomic,retain) CCSprite *ball;
-(void) createSoftBall:(b2World*)world:(float)x:(float)y;
- (void) bounce:(CGPoint)location;
-(void)makeAnimationDown;
-(void)makeAnimationUp;
-(void)gameStarted;
-(void)doRandomAnimation;
-(void)makeAllBodiesPassthrough;
-(void)invisibleForObstacles;
-(void)makeVisibleForObstacle;
-(void)makeAllBodySlow;
@end
