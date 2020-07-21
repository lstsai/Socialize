//
//  ParseHelper.m
//  Sprout
//
//  Created by laurentsai on 7/21/20.
//  Copyright © 2020 laurentsai. All rights reserved.
//

#import "ParseHelper.h"

@implementation ParseHelper
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image withName:(NSString*)imageName {
    if(image)//no image
    {
        NSData *imageData = UIImagePNGRepresentation(image);
        imageName=[imageName stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* fileName=[imageName stringByAppendingString:@".png"];
        if(imageData)
            return [PFFileObject fileObjectWithName:fileName data:imageData];
    }
    
    return nil;//if image data or image is nil
}
@end
