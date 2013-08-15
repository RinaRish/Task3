//
//  Tweet.m
//  Task3
//
//  Created by Catherine Trishina on 08/08/2013.
//  Copyright (c) 2013 Catherine Trishina. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

-(id) init {
    return [self initWithText:nil
                       author:nil
                        photo:nil];
}

- (id)initWithText:(NSString *)theText
            author:(NSString *)theAuthor 
             photo:(NSString *)thePhoto {
    self = [super init];
    if(self) {
        self.text = theText;
        self.author =theAuthor;
        self.photo = thePhoto;
            }
    return self;
}




@end
