//
//  RKCROSSession.h
//  RoadKill
//
//  Created by Hal Mueller on 10/4/10.
//

#import <Foundation/Foundation.h>

// encapsulate the credentials for a session with the CROS server
@interface RKCROSSession : NSObject {
	NSURLConnection *connection;
	NSMutableData *receivedData;
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *receivedData;

+ (NSMutableURLRequest *)authenticationRequestWithUsername:(NSString *)username password:(NSString *)password;
- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
- (void)doSomethingWithResponse:(NSURLResponse *)response;
@end
