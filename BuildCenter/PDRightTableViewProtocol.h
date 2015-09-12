//
//  PDRightTableViewProtocol.h
//  BuildCenter
//
//  Created by Peng Tao on 15/9/11.
//  Copyright (c) 2015年 Peng Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface PDRightTableViewProtocol : NSObject
<UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, strong) NSArray *historyBuilds;

@end
