# Original App Design Project - README Template
===

# Sprout
## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
This app lets users more easily find ways to engage with social causes in their area. Allows users to quickly look up verified local organizations/nonprofits that match keywords, so they can find places to donate to or volunteer with. Users can see what organizations their friends have been involved with or which volunteer events they are attending. 
### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social/Informational
- **Mobile:** The app will use the user's location to filter for local organizations. They can also use the map to show users where certain orgs/events are. Users can also use the camera to take their profile pictures.
- **Story:** This allows users to be more active with social causes. It organizes several different methods of social activism so that the user can view them all in one place. It can also help the user see which causes their friends are involved with and possibly help people organize group events (protests/volunteering etc).
- **Market:** Many people have been using their social media platforms to post information about petitions, organizations, and organize protests. However, it is not always easy to gather all this information on social media. This app will work even if there are only a few users in the same area. They can look up local organizations and organize events in their area. Anyone looking to be more involved with social issues can use this app.
- **Habit:** Users will probably not check this app everyday, but they can check once in a while to see what events/orgs their friends have recently been involved with. Users will mostly consume the app, but they can also create posts to organize events with other users.
- **Scope:** I think this app will be interesting to build because there are several different core components to make this app fuction. There will need to be a page to search for organizations, a page to search for events, a page to see the user's profile, and ways to see what the user's friends are interested in.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User sees app icon in home screen and styled launch screen.
* User can sign in
* user can register
* User can search for organizations
    * get user location or have user type in location
    * make network requests to filter the organizations based on search 
    * implement table view to see overview of the organizations
* User can tap on a organization to see more details (details page)
    * location of the org (map)
    * mission/description statement
    * link to website (open web view)
* User can pull to refresh data
* User can see the tab bar to navigate between pages
    * org search, profile, events 
* User can see own profile
    * list friends and liked orgs
* User can like certain organizations or indicate they are going to an event
* user can add/follow friends
* User can see icons to indicate friends are involved with certain org/ going to events
* User can create events and share with friends/public
* user can take pictures and post on their profile
* User can logout
**Optional Nice-to-have Stories**

* Add tab section that users can search for news articles about the issues that interest them
* user can search for other users and see their profile
* timeline for the activity of friends
* calander for users to see when they have signed up for events
* user can see events that have conflicts
* infinite scrolling that keeps getting location further and further away

### 2. Screen Archetypes

* login/register
   * user can log in
* stream
   * user can look up organizations etc,
   * timeline for user/friend activity
   * searching for other users
* Details
    * detail page about events, orgs
* Profile
    * user can see own profile
    * user can see friend profile
* Creation
    * user can create a new event
* Calander
    * user can see all the events they are going to on a calander
* 

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* home feed
* Look Up orgs
* Profile 
* Calander

**Flow Navigation** (Screen to Screen)

* Login/register 
   * home
* Stream
   * details page for org or user or event
   * create event
* Creations
    * home after posting, 
* search screen
    * details to view whatever search results
    * back to home
* calander
    * click on events to view details
    * home
    * create an event

## Wireframes
[Add picture of your hand sketched wireframes in this section]
<img src="wireframe.png" width=600>

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
#### User
| Property  | Type    | Description|
|-----------|---------|------------|
|objectId   |String   |unique id for the user (default field)| 
|username   |string   |unique string for identifying user|
|password   |string   |password for the user account   |
|email      |string   |email of the user  |
|friends    |Array of Pointers to Users | reference to all of the user's friends|
|profileImage |File |profile image file for the user |
|likedOrgs |Array of Pointers to Organizations| reference to all the organizations the user has been involved with/starred |
|likedEvents |Array of Pointers to Events |reference to all the events that the user is interested/went to |
|location| string| city, zipcode, state, country of the user |
|createdAt | DateTime |date when user was created (default field) |

#### Organization
| Property  | Type    | Description|
|-----------|---------|------------|
|objectId   |String   |unique id for the organization (default field)| 
|ein |string |Employer Identification Number (EIN) |
|name |string |charity name |
|category |string | the category description of the charity |
|website |string  |link to the organization website |
|street |string| street address of orgaization|
|city |string |organization's city location |
|state |string | organization's state location |
|zipCode |Number |zipcode of the organization location |
|missionStatement|string |Organization Mission Statement |
|acceptingDonations|	string|	Organization Accepts Donations Yes=1, No=0 |

#### Volunteer Events
| Property  | Type    | Description|
|-----------|---------|------------|
|objectId   |String   |unique id for the volunteer events (default field)|
|title| String|shows the title of the opportunity|
|availability |string |shows when the opportunity is taking place |
|beneficiary |string |shows the beneficiary organization of the opportunity |
|categoryIds |Array of strings | shows the categories associated to this opportunity |
|contact |string  |contact information |
|description|string |shows the description of the opportunity |
| id|string |id the identifier of this event |
|imageUrl| string | url to image associated with the event |
|location |string  | location of the URL |
|requirements |JSON object |shows the requirements as a JSON array |
|skillsList | JSON object |shows the list of skills as a JSON array |
|vmUrl |string |url of the opportunity on VolunteerMatch |

#### Created Events
| Property  | Type    | Description|
|-----------|---------|------------|
|objectId   |String   |unique id for the created events (default field)|
|user |Pointer to User | user that created the event |
|name |string |name of the created event |
|time |DateTime | scheduled time of the event |
|location |String |location of the created event |
|description |string | details about the event |
|image |file |image associated with the event |
|createdAt | DateTime |date when event is created (default field) 

#### Post
| Property  | Type    | Description|
|-----------|---------|------------|
|objectId	|String	|unique id for the user post (default field)|
|author	|Pointer to User|	post author|
|organization	|String	|the organization the post is about|
|event	|String	|the event the post is about|
|text|	String	|post text by author|
|createdAt|	DateTime|	date when post is created (default field)|
|updatedAt|	DateTime|	date when post is last updated (default field)|
### Networking
- [Add list of network requests by screen ]
- login screen
    - GET the user associated with the login
    -  ```objective C
          [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil)
        {
            [self.alert setMessage:[NSString stringWithFormat: @"%@", error.description]];
            [self presentViewController:self.alert animated:YES completion:^{
                //nobthing
            }];
            NSLog(@"User log in failed: %@", error.localizedDescription);
        }
        else
        {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
        [self.activityIndicator stopAnimating];

    }];
         ```
- home screen/timeline
    - GET the posts for the timeline
    ``` objective C
     PFQuery *postQuery= [PFQuery queryWithClassName:@"Post"];
    self.postLimit+=20;//get 20 more posts each time
    postQuery.limit=self.postLimit;//limit 20 posts
    [postQuery orderByDescending:@"createdAt"];
    [postQuery includeKey:@"author"];

    [postQuery findObjectsInBackgroundWithBlock:^(NSArray<PFObject *> * _Nullable objects, NSError * _Nullable error) {
        if(error)
        {
            NSLog(@"Error loading posts: %@", error.description);
        }
        else
        {
            //NSLog(@"Success getting post %@", objects);
            self.posts=objects;
            [self.tableView reloadData];
        }
        self.isMoreDataLoading=NO;
        [self.refreshControl endRefreshing];
    }];
    ```
    - DELETE delete existing post
    ``` objective C
    PFObject deletePost= self.post
    [deletePost deleteInBackground]
    ```
    - POST create a new post for timeline
    ```objective c
    Post *newPost= [Post new];
    newPost.postText= post.text;
    newPost.author=[PFUser currentUser];
    [newPost saveInBackground];
    ```
- Create Event screen
    - POST create a new event for timeline
    ```objective c
    Event *newEvent= [Event new];
    newEvent.eventText= event.text;
    newEvent.author=[PFUser currentUser];
    [newEvent saveInBackground];
    ```
- Search Page
    - Get the events/orgs that the user or his/her friends have starred
- Profile page
    - GET current user's profile information
    ``` objective c
    PFQuery *profileQuery= [PFQuery queryWithClassName:@"User"];
    [profileQuery includeKey:@"events"];
    [profileQuery includeKey:@"organizations"];
    [profileQuery whereKey:@"author" equalTo:self.user];
    [profileQuery orderByDescending:@"createdAt"];
    [profileQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(error)
            NSLog(@"Error Loading profile: %@", error.localizedDescription);
        else{
            self.posts=objects;
            self.usernameLabel.text=self.user.username;
            self.postCount.text=[NSString stringWithFormat:@"%lu", self.posts.count];
            NSLog(@"Sucess loading profile, %@", self.usernameLabel.text );
        }
    }];
    ```
    - PUT update current user's information (profile pictures etc) 
    ```objective c
    self.user[@"profilePicture"]= [PFFileObject fileObjectWithName:profileImageName data:pImageData];
    // Dismiss UIImagePickerController to go back to your original view controller
    [self.user saveInBackground];
    ```

#### Requirement Demos
- Your app has multiple views
<img src='http://g.recordit.co/nLCvmZSLAJ.gif' alt='Multiple Views'/>
- Your app interacts with a database (e.g. Parse)
<img src='http://g.recordit.co/85XTlXW5fb.gif' alt='Parse Database for Posts and Events'/>
- You can log in/log out of your app as a user
<img src='http://g.recordit.co/Zd17UTic32.gif' alt='Log in and out'/>
- You can sign up with a new user profile
<img src='http://g.recordit.co/PWRhJuIXQ1.gif' alt='New User Signin'/>
- Somewhere in your app you can use the camera to take a picture and do something with the picture (e.g. take a photo and share it to a feed, or take a photo and set a user’s profile picture)
<img src='http://g.recordit.co/YD03L5Ni3w.gif' alt='Camera for Profile Pic'/>
- Your app integrates with a SDK (e.g. Google Maps SDK, Facebook SDK)
<img src='http://g.recordit.co/2iXI5s3puD.gif' alt='Google Maps SDK'/>
- Your app contains at least one more complex algorithm (talk over this with your manager)
- Your app uses gesture recognizers (e.g. double tap to like, e.g. pinch to scale)
<img src='http://g.recordit.co/QIHOzetNWr.gif' alt='Pinch to Zoom'/>
- Your app use an animation (doesn’t have to be fancy) (e.g. fade in/out, e.g. animating a view growing and shrinking)
<img src='http://g.recordit.co/KnHZZ45Rod.gif' alt='Private View Fade Out'/>
- Your app incorporates an external library to add visual polish
<img src='http://g.recordit.co/hm4547P20J.gif' alt='Empty Data Placeholder'/>
