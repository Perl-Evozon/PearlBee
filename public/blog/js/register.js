/**
 * Created by mihaelamarinca on 4/26/2016.
 */
$(document).ready(function(){
    //confirm register
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
        var errors = 0;
        var ascii = /^[\x21-\x7E]+/;
        var speciaCharacters = /[^\w\s\.@-]/g;

        //Email validation
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

        } else if (!(username).match(ascii)) { //      Username ascii validation
            $('.change_error').text('Username characters must be in ascii table range').css('color' , 'red');
            $('.error_ascii').slideToggle( "slow" );
            $('#usernameRegister').css('border-color' , 'red');
            $("#usernameRegister").keyup(function() {
                $('.error_ascii').fadeOut( "slow" );
                $('#usernameRegister').css('border-color' , '0');
            })
            errors++;

        } else if ((username).match(speciaCharacters)) { //      Username special URL char validation
            $('.change_error').text('Username characters must be in ascii table range').css('color' , 'red');
            $('.error_char').slideToggle( "slow" );
            $('#usernameRegister').css('border-color' , 'red');
            $("#usernameRegister").keyup(function() {
                $('.error_char').fadeOut( "slow" );
                $('#usernameRegister').css('border-color' , '0');
            })
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

    // register_done button
    $("#start-blogging").on('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        window.location = window.location.protocol + "//" + window.location.host + "/";
    });
});