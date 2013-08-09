//
//  ViewController.h
//  Task3
//
//  Created by Catherine Trishina on 08/08/2013.
//  Copyright (c) 2013 Catherine Trishina. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tweetTableView;
@property (strong, nonatomic) NSArray *dataSource;


@end
