//
//  MainViewController.m
//  拼图
//
//  Created by chenjun on 16/6/29.
//  Copyright © 2016年 cloudssky. All rights reserved.
//

#import "MainViewController.h"
#import "Masonry.h"
#import "GameViewController.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface MainViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
/**
 *  需要拼的图
 */
@property (nonatomic ,strong) UIImageView *imageView;
/**
 *  难度等级
 */
@property (nonatomic ,assign) int level;

@end

@implementation MainViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
    self.level = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - createView
- (void)createView {
    [self.view addSubview:self.imageView];
    [self imageViewAutoLayout];
    
    //选择图片
    UIButton *chooseBtn = [[UIButton alloc] init];
    [self.view addSubview:chooseBtn];
    [chooseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(40);
        make.left.equalTo(@40);
        make.right.equalTo(@(-40));
        make.height.equalTo(@44);
    }];
    [chooseBtn setBackgroundColor:[UIColor colorWithRed:111 / 255.0 green:193 / 255.0 blue:249 / 255.0 alpha:1]];
    [chooseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [chooseBtn setTitle:@"选择图片" forState:UIControlStateNormal];
    [chooseBtn addTarget:self action:@selector(chooseImage) forControlEvents:UIControlEventTouchUpInside];
    
    //游戏难度
    UIButton *levelBtn = [[UIButton alloc] init];
    [self.view addSubview:levelBtn];
    [levelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(chooseBtn.mas_bottom).offset(10);
        make.left.equalTo(@40);
        make.right.equalTo(@(-40));
        make.height.equalTo(@44);
    }];
    [levelBtn setBackgroundColor:[UIColor colorWithRed:111 / 255.0 green:193 / 255.0 blue:249 / 255.0 alpha:1]];
    [levelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [levelBtn setTitle:@"游戏难度" forState:UIControlStateNormal];
    [levelBtn addTarget:self action:@selector(levelSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //开始游戏
    UIButton *startBtn = [[UIButton alloc] init];
    [self.view addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(levelBtn.mas_bottom).offset(10);
        make.left.equalTo(@40);
        make.right.equalTo(@(-40));
        make.height.equalTo(@44);
    }];
    [startBtn setBackgroundColor:[UIColor colorWithRed:111 / 255.0 green:193 / 255.0 blue:249 / 255.0 alpha:1]];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn setTitle:@"开始游戏" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *squreImage = [self cutImage:image];
    self.imageView.image = squreImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - private method
- (void)chooseImage {
    NSLog(@"选择图片");
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片不可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)levelSelect {
    NSLog(@"游戏难度");
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"选择游戏难度" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"简单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.level = 5;
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"正常" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.level = 7;
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"困难" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.level = 9;
    }];
    [alertCon addAction:action1];
    [alertCon addAction:action2];
    [alertCon addAction:action3];
    [self presentViewController:alertCon animated:YES completion:nil];
}

- (void)start {
    NSLog(@"开始游戏");
    GameViewController *gameVC = [[GameViewController alloc] init];
    gameVC.level = self.level;
    gameVC.image = self.imageView.image;
    [self presentViewController:gameVC animated:YES completion:nil];
}

//裁剪图片
- (UIImage *)cutImage:(UIImage*)image
{
    //压缩图片
    CGSize newSize;
    CGRect newRect;
    CGImageRef imageRef = nil;
    NSLog(@"height=%f -- width=%f", image.size.height, image.size.width);
    if ((image.size.width / image.size.height) < 1) {
        newSize.width = image.size.width;
        newSize.height = image.size.width;
        newRect = CGRectMake(0, fabs(image.size.height - newSize.height) * 0.5, newSize.width, newSize.height);
        imageRef = CGImageCreateWithImageInRect([image CGImage], newRect);
        
    } else {
        newSize.height = image.size.height;
        newSize.width = image.size.height;
        newRect = CGRectMake(fabs(image.size.width - newSize.width) * 0.5, 0, newSize.width, newSize.height);
        imageRef = CGImageCreateWithImageInRect([image CGImage], newRect);
        
    }
    UIGraphicsBeginImageContext(newSize);
    CGContextRef currentRef = UIGraphicsGetCurrentContext();
    CGContextDrawImage(currentRef, newRect, imageRef);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    return newImage;
}

////图片切割
//- (UIImage *)scaleImage:(UIImage *)image {
//    
//    CGRect myImageRect;
//    if (image.size.height > image.size.width) {
//        myImageRect = CGRectMake(0, (image.size.height - image.size.width) * 0.5, image.size.width, image.size.width);
//    } else {
//        myImageRect = CGRectMake((image.size.width - image.size.height) * 0.5, 0, image.size.height, image.size.height);
//    }
//    
//    CGImageRef imageRef = image.CGImage;
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
//    CGSize size;
//    size = myImageRect.size;
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, myImageRect, subImageRef);
//    UIImage* clipImage = [UIImage imageWithCGImage:subImageRef];
//    CGImageRelease(subImageRef);
//    UIGraphicsEndImageContext();
//    return clipImage;
//    
//}

#pragma mark - autoLayout
- (void)imageViewAutoLayout {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@40);
        make.right.equalTo(@(-40));
        make.top.equalTo(@70);
        make.height.equalTo(@(SCREEN_WIDTH - 80));
    }];
}

#pragma mark - getter and setter
- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor redColor];
        UIImage *spureImage = [self cutImage:[UIImage imageNamed:@"la"]];
        _imageView.image = spureImage;
    }
    return _imageView;
}

@end
