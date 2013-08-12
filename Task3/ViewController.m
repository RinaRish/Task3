//
//  ViewController.m
//  Task3
//
//  Created by Catherine Trishina on 08/08/2013.
//  Copyright (c) 2013 Catherine Trishina. All rights reserved.
//
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import "ViewController.h"
#import "DetailViewController.h"
#import "TweetCell.h"




@interface ViewController ()


@end

@implementation ViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //[self fetchTimelineForUser:@"rinarish@mail.ru"];
    [self getTimeLine];

}


- (void)getTimeLine {
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account
                                  accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [account requestAccessToAccountsWithType:accountType
                                     options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account
                                         accountsWithAccountType:accountType];
             
             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = [arrayOfAccounts lastObject];
                 //http://api.twitter.com/1/statuses/user_timeline.json
                 NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/1/statuses/home_timeline.json"];
                 
                 NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                 [parameters setObject:@"20" forKey:@"count"];
                 //[parameters setObject:@"name" forKey:@"screen_name"];
                 //[parameters setObject:@"20" forKey:@"include_entities"];
                 
                 SLRequest *postRequest = [SLRequest
                                           requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                           URL:requestURL parameters:parameters];
                 
                 postRequest.account = twitterAccount;
                 
                 [postRequest performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse
                    *urlResponse, NSError *error)
                  {
                      self.dataSource = [NSJSONSerialization
                                         JSONObjectWithData:responseData
                                         options:NSJSONReadingMutableLeaves
                                         error:&error];
                      
                      if (self.dataSource.count != 0) {
                          // NSLog(@"Ok");
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [self.tweetTableView reloadData];
                          });
                      }
                  }];
             }
         } else {
             // Handle failure to get account access
             NSLog(@"Error");
         }
     }];
}
//


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TweetCell *cell = [self.tweetTableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TweetCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *tweet = self.dataSource[[indexPath row]];

    cell.name.text = [tweet valueForKeyPath:@"user.name"];
    cell.tweetText.text = tweet[@"text"];
   // cell.poster.image = [UIImage imageNamed:[tweet valueForKeyPath:@"user.profile_image_url"]];
    dispatch_queue_t main = dispatch_get_main_queue();
    NSURL *imageURL = [NSURL URLWithString:[[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"]];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    dispatch_async(main, ^{
        cell.poster.image = [UIImage imageWithData:imageData];
    });
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    DetailViewController *vc = [[DetailViewController alloc] init];
//    vc.tweetDetail = [[self.dataSource objectAtIndex:[indexPath row]] valueForKeyPath:@"text"];
//    

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Detail"]) {
        DetailViewController *vc = (DetailViewController *)segue.destinationViewController;
        vc.tweetDetail = [self.dataSource[[self.tweetTableView indexPathForSelectedRow].row] valueForKeyPath:@"text"];//[[self.tableView indexPathForSelectedRow].row]; //@"My label";
        
    }
}

@end




