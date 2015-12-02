// Replace the classes for the google code prettefier to work

$(document).ready(function() {

    $('pre').each(function(){ 
        var class_name = $(this).attr('class');
        $(this).className = $(this).attr('class', class_name.replace(/brush:/,'prettyprint lang-').replace(/;$/,'')); 
    });
    
    $(".reply_comment_div").each(function(){
        $(this).hide();
        $(this).find('form').prepend('<input type="hidden" value="' + this.id + '" name="in_reply_to" />');
        $(this).find('div .title').replaceWith( "<h5>Reply</h5>" );
        
        if ($(this).attr('id') == $(this).attr('div_set')) {
            // repopulate the submitted form
            $(this).find('input[id=name]').val($(this).attr('field_fullname'));
            $(this).find('input[id=email]').val($(this).attr('field_email'));
            $(this).find('input[id=website]').val($(this).attr('field_website'));
            $(this).find('textarea[name=comment]').val($(this).attr('field_comment'));
            $( this ).show(); //if this was submitted, show it again
        } else {
            //clear info from this kind of fields
            $(this).find('input[id=name]').val('');
            $(this).find('input[id=email]').val('');
            $(this).find('input[id=website]').val('');
            $(this).find('textarea[name=comment]').val('');
        }
    });
    
    $(".comment_reply").on('click', function( aaa ){
        var reply_comm = this.id + '_div';
        
        if ($("#" + reply_comm).is(":visible")) {
             $( "#" + reply_comm ).hide();
        } else {
            $( "#" + reply_comm ).show();
        }
    });
	
//	Blog start overlay
	if ($(".blog-start").hasClass("show")) {
		$("body").addClass("active-overlay");
	}
	
	$("#close_overlay").on('click', function() {
		$(".blog-start").slideToggle( "slow" );
		$(".blog-start").removeClass("show");
		$("body").removeClass("active-overlay");
	});

//    Register
  $("#confirmPasswordRegister").keyup(function() {
    if( $(this).val() !== $("#passwordRegister").val() ){
        $("#confirmPasswordRegister").addClass('error');
    } else {
        $("#confirmPasswordRegister").removeClass('error');                      
    }  
  });

//Form Register validation
  
  function validationForm(event) {    
      var email = $("#emailRegister").val();
      var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
      var username = $("#usernameRegister").val();
      var name = $("#displayNameRegister").val();
      var password = $("#passwordRegister").val();
      var confirmPassword = $("#confirmPasswordRegister").val();
      var terms = $("#confirmTerms").is(":checked");
      var errors = 0;
    
//      Email validation
      $('#register_form input').css('border-color' , '#CCC').removeClass('error');
    
      if (email.length < 1) { //      Email validation
        $('.change_error').text('Email field is necesary').css('color' , 'red');        
        $('#emailRegister').css('border-color' , 'red');
        errors++;
        
      } else if (!(email).match(emailReg)) { //  Email Regex validation
        $('.change_error').text('Invalid Email').css('color' , 'red');        
        $('#emailRegister').addClass('error');                
        errors++;
        
      } else if (username.length < 3) { //      Username validation
        $('.change_error').text('Username field is necesary').css('color' , 'red');        
        $('#usernameRegister').css('border-color' , 'red');        
        errors++;
        
      } 
      else if (name.length < 3) { //      Display name validation
        $('.change_error').text('Display name field is necesary').css('color' , 'red');        
        $('#displayNameRegister').css('border-color' , 'red');
        errors++;
        
      } 
      else if (password.length < 3) { //      Password validation
        $('.change_error').text('Password is necesary').css('color' , 'red');        
        $('#passwordRegister').css('border-color' , 'red');
        errors++;
        
      } 
      else if (confirmPassword !== password) { //      Confirm password validation
        $('.change_error').text("Confirm password doesn't mach with password").css('color' , 'red');        
        $('#confirmPasswordRegister').css('border-color' , 'red');
        errors++;
        
      } 
      else if (!terms) { //      Checkbox validation
        $('.change_error').text("Terms and conditions checkbox is necesary").css('color' , 'red');         
        errors++;
        
      }
    
      if (errors === 0) {
        return true;
      }
    
      return false;
    }
    
  $("#register_form").on('submit', function() {
    if (validationForm()) // Calling validation function.
      {      
        $("#register_form").submit(); // Form submission.
      } else {
      return false;
      }
    });


//	Sign up
	$('.sign-up').css('min-height',$(window).height()-80);
	$(window).resize(function(){
	  $('.sign-up').css('min-height',$(window).height()-80);
	});
  
});