//
//  RSSParser.m
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSParser.h"
#import "RSSDataManager.h"
#import "RSSChannel.h"
#import "RSSItem.h"

@interface RSSParser () <NSXMLParserDelegate>

@property (copy, nonatomic) SuccessBlock successBlock;
@property (copy, nonatomic) FailureBlock failureBlock;

@property (strong, nonatomic) RSSChannel *currentChannel;
@property (strong, nonatomic) RSSItem *item;

@property (strong, nonatomic) NSString *currentElement;

@property (strong, nonatomic) NSMutableString *currentTitle;
@property (strong, nonatomic) NSMutableString *currentLink;
@property (strong, nonatomic) NSMutableString *currentInfo;
@property (strong, nonatomic) NSMutableString *currentGuid;
@property (strong, nonatomic) NSMutableString *currentPubDate;

@end

@implementation RSSParser

- (void)getItemsFromChanel:(RSSChannel *)channel
                 onSuccess:(SuccessBlock)successBlock
                 onFailure:(FailureBlock)failureBlock {
    
    if (successBlock) {
        self.successBlock = successBlock;
    }
    
    if (failureBlock) {
        self.failureBlock = failureBlock;
    }
    
    self.currentChannel = channel;
    
    NSURL *URL = [NSURL URLWithString:channel.channel];
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    
    parser.delegate = self;
    
    parser.shouldProcessNamespaces = NO;
    parser.shouldReportNamespacePrefixes = NO;
    parser.shouldResolveExternalEntities = NO;
    
    [parser parse];
}

#pragma mark - Private Methods

+ (NSDateFormatter *)dateFormatter {
    
    static NSDateFormatter *dateFormatter = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        // Fri, 10 Jul 2015 00:59:00 +0300
        dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
    });
    
    return dateFormatter;
}

- (NSString *)trimString:(NSString *)string {
    
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDate *)dateFromString:(NSString *)string {

    return [[RSSParser dateFormatter] dateFromString:[self trimString:string]];
}

#pragma mark - <NSXMLParserDelegate>

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.currentElement = elementName;
    
    if ([elementName isEqualToString:@"item"]) {
        self.currentTitle = [NSMutableString string];
        self.currentInfo = [NSMutableString string];
        self.currentLink = [NSMutableString string];
        self.currentPubDate = [NSMutableString string];
        self.currentGuid = [NSMutableString string];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([self.currentElement isEqualToString:@"title"]) {
        [self.currentTitle appendString:string];
    } else if ([self.currentElement isEqualToString:@"description"]) {
        [self.currentInfo appendString:string];
    } else if ([self.currentElement isEqualToString:@"link"]) {
        [self.currentLink appendString:string];
    } else if ([self.currentElement isEqualToString:@"pubDate"]) {
        [self.currentPubDate appendString:string];
    } else if ([self.currentElement isEqualToString:@"guid"]) {
        [self.currentGuid appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        NSString *title = [self trimString:self.currentTitle];
        NSString *info  = [self trimString:self.currentInfo];
        NSString *link  = [self trimString:self.currentLink];
        NSString *guid  = [self trimString:self.currentGuid];
        NSDate *pubDate = [self dateFromString:self.currentPubDate];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
        
            if (![[RSSDataManager sharedManager] foundGuid:[self trimString:self.currentGuid]
                                       inLocalChannelStore:self.currentChannel]) {
                
                RSSItem *item = [[RSSDataManager sharedManager] createItemInChannel:self.currentChannel];
                
                item.title = title;
                item.info  = info;
                item.link  = link;
                item.guid  = guid;
                item.pubDate = pubDate;
            }
        });
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    if (self.successBlock) {
        self.successBlock();
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (self.failureBlock) {
        self.failureBlock(parseError);
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    if (self.failureBlock) {
        self.failureBlock(validationError);
    }
}

@end
