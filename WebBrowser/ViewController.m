//
//  ViewController.m
//  WebBrowser
//
//  Created by Takeshi Bingo on 2013/08/02.
//  Copyright (c) 2013年 Takeshi Bingo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    IBOutlet UIWebView *webView;
    IBOutlet UITextField *urlField;
    
    NSString *pageTitle;
    NSString *url;
    
    NSString *databaseName;
    NSString *databasePath;
    bool loadSuccessful;
}

-(void)createAndCheckDatabase {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    success = [fileManager fileExistsAtPath:databasePath];
    
    if (success)   return;
    
    NSString *databasePathFromApp = [[[NSBundle mainBundle]resourcePath] stringByAppendingPathComponent:databaseName];
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}
-(void)makeRequest {
    NSURLRequest *urlReq = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSLog(@"%@",[NSURL URLWithString:url]);
    [webView loadRequest:urlReq];
    loadSuccessful = false;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void)webViewDidFinishLoad:(UIWebView *)view   {
    url = [[webView.request URL] absoluteString];
    pageTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    urlField.text = url;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    loadSuccessful = true;    
    
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible   = NO;
    if (([[error domain]isEqual:NSURLErrorDomain])&&([error code] != NSURLErrorCancelled)) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = @"エラー";
        alert.message = [NSString stringWithFormat:@"「%@」をロードするのに失敗しました。",url];
        [alert addButtonWithTitle:@"OK"];
        [alert show];
    }
}
-(BOOL)textFieldShouldReturn:(UITextField *)sender {
    NSString *keyboardInput = sender.text;
    
    if (![keyboardInput hasPrefix:@"http://"]) {
        NSString *prefix = @"http://";
        url = [prefix stringByAppendingString:keyboardInput];
        sender.text = url;
    } else {
        url = keyboardInput;
    }
    //キーボードを閉じる
    [sender resignFirstResponder];
    //指定されたページをロード
    [self makeRequest];
    return TRUE;
}

//お気に入り追加ボタンが押され時の処理
-(IBAction)saveFavorite:(id)sender {
    //新しいページをロード中はお気に入り登録を禁止
    if (loadSuccessful == false) {
        //エラーメッセージを表示
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.title = @"エラー";
        alert.message = @"正常にロードされていません";
        [alert addButtonWithTitle:@"OK"];
        [alert show];
        
        return;
    }
    //Databaseを開く
    FMDatabase* db = [FMDatabase databaseWithPath:databasePath];
    [db open];
    //クエリ文を指定
    NSString *query = [NSString stringWithFormat:@"INSERT INTO my_favorites (title, url) VALUES ('%@','%@');", pageTitle, url];
    //クエリ開始
    [db beginTransaction];
    //クエリ実行
    [db executeUpdate:query];
    //Databaseへの変更確定
    [db commit];
    //Databaseを閉じる
    [db close];
    //メッセージを表示
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"お気に入り登録完了";
    alert.message = [NSString stringWithFormat:@"「%@」を登録しました", pageTitle];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}
-(IBAction)goToFavorites:(id)sender {
    //お気に入り画面へのSegueを始動
    [self performSegueWithIdentifier:@"toFavoritesView" sender:self];
}

//お気に入り画面へのSegueの発動
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //FavoritesViewController（FVC）のインスタンスを作成し、
    //delegate通知をこのクラスで受けれるようにする
    if ([[segue identifier] isEqualToString:@"toFavoritesView"]) {
        FavoritesViewController *fvc = (FavoritesViewController*)[segue destinationViewController];
        fvc.delegate = (id)self;
    }
}
//Favoritesのリストで「戻る」が押された
- (void)favoritesViewControllerDidCancel:(FavoritesViewController *)controller {
    //Favorites View Controllerを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}
//Favoritesのリストで何かが選択された時に呼ばれる
- (void)favoritesViewControllerDidSelect:(FavoritesViewController *)controller withUrl:(NSString *)favoriteUrl {
    //セレクトされたURLをロード
    url = favoriteUrl;
    [self makeRequest];
    //Favorites View Controllerを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //webViewとtextFieldからのdelegate通知をこのクラスで受け取る
    webView.delegate = self;
    urlField.delegate = self;
    
    //データベースのファイルパスを取得
    databaseName = @"favorites.sqlite";
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    databasePath = [documentDir stringByAppendingPathComponent:databaseName];
    
    //サンドボックス内の「Documents」にDBがあるかを確認、無ければコピー
    [self createAndCheckDatabase];
    //初期URLを設定
    url = @"http://www.google.co.jp";
    //初期URLのページを要求・表示
    [self makeRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
