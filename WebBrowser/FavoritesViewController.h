//
//  FavoritesViewController.h
//  WebBrowser
//
//  Created by Takeshi Bingo on 2013/08/02.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "Favorites.h"
@protocol FavoritesViewControllerDelegate;

@interface FavoritesViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
@property id <FavoritesViewControllerDelegate> delegate;
@end

//独自のプロトコルを作成
@protocol FavoritesViewControllerDelegate <NSObject>

-(void)favoritesViewControllerDidCancel: (FavoritesViewController *)controller;
-(void)favoritesViewControllerDidSelect: (FavoritesViewController *)controller withUrl:(NSString *)favoritesUrl;

@end
