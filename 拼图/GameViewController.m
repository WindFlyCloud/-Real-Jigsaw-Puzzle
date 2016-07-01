//
//  GameViewController.m
//  拼图
//
//  Created by chenjun on 16/6/29.
//  Copyright © 2016年 cloudssky. All rights reserved.
//

#import "GameViewController.h"
#import "Masonry.h"
#import "RecoredViewController.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface GameViewController () <UIAlertViewDelegate>
/**
 *  图片数组
 */
@property (nonatomic ,strong) NSMutableArray *picArray;
/**
 *  图片tag数组
 */
@property (nonatomic ,strong) NSMutableArray *tagArray;
/**
 *  空的图片
 */
@property (nonatomic ,assign) int enptyNumber;
@property (nonatomic ,assign) int oldNumber;
@property (nonatomic ,strong) UIView *pictureView;
@property (nonatomic ,assign) BOOL isApper;
@property (nonatomic ,assign) int time;
@property (nonatomic ,assign) int step;

@property (nonatomic ,strong) UILabel *timeLabel;
@property (nonatomic ,strong) UILabel *stepLabel;

@property (nonatomic ,strong) NSTimer *timer;

@end

@implementation GameViewController
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tagArray = [NSMutableArray array];
    self.view.backgroundColor = [UIColor whiteColor];
    [self cutImage:self.image];
    [self createView];
    [self restart];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeAdd) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.timer setFireDate:[NSDate distantPast]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"picArray"];
}

#pragma mark - createView
- (void)createView {
    //上方三个按钮
    UIButton *settingBtn = [[UIButton alloc] init];
    [self.view addSubview:settingBtn];
    [settingBtn setBackgroundColor:[UIColor colorWithRed:111 / 255.0 green:193 / 255.0 blue:249 / 255.0 alpha:1]];
    UIButton *restartBtn = [[UIButton alloc] init];
    [self.view addSubview:restartBtn];
    [restartBtn setBackgroundColor:[UIColor colorWithRed:111 / 255.0 green:193 / 255.0 blue:249 / 255.0 alpha:1]];
    UIButton *recordBtn = [[UIButton alloc] init];
    [self.view addSubview:recordBtn];
    [recordBtn setBackgroundColor:[UIColor colorWithRed:111 / 255.0 green:193 / 255.0 blue:249 / 255.0 alpha:1]];
    [settingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.left.equalTo(@10);
        make.right.equalTo(restartBtn.mas_left).offset(-20);
        make.height.equalTo(@40);
        make.width.equalTo(restartBtn);
    }];
    [restartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.height.equalTo(@40);
        make.left.equalTo(settingBtn.mas_right).offset(20);
        make.right.equalTo(recordBtn.mas_left).offset(-20);
        make.width.equalTo(recordBtn);
    }];
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@30);
        make.height.equalTo(@40);
        make.left.equalTo(restartBtn.mas_right).offset(20);
        make.right.equalTo(@(-10));
    }];
    [settingBtn setTitle:@"设置" forState:UIControlStateNormal];
    [restartBtn setTitle:@"重新开始" forState:UIControlStateNormal];
    [recordBtn setTitle:@"记录" forState:UIControlStateNormal];
    [settingBtn addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    [restartBtn addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    [recordBtn addTarget:self action:@selector(record) forControlEvents:UIControlEventTouchUpInside];
    
    //中间拼图
    UIView *pictureView = [[UIView alloc] init];
    [self.view addSubview:pictureView];
    [pictureView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(restartBtn.mas_bottom).offset(10);
        make.left.equalTo(@5);
        make.right.equalTo(@(-5));
        make.height.equalTo(@(SCREEN_WIDTH - 10));
    }];
    pictureView.backgroundColor = [UIColor grayColor];
    float width = ((SCREEN_WIDTH - 10 - self.level) / self.level);
    for (int i = 0; i < self.level * self.level; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [pictureView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(i / self.level * (width + 1)));
            make.left.equalTo(@(i % self.level * (width + 1)));
            make.width.equalTo(@(width));
            make.height.equalTo(@(width));
        }];
        if ([self.picArray[i] isKindOfClass:[UIImage class]]) {
            imageView.image = self.picArray[i];
        }
        imageView.tag = i;
    }
    //增加手势
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *upSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    UISwipeGestureRecognizer *downSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    upSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    downSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
    [self.view addGestureRecognizer:upSwipeGestureRecognizer];
    [self.view addGestureRecognizer:downSwipeGestureRecognizer];
    [self addObserver:self forKeyPath:@"picArray" options:NSKeyValueObservingOptionInitial context:nil];
    self.pictureView = pictureView;
    
    //下方小图
    UIImageView *smallImage = [[UIImageView alloc] init];
    [self.view addSubview:smallImage];
    [smallImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.width.equalTo(@100);
        make.height.equalTo(@100);
        make.top.equalTo(pictureView.mas_bottom).offset(30);
    }];
    smallImage.image = self.image;
    
    self.timeLabel = [[UILabel alloc] init];
    [self.view addSubview:self.timeLabel];
    self.stepLabel = [[UILabel alloc] init];
    [self.view addSubview:self.stepLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(smallImage.mas_top).offset(20);
        make.left.equalTo(smallImage.mas_right).offset(30);
        make.height.equalTo(self.stepLabel);
        make.width.equalTo(@100);
        make.bottom.equalTo(self.stepLabel.mas_top).offset(-20);
    }];
    [self.stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(smallImage.mas_bottom).offset(-20);
        make.left.equalTo(smallImage.mas_right).offset(30);
        make.height.equalTo(self.timeLabel);
        make.width.equalTo(@100);
        make.top.equalTo(self.timeLabel.mas_bottom).offset(20);
    }];
}

#pragma mark - private method
- (void)restart {
    NSLog(@"重新开始");
    self.isApper = NO;
    for (int i = 0; i < 200; i++) {
        /*
         0 -> up
         1 -> right
         2 -> down
         3 -> left
         */
        int direction = arc4random() % 4;
        if (direction == 0) {
            UISwipeGestureRecognizer *sender = [[UISwipeGestureRecognizer alloc] init];
            sender.direction = UISwipeGestureRecognizerDirectionUp;
            [self handleSwipes:sender];
        }
        if (direction == 1) {
            UISwipeGestureRecognizer *sender = [[UISwipeGestureRecognizer alloc] init];
            sender.direction = UISwipeGestureRecognizerDirectionRight;
            [self handleSwipes:sender];
        }
        if (direction == 2) {
            UISwipeGestureRecognizer *sender = [[UISwipeGestureRecognizer alloc] init];
            sender.direction = UISwipeGestureRecognizerDirectionDown;
            [self handleSwipes:sender];
        }
        if (direction == 3) {
            UISwipeGestureRecognizer *sender = [[UISwipeGestureRecognizer alloc] init];
            sender.direction = UISwipeGestureRecognizerDirectionLeft;
            [self handleSwipes:sender];
        }
    }
    
    for (int i = 0; i < self.level; i++) {
        UISwipeGestureRecognizer *sender = [[UISwipeGestureRecognizer alloc] init];
        sender.direction = UISwipeGestureRecognizerDirectionLeft;
        [self handleSwipes:sender];
    }
    for (int i = 0; i < self.level; i++) {
        UISwipeGestureRecognizer *sender = [[UISwipeGestureRecognizer alloc] init];
        sender.direction = UISwipeGestureRecognizerDirectionUp;
        [self handleSwipes:sender];
    }
    self.isApper = YES;
    self.time = 0;
    self.step = 0;
    self.timeLabel.text = [NSString stringWithFormat:@"时间： %ds", self.time];
    self.stepLabel.text = [NSString stringWithFormat:@"步数： %d", self.step];
}

- (void)setting {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)record {
    NSLog(@"记录");
    [self.timer setFireDate:[NSDate distantFuture]];
    RecoredViewController *recoreVC = [[RecoredViewController alloc] init];
    [self presentViewController:recoreVC animated:YES completion:nil];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"左滑");
        if ((self.enptyNumber + 1) % self.level != 0) {
            [self.picArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber + 1];
            [self.tagArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber + 1];
            self.enptyNumber = self.enptyNumber + 1;
            NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.picArray];
            self.picArray = muArr;
            self.step++;
            self.stepLabel.text = [NSString stringWithFormat:@"步数： %d", self.step];
        }
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"右滑");
        if (self.enptyNumber % self.level != 0) {
            [self.picArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber - 1];
            [self.tagArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber - 1];
            self.enptyNumber = self.enptyNumber - 1;
            NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.picArray];
            self.picArray = muArr;
            self.step++;
            self.stepLabel.text = [NSString stringWithFormat:@"步数： %d", self.step];
        }
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"上滑");
        if (self.enptyNumber / self.level != self.level - 1) {
            [self.picArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber + self.level];
            [self.tagArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber + self.level];
            self.enptyNumber = self.enptyNumber + self.level;
            NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.picArray];
            self.picArray = muArr;
            self.step++;
            self.stepLabel.text = [NSString stringWithFormat:@"步数： %d", self.step];
        }
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"下滑");
        if (self.enptyNumber / self.level != 0) {
            [self.picArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber - self.level];
            [self.tagArray exchangeObjectAtIndex:self.enptyNumber withObjectAtIndex:self.enptyNumber - self.level];
            self.enptyNumber = self.enptyNumber - self.level;
            NSMutableArray *muArr = [NSMutableArray arrayWithArray:self.picArray];
            self.picArray = muArr;
            self.step++;
            self.stepLabel.text = [NSString stringWithFormat:@"步数： %d", self.step];
        }
    }
}

//裁剪图片
- (void)cutImage:(UIImage*)image
{
    //压缩图片
    CGSize newSize = CGSizeMake(image.size.width / self.level, image.size.height / self.level);
    CGImageRef imageRef = nil;
    NSMutableArray *mutabArray = [NSMutableArray array];
    
    for (int i = 0; i < self.level * self.level; i++) {
        imageRef = CGImageCreateWithImageInRect([image CGImage], CGRectMake(newSize.width * (i % self.level), newSize.height * (i / self.level), newSize.width, newSize.height));
        [mutabArray addObject:[UIImage imageWithCGImage:imageRef]];
        [self.tagArray addObject:[NSNumber numberWithInt:i]];
        CGImageRelease(imageRef);
    }
    self.enptyNumber = self.level * self.level - 1;
    self.oldNumber = self.level * self.level - 1;
    [mutabArray removeLastObject];
    [mutabArray addObject:@""];
    self.picArray = mutabArray;
}

- (void)timeAdd {
    self.time++;
    self.timeLabel.text = [NSString stringWithFormat:@"时间： %ds", self.time];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UITextField *nameField = [alertView textFieldAtIndex:0];
    NSDictionary *dict = @{@"name":nameField.text, @"time":[NSNumber numberWithInt:self.time], @"step":[NSNumber numberWithInt:self.step], @"level":[NSNumber numberWithInt:self.level]};
    NSMutableArray *muArray = [NSMutableArray array];
    [muArray addObject:dict];
    
    NSArray *Rpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *RdocPath = [Rpaths objectAtIndex:0];
    NSString *RmyFile = [RdocPath stringByAppendingPathComponent:@"systemInfoFile.list"];
    NSMutableDictionary *Rdict = [[NSMutableDictionary alloc] initWithContentsOfFile:RmyFile];
    if (Rdict == nil) {
        Rdict = [NSMutableDictionary dictionary];
        [Rdict setObject:muArray forKey:@"MAIN_KEY"];
    } else {
        [Rdict setObject:muArray forKey:@"MAIN_KEY"];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [paths objectAtIndex:0];
    NSString *myFile = [docPath stringByAppendingPathComponent:@"systemInfoFile.list"];
    [Rdict writeToFile:myFile atomically:YES];
    
    if (buttonIndex == 0) {
        
        RecoredViewController *recoreVC = [[RecoredViewController alloc] init];
        [self presentViewController:recoreVC animated:YES completion:nil];
        
        [self.timer setFireDate:[NSDate distantFuture]];
        self.time = 0;
    } else {
        [self restart];
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"picArray"]) {
        NSLog(@"改变");
        NSArray *subviewArray = self.pictureView.subviews;
        for (UIImageView *imageView in subviewArray) {
            if (imageView.tag == self.enptyNumber) {
                imageView.image = nil;
            }
            if (imageView.tag == self.oldNumber) {
                imageView.image = self.picArray[self.oldNumber];
            }
        }
        self.oldNumber = self.enptyNumber;
        BOOL success = YES;
        for (int i = 1; i < self.tagArray.count; i++) {
            if ([self.tagArray[i - 1] intValue] > [self.tagArray[i] intValue]) {
                success = NO;
            }
        }
        if (success && self.isApper == YES) {
            NSLog(@"成功");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"恭喜通关" message:@"牛人，请留下你的大名" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"继续", nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [alert show];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
