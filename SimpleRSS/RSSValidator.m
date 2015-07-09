//
//  RSSValidator.m
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSValidator.h"
#import "RSSChannel.h"
#import "RSSDataManager.h"

@interface RSSValidator () <NSXMLParserDelegate>

@property (strong, nonatomic) NSString *stringURL;

@property (copy, nonatomic) SuccessBlock successBlock;
@property (copy, nonatomic) FailureBlock failureBlock;

@property (strong, nonatomic) RSSChannel *channel;

@property (strong, nonatomic) NSString *currentElement;

@property (strong, nonatomic) NSMutableString *currentTitle;
@property (strong, nonatomic) NSMutableString *currentLink;
@property (strong, nonatomic) NSMutableString *currentInfo;

@end

@implementation RSSValidator

- (BOOL)getChannelDetailsFromURLWithString:(NSString *)stringURL
                       onSuccess:(SuccessBlock)successBlock
                       onFailure:(FailureBlock)failureBlock {
    
    if (successBlock) {
        self.successBlock = successBlock;
    }
    
    if (failureBlock) {
        self.failureBlock = failureBlock;
    }
    
    self.stringURL = stringURL;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:stringURL]];
    
    parser.delegate = self;
    
    parser.shouldProcessNamespaces = NO;
    parser.shouldReportNamespacePrefixes = NO;
    parser.shouldResolveExternalEntities = NO;
    
    if (![parser parse]) {
        return parser.parserError.code == NSXMLParserDelegateAbortedParseError;
    }
    
    return YES;
}

#pragma mark - <NSXMLParserDelegate>

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    self.currentElement = elementName;
    
    if ([elementName isEqualToString:@"channel"]) {
        self.channel = [[RSSDataManager sharedManager] createChanel];
        self.channel.channel = self.stringURL;
    } else if ([elementName isEqualToString:@"title"]) {
        self.currentTitle = [NSMutableString string];
    } else if ([elementName isEqualToString:@"description"]) {
        self.currentInfo = [NSMutableString string];
    } else if ([elementName isEqualToString:@"link"]) {
        self.currentLink = [NSMutableString string];
    } else if ([elementName isEqualToString:@"item"]) {
        if (self.successBlock) {
            self.successBlock();
        }
        [parser abortParsing];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([self.currentElement isEqualToString:@"title"]) {
        [self.currentTitle appendString:string];
    } else if ([self.currentElement isEqualToString:@"description"]) {
        [self.currentInfo appendString:string];
    } else if ([self.currentElement isEqualToString:@"link"]) {
        [self.currentLink appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"title"]) {
        self.channel.title = self.currentTitle;
    } else if ([elementName isEqualToString:@"description"]) {
        self.channel.info = self.currentInfo;
    } else if ([elementName isEqualToString:@"link"]) {
        self.channel.link = self.currentLink;
    }
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    if (self.failureBlock && parseError.code != NSXMLParserDelegateAbortedParseError) {
        self.failureBlock(parseError);
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    if (self.failureBlock) {
        self.failureBlock(validationError);
    }
}

@end
