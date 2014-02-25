//
//  HttpUtils.h
//  GoBizMo
//
//  Created by Prince Kumar Sharma on 04/11/13.
//  Copyright (c) 2013 Prince Kumar Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpUtils : NSObject
typedef void(^processCompletion)(NSString *response,NSDictionary *paramObj,NSError *error,BOOL isSuccess);
+(void)invokeAPIWithURL:(NSURL*)url parameters:(NSDictionary*)params andCompletionHandler:(processCompletion)block inView:(UIView*)view andLoadmessage:(NSString*)loadMsg;
@end
