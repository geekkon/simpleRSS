//
//  RSSParser.m
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSParser.h"
#import "RSSParsedItem.h"

@interface RSSParser () <NSXMLParserDelegate>

@property (copy, nonatomic) CompletionBlock completionBlock;

@property (strong, nonatomic) NSMutableArray *items;

@property (strong, nonatomic) NSString *currentElement;

@property (strong, nonatomic) NSMutableString *currentTitle;
@property (strong, nonatomic) NSMutableString *currentLink;
@property (strong, nonatomic) NSMutableString *currentInfo;
@property (strong, nonatomic) NSMutableString *currentGuid;
@property (strong, nonatomic) NSMutableString *currentPubDate;

@end

@implementation RSSParser

- (void)getItemsFromURLWithString:(NSString *)string
                  completionBlock:(CompletionBlock)completionBlock {
    
    if (completionBlock) {
        self.completionBlock = completionBlock;
    }
    
    NSURL *URL = [NSURL URLWithString:string];
    
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
        NSLocale *en_US_POSIX = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = en_US_POSIX;
        // Fri, 10 Jul 2015 00:59:00 +0300
        dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z ";
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

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
    self.items = [NSMutableArray array];
}

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
        
        RSSParsedItem *item = [[RSSParsedItem alloc] init];
        
        item.title = [self trimString:self.currentTitle];
        item.info  = [self trimString:self.currentInfo];
        item.link  = [self trimString:self.currentLink];
        item.guid  = [self trimString:self.currentGuid];
        item.pubDate = [self dateFromString:self.currentPubDate];
        
        [self.items addObject:item];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    __weak RSSParser *weakSelf = self;
    
    if (self.completionBlock) {
        self.completionBlock(YES, weakSelf.items, nil);
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (self.completionBlock) {
        self.completionBlock(NO, nil, parseError);
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    if (self.completionBlock) {
        self.completionBlock(NO, nil, validationError);
    }
}

@end
