// Facebook
$(document).ready(function() {

    // Load the SDK asynchronously
    (function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0];
        if (d.getElementById(id)) return;
        js = d.createElement(s);
        js.id = id;
        js.src = "//connect.facebook.net/en_US/sdk.js";
        fjs.parentNode.insertBefore(js, fjs);
    }(document, 'script', 'facebook-jssdk'));

    // Initialize facebook integration & register event handlers
    fbAsyncInit = function(){
        FB.init({
            appId: '561229140719641',
            cookie: true,
            xfbml: true,
            version: 'v2.6'
        });

        FB.Event.subscribe('auth.login', function(response) {
            // window.location.reload();
            console.log("Login event");
        });

        FB.Event.subscribe('auth.logout', function(response) {
            // window.location.reload();
            console.log("Logout event");
        });

    };

    // This is called with the results from from FB.getLoginStatus().
    function statusChangeCallback(response) {
        console.log('statusChangeCallback');
        console.log(response);

        if (response.status === 'connected') {
            // Logged into your app and Facebook.
            testAPI();
        } else if (response.status === 'not_authorized') {
            // The person is logged into Facebook, but not your app.
            document.getElementById('status').innerHTML = 'Please log into this app.';
        } else {
            // The person is not logged into Facebook, so we're not sure if
            // they are logged into this app or not.
            document.getElementById('status').innerHTML = 'Please log into Facebook.';
        }
    };

    // This function is called when someone finishes with the Login
    // Button.  See the onlogin handler attached to it in the sample
    // code below.
    checkLoginState = function() {
        console.log("Checking login state...");
        FB.getLoginStatus(function(response) {
            statusChangeCallback(response);
        });
    };

    // Test the fb api
    function testAPI() {
        console.log('Welcome!  Fetching your information.... ');
        FB.api('/me', function(response) {
            console.log('Successful login for: ' + response.name);
            document.getElementById('status').innerHTML = 'Thanks for logging in, ' + response.name + '!';
            console.log("Your userID is " + response.id);
            console.log("Basically we should save the userID in the backend and afterwards, verify if the logged in user authenticates accordingly.")

        });
    };


})

// function myFunction() {
//   url = '/smlogin?socialMediaService=openid' + window.location.search;
//   return url;
// }
// // Twitter
//
// $('a[rel=popover]').popover({
// html: 'true',
// placement: 'bottom'
// });

$('.btn-facebook').on('click', function() {
  $('#FacebookCollapse:visible').length ?  $('.fa-facebook').text(' Connect with Facebook') : $('.fa-facebook').text(' Disconnect Facebook');
});

$('.btn-twitter').on('click', function() {
$('#TwitterCollapse:visible').length ?  $('.fa-twitter').text(' Connect with Twitter') : $('.fa-twitter').text(' Disconnect Twitter');
});
$('.btn-linkedin').on('click', function() {
$('#LinkedInCollapse:visible').length ?  $('.fa-linkedin').text(' Connect with LinkedIn') : $('.fa-linkedin').text(' Disconnect LinkedIn');
});
$('.btn-google').on('click', function() {
$('#GoogleCollapse:visible').length ?  $('.fa-google').text(' Connect with Google') : $('.fa-google').text(' Disconnect Google');
});
$('.btn-github').on('click', function() {
$('#GithubCollapse:visible').length ?  $('.fa-github').text(' Connect with Github') : $('.fa-github').text(' Disconnect Github');
});

// Google


// Github


// LinkedIn


// OpenID
