//
//  RemoteStrings.h
//  NMRemoteBundle
//
//  Created by Nicola Miotto on 3/25/13.
//  Copyright (c) 2013 Nicola Miotto. All rights reserved.
//

#ifndef NMRemoteBundle_RemoteStrings_h
#define NMRemoteBundle_RemoteStrings_h

/* ---- SOME USEFUL MACROS ---- */

#define NMRemoteLocalizedString(key, comment)^NSString*{\
NSBundle *bundle = [NSBundle mainRemoteBundle];\
bundle = bundle?: [NSBundle mainBundle];\
return [bundle localizedStringForKey:(key) value:@"" table:nil];\
}()

// Uncomment to seamlessly use the remote strings if available
// #define NSLocalizedString(key, comment) NMRemoteLocalizedString(key, comment)

/* --------------------------- */

#endif
