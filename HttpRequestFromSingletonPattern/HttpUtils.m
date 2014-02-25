//
//  HttpUtils.m
//  GoBizMo
//
//  Created by Prince Kumar Sharma on 04/11/13.
//  Copyright (c) 2013 Prince Kumar Sharma. All rights reserved.
//

#import "HttpUtils.h"
#import "MBProgressHUD.h"

@implementation HttpUtils

static MBProgressHUD *progressHud;

+(void)showHUDFor:(UIView*)view
{
    progressHud=[MBProgressHUD showHUDAddedTo:view animated:YES];
    progressHud.labelText=@"Please Wait...";
}

+(void)invokeAPIWithURL:(NSURL*)url parameters:(NSDictionary*)params andCompletionHandler:(processCompletion)block inView:(UIView*)view andLoadmessage:(NSString*)loadMsg
{
    @try {
        BOOL synchronous=YES;
        //params=@{@"header":@"header params",@"isPost":@"get or post",@"paramObj":@"params to send with response",@"postdata":@"data to post"};
        
        BOOL isPost=[[params objectForKey:@"isPost"] boolValue];
        
        NSMutableDictionary *paramObj=[[NSMutableDictionary alloc] init];
        
        if ([params objectForKey:@"paramObj"]!=nil) {
            paramObj=[params objectForKey:@"paramObj"];
        }
        
        NSString *send_data=[url absoluteString];
        
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120.0];
        
        NSArray *headerObj=[params objectForKey:@"header"];
        
        if (isPost) {
            
            for (NSDictionary *header in headerObj) {
                NSString *headerVal=([header valueForKey:@"value"]!=NULL)?[header valueForKey:@"value"]:@"";
                NSString *headerName=([header valueForKey:@"name"]!=NULL)?[header valueForKey:@"name"]:@"";
                
                [request setValue:headerVal forHTTPHeaderField:headerName];
                
                NSLog(@"header for login %@",header);
            }

            NSString *bodyStr=([params objectForKey:@"postdata"]!=NULL)?[params objectForKey:@"postdata"]:@"";
            
            
            NSLog(@"body string %@",bodyStr);
            
           
            
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];

        }else{
            
            BOOL isParam=false;
            
            for (int i=0;i<[headerObj count];i++) {
                NSDictionary *header=[[NSDictionary alloc] initWithDictionary:headerObj[i]];
                
                if (i>0) {
                    [send_data stringByAppendingFormat:@"&%@=%@",header[@"name"],header[@"value"]];
                }else{
                    [send_data stringByAppendingFormat:@"?%@=%@",header[@"name"],header[@"value"]];
                    isParam=true;
                }
            }
            
            if (isParam) {
               send_data = [send_data stringByAppendingFormat:@"=%@",randNo()];
            }else{
               send_data = [send_data stringByAppendingFormat:@"?rand=%@",randNo()];
            }
            
            url=[NSURL URLWithString:send_data];
        }
        
        if (view!=nil) {
            
            if (![view.subviews containsObject:progressHud]) {
               progressHud=[MBProgressHUD showHUDAddedTo:view animated:YES];   
            }
            
            if (loadMsg!=NULL) {
                NSString *key=[loadMsg substringWithRange:NSMakeRange(0,3)];
                
               
            }
            
            progressHud.labelText=(loadMsg!=NULL)?loadMsg:@"Please Wait...";
        }
        
        if (synchronous) {
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
                NSURLResponse *response=nil;
                NSError *error=nil;
                
                NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                BOOL isSuccess=NO;
                
                if([httpResponse statusCode]==200){
                    isSuccess=YES;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                     [progressHud hide:YES];
                     [progressHud removeFromSuperview];
                    
                    NSString *responsedata=[[NSString alloc] init];
                    
                    if (data!=nil) {
                        responsedata=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        
                        if ([responsedata rangeOfString:@"</osml>"].location != NSNotFound) {
                            NSRange range=[responsedata rangeOfString:@"</osml>"];
                            int lastLocation=range.location+range.length;
                            responsedata=[responsedata substringToIndex:lastLocation];
                        }
                    }
                   
                    block(responsedata,paramObj,error,isSuccess);
                });
            });
        
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception In invokeAPIWithURL %@",exception);
    }
}

NSString *(^randNo)(void) = ^{
    int min=0,max=100;
    int randNum = rand() % (max - min) + min;
    NSString *num = [NSString stringWithFormat:@"%d", randNum];
    return num;
};

NSString *(^encodeXMLString)(NSString*)=^(NSString* bodyStr)
{
    NSMutableString * temp = [bodyStr mutableCopy];
    
    [temp replaceOccurrencesOfString:@"&"
                          withString:@"&amp;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"<"
                          withString:@"&lt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@">"
                          withString:@"&gt;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"\""
                          withString:@"&quot;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    [temp replaceOccurrencesOfString:@"'"
                          withString:@"&apos;"
                             options:0
                               range:NSMakeRange(0, [temp length])];
    return temp;
};


@end
