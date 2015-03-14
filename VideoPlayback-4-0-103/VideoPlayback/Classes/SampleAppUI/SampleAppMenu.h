/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/


#import <Foundation/Foundation.h>

@class SampleAppMenu;

@protocol SampleAppMenuCommandProtocol <NSObject>
// this method is called when a menu item is selected.
// the application can return NO to notify the command failed.
- (bool) menuProcess:(SampleAppMenu *) menu command:(int) command value:(bool) value;
@end

@interface SampleAppMenuItem : NSObject
@property (nonatomic, retain) NSString * text;
@property (nonatomic) int command;

- (bool) isON;
- (bool) isRadioButton;
- (bool) isCheckBox;
- (bool) isTextItem;

- (bool) swapSelection;

@end


@interface SampleAppMenuGroup : NSObject
- (NSString *) title;

// command will be used for the notification, a negative value is internally handled as a "back" command
- (void) addTextItem:(NSString *)text command:(int) command;

- (void) addSelectionItem:(NSString *)text command:(int) command isSelected:(bool)isSelected;

- (void) setActiveItem:(NSUInteger) indexItem;

- (NSUInteger) nbItems;

@end

@interface SampleAppMenu : NSObject

@property(nonatomic,retain) NSString * title;

@property(nonatomic,assign) id <SampleAppMenuCommandProtocol> commandProtocol;

+ (SampleAppMenu *)instance;

+ (SampleAppMenu *) prepareWithCommandProtocol:(id<SampleAppMenuCommandProtocol>) commandProtocol title:(NSString *) title;

- (SampleAppMenuGroup *) addGroup:(NSString *) title;

- (SampleAppMenuGroup *) addSelectionGroup:(NSString *) title;

- (NSUInteger) nbGroups;

- (bool) notifyCommand:(int)command value:(bool) value;

- (void) clear;

- (bool)setSelectionValueForCommand:(int ) command value:(bool) value;

// for rendering purpose

- (NSUInteger) nbItemsInGroupIndex:(NSUInteger) index;

- (NSString *) titleForGroupIndex:(NSUInteger) index;

- (SampleAppMenuItem *) itemInGroup:(NSUInteger) indexGroup atIndex:(NSUInteger)indexItem;

- (SampleAppMenuGroup *) groupAtIndex:(NSUInteger) indexGroup;

@end
