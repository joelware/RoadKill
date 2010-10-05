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
	NSMutableData *responseData;
}

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;

- (void)authenticateWithUsername:(NSString *)username password:(NSString *)password;
@end
