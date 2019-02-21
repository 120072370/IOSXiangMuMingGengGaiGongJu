//
//  LogViewController.m
//  ReplaceProjectNameTool
//
//  Created by shikeeapp_003 on 2018/4/3.
//  Copyright © 2018年 shikeeapp_003. All rights reserved.
//

#import "LogViewController.h"

@interface LogViewController ()
@property(nonatomic,weak) IBOutlet NSTextView *textView;

@end

@implementation LogViewController

-(void)dealloc
{
    NSLog(@"logVC release");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.textView.editable=NO;
}

- (void)viewWillLayout NS_AVAILABLE_MAC(10_10)
{
    [super viewWillLayout];
    __block NSString *msg=[NSString stringWithFormat:@"成功更改%ld个文件:\n",self.logModel.count];
    [self.logModel.pathArray enumerateObjectsUsingBlock:^(NSString * _Nonnull path, NSUInteger idx, BOOL * _Nonnull stop) {
        msg=[NSString stringWithFormat:@"%@\n%@",msg,path];
    }];
    msg=[NSString stringWithFormat:@"%@\n\n\n\n",msg];
    self.textView.string=msg;
}

-(void)setLogModel:(LogModel *)logModel
{
    _logModel=logModel;
    [self.view setNeedsLayout:YES];
    [self.view layoutSubtreeIfNeeded];
}

-(IBAction)closeBtnAction:(id)sender
{
    [self.view.window orderOut:self];
}

@end
