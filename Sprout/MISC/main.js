//Parse.Cloud.define("addFriend", (request) => {
//
//    const User = Parse.Object.extend('_User');
//    const query = new Parse.Query(User);
//
//    //query.equalTo("objectId", request.params.userId);
//
//    var friend=await query.get(request.params.userId);
//    console.log(friend);
//      // The object was retrieved successfully.
//    friend.add("friends", request.params.currentUserId);
//    friend.save(null,{useMasterKey:true});
//    return(friend);
//});
Parse.Cloud.define("hello", (request) => {
    const query = new Parse.Query("_User");
    var friend= query.get(request.params.userId);
    friend.set("friends", "!");

    return(friend);
});
//Parse.Cloud.define("test", (request) => {
//var query = new Parse.Query(Parse.User);
//   query.equalTo("objectId", request.params.objectId);
//   query.first({
//      success: function(object) {
//         object.set("test", "1");
//         object.save({useMasterKey:true});
//         return("Success Message");
//      },
//      error: function(error) {
//         return("Error Message");
//      }
//   });
//});
