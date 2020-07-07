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
    * pictures?
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



### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
