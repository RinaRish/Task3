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
#import "SystemConfiguration/SystemConfiguration.h"
#import "ViewController.h"
#import "DetailViewController.h"
#import "TweetCell.h"
#import "Reachability.h"




@interface ViewController ()


@end

@implementation ViewController


BOOL flag;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWWAN) {
        
        //Code when there is a WAN connection
        NSLog(@"WAN");
        flag=true;
        
    } else if (networkStatus == ReachableViaWiFi) {
        
        //Code when there is a WiFi connection
        NSLog(@"wi-fi");
        flag=true;
        [self getTimeLine];
        
        
    } else if (networkStatus == NotReachable) {
        
        //Code when there is no connection
        NSLog(@"no internet");
        flag=false;
        
        
     
    }
  
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
                    //  self.dataSource =
                      
                      if (self.dataSource.count != 0) {
                          // NSLog(@"Ok");
                          NSLog(@"%@", self.dataSource);
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



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tweetTableView deselectRowAtIndexPath:[self.tweetTableView indexPathForSelectedRow] animated:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (flag==true) {
        return self.dataSource.count;
    }
    else {
        return 20;
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    TweetCell *cell = [self.tweetTableView
                       dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TweetCell alloc]
                initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    
    if (flag==true) { //if we have internet
        static int count = 0;
        NSDictionary *tweet = self.dataSource[indexPath.row];
        
        // WRITE TO PLIST
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:tweet forKey:[NSString stringWithFormat:@"tweet_%d", count]];
        ++count;
        [archiver encodeObject:@(count) forKey:@"count"];
        [archiver finishEncoding];
        NSError *error;
        if(![data writeToFile:@"/Users/rinarish/Desktop/Task3/Task3/Tweets.plist" options:NSDataWritingAtomic error:&error])
        {
            NSLog(@"%@", error);
        }
        

        cell.name.text = [tweet valueForKeyPath:@"user.name"];
        cell.tweetText.text = tweet[@"text"];
        

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrl = [[tweet objectForKey:@"user"] objectForKey:@"profile_image_url"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.poster.image = [UIImage imageWithData:data];
            });
        });
        
        if([tweet valueForKeyPath:@"place.attributes.country"]!=nil)
            cell.location.text = @"undefinied"; 
        else cell.location.text = [tweet valueForKeyPath:@"place.attributes.name"];
        return cell;

    } else { // NO INTERNET
       
        // READ FROM PLIST
//        NSDictionary *tweet2;
        NSData *data2 = [[NSMutableData alloc] initWithContentsOfFile:@"/Users/rinarish/Desktop/Task3/Task3/Tweets.plist"];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data2];
        //NSNumber *localCount = [unarchiver decodeObjectForKey:@"count"];
        [unarchiver decodeObjectForKey:@"count"];
//        for(NSInteger i = 0; i < localCount.integerValue; ++i) {
            NSDictionary *tweet = [unarchiver decodeObjectForKey:[NSString stringWithFormat:@"tweet_%d", indexPath.row]];
            [unarchiver finishDecoding];
            cell.name.text = [tweet valueForKeyPath:@"user.name"];
            cell.tweetText.text = tweet[@"text"];
            cell.poster.image =[UIImage imageNamed:@"placeholder.png"];
//        }
        
        return cell;
        
    }
        

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
        if (flag==true) {
            
            vc.tweetDetail = [self.dataSource[[self.tweetTableView indexPathForSelectedRow].row] valueForKeyPath:@"text"];//[[self.tableView indexPathForSelectedRow].row]; //@"My label";
            
        } else {
            
            // read from plist
            NSData *data2 = [[NSMutableData alloc] initWithContentsOfFile:@"/Users/rinarish/Desktop/Task3/Task3/Tweets.plist"];
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data2];
            NSNumber *localCount = [unarchiver decodeObjectForKey:@"count"];
            //        for(NSInteger i = 0; i < localCount.integerValue; ++i) {
            NSDictionary *tweet = [unarchiver decodeObjectForKey:[NSString stringWithFormat:@"tweet_%d", localCount]];
            [unarchiver finishDecoding];
            
            
            vc.tweetDetail = [tweet valueForKeyPath:@"text"];
        //vc.tweetDetail = [tweet2[[self.tweetTableView indexPathForSelectedRow].row] valueForKeyPath:@"text"];//[[self.tableView indexPathForSelectedRow].row]; //@"My label";
            
        }
    }
}




- (IBAction)postNewTweet:(id)sender {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@""];
        //[tweetSheet addImage:[UIImage imageNamed:@"/Applications/iPhoto.app"]];

        [self presentViewController:tweetSheet animated:YES completion:nil];
        
       
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
@end




