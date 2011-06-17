/*
 *  RKConstants.h
 *  RoadKill
 *
 *  Created by Hal Mueller on 10/4/10.
 *
 */

#define RKWebServer @"www.wildlifecrossing.net"

// constants used for accessing application Settings
#define RKIsFirstLaunchKey		@"isFirstLaunch"
#define RKSettingsUsernameKey	@"username"
#define RKSettingsPasswordKey	@"password"
#define RKSettingsIsTestModeKey @"isTestMode"

// test account
//#define RKTestUsername @"halmueller"		  // note: now using Settings to store this, retrieve as follows:
											  //    [[NSUserDefaults standardUserDefaults] stringForKey:RKSettingsUsernameKey]
//#define RKCorrectTestPassword @"JhPs3rtYtU" // note: now using Settings to store this, retrieve as follows:
											  //    [[NSUserDefaults standardUserDefaults] stringForKey:RKSettingsPasswordKey]
//#define RKFailingTestPassword @"xyzzy"	  // note: this wasn't being used

// Core Data entities
#define RKObservationEntity @"Observation"
#define RKSpeciesEntity @"Species"
#define RKSpeciesCategoryEntity @"SpeciesCategory"
#define RKStateEntity @"State"
#define RKUserEntity @"User"
#define RKPhotoEntity @"Photo"

// observation sent status
#define kRKNotReady @"Not ready"
#define kRKReady @"Ready"
#define kRKQueued @"Queued"
#define kRKComplete @"Complete"

//observation confidence levels
#define kRK100PercentCertain @"100% Certain"
#define kRKSomewhatConfident @"Somewhat confident"
#define kRKBestGuess @"Best guess"


// species database header fields, http://www.wildlifecrossing.net/california/files/xing/CA-taxa.csv
#define kCSVHeaderNID @"ID"
#define kCSVHeaderCategory @"Species Category"
#define kCSVHeaderCommon @"Common Name"
#define kCSVHeaderLatin @"Scientific Name"

#define kNinetyDaysInSeconds 90.*24.*60.*60.

// default location coordinates for testing purposes
#define kDefaultLatitude     38.0
#define kDefaultLongitude  -120.0

// Notification message constants
#define RKSpeciesSelectedNotification      @"RKSpeciesSelected"
