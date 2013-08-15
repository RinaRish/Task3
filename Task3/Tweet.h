//
//  Tweet.h
//  Task3
//
//  Created by Catherine Trishina on 08/08/2013.
//  Copyright (c) 2013 Catherine Trishina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *author;
@property (strong, nonatomic) NSString *photo;

- (id)initWithText:(NSString *)theText
            author:(NSString *)theAuthor
             photo:(NSString *)thePhoto;

@end
