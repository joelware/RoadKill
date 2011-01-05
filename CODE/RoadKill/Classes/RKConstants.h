/*
 *  RKConstants.h
 *  RoadKill
 *
 *  Created by Hal Mueller on 10/4/10.
 *
 */

#define RKWebServer @"www.wildlifecrossing.net"

// test account
#define RKTestUsername @"halmueller"
#define RKCorrectTestPassword @"JhPs3rtYtU"
#define RKFailingTestPassword @"xyzzy"

// Core Data entities
#define RKObservationEntity @"Observation"
#define RKSpeciesEntity @"Species"
#define RKSpeciesCategoryEntity @"SpeciesCategory"
#define RKStateEntity @"State"
#define RKUserEntity @"User"
#define RKPhotoEntity @"Photo"

// observation sent status
#define kRKNotReady @"not ready"
#define kRKReady @"ready"
#define kRKQueued @"queued"
#define kRKComplete @"complete"

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


// Notification message constants
#define RKSpeciesSelectedNotification      @"RKSpeciesSelected"
