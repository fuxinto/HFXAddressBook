//
//  AddressBookVC.m
//  Text
//
//  Created by fa_mac_one on 2017/8/30.
//  Copyright © 2017年 黄福鑫. All rights reserved.
//

#import "AddressBookVC.h"
#import <Contacts/Contacts.h>
#import "AddressBookModel.h"
#import "AddressBookCell.h"





static NSString *reuseIdentifier = @"AddressBookCell";
@interface AddressBookVC ()<UITableViewDelegate,UITableViewDataSource,UISearchControllerDelegate,UISearchResultsUpdating>{
    
    BOOL _active;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, strong) UISearchController *searchControl;
@property (nonatomic, strong) NSMutableArray *searchArray;
@property (nonatomic, strong) NSMutableArray *indexesArray;



@end

@implementation AddressBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 64.0 ,self.view.frame.size.width , self.searchControl.searchBar.frame.size.height)];
    
    searchBarView.backgroundColor = [UIColor whiteColor];

    [searchBarView addSubview: self.searchControl.searchBar];

    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    [self.view addSubview:searchBarView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //搜索时导航栏不消失
    self.searchControl.hidesNavigationBarDuringPresentation
    = NO;
     self.definesPresentationContext = YES;
    
    [self getAddressBoosInfo];
    
    [self createIndexesArray];
  
    [self createSectionArray];


    // 刷新等操作。
    self.tableView.sectionIndexBackgroundColor=[UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    //索引添加搜索按钮
    [self.indexesArray insertObject:@"{search}" atIndex:0];
    
    [self.tableView reloadData];
    
}

//根据索引创建section数组 {
- (void)createSectionArray {
    
    NSMutableArray *arrays = [NSMutableArray array];
    for (NSString *str in self.indexesArray) {
        
        NSMutableArray *sectionsArray = [NSMutableArray array];
        for (AddressBookModel *model in self.models) {
            
            if ([model.initial isEqualToString:str]) {
                
                [sectionsArray addObject:model];
            }
        }
        [arrays addObject:sectionsArray];
    }
    
    self.models = [NSMutableArray arrayWithArray:arrays];
}


//建立索引数组，
- (void)createIndexesArray {
    
    //索引数组添加数据
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (AddressBookModel *model in self.models) {
        
        NSString *c =  [self transform:model.name];
        
        if (c.length) {
            model.initial = c;
            [mutableArray addObject:c];
        }
    }
    
    
    //首字母去重
    for (int i = 0; i < [mutableArray count]; i++){
        //是否包含
        if ([self.indexesArray containsObject:[mutableArray objectAtIndex:i]] == NO){
            [self.indexesArray addObject:[mutableArray objectAtIndex:i]];
        }
        
    }
}




#pragma mark - 获取联系人信息
- (void)getAddressBoosInfo {
    
    // 2. 获取联系人仓库
    CNContactStore * store = [[CNContactStore alloc] init];
    
    // 3. 创建联系人信息的请求对象
    NSArray * keys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
    
    // 4. 根据请求Key, 创建请求对象
    CNContactFetchRequest * request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    
    // 5. 发送请求
    [store enumerateContactsWithFetchRequest:request error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        
        AddressBookModel *model = [[AddressBookModel alloc]init];
        // 6.1 获取名
        NSString * givenName = contact.givenName;
        //姓
        NSString * familyName = contact.familyName;
        NSLog(@"%@%@", familyName, givenName);
        
        NSString *name = [NSString stringWithFormat:@"%@%@",familyName,givenName];
        
        model.name = name;
        
        // 6.2 获取电话
        NSArray * phoneArray = contact.phoneNumbers;
        for (CNLabeledValue * labelValue in phoneArray) {
            
            CNPhoneNumber * number = labelValue.value;
            
            NSString *photo = [number.stringValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            model.phoneNumber = photo;
            NSLog(@"%@", number.stringValue);
        }
        [self.models addObject:model];
        
    }];
    

}

/**
 汉字转拼音
 
 @param chinese 传入文字
 @return 返回大写首字母
 */
- (NSString *)transform:(NSString *)chinese {
    if (!chinese.length) {
        
        return nil;
    }
    
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    NSString *oneStr = [pinyin substringToIndex:1];
    
    return [oneStr uppercaseString];;
}



#pragma mark 搜索的协议方法
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    //在点击搜索时会调用一次，点击取消按钮又调用一次
    if (searchController.searchBar.text.length) {
        //判断当前搜索是否在搜索状态还是取消状态
        if (self.searchControl.isActive) {
            //表示搜索状态
            
            //初始化搜索数组
            
            [self.searchArray removeAllObjects];
            //遍历数据源，给搜索数组添加对象
            for (NSArray *array in self.models) {
                
                for (AddressBookModel *model in array) {
                    NSRange range = [model.name rangeOfString:searchController.searchBar.text];
                    
                    if (range.location != NSNotFound) {
                        [self.searchArray addObject:model];
                    }
                }
                
            }
            _active = YES;
        }else {
            
            _active = NO;
        }
    }else {
        
        _active = NO;
    }
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _active ? 1 : self.models.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _active ? self.searchArray.count :[self.models[section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    if (_active) {
        cell.model = self.searchArray[indexPath.row];
    }else {
        cell.model = self.models[indexPath.section][indexPath.row];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    AddressBookModel *model;
    if (self.searchControl.searchBar.text.length) {
       model = self.searchArray[indexPath.row];
    }else {
        model = self.models[indexPath.section][indexPath.row];
    }

    if ([self.delegate respondsToSelector:@selector(currentSelectWithName:phoneNumber:)]) {
        [self.delegate currentSelectWithName:model.name phoneNumber:model.phoneNumber];
    }
     [self dismissViewControllerAnimated:YES completion:nil];
}

//返回索引数组
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    return self.indexesArray;
}

//点击索引栏标题时执行
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    //这里是为了指定索引index对应的是哪个section的，默认的话直接返回index就好。其他需要定制的就针对性处理
    if ([title isEqualToString:UITableViewIndexSearch])
    {
        [tableView setContentOffset:CGPointZero animated:NO];//tabview移至顶部
        return NSNotFound;
    }else {
        return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index] - 1; // -1 添加了搜索标识
    }
}

//
////分组title。背景色不可改，自定义headerView
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//   return _active ? @"搜索结果" : self.indexesArray[section+1];
//
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return _active ? 20 : 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, self.view.frame.size.width, 20)];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = _active ? @"搜索结果" : self.indexesArray[section+1];
    
    [view addSubview:label];
    
    return view;
}


#pragma mark - 懒加载
- (UISearchController *)searchControl {
    
    if (!_searchControl) {
        _searchControl =[[UISearchController alloc]initWithSearchResultsController:nil];
        [_searchControl.searchBar setValue:@"取消"forKey:@"_cancelButtonText"]; // 设置搜索框那个取消按钮文字
        
        //       _searchControl.searchBar.frame = CGRectMake(0, 22, self.view.frame.size.width, 44)；
        _searchControl.delegate = self;
        _searchControl.searchResultsUpdater = self;
        _searchControl.searchBar.placeholder = @"搜索";
        _searchControl.dimsBackgroundDuringPresentation = NO;
        [_searchControl.searchBar sizeToFit];
//        [_searchControl.searchBar setShowsCancelButton:NO];
//        _searchControl.searchBar.barStyle=UIBarStyleDefault;
        //隐藏线
        _searchControl.searchBar.searchBarStyle =UISearchBarStyleMinimal;
        //颜色设置
//        _searchControl.searchBar.barTintColor = [UIColor colorWithR:250 G:250 B:250 alpha:1];
        //       [_searchControl.searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor colorWithR:250 G:250 B:250 alpha:1]] forState:UIControlStateNormal];
        //开启允许另一个tvc做呈现的控制器
        //    self.definesPresentationContext = YES;
    }
    return _searchControl;
}

- (UITableView *)tableView {
    
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        _tableView.sectionIndexColor = [UIColor grayColor];
        _tableView.tableHeaderView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([AddressBookCell class]) bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    }
    return _tableView;
}



- (NSMutableArray *)models {
    if (!_models) {
        _models = [NSMutableArray array];
    }
    return _models;
}

- (NSMutableArray *)searchArray {
    if (!_searchArray) {
        _searchArray = [NSMutableArray array];
    }
    return _searchArray;
}


- (NSMutableArray *)indexesArray {
    if (!_indexesArray) {
        _indexesArray = [NSMutableArray array];
    }
    return _indexesArray;
}

@end
