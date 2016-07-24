#import "cocos2d.h"
#import "FlexibleBall.h"
#import "SimpleAudioEngine.h"
#define PTM_RATIO 32.0f

@implementation FlexibleBall
@synthesize ball;
-(id)init{
    self = [super init];
    flag = TRUE;
    numOfBalls = NUM_SEGMENT;
    rotateOnPosition = YES;
    ball = [[CCSprite alloc]init];
    bodies = [[NSMutableArray alloc]init];
    showBubble= NO;
    
    texture = [[CCTextureCache sharedTextureCache] addImage:@"blink1.png"];
    bubble = [[CCTextureCache sharedTextureCache] addImage:@"bubble-1.png"];
    self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture];
    int volumeInd = [[[NSUserDefaults standardUserDefaults] objectForKey:@"volume"] intValue];
    if(volumeInd==0){
        volume = TRUE;
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"volume"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }else if(volumeInd == 1){
        volume = TRUE;
        
    }else if(volumeInd == 2){
        volume = FALSE;
    }
    return self;
}
-(void)makeAllBodiesPassthrough{
    b2Fixture *temp = innerCircleBody->GetFixtureList();
    b2Filter tempFilter = temp->GetFilterData();
    tempFilter.groupIndex = -8;
    temp->SetFilterData(tempFilter);
    for (int i = 0; i < NUM_SEGMENT; i++) {
        b2Body *currentBody = (b2Body*)[[bodies objectAtIndex:i] pointerValue];
        temp = currentBody->GetFixtureList();
        tempFilter = temp->GetFilterData();
        tempFilter.groupIndex = -8;
        temp->SetFilterData(tempFilter);
    }
}
-(void)invisibleForObstacles{
    b2Fixture *temp = innerCircleBody->GetFixtureList();
    b2Filter tempFilter = temp->GetFilterData();
    tempFilter.groupIndex = -7;
    temp->SetFilterData(tempFilter);
    for (int i = 0; i < NUM_SEGMENT; i++) {
        b2Body *currentBody = (b2Body*)[[bodies objectAtIndex:i] pointerValue];
        temp = currentBody->GetFixtureList();
        tempFilter = temp->GetFilterData();
        tempFilter.groupIndex = -7;
        temp->SetFilterData(tempFilter);
    }
}
-(void)makeVisibleForObstacle{
    b2Fixture *temp = innerCircleBody->GetFixtureList();
    b2Filter tempFilter = temp->GetFilterData();
    tempFilter.groupIndex = 1;
    temp->SetFilterData(tempFilter);
    for (int i = 0; i < NUM_SEGMENT; i++) {
        b2Body *currentBody = (b2Body*)[[bodies objectAtIndex:i] pointerValue];
        temp = currentBody->GetFixtureList();
        tempFilter = temp->GetFilterData();
        tempFilter.groupIndex = 1;
        temp->SetFilterData(tempFilter);
    }
}
-(void)makeAllBodySlow{
    innerCircleBody->SetLinearVelocity(b2Vec2(0,0));
    for (int i = 0; i < NUM_SEGMENT; i++) {
        b2Body *currentBody = (b2Body*)[[bodies objectAtIndex:i] pointerValue];
        currentBody->SetLinearVelocity(b2Vec2(0,0));
    }
}
-(void)createSoftBall:(b2World*)world:(float) x:(float) y{
    b2Vec2 center = b2Vec2(x/PTM_RATIO, y/PTM_RATIO);
    float springiness;
    b2CircleShape circleshape;
        circleshape.m_radius = .20f;
        springiness =20;
    
    fixtureDef.shape = &circleshape;
    fixtureDef.restitution = -2;
    fixtureDef.density = 0.5;
    fixtureDef.friction = 2.0;
//    fixtureDef.filter.groupIndex = -8;
    deltaAngle = (2.0f * M_PI)/NUM_SEGMENT;
    float radius;
    radius = 30;
    ball = [CCSprite spriteWithFile:@"blink1.png"];
    ball.tag = 5;
    ball.position = ccp(1000, 2500);
    ball.visible = FALSE;
    [self addChild:ball];
    for(int i=0;i<NUM_SEGMENT;i++){
        float theta = deltaAngle*i;
        float x = radius * cosf(theta);
        float y = radius * sinf(theta);
        b2Vec2 circlePosition = b2Vec2(x/PTM_RATIO,y/PTM_RATIO);
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.position = (center + circlePosition);
        bodyDef.userData = (__bridge void*)ball;
        body[i] = world->CreateBody(&bodyDef);
        outerBodyFixture[i]=body[i]->CreateFixture(&fixtureDef);
//        b2Fixture *temp = body[i]->GetFixtureList();
//        b2Filter tempFilter = temp->GetFilterData();
//        tempFilter.groupIndex = -8;
//        temp->SetFilterData(tempFilter);
        [bodies addObject:[NSValue valueWithPointer:body[i]]];
    }
    innerCircleBodyDef.type = b2_dynamicBody;
    innerCircleBodyDef.position = center;
    innerCircleBodyDef.userData = (__bridge void*)ball;
    innerCircleBody = world->CreateBody(&innerCircleBodyDef);
    
    innerCircleBodyFixture=innerCircleBody->CreateFixture(&fixtureDef);
    
//    b2Fixture *temp = innerCircleBody->GetFixtureList();
//    b2Filter tempFilter = temp->GetFilterData();
//    tempFilter.groupIndex = -8;
//    temp->SetFilterData(tempFilter);
    fixtureDef.shape = &circleshape;
    
    b2DistanceJointDef jointDef;
    
    for (int i = 0; i < NUM_SEGMENT; i++) {
        int neighborIndex = (i + 1) % NUM_SEGMENT;
        b2Body *currentBody = (b2Body*)[[bodies objectAtIndex:i] pointerValue];
        b2Body *neighborBody = (b2Body*)[[bodies objectAtIndex:neighborIndex] pointerValue];
        
        
        jointDef.Initialize(currentBody, neighborBody,currentBody->GetWorldCenter(),neighborBody->GetWorldCenter() );
        jointDef.collideConnected = true;
        jointDef.frequencyHz = springiness;
        jointDef.dampingRatio = 0.5f;
        world->CreateJoint(&jointDef);
        jointDef.Initialize(currentBody, innerCircleBody, currentBody->GetWorldCenter(), center);
        jointDef.collideConnected = true;
        jointDef.frequencyHz = springiness;
        jointDef.dampingRatio = 0.5f;
        world->CreateJoint(&jointDef);
        
    }
}
-(void)sound
{
    if(volume){
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0.1f];
        [[SimpleAudioEngine sharedEngine] playEffect:@"eyesanimation_1.caf"];
    }
    
}
-(void) draw{
    if(!invisible){
        
        triangleFanPos[0] = Vertex2DMake(innerCircleBody->GetPosition().x * PTM_RATIO - self.position.x,innerCircleBody->GetPosition().y * PTM_RATIO - self.position.y);
        
        
        for (int i = 0; i < NUM_SEGMENT; i++) {
            
            b2Body *currentBody = (b2Body*)[[bodies objectAtIndex:i] pointerValue];
            Vertex2D pos = Vertex2DMake(currentBody->GetPosition().x * PTM_RATIO - self.position.x,currentBody->GetPosition().y * PTM_RATIO - self.position.y);
            
            triangleFanPos[i+1] = Vertex2DMake(pos.x, pos.y);
            
        }
        
        triangleFanPos[NUM_SEGMENT+1] = triangleFanPos[1];
        
        
        
        textCoords[0] = Vertex2DMake(0.5f, 0.5f);
        
        
        for (int i = 0; i < NUM_SEGMENT; i++) {
            
            GLfloat theta = M_PI + (deltaAngle * i);
            
            textCoords[i+1] = Vertex2DMake(0.5+cosf(theta)*0.5,0.5+sinf(theta)*0.5);
            
        }
        
        
        textCoords[NUM_SEGMENT+1] = textCoords[1];
        
        CC_NODE_DRAW_SETUP();
        ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);
        ccGLBindTexture2D([texture name]);
        glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, textCoords);
        glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_TRUE, 0, triangleFanPos);
        glDrawArrays(GL_TRIANGLE_FAN, 0, NUM_SEGMENT+2);
        ccGLEnableVertexAttribs( kCCVertexAttribFlag_Color);
        if (showBubble) {
            CC_NODE_DRAW_SETUP();
            ccGLEnableVertexAttribs(kCCVertexAttribFlag_Position | kCCVertexAttribFlag_TexCoords);
            ccGLBindTexture2D([bubble name]);
            glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, 0, textCoords);
            glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_TRUE, 0, triangleFanPos);
            glDrawArrays(GL_TRIANGLE_FAN, 0, NUM_SEGMENT+2);
            ccGLEnableVertexAttribs( kCCVertexAttribFlag_Color);
        }
        
    }
    
}
-(void)changeTexture1:(NSNumber*)i{
    texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"blink%@.png",i]];
}
-(void)changeTextureright:(NSNumber*)i{
    texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"right%@.png",i]];
}
-(void)changeTextureLeft:(NSNumber*)i{
    texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"left%@.png",i]];
}
-(void)gameStarted{
    showBubble = YES;
    texture = [[CCTextureCache sharedTextureCache] addImage:@"blink1.png"];
}
-(void)makeAnimationDown{
    
    for (int i = 2; i<7; i++) {
        [self performSelector:@selector(changeTexture1:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*i];
        [self performSelector:@selector(sound) withObject:nil afterDelay:0.05*2];
    }
    int j = 1;
    for(int i=6;i>0;i--){
        [self performSelector:@selector(changeTexture1:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*6 + 0.05*j++];
    }
}
- (void) bounce:(CGPoint)location {
    b2Vec2 impulse;
    if (location.x > innerCircleBody->GetPosition().x*PTM_RATIO) {
        impulse = b2Vec2(20*innerCircleBody->GetMass(),0);
    }else{
        impulse = b2Vec2(-20*innerCircleBody->GetMass(),0);
    }
    
    b2Vec2 impulsePoint = innerCircleBody->GetPosition();
    innerCircleBody->ApplyLinearImpulse(impulse, impulsePoint);
}
-(void)doRandomAnimation{
    for (int i = 2; i<7; i++) {
        [self performSelector:@selector(changeTexture1:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*i];
        
    }
    [self performSelector:@selector(sound) withObject:nil afterDelay:0.05*2];
    int j = 1;
    for(int i=6;i>0;i--){
        [self performSelector:@selector(changeTexture1:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*6 + 0.05*j++];
    }
    for (int i = 2; i<7; i++) {
        [self performSelector:@selector(changeTexture1:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*i + 0.05*12];
        
    }
    [self performSelector:@selector(sound) withObject:nil afterDelay:0.05*2 + 0.05*12];
    j=1;
    for(int i=6;i>0;i--){
        [self performSelector:@selector(changeTexture1:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*18 + 0.05*j++];
    }
    for (int i = 2; i<7; i++) {
        [self performSelector:@selector(changeTextureright:) withObject:[NSNumber numberWithInt:i] afterDelay:24*0.05 + 0.05*i];
    }
    j = 1;
    for(int i=6;i>0;i--){
        [self performSelector:@selector(changeTextureright:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*30 + 0.05*j++];
    }
    for (int i = 2; i<6; i++) {
        [self performSelector:@selector(changeTextureLeft:) withObject:[NSNumber numberWithInt:i] afterDelay:36*0.05 + 0.05*i];
    }
    j = 1;
    for(int i=5;i>0;i--){
        [self performSelector:@selector(changeTextureLeft:) withObject:[NSNumber numberWithInt:i] afterDelay:0.05*42 + 0.05*j++];
    }
}
@end
