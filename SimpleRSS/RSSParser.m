//
//  RSSParser.m
//  SimpleRSS
//
//  Created by Dim on 07.07.15.
//  Copyright (c) 2015 Dmitriy Baklanov. All rights reserved.
//

#import "RSSParser.h"
#import "RSSItem.h"

@interface RSSParser () <NSXMLParserDelegate>

@property (copy, nonatomic) ItemsBlock itemsBlock;
@property (copy, nonatomic) FailureBlock failureBlock;

@property (strong, nonatomic) NSMutableArray *items;

@end

@implementation RSSParser

- (void)getItemsFromURL:(NSURL *)URL
              onSuccess:(ItemsBlock)itemsBlock
              onFailure:(FailureBlock)failureBlock {
    
    if (itemsBlock) {
        self.itemsBlock = itemsBlock;
    }
    
    if (failureBlock) {
        self.failureBlock = failureBlock;
    }
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    
    parser.delegate = self;
    
    parser.shouldProcessNamespaces = NO;
    parser.shouldReportNamespacePrefixes = NO;
    parser.shouldResolveExternalEntities = NO;
    
    [parser parse];
}

#pragma mark - Private

#pragma mark - <NSXMLParserDelegate>

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    
    NSLog(@"parserDidStartDocument");

}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    NSLog(@"parserDidEndDocument");
    
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"parseErrorOccurred");
    if (self.failureBlock) {
        self.failureBlock(parseError);
    }
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"validationErrorOccurred");
    if (self.failureBlock) {
        self.failureBlock(validationError);
    }
}

@end
