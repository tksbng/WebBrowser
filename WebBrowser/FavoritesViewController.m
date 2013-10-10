//
//  FavoritesViewController.m
//  WebBrowser
//
//  Created by Takeshi Bingo on 2013/08/02.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "FavoritesViewController.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController {
    //お気に入り一式を格納する配列
    NSMutableArray *favoriteList;
    NSString *databaseName;
    NSString *databasePath;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //favoritesを初期化
    favoriteList = [[NSMutableArray alloc] init];
    
    //データベースのファイルパスを取得
    databaseName = @"favorites.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    databasePath = [documentDir stringByAppendingPathComponent:databaseName];
    
    //データベースを参照して内容をfavoritesに入れる
    [self queryDB];
}

-(void)queryDB{
    //Open database
    FMDatabase *db = [FMDatabase databaseWithPath:databasePath];
    [db open];
    //クエリー文を指定
    NSString *query = [NSString stringWithFormat:@"SELECT distinct title,url FROM my_favorites where title <> ''"];
    //クエリー開始
    [db beginTransaction];
    
    FMResultSet *results = [db executeQuery:query];
    while ([results next]) {
        Favorites *f = [[Favorites alloc] init];
        f.title = [results stringForColumn:@"title"];
        f.url = [results stringForColumn:@"url"];
        [favoriteList addObject:f];
        
    }
    [db close];

}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [favoriteList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cells";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Favorites *f = [favoriteList objectAtIndex:[indexPath row]];
    cell.textLabel.text = f.title;
    return cell;
        
        
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Favorites *f = [favoriteList objectAtIndex:[indexPath row]];
    NSString *selectedURL = f.url;
    
    [self.delegate favoritesViewControllerDidSelect:self withUrl:selectedURL];
}
-(IBAction)back:(id)sender{
    [self.delegate favoritesViewControllerDidCancel:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
