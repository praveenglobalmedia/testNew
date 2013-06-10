//
//  myView.m
//  W3WebService
//
//  Created by Ravi Dixit on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "myView.h"


@implementation myView
@synthesize txt1,output;

#define startActivityIndicator  [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES]
#define stopActivityIndicator  [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		nodeContent = [[NSMutableString alloc]init];
       
        
    }
    return self;
}

-(IBAction)invokeService
{
	
	if ([txt1.text length]==100) {
		
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"WebService" message:@"Supply Data in text field" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok",nil];
		[alert show];
		[alert release];
	}
	else {
		
		[txt1 resignFirstResponder];
		NSString *soapFormat = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
								"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
								"<soap:Body>\n"
                                "<InsertRecord xmlns=\"http://tempuri.org/\">\n"
								"<sUserName>newuseruser</sUserName>\n"
                                "<sPassword>213123213</sPassword>\n"
								"</InsertRecord>\n"
								"</soap:Body>\n"
								"</soap:Envelope>\n"];
		
		
		NSLog(@"The request format is %@",soapFormat);
		
		NSURL *locationOfWebService = [NSURL URLWithString:@"http://ws-01.gmi-projects.com/api-webservices/Service.asmx"];
		
		NSLog(@"web url = %@",locationOfWebService);
		
		NSMutableURLRequest *theRequest = [[NSMutableURLRequest alloc]initWithURL:locationOfWebService];
		
		NSString *msgLength = [NSString stringWithFormat:@"%d",[soapFormat length]];
		
		[theRequest addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
		[theRequest addValue:@"http://tempuri.org/InsertRecord" forHTTPHeaderField:@"SOAPAction"];
		[theRequest addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        
       //[theRequest setValue:@"application/soap+xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        //[theRequest setValue:@"wsdl2objc" forHTTPHeaderField:@"User-Agent"];
        
        [theRequest setValue:@"ws-01.gmi-projects.com" forHTTPHeaderField:@"Host"];
		[theRequest setHTTPMethod:@"POST"];
		//the below encoding is used to send data over the net
		[theRequest setHTTPBody:[soapFormat dataUsingEncoding:NSUTF8StringEncoding]];
		
		
		NSURLConnection *connect = [[NSURLConnection alloc]initWithRequest:theRequest delegate:self];
		
		if (connect) {
			webData = [[NSMutableData alloc]init];
            startActivityIndicator;
		}
		else {
			NSLog(@"No Connection established");
		}
		
		
	}

}

-(IBAction)backGroundTap:(id)sender
{
	[txt1 resignFirstResponder];
}

//NSURLConnection delegate method

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[webData setLength: 0];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[webData appendData:data];
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"ERROR with theConenction");
	[connection release];
	[webData release];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"DONE. Received Bytes: %d", [webData length]);
	NSString *theXML = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding:NSUTF8StringEncoding];
	NSLog(@"xml response : %@",theXML);
	
    NSLog(@"web data %@",[[NSString alloc]initWithData:webData encoding:NSUTF8StringEncoding]);
    
	xmlParser = [[NSXMLParser alloc]initWithData:webData];
	[xmlParser setDelegate: self];
	//[xmlParser setShouldResolveExternalEntities: YES];
	[xmlParser parse];
//	
	[connection release];
	//[webData release];
	//[resultTable reloadData];
    stopActivityIndicator;
}


//xml delegates

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[nodeContent appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"CelsiusToFahrenheitResult"]) {
		
		finaldata = nodeContent;
		output.text = finaldata;
		
	}
	output.text = finaldata;
}
/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[txt1 release];
	[output release];
    [super dealloc];
}


@end
