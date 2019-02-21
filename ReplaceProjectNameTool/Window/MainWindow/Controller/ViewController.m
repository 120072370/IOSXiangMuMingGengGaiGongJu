//
//  ViewController.m
//  ReplaceProjectNameTool
//
//  Created by shikeeapp_003 on 2018/4/2.
//  Copyright © 2018年 shikeeapp_003. All rights reserved.
//



#import "ViewController.h"
#import "CoreService.h"
#import "LogWindowController.h"

NSString  * const kEmptyPath=@"尚未读取到";
NSString  * const kErrorPath=@"尚未读取到,请确认这是一个正确的IOS项目路径";
NSString  * const kSavePath =@"kSavePath";

@interface ViewController()

typedef NS_OPTIONS(NSInteger, TextFileTag) {
    TextFileTagPath=10001,
    TextFileTagOldProjectName=10002,
    TextFileTagCurrProjectName=10003,
    TextFileTagOldPrefix=10004,
    TextFileTagCurrPrefix=10005
};
@property(nonatomic,weak) IBOutlet NSTextField *pathTextField;
@property(nonatomic,weak) IBOutlet NSTextField *oldProjectNameTextField;
@property(nonatomic,weak) IBOutlet NSTextField *currProjectNameTextField;
@property(nonatomic,weak) IBOutlet NSTextField *oldPrefixTextField;
@property(nonatomic,weak) IBOutlet NSTextField *currPrefixTextField;
@property(nonatomic,weak) IBOutlet NSButton    *replaceBtn;
@property(nonatomic,strong) LogWindowController *logWC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pathTextField.tag=TextFileTagPath;
    self.oldProjectNameTextField.tag=TextFileTagOldProjectName;
    self.currProjectNameTextField.tag=TextFileTagCurrProjectName;
    self.currProjectNameTextField.enabled=NO;
    self.oldPrefixTextField.tag=TextFileTagOldPrefix;
    self.oldPrefixTextField.enabled=NO;
    self.currPrefixTextField.tag=TextFileTagCurrPrefix;
    self.currPrefixTextField.enabled=NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controlTextDidChange:) name:NSControlTextDidChangeNotification object:nil];
}

#pragma mark- notify
- (void)controlTextDidChange:(NSNotification *)obj {
    NSTextField *textField=obj.object;
    if([textField isKindOfClass: [NSTextField class]]){
        
        NSString *value=textField.stringValue;
        switch (textField.tag) {
            case TextFileTagPath:
            {
                
            }
                break;
            case TextFileTagOldProjectName:
            {
//                if(value.length>0&&![value isEqualToString:kEmptyPath]&&![value isEqualToString:kErrorPath]){
//
//                }
            }
                break;
            case TextFileTagCurrProjectName:
            {

            }
                break;
            case TextFileTagOldPrefix:
            {
                if(value.length>1){
                    self.currPrefixTextField.enabled=YES;
                }else{
                    self.currPrefixTextField.enabled=NO;
                }
            }
                break;
            case TextFileTagCurrPrefix:
            {
                
            }
                break;
                
            default:
                break;
        }
    }
}

#pragma mark- event
-(IBAction)selectSavePathAction:(id)sender
{
    NSOpenPanel *save=[NSOpenPanel openPanel];
    save.canChooseFiles=NO;
    save.canChooseDirectories=YES;
    [save beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        NSLog(@"result:%ld\n",result);
        if(result==NSOKButton){
            NSString* projectPath=[[save URL] path];
            NSLog(@"oepn path:%@",projectPath);
            self.pathTextField.stringValue=projectPath;
            NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
            [ud setObject:projectPath forKey:kSavePath];
            [ud synchronize];
            
            CoreService *service=[CoreService sharedManager];
            NSString *oldPrjName=[service oldProjectNameWithRootPath:self.pathTextField.stringValue];
            if(oldPrjName.length<1){
                oldPrjName=kErrorPath;
                self.currProjectNameTextField.enabled=NO;
                self.oldPrefixTextField.enabled=NO;
                self.currPrefixTextField.enabled=NO;
            }else{
                self.currProjectNameTextField.enabled=YES;
                if(self.oldProjectNameTextField.stringValue.length){
                    self.oldPrefixTextField.enabled=YES;
                }
                if(self.oldPrefixTextField.stringValue.length){
                    self.currPrefixTextField.enabled=YES;
                }
            }
            self.oldProjectNameTextField.stringValue=oldPrjName;
        }
    }];
}

-(IBAction)replaceBtnAction:(id)sender
{
    CoreService *service=[CoreService sharedManager];
    NSString *pathStr=self.pathTextField.stringValue;
    NSString *newPrjName=self.currProjectNameTextField.stringValue;
    NSString *oldPrjName=self.oldProjectNameTextField.stringValue;
    NSString *newPrefix=self.currPrefixTextField.stringValue;
    NSString *oldPrefix=self.oldPrefixTextField.stringValue;
    
    if(pathStr.length<1||oldPrjName.length<1||[oldPrjName isEqualToString:kEmptyPath]||[oldPrjName isEqualToString:kErrorPath]){
        NSAlert *alert=[[NSAlert alloc]init];
        alert.messageText=@"这不是一个正确的IOS项目根目录";
        [alert addButtonWithTitle:@"好"];
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
        return;
    }
    
    //先替换项目名
    [service replaceWithFilePath:pathStr prjRootPath:pathStr oldFileName:oldPrjName newFileName:newPrjName completeCallback:^(NSString *errorMsg,NSInteger count,NSArray<NSString*>* changePath) {
        if(self.oldPrefixTextField.stringValue.length){//再替换前缀
            [service replacePrefixWithFilePath:pathStr oldPrefix:oldPrefix newPrefix:newPrefix completeCallback:^(NSString *errorMsg, NSInteger successCount, NSInteger failCount, NSArray<NSString *> *successChangePath, NSArray<NSString *> *failChangePath) {
                self.oldProjectNameTextField.stringValue=[service oldProjectNameWithRootPath:self.pathTextField.stringValue];
                if(errorMsg.length<1){
                    NSString *msg=[NSString stringWithFormat:@"%ld个文件被替换成功",successCount+count];
                    NSAlert *alert=[[NSAlert alloc]init];
                    alert.messageText=msg;
                    [alert addButtonWithTitle:@"查看被更改的文件"];
                    [alert addButtonWithTitle:@"好"];
                    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                        if(returnCode-1000==0){
                            if(!self.logWC){
                                self.logWC=[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LogWindowController"];
                            }
                            LogViewController *logVC=(LogViewController*)self.logWC.contentViewController;
                            LogModel *logModel=[LogModel new];
                            logModel.count=successCount+count;
                            if(changePath.count){
                                NSMutableArray<NSString *>*tempArray=[[NSMutableArray alloc]initWithArray:changePath];
                                [tempArray addObjectsFromArray:successChangePath];
                                logModel.pathArray=tempArray;
                            }else{
                                logModel.pathArray=successChangePath;
                            }
                            
                            logVC.logModel=logModel;
                            [self.logWC showWindow:self];
                        }
                    }];
                }else{
                    NSAlert *alert=[[NSAlert alloc]init];
                    alert.messageText=errorMsg;
                    [alert addButtonWithTitle:@"好"];
                    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                        
                    }];
                }
            }];
        }else{
            if(errorMsg.length<1){
                self.oldProjectNameTextField.stringValue=[service oldProjectNameWithRootPath:self.pathTextField.stringValue];
                NSString *msg=[NSString stringWithFormat:@"%ld个文件被替换成功",count];
                NSAlert *alert=[[NSAlert alloc]init];
                alert.messageText=msg;
                [alert addButtonWithTitle:@"查看被更改的文件"];
                [alert addButtonWithTitle:@"好"];
                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                    if(returnCode-1000==0){
                        if(!self.logWC){
                            self.logWC=[[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"LogWindowController"];
                        }
                        LogViewController *logVC=(LogViewController*)self.logWC.contentViewController;
                        LogModel *logModel=[LogModel new];
                        logModel.count=count;
                        logModel.pathArray=changePath;
                        logVC.logModel=logModel;
                        [self.logWC showWindow:self];
                    }
                }];
            }else{
                NSAlert *alert=[[NSAlert alloc]init];
                alert.messageText=errorMsg;
                [alert addButtonWithTitle:@"好"];
                [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
                    
                }];
            }
        }
    }];
}


-(void)replacePrjName
{
    
}

-(void)replacePrefix
{
    
}



- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
