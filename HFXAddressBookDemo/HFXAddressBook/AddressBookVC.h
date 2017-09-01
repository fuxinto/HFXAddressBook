//
//  AddressBookVC.h
//  Text
//
//  Created by fa_mac_one on 2017/8/30.
//  Copyright © 2017年 黄福鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HFXAddressBookDelegate <NSObject>

- (void)currentSelectWithName:(NSString *)name phoneNumber:(NSString *)phoneNumber;

@end
@interface AddressBookVC : UIViewController
@property (nonatomic, weak) id<HFXAddressBookDelegate> delegate;
@end
