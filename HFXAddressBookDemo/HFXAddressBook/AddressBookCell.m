//
//  AddressBookCell.m
//  Text
//
//  Created by fa_mac_one on 2017/8/29.
//  Copyright © 2017年 黄福鑫. All rights reserved.
//

#import "AddressBookCell.h"
@interface AddressBookCell ()


@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;


@end

@implementation AddressBookCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    
}


- (void)setModel:(AddressBookModel *)model {
    
    _model = model;
    
    self.nameLabel.text = model.name;
    self.phoneNumberLabel.text = model.phoneNumber;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
