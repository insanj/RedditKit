//
//  RKComment+Submarine.m
//  
//
//  Created by Julian Weiss on 8/14/15.
//
//

#import "RKComment+Submarine.h"
#import <objc/runtime.h>

static NSString *kSubmarineAuthorFlairTextKey = @"SubmarineAuthorFlair", *kSubmarineAuthorFlairClassKey = @"SubamrineAuthorFlairClass";

@implementation RKComment (Submarine)

- (NSString *)submarineAuthorFlairText {
    return objc_getAssociatedObject(self, &kSubmarineAuthorFlairTextKey);
}

- (void)setSubmarineAuthorFlairText:(NSString *)submarineAuthorFlairText {
    objc_setAssociatedObject(self, &kSubmarineAuthorFlairTextKey, submarineAuthorFlairText, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)submarineAuthorFlairClass {
    return objc_getAssociatedObject(self, &kSubmarineAuthorFlairClassKey);
}

- (void)setSubmarineAuthorFlairClass:(NSString *)submarineAuthorFlairClass {
    objc_setAssociatedObject(self, &kSubmarineAuthorFlairClassKey, submarineAuthorFlairClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(JSONKeyPathsByPropertyKey);
        SEL swizzledSelector = @selector(submarine_JSONKeyPathsByPropertyKey);
        
        Method originalMethod = class_getClassMethod(class, originalSelector);
        Method swizzledMethod = class_getClassMethod(class, swizzledSelector);
        
        Class stringClass = [NSString class];
        
        objc_property_attribute_t authorFlairTextType = { "T", "@\"NSString\"" };
        objc_property_attribute_t authorFlairTextOwnership = { "C", "" };
        objc_property_attribute_t authorFlairTextAttrs[] = { authorFlairTextType, authorFlairTextOwnership };
        class_addProperty(stringClass, "submarineAuthorFlairText", authorFlairTextAttrs, 2);
        
        objc_property_attribute_t type = { "T", "@\"NSString\"" };
        objc_property_attribute_t ownership = { "C", "" };
        objc_property_attribute_t attrs[] = { type, ownership };
        class_addProperty(stringClass, "submarineAuthorFlairClass", attrs, 2);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

+ (NSDictionary *)submarine_JSONKeyPathsByPropertyKey
{
    NSDictionary *keyPaths = @{
                               @"approvedBy": @"data.approved_by",
                               @"bannedBy": @"data.banned_by",
                               @"author": @"data.author",
                               @"linkAuthor": @"data.link_author",
                               @"body": @"data.body",
                               @"bodyHTML": @"data.body_html",
                               @"scoreHidden": @"data.score_hidden",
                               @"replies": @"data.replies",
                               @"edited": @"data.edited",
                               @"archived": @"data.archived",
                               @"saved": @"data.saved",
                               @"linkID": @"data.link_id",
                               @"gilded": @"data.gilded",
                               @"score": @"data.score",
                               @"controversiality": @"controversiality",
                               @"parentID": @"data.parent_id",
                               @"subreddit": @"data.subreddit",
                               @"subredditID": @"data.subreddit_id",
                               @"submissionContentText": @"data.contentText", // Note: This data is only sent back from reddit's API as a response to submitting a new comment.
                               @"submissionContentHTML": @"data.contentHTML", // Note: This data is only sent back from reddit's API as a response to submitting a new comment.
                               @"submissionLink": @"data.link", // Note: This data is only sent back from reddit's API as a response to submitting a new comment.
                               @"submissionParent": @"data.parent", // Note: This data is only sent back from reddit's API as a response to submitting a new comment.
                               //		@"totalReports": @"data.num_reports",          // not required for now.
                               //		@"distinguishedStatus": @"data.distinguished", // not required for now.
                               @"submarineAuthorFlairClass": @"data.author_flair_css_class",
                               @"submarineAuthorFlairText": @"data.author_flair_text"
                               };
    
    return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:keyPaths];
}
@end

