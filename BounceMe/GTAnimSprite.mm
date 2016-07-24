#import "GTAnimSprite.h"

@implementation GTAnimSprite

-(void)onEnter
{
    [super onEnter];
    
    counter = 0.0f;
    
    bouncing = true;
    
    [self scheduleUpdate];
}

-(void)update:(ccTime)dt
{
    if (bouncing)
    {
        counter += dt;
        
        self.scaleX = ( (sin(counter*10) + 1)/2.0 * 0.1 + 1);
        self.scaleY = ( (cos(counter*10) + 1)/2.0 * 0.1 + 1);
        
        if (counter > M_PI*10){
            counter = 0;
        }
    }
}

-(void)onExit
{
    [self unscheduleUpdate];
    
    [super onExit];
}

@end