//
//  Global.h
//  TileMapTestApp
//
//  Created by 本多　郁 on 2020/06/13.
//  Copyright © 2020 deepkick. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - ログ
// ログ
#ifdef DEBUG
# define LOG(...) NSLog(__VA_ARGS__)
# define LOG_CURRENT_METHOD NSLog(@"%@/%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
# define LOGING(...) NSLog(@"【%@/%@】%@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), __VA_ARGS__)
# define LOGING_DIC(...) LOGING([Global descriptionWithNSDictionary:__VA_ARGS__])
#else
# define LOG(...);
# define LOG_CURRENT_METHOD;
# define LOGING(...);
# define LOGING_DIC(...);
#endif

NS_ASSUME_NONNULL_BEGIN

@interface Global : NSObject

@end

NS_ASSUME_NONNULL_END
