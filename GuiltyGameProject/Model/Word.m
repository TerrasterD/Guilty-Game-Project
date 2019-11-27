
//
//  NSObject+Word.m
//  GuiltyGameProject
//
//  Created by Guilherme Martins Dalosto de Oliveira on 26/11/19.
//  Copyright © 2019 Guilherme Martins Dalosto de Oliveira. All rights reserved.
//

#import "Word.h"

@implementation Word

- (instancetype)init : (NSString*) title _: (NSInteger*) difficulty _: (NSString*) deck
{
    self = [super init];
    if (self) {
        self.title = title;
        self.difficulty = difficulty;
        self.deck = deck;
        
    }
    return self;
}

@end