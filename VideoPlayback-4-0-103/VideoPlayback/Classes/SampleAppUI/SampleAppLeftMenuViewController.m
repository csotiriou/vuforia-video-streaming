/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.
 
Confidential and Proprietary - Qualcomm Connected Experiences, Inc.
Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/


#import "SampleAppLeftMenuViewController.h"
#import "SampleAppMenu.h"
#import "SampleAppSlidingMenuController.h"

@interface SampleAppLeftMenuViewController ()
@end

@implementation SampleAppLeftMenuViewController

@synthesize tableView=_tableView;
@synthesize slidingMenuViewController=_slidingMenuViewController;

- (id)init {
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter]
            addObserver:self
            selector:@selector(updateMenu)
            name:@"kMenuChange"
            object:nil];
        
    }
    return self;
}



- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_tableView release];
    _tableView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_tableView) {
        UINavigationBar *navBar = [[UINavigationBar alloc] init];
        [navBar setFrame:CGRectMake(0,0,CGRectGetWidth(self.view.frame),44)];
        
        SampleAppMenu * menu = [SampleAppMenu instance];

        // push a navigation item in order to be able to set a title to the navigation bar
        UINavigationItem * navItem = [[UINavigationItem alloc]initWithTitle:menu.title];
        [navBar pushNavigationItem:navItem animated:NO];
        [navItem release];
        
        navBar.barStyle = UIBarStyleDefault;
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = (id<UITableViewDelegate>)self;
        tableView.dataSource = (id<UITableViewDataSource>)self;
        tableView.tableHeaderView = navBar;
        [self.view addSubview:tableView];
        [navBar release];
        self.tableView = tableView;
        [tableView release];
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    SampleAppMenu * menu = [SampleAppMenu instance];
    return [menu nbGroups];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    SampleAppMenu * menu = [SampleAppMenu instance];
    return [menu nbItemsInGroupIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    SampleAppMenu * menu = [SampleAppMenu instance];
    return [menu titleForGroupIndex:section];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    SampleAppMenu * menu = [SampleAppMenu instance];
    NSInteger indexGroup = indexPath.section;
    NSInteger indexItem = indexPath.row;
    SampleAppMenuItem * menuItem = [menu itemInGroup:indexGroup atIndex:indexItem];
    
    cell.textLabel.text = menuItem.text;
    
    if ([menuItem isRadioButton]) {
        if ([menuItem isON]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.accessoryView = nil;
    } else if ([menuItem isCheckBox]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        cell.accessoryView = switchView;
        [switchView setOn:[menuItem isON] animated:NO];
        [switchView addTarget:self action:@selector(tableCellSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [switchView release];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void) tableCellSwitchChanged:(id)sender {
    // find the parent who is a UITableViewCell
    UIView *view = sender;
    while (![view isKindOfClass:[UITableViewCell class]]) {
        view = view.superview;
    }
    UITableViewCell * cell = (UITableViewCell*) view;

    // nd locate it in the TableView
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    SampleAppMenu * menu = [SampleAppMenu instance];
    NSInteger indexGroup = indexPath.section;
    NSInteger indexItem = indexPath.row;
    SampleAppMenuItem * menuItem = [menu itemInGroup:indexGroup atIndex:indexItem];

    if ([menuItem isCheckBox]) {
        bool value = [menuItem swapSelection];
        if (! [menu notifyCommand:[menuItem command] value:value]) {
            // the command failed, we reset the value to its previous state
            [menuItem swapSelection];
        }
        // we refresh the menu
        [self updateMenu];
        [self.slidingMenuViewController showRootController:YES];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SampleAppMenu * menu = [SampleAppMenu instance];
    NSInteger indexGroup = indexPath.section;
    NSInteger indexItem = indexPath.row;
    SampleAppMenuItem * menuItem = [menu itemInGroup:indexGroup atIndex:indexItem];

    // if the 'command' value is negative, that means
    // that it's a 'back' command and we dismiss the view
    if ([menuItem command] < 0) {
        [self.slidingMenuViewController dismiss];
    } else {
        if ([menuItem isTextItem]) {
            [menu notifyCommand:[menuItem command] value:YES];
        } else if ([menuItem isCheckBox]) {
            bool value = [menuItem swapSelection];
            if (! [menu notifyCommand:[menuItem command] value:value]) {
                // the command failed, we reset the value to its previous state
                [menuItem swapSelection];
            }
        } else if ([menuItem isRadioButton]) {
            if (! [menuItem isON]) {
                // we handle the notification only if the item is not already set
                if ([menu notifyCommand:[menuItem command] value:YES]) {
                    SampleAppMenuGroup * group = [menu groupAtIndex:indexGroup];
                    [group setActiveItem:indexItem];
                }
            }
        }
    }
    
    // we refresh the menu
    [self updateMenu];
    [self.slidingMenuViewController showRootController:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) updateMenu {
    [self.tableView reloadData];
}
@end
