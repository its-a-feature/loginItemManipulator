//
//  main.m
//  loginitems
//
//  Created by Cody Thomas on 5/5/21.
//
#import <Foundation/Foundation.h>

const char* removeSessionLoginItems(char* removePath){
    NSString* output = @"[*] Looking to remove Session Login Items\n";
    NSString* NSRemovePath = [[NSString alloc] initWithCString:removePath encoding:NSUTF8StringEncoding];
    OSStatus result;
    LSSharedFileListRef loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, nil);
    LSSharedFileListItemRef itemRef = nil;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    if (loginItems) {
        UInt32 seedValue;
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        for(int i = 0; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
            if (LSSharedFileListItemResolve(currentItemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                NSString * urlPath = [(__bridge NSURL*)url path];
                
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Found SessionItem: %s\n", urlPath.UTF8String]];
                if ([urlPath compare:NSRemovePath] == NSOrderedSame){
                    itemRef = currentItemRef;
                    result = LSSharedFileListItemRemove(loginItems, currentItemRef);
                    output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Remove Result: %d\n", result]];
                }
            }
        }
    }else{
        return "[-] Failed to get login items\n";
    }
    CFRelease(loginItems);
    return output.UTF8String;
    
}
const char* removeGlobalLoginItems(char* removePath, char* removeName){
    NSString* output = @"[*] Looking to remove Global Login Items\n";
    OSStatus result;
    NSString* NSRemovePath = [[NSString alloc] initWithCString:removePath encoding:NSUTF8StringEncoding];
    NSString* NSRemoveName = [[NSString alloc] initWithCString:removeName encoding:NSUTF8StringEncoding];
    LSSharedFileListRef loginItems =loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListGlobalLoginItems, nil);
    LSSharedFileListItemRef itemRef = nil;
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    if (loginItems) {
        UInt32 seedValue;
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        for(int i = 0; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
            if (LSSharedFileListItemResolve(currentItemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                NSString * urlPath = [(__bridge NSURL*)url path];
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Found GlobalItem: %s\n", urlPath.UTF8String]];
                if ([urlPath compare:NSRemovePath] == NSOrderedSame){
                    itemRef = currentItemRef;
                    result = LSSharedFileListItemRemove(loginItems, currentItemRef);
                    output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Remove Result: %d\n", result]];
                }
            }else{
                CFStringRef name = LSSharedFileListItemCopyDisplayName(currentItemRef);
                NSString *yourFriendlyNSString = (__bridge NSString *)name;
                CFErrorRef urlErr;
                CFURLRef cfurl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, &urlErr);
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Found GlobalItem with Name: %s and ", yourFriendlyNSString.UTF8String]];
                yourFriendlyNSString = (__bridge NSString*)cfurl;
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"url: %s\n", yourFriendlyNSString.UTF8String]];
                if([yourFriendlyNSString compare:NSRemoveName] == NSOrderedSame){
                    itemRef = currentItemRef;
                    result = LSSharedFileListItemRemove(loginItems, currentItemRef);
                    output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Remove Result: %d\n", result]];
                }
            }
        }
    }else{
        return "[-] Failed to get login items\n";
    }
    return output.UTF8String;
    
}
const char* addGlobalLoginItem(unsigned char* path, unsigned char* name){
    AuthorizationRef auth = NULL;
    OSStatus result = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth);
    if (result != 0) {
        printf("auth error %d\n", result);
        return "[-] Failed to get authorization in addGlobalLoginItem\n";
    }
    LSSharedFileListRef loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListGlobalLoginItems, nil);
    if (loginItems) {
        LSSharedFileListSetAuthorization(loginItems, auth);
        CFStringRef itemName = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII);
        CFURLRef pathURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, path, strlen(path), false);
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, itemName, nil, pathURL, nil, nil);
        if (item != NULL) {
            return "[+] Successfully added Global login item\n";
        }else{
            return "[-] Failed to add Global login item\n";
        }
    }else{
        return "[-] Failed to get login items\n";
    }
}
const char* addSessionLoginItem(unsigned char* path, unsigned char* name){
    AuthorizationRef auth = NULL;
    OSStatus result = AuthorizationCreate(nil, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &auth);
    if (result != 0) {
        return "[-] Failed to get authorization in addSessionLoginItem\n";
    }
    LSSharedFileListRef loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, nil);
    if (loginItems) {
        LSSharedFileListSetAuthorization(loginItems, auth);
        CFStringRef itemName = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII);
        CFURLRef pathURL = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, path, strlen(path), false);
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, itemName, nil, pathURL, nil, nil);
        if (item != NULL) {
            return "[+] Successfully added Session login item\n";
        }else{
            return "[-] Failed to add Session login item\n";
        }
    }else{
        return "[-] Failed to get login items\n";
    }
    
}
const char* listSessionLoginItems(){
    NSString* output = @"[*] Listing Session Login Items\n";
    LSSharedFileListRef loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListSessionLoginItems, nil);
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    if (loginItems) {
        UInt32 seedValue;
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        for(int i = 0; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
            if (LSSharedFileListItemResolve(currentItemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                NSString * urlPath = [(__bridge NSURL*)url path];
                
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Found SessionItem: %s\n", urlPath.UTF8String]];
            }
        }
    }else{
        return "[-] Failed to get login items in ListSessionLoginItems\n";
    }
    CFRelease(loginItems);
    return output.UTF8String;
    
}
const char* listGlobalLoginItems(){
    NSString* output = @"[*] Listing Global Login Items\n";
    LSSharedFileListRef loginItems = loginItems = LSSharedFileListCreate(kCFAllocatorDefault, kLSSharedFileListGlobalLoginItems, nil);
    NSString * appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    if (loginItems) {
        UInt32 seedValue;
        NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItems, &seedValue);
        for(int i = 0; i< [loginItemsArray count]; i++){
            LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray
                                                                        objectAtIndex:i];
            if (LSSharedFileListItemResolve(currentItemRef, 0, (CFURLRef*) &url, NULL) == noErr) {
                NSString * urlPath = [(__bridge NSURL*)url path];
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Found GlobalItem: %s\n", urlPath.UTF8String]];
            }else{
                CFStringRef name = LSSharedFileListItemCopyDisplayName(currentItemRef);
                NSString *yourFriendlyNSString = (__bridge NSString *)name;
                CFErrorRef urlErr;
                CFURLRef cfurl = LSSharedFileListItemCopyResolvedURL(currentItemRef, 0, &urlErr);
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"[*] Found GlobalItem with Name: %s and ", yourFriendlyNSString.UTF8String]];
                NSURL* yourFriendlyNSURL = (__bridge NSURL*)cfurl;
                output = [output stringByAppendingString:[[NSString alloc] initWithFormat:@"url: %s\n", yourFriendlyNSURL.absoluteString.UTF8String]];
            }
        }
    }else{
        return "[-] Failed to get login items in listGlobalLoginItems\n";
    }
    return output.UTF8String;
    
}


const char * removeitem(char* path, char* name){
    NSString* output = @"";
    output = [output stringByAppendingString:[[NSString alloc] initWithUTF8String:removeGlobalLoginItems(path, name)]];
    output = [output stringByAppendingString:[[NSString alloc] initWithUTF8String:removeSessionLoginItems(path)]];
    return output.UTF8String;
}
const char * addsessionitem(char* path, char* name){
    NSString* output = @"";
    output = [output stringByAppendingString:[[NSString alloc] initWithUTF8String:addSessionLoginItem(path, name)]];
    return output.UTF8String;
}
const char * addglobalitem(char* path, char* name){
    NSString* output = @"";
    output = [output stringByAppendingString:[[NSString alloc] initWithUTF8String:addGlobalLoginItem(path, name)]];
    return output.UTF8String;
}
const char * listitems(){
    NSString* output = @"";
    output = [output stringByAppendingString:[[NSString alloc] initWithUTF8String:listSessionLoginItems()]];
    output = [output stringByAppendingString:[[NSString alloc] initWithUTF8String:listGlobalLoginItems()]];
    return output.UTF8String;
}
int main(int argc, const char * argv[]) {
    if(argc <= 1){
        printf("%s\n", listitems());
    }else if(argc != 4){
        printf("./loginitems <removeitem | addsession | addglobal> <path to item on disk> <name of item>");
    }else{
        NSString* command = [NSString stringWithUTF8String:argv[1]];
        if( [command isEqualToString:@"removeitem"] ){
            printf("%s\n", removeitem(argv[2], argv[3]));
        }else if( [command isEqualToString:@"addsession"] ){
            printf("%s\n", addsessionitem(argv[2], argv[3]));
        }else if( [command isEqualToString:@"addglobal"] ){
            printf("%s\n", addglobalitem(argv[2], argv[3]));
        }else{
            printf("[-] Unknown command\n");
        }
    }
    return 0;
}

// for local session additions - the path must exist, root doesn't have "session" login items
// for global session additions - the path doesn't have to exist, but you do need to give a name
// for global session additions - adding global as root, user can't see. adding global as user, root can't see.
// for global session additions - add as root, when the user logs in, get execution as root. add as user, when other user logs in, get execution as userA?
// switch user-> root (sudo su - ), root but still able to see user things (sudo su )
