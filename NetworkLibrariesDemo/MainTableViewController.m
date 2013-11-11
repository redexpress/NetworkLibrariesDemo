//
//  MainTableViewController.m
//  NetworkLibrariesDemo
//
//  Created by Gavin Yang on 13-11-10.
//  Copyright (c) 2013年 redexpress.github.com. All rights reserved.
//

#import "MainTableViewController.h"
#import "WeatherHTTPClient.h"
#import "GDataXMLNode.h"
#import "Weather.h"

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
            NSArray *commingWeather = self.weather[@"data"][@"weather"];
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
            daysWeather = self.weather[@"data"][@"current_condition"][0];
            break;
        }
        case 1:{
            NSArray *commingWeather = self.weather[@"data"][@"weather"];
            daysWeather = [commingWeather objectAtIndex:indexPath.row];
        }
        default:
            break;
    }

    cell.textLabel.text = daysWeather[@"weatherDesc"][0][@"value"];
    
    __weak UITableViewCell *weakcell = cell;
//    [cell.imageView setImageWithURL:[NSURL URLWithString:daysWeather.weatherIconURL]];
    
    [cell.imageView setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:daysWeather[@"weatherIconUrl"][0][@"value"]]]
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
        NSDictionary *parameters = [NSDictionary dictionaryWithObject:@"xml" forKey:@"format"];
        
        AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
        [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [client setDefaultHeader:@"Accept" value:@"application/xml"];
        
        [client postPath:@"weather.php"
              parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     if (YES) {
                         self.weather = responseObject;
                         self.title = @"HTTP POST";
                         [self.tableView reloadData];
                     } else {
                         [self parseWeatherFromData:responseObject];
                     }
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

- (NSDictionary *)parseWeatherFromData:(NSData *)data{
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    <?xml version="1.0" encoding="UTF-8" ?>
//    <data>
//    <current_condition>
//    <cloudcover>16</cloudcover>
//    <humidity>59</humidity>
//    <observation_time>09:09 PM</observation_time>
//    <precipMM>0.1</precipMM>
//    <pressure>1010</pressure>
//    <temp_C>10</temp_C>
//    <temp_F>49</temp_F>
//    <visibility>10</visibility>
//    <weatherCode>113</weatherCode>
//    <weatherDesc>
//    <value>Clear</value>
//    </weatherDesc>
//    <weatherIconUrl>
//    <value>http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0008_clear_sky_night.png</value>
//    </weatherIconUrl>
//    <winddir16Point>NW</winddir16Point>
//    <winddirDegree>316</winddirDegree>
//    <windspeedKmph>47</windspeedKmph>
//    <windspeedMiles>29</windspeedMiles>
//    </current_condition>
//    <request>
//    <query>Lat 32.35 and Lon 141.43</query>
//    <type>LatLon</type>
//    </request>
//    <weather>
//    <date>2013-01-15</date>
//    <precipMM>1.8</precipMM>
//    <tempMaxC>12</tempMaxC>
//    <tempMaxF>53</tempMaxF>
//    <tempMinC>10</tempMinC>
//    <tempMinF>50</tempMinF>
//    <weatherCode>119</weatherCode>
//    <weatherDesc>
//    <value>Cloudy</value>
//    </weatherDesc>
//    <weatherIconUrl>
//    <value>http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0003_white_cloud.png</value>
//    </weatherIconUrl>
//    <winddir16Point>NNW</winddir16Point>
//    <winddirDegree>348</winddirDegree>
//    <winddirection>NNW</winddirection>
//    <windspeedKmph>66</windspeedKmph>
//    <windspeedMiles>41</windspeedMiles>
//    </weather>
//    <weather>
    //    <date>2013-01-16</date>
    //    <precipMM>0.6</precipMM>
    //    <tempMaxC>13</tempMaxC>
    //    <tempMaxF>56</tempMaxF>
    //    <tempMinC>11</tempMinC>
    //    <tempMinF>51</tempMinF>
    //    <weatherCode>113</weatherCode>
    //    <weatherDesc>
    //    <value>Sunny</value>
    //    </weatherDesc>
    //    <weatherIconUrl>
    //    <value>http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png</value>
    //    </weatherIconUrl>
    //    <winddir16Point>WNW</winddir16Point>
    //    <winddirDegree>284</winddirDegree>
    //    <winddirection>WNW</winddirection>
    //    <windspeedKmph>33</windspeedKmph>
    //    <windspeedMiles>21</windspeedMiles>
//    </weather>
//    <weather>
//    <date>2013-01-17</date>
//    <precipMM>0.5</precipMM>
//    <tempMaxC>14</tempMaxC>
//    <tempMaxF>56</tempMaxF>
//    <tempMinC>7</tempMinC>
//    <tempMinF>44</tempMinF>
//    <weatherCode>119</weatherCode>
//    <weatherDesc>
//    <value>Cloudy</value>
//    </weatherDesc>
//    <weatherIconUrl>
//    <value>http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0003_white_cloud.png</value>
//    </weatherIconUrl>
//    <winddir16Point>WNW</winddir16Point>
//    <winddirDegree>293</winddirDegree>
//    <winddirection>WNW</winddirection>
//    <windspeedKmph>41</windspeedKmph>
//    <windspeedMiles>25</windspeedMiles>
//    </weather>
//    <weather>
//    <date>2013-01-18</date>
//    <precipMM>1.9</precipMM>
//    <tempMaxC>11</tempMaxC>
//    <tempMaxF>51</tempMaxF>
//    <tempMinC>7</tempMinC>
//    <tempMinF>44</tempMinF>
//    <weatherCode>353</weatherCode>
//    <weatherDesc>
//    <value>Light rain shower</value>
//    </weatherDesc>
//    <weatherIconUrl>
//    <value>http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0009_light_rain_showers.png</value>
//    </weatherIconUrl>
//    <winddir16Point>NW</winddir16Point>
//    <winddirDegree>312</winddirDegree>
//    <winddirection>NW</winddirection>
//    <windspeedKmph>66</windspeedKmph>
//    <windspeedMiles>41</windspeedMiles>
//    </weather>
//    <weather>
//    <date>2013-01-19</date>
//    <precipMM>1.1</precipMM>
//    <tempMaxC>7</tempMaxC>
//    <tempMaxF>45</tempMaxF>
//    <tempMinC>6</tempMinC>
//    <tempMinF>43</tempMinF>
//    <weatherCode>176</weatherCode>
//    <weatherDesc>
//    <value>Patchy rain nearby</value>
//    </weatherDesc>
//    <weatherIconUrl>
//    <value>http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0009_light_rain_showers.png</value>
//    </weatherIconUrl>
//    <winddir16Point>NW</winddir16Point>
//    <winddirDegree>324</winddirDegree>
//    <winddirection>NW</winddirection>
//    <windspeedKmph>52</windspeedKmph>
//    <windspeedMiles>32</windspeedMiles>
//    </weather>
//    </data>
    NSLog(@"%@", str);
    if (NO) {
        NSMutableArray *weatherList = [NSMutableArray new];
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *items = [doc nodesForXPath:@"//weather" error:nil];
        for (GDataXMLElement *item in items) {
            Weather *weather = [Weather new];
            for(GDataXMLElement *wea in [item nodesForXPath:@"//weatherDesc/value" error:nil]) {
                weather.weatherDesc = wea.stringValue;
                break;
            }
            for(GDataXMLElement *wea in [item nodesForXPath:@"//weatherIconUrl/value" error:nil]) {
                weather.weatherImageUrl = wea.stringValue;
                break;
            }
            [weatherList addObject:weather];
            
        }
    } else {
        //TODO: KissXML
    }

    return nil;
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


/*


{
    "current_condition" =     (
                {
            cloudcover = 16;
            humidity = 59;
            "observation_time" = "09:09 PM";
            precipMM = "0.1";
            pressure = 1010;
            "temp_C" = 10;
            "temp_F" = 49;
            visibility = 10;
            weatherCode = 113;
            weatherDesc =             (
                                {
                    value = Clear;
                }
            );
            weatherIconUrl =             (
                                {
                    value = "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0008_clear_sky_night.png";
                }
            );
            winddir16Point = NW;
            winddirDegree = 316;
            windspeedKmph = 47;
            windspeedMiles = 29;
        }
    );
    request =     (
                {
            query = "Lat 32.35 and Lon 141.43";
            type = LatLon;
        }
    );
    weather =     (
                {
            date = "2013-01-15";
            precipMM = "1.8";
            tempMaxC = 12;
            tempMaxF = 53;
            tempMinC = 10;
            tempMinF = 50;
            weatherCode = 119;
            weatherDesc =             (
                                {
                    value = Cloudy;
                }
            );
            weatherIconUrl =             (
                                {
                    value = "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0003_white_cloud.png";
                }
            );
            winddir16Point = NNW;
            winddirDegree = 348;
            winddirection = NNW;
            windspeedKmph = 66;
            windspeedMiles = 41;
        },
                {
            date = "2013-01-16";
            precipMM = "0.6";
            tempMaxC = 13;
            tempMaxF = 56;
            tempMinC = 11;
            tempMinF = 51;
            weatherCode = 113;
            weatherDesc =  (
                {
                    value = Sunny;
                }
            );
            weatherIconUrl =             (
                                {
                    value = "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0001_sunny.png";
                }
            );
            winddir16Point = WNW;
            winddirDegree = 284;
            winddirection = WNW;
            windspeedKmph = 33;
            windspeedMiles = 21;
        },
                {
            date = "2013-01-17";
            precipMM = "0.5";
            tempMaxC = 14;
            tempMaxF = 56;
            tempMinC = 7;
            tempMinF = 44;
            weatherCode = 119;
            weatherDesc = (
                {
                    value = Cloudy;
                }
            );
            weatherIconUrl =             (
                                {
                    value = "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0003_white_cloud.png";
                }
            );
            winddir16Point = WNW;
            winddirDegree = 293;
            winddirection = WNW;
            windspeedKmph = 41;
            windspeedMiles = 25;
        },
                {
            date = "2013-01-18";
            precipMM = "1.9";
            tempMaxC = 11;
            tempMaxF = 51;
            tempMinC = 7;
            tempMinF = 44;
            weatherCode = 353;
            weatherDesc =  (
                  {
                    value = "Light rain shower";
                }
            );
            weatherIconUrl =             (
                                {
                    value = "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0009_light_rain_showers.png";
                }
            );
            winddir16Point = NW;
            winddirDegree = 312;
            winddirection = NW;
            windspeedKmph = 66;
            windspeedMiles = 41;
        },
                {
            date = "2013-01-19";
            precipMM = "1.1";
            tempMaxC = 7;
            tempMaxF = 45;
            tempMinC = 6;
            tempMinF = 43;
            weatherCode = 176;
            weatherDesc = (
                {
                    value = "Patchy rain nearby";
                }
            );
            weatherIconUrl =  (
                {
                    value = "http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0009_light_rain_showers.png";
                }
            );
            winddir16Point = NW;
            winddirDegree = 324;
            winddirection = NW;
            windspeedKmph = 52;
            windspeedMiles = 32;
        }
    );
}

 */
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
