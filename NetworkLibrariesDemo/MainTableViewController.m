//
//  MainTableViewController.m
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-10.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

#import "MainTableViewController.h"
#import "WeatherHTTPClient.h"
#import "NSDictionary+weather_package.h"
#import "NSDictionary+weather.h"

@interface MainTableViewController () <WeatherHttpClientDelegate, UIActionSheetDelegate, NSXMLParserDelegate>

@property (strong, nonatomic) NSDictionary *weather;
@property (strong, nonatomic) NSMutableDictionary *xmlWeather;
@property (strong, nonatomic) NSMutableDictionary *currentDictionary;
@property (strong, nonatomic) NSString *previousElementName;
@property (strong, nonatomic) NSString *elementName;
@property (strong, nonatomic) NSMutableString *outstring;


@end

#define kLatitude 22.565108
#define kLongitude 114.060319
static NSString *const BaseURLString = @"http://www.raywenderlich.com/downloads/weather_sample/";

@implementation MainTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.toolbarHidden = NO;
    CLLocation *shenzhen = [[CLLocation alloc] initWithLatitude:kLatitude longitude:kLongitude];
    [self updateWeatherFromLocation:shenzhen];
    [self.tableView reloadData];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!self.weather)
        return 0;
    
    switch (section) {
        case 0:{
            return 1;
        }
        case 1:{
            NSArray *commingWeather = [self.weather commingWeather];
            return [commingWeather count];
        }
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WeatherCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *daysWeather;
    
    switch (indexPath.section) {
        case 0:{
            daysWeather = [self.weather currentCondition];
            break;
        }
        case 1:{
            NSArray *commingWeather = [self.weather commingWeather];
            daysWeather = [commingWeather objectAtIndex:indexPath.row];
        }
        default:
            break;
    }
    
    cell.textLabel.text = [daysWeather weatherDescription];
    
    __weak UITableViewCell *weakcell = cell;
//    [cell.imageView setImageWithURL:[NSURL URLWithString:daysWeather.weatherIconURL]];
    
    [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:daysWeather.weatherIconURL]]
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                       weakcell.imageView.image = image;
                                       [weakcell setNeedsLayout];
                                   }
                                   failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                       
                                   }];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)clearClicked:(id)sender {
    self.weather = nil;
    [self.tableView reloadData];
    self.title = @"";
}

- (IBAction)apiClicked:(id)sender {
    CLLocation *shenzhen = [[CLLocation alloc] initWithLatitude:kLatitude longitude:kLongitude];
    [self updateWeatherFromLocation:shenzhen];
    [self.tableView reloadData];
}

- (void)updateWeatherFromLocation:(CLLocation *)location{
    WeatherHTTPClient *client = [WeatherHTTPClient sharedWeatherHTTPClient];
    client.delegate = self;
    [client updateWeatherAtLocation:location forNumberOfDays:5];
}

#pragma mark - WeatherHttpClientDelegate

-(void)weatherHTTPClient:(WeatherHTTPClient *)client didUpdateWithWeather:(id)aWeather{
    self.weather = aWeather;
    if (aWeather[@"data"][@"error"]) {
        self.title = @"API Request Error";
    } else {
        self.title = @"API Updated";
    }
    [self.tableView reloadData];
}

-(void)weatherHTTPClient:(WeatherHTTPClient *)client didFailWithError:(NSError *)error{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                 message:[NSString stringWithFormat:@"%@",error]
                                                delegate:nil
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(buttonIndex==0){
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:BaseURLString]];
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"json" forKey:@"format"];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Accept" value:@"application/json"];
        
        [client postPath:@"weather.php"
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     self.weather = responseObject;
                     self.title = @"HTTP POST";
                     [self.tableView reloadData];
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                  message:[NSString stringWithFormat:@"%@",error]
                                                                 delegate:nil
                                                        cancelButtonTitle:@"OK" otherButtonTitles:nil];
                     [av show];
                     
                 }
         ];
    }
    else if (buttonIndex==1){
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:BaseURLString]];
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"json" forKey:@"format"];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Accept" value:@"application/json"];
        
        [client getPath:@"weather.php"
             parameters:parameters
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    self.weather = responseObject;
                    self.title = @"HTTP GET";
                    [self.tableView reloadData];
                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                 message:[NSString stringWithFormat:@"%@",error]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    
                }
         ];
    } else if (buttonIndex == 2) {
        NSString *weatherUrl = [NSString stringWithFormat:@"%@weather.php?format=json",BaseURLString];
        
        NSURL *url = [NSURL URLWithString:weatherUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFJSONRequestOperation *operation =
        [AFJSONRequestOperation JSONRequestOperationWithRequest: request
                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                                                            self.weather  = (NSDictionary *)JSON;
                                                            self.title = @"JSON Retrieved";
                                                            [self.tableView reloadData];
                                                            
                                                        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                                            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                                                         message:[NSString stringWithFormat:@"%@",error]
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                            [av show];
                                                        }];
        
        
        
        [operation start];
    } else if(buttonIndex == 3){
        NSString *weatherUrl = [NSString stringWithFormat:@"%@weather.php?format=xml",BaseURLString];
        NSURL *url = [NSURL URLWithString:weatherUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFXMLRequestOperation *operation =
        [AFXMLRequestOperation XMLParserRequestOperationWithRequest:request
                                                            success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSXMLParser *XMLParser) {
                                                                self.xmlWeather = [NSMutableDictionary dictionary];
                                                                
                                                                XMLParser.delegate = self;
                                                                [XMLParser setShouldProcessNamespaces:YES];
                                                                [XMLParser parse];
                                                                
                                                            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, NSXMLParser *XMLParser) {
                                                                UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Weather"
                                                                                                             message:[NSString stringWithFormat:@"%@",error]
                                                                                                            delegate:nil
                                                                                                   cancelButtonTitle:@"OK" otherButtonTitles:nil];
                                                                [av show];
                                                            }];
        
        [operation start];
    }
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict  {
    
    self.previousElementName = self.elementName;
    
    if (qName) {
        self.elementName = qName;
    }
    
    if([qName isEqualToString:@"current_condition"]){
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    else if([qName isEqualToString:@"weather"]){
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    else if([qName isEqualToString:@"request"]){
        self.currentDictionary = [NSMutableDictionary dictionary];
    }
    
    self.outstring = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.elementName){
        return;
    }
    
    [self.outstring appendFormat:@"%@", string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if([qName isEqualToString:@"current_condition"] ||
       [qName isEqualToString:@"request"]){
        [self.xmlWeather setObject:[NSArray arrayWithObject:self.currentDictionary] forKey:qName];
        self.currentDictionary = nil;
    }
    else if([qName isEqualToString:@"weather"]){
        
        // Initalise the list of weather items if it dosnt exist
        NSMutableArray *array = [self.xmlWeather objectForKey:@"weather"];
        if(!array)
            array = [NSMutableArray array];
        
        [array addObject:self.currentDictionary];
        [self.xmlWeather setObject:array forKey:@"weather"];
        
        self.currentDictionary = nil;
    }
    
    else if([qName isEqualToString:@"value"]){
        //Ignore value tags they only appear in the two conditions below
    }
    else if([qName isEqualToString:@"weatherDesc"] ||
            [qName isEqualToString:@"weatherIconUrl"]){
        [self.currentDictionary setObject:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:self.outstring forKey:@"value"]] forKey:qName];
    }
    else{
        [self.currentDictionary setObject:self.outstring forKey:qName];
    }
    
	self.elementName = nil;
}



-(void) parserDidEndDocument:(NSXMLParser *)parser {
    self.weather = [NSDictionary dictionaryWithObject:self.xmlWeather forKey:@"data"];
    self.title = @"XML Retrieved";
    [self.tableView reloadData];
}


#pragma mark -

- (IBAction)afnetworking1Clicked:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"AFNetworing 1.x" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"HTTP POST", @"HTTP GET", @"JSON", @"XML" , nil];
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

- (IBAction)afnetworking2Clicked:(id)sender {
}

- (IBAction)mknetwokkitClicked:(id)sender {
}

- (IBAction)restkitClicked:(id)sender {
}
@end
