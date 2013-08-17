//
//  TweetCell.h
//  Task3
//
//  Created by Catherine Trishina on 11/08/2013.
//  Copyright (c) 2013 Catherine Trishina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell

@property(nonatomic, weak) IBOutlet UILabel *name;
@property(nonatomic, weak) IBOutlet UILabel *tweetText;
@property(nonatomic, weak) IBOutlet UIImageView *poster;
@property(nonatomic, weak) IBOutlet UILabel *location;

@end
