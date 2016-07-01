//
//  RecordView.m
//  拼图
//
//  Created by chenjun on 16/7/1.
//  Copyright © 2016年 cloudssky. All rights reserved.
//

#import "RecordView.h"
#import "Masonry.h"

@interface RecordView ()
{
    UILabel *nameLabel;
    UILabel *timeAndStepLabel;
}

@end

@implementation RecordView

- (instancetype)init {
    if (self = [super init]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    nameLabel = [[UILabel alloc] init];
    [self addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@20);
        make.width.equalTo(@300);
        make.height.equalTo(@20);
    }];
    timeAndStepLabel = [[UILabel alloc] init];
    [self addSubview:timeAndStepLabel];
    [timeAndStepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nameLabel.mas_bottom);
        make.left.equalTo(@20);
        make.width.equalTo(@300);
        make.height.equalTo(@20);
    }];
}

- (void)setInfoDict:(NSDictionary *)infoDict {
    _infoDict = infoDict;
    nameLabel.text = infoDict[@"name"];
    timeAndStepLabel.text = [NSString stringWithFormat:@"难度%@ 用时%@s 移动%@步", infoDict[@"level"], infoDict[@"time"], infoDict[@"step"]];
}

@end
