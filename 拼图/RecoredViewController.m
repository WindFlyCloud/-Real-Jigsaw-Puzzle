//
//  RecoredViewController.m
//  拼图
//
//  Created by chenjun on 16/7/1.
//  Copyright © 2016年 cloudssky. All rights reserved.
//

#import "RecoredViewController.h"
#import "RecordView.h"
#import "Masonry.h"

@interface RecoredViewController ()

@property (nonatomic ,strong) NSArray *array;

@end

@implementation RecoredViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *muArray;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *myFile = [docPath stringByAppendingPathComponent:@"systemInfoFile.list"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:myFile];
    if (dict == nil) {
        muArray = [NSMutableArray array];
    } else {
        if ([dict objectForKey:@"MAIN_KEY"] == nil) {
            muArray = [NSMutableArray array];
        } else {
            muArray = [dict objectForKey:@"MAIN_KEY"];
        }
    }
    self.array = [NSArray arrayWithArray:muArray];
    
    [self createView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - createView
- (void)createView {
    UIButton *backBtn = [[UIButton alloc] init];
    [self.view addSubview:backBtn];
    [backBtn setBackgroundColor:[UIColor greenColor]];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.array.count == 0) {
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@60);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@40);
        }];
    }
    
    for (int i = 0; i < self.array.count; i++) {
        RecordView *recordView = [[RecordView alloc] init];
        [self.view addSubview:recordView];
        recordView.infoDict = self.array[i];
        [recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(60 + 40 * i));
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@40);
        }];
        [backBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(recordView.mas_bottom);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@40);
        }];
    }
}

#pragma mark - private method
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
