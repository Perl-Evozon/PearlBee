/**
 * Created by mihaelamarinca on 4/25/2016.
 */

$(document).ready(function() {
	
//	if ($("#image_upload_preview").attr('src') == "/blog/img/male-user.png") {
//    $(".picture-btn").css("margin-top", "170px");
//	}
//	
// Image upload preview modal cancel button
    $(".modal-footer .cancel-img").on('click', function(){
        var src = $( ".credentials .bubble" ).parent().find('img').attr('src');
        $('#image_upload_preview').attr('src', src);

        if (!$('#image_upload_preview').hasClass('defaultAvatar')) {
            $('#image_upload_preview').addClass('hidden');
            $('#croppie-avatars').croppie('bind', {
                url: src
            }, function() {
                $('#croppie-avatars .cr-image').css({
                    'transform-origin': '20px 20px 0',
                    '-webkit-transform-origin': '20px 20px 0',
                    'transform': 'translate3d(20px, 20px, 0)',
                    'width': '140px',
                    'height': '140px'
                });
                $('#croppie-avatars .cr-slider').attr('min', 1).attr('max', 2).val(1);
            });

            $('#croppie-avatars').removeClass('hidden');
        } else {
            $('#croppie-avatars').addClass('hidden');
            $('#image_upload_preview').removeClass('hidden');
            $('#image_upload_preview').hasClass('defaultAvatar').show();
        }
        $('#upload-img').get(0).reset();
    });

    $('#croppie-avatars').croppie({
        url: $('#image_upload_preview').attr('src'),
        viewport: {
            width: 140,
            height: 140,
            type: 'circle'
        },
        boundary: {
            width: 180,
            height: 180
        }
    });

    $('#changeImg').on('show.bs.modal', function() {
        $('#croppie-avatars .cr-image').css({
            'transform-origin': '20px 20px 0',
            'transform': 'translate3d(20px, 20px, 0)',
            'width': 140,
            'height': 140
        });
        $('#croppie-avatars .cr-slider').attr('min', 1).attr('max', 2);
    });

    if (!$('#image_upload_preview').hasClass('defaultAvatar')){
        $('#image_upload_preview').addClass('hidden');
    } else {
        $('#croppie-avatars').addClass('hidden');
    }

    //my profile Email validation
    function isValidEmailAddress(emailAddress) {
        var error = 0;
        var email = $("#user_email").val();
        var pattern = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
        //return pattern.test(emailAddress);

        if (!(email).match(pattern)) {
            $('#user_email').addClass('error');
            error++;
        }
        if (error === 0) {
            return true;
        }
        else {
            return false;
        }
    };

    $("#changeSetings").on('submit', function() {
        if (isValidEmailAddress()) // Calling validation function.
        {
            $("#changeSetings").submit(); // Form submission.
        } else {
            $('#user_email').css('border-color' , 'red');
            return false;
        }
    });

    // Image upload preview
    function readURL(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                $('#image_upload_preview').attr('src', e.target.result).addClass('hidden');
                var imageStyle = $('#croppie-avatars .cr-image').get(0).style;
                imageStyle.removeProperty('transform-origin');
                imageStyle.removeProperty('transform');
                imageStyle.removeProperty('width');
                imageStyle.removeProperty('height');

                $('#croppie-avatars').croppie('bind', {
                    url: e.target.result
                }, function() {
                    var minZoom = +$('#croppie-avatars .cr-image')[0].style['transform']
                        .split(")")
                        .find(function(item) {
                            return item.indexOf('scale') >=0
                        }).replace("scale(", '');

                    minZoom = (minZoom < 1) ? minZoom : 1;

                    $('#croppie-avatars .cr-slider').attr('min', minZoom).attr('max', 2);
                }).removeClass('hidden');
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    function getOrientation(file, callback) {
        var reader = new FileReader();
        reader.onload = function(e) {

            var view = new DataView(e.target.result);
            if (view.getUint16(0, false) != 0xFFD8) return callback(-2);
            var length = view.byteLength, offset = 2;

            while (offset < length) {
                var marker = view.getUint16(offset, false);
                offset += 2;
                if (marker == 0xFFE1) {
                    if (view.getUint32(offset += 2, false) != 0x45786966) return callback(-1);
                    var little = view.getUint16(offset += 6, false) == 0x4949;
                    offset += view.getUint32(offset + 4, little);
                    var tags = view.getUint16(offset, little);
                    offset += 2;
                    for (var i = 0; i < tags; i++)
                        if (view.getUint16(offset + (i * 12), little) == 0x0112)
                            return callback(view.getUint16(offset + (i * 12) + 8, little));
                }
                else if ((marker & 0xFF00) != 0xFF00) break;
                else offset += view.getUint16(offset, false);
            }

            return callback(-1);
        };
        reader.readAsArrayBuffer(file.slice(0, 64 * 1024));
        //	console.log(orientation);
    }

    var input = document.getElementById('file-upload');
    input.onchange = function(e) {
        getOrientation(input.files[0], function(orientation) {
            if (orientation === 6) {
                $(".croppie-container .cr-boundary").rotate({animateTo:90});
            }
        });
    }

    $("#file-upload").change(function () {
        readURL(this);
        //getOrientation(this);
    });

    //delete image
    $(".modal-footer .delete-img").on('click', function(){
        var themeinitial = $('#cmn-toggle-4').is(':checked');
        $( "#file-upload" ).val("");
        if (themeinitial === false){
            $('#image_upload_preview').attr('src', '/blog/img/male-user.png');
        } else if (themeinitial === true) {
            $('#image_upload_preview').attr('src', '/blog/img/male-user-light.png');
        }

        $('[name=action_form]').val('delete');

        $('#image_upload_preview').removeClass('hidden');
        $('#croppie-avatars').addClass('hidden');
    });


    // Validation file input for img only
    function stringEndsWithValidExtension(stringToCheck, acceptableExtensionsArray, required) {
        if (required == false && stringToCheck.length == 0) { return true; }
        for (var i = 0; i < acceptableExtensionsArray.length; i++) {
            if (stringToCheck.toLowerCase().endsWith(acceptableExtensionsArray[i].toLowerCase())) { return true; }
        }
        return false;
    }

    String.prototype.startsWith = function (str) { return (this.match("^" + str) == str) }
    String.prototype.endsWith = function (str) { return (this.match(str + "$") == str) }

    //submitting upload picture form
    $(".save-img").click(function() {
        if (!stringEndsWithValidExtension($("[id*='file-upload']").val(), [".png", ".jpeg", ".jpg", ".bmp", ".gif"], false)) {
            $('.error_file').fadeIn().delay(3000).fadeOut(2000);
            return false;
        }
        //croppie avatars
        var cropData= $('#croppie-avatars').croppie('get');
        var topLeftX = cropData.points[0];
        var topLeftY = cropData.points[1];
        var bottomRightX = cropData.points[2];
        var bottomRightY = cropData.points[3];

        $('#upload-img [name=top]').val(topLeftY);
        $('#upload-img [name=left]').val(topLeftX);
        $('#upload-img [name=width]').val(bottomRightX - topLeftX);
        $('#upload-img [name=height]').val(bottomRightY - topLeftY);
        $('#upload-img [name=zoom]').val(cropData.zoom);

        var widthCrop = $('#upload-img').find('input[name="width"]').val();
        var heighthCrop = $('#upload-img').find('input[name="height"]').val();
        var top = $('#upload-img').find('input[name="top"]').val();
        var left = $('#upload-img').find('input[name="left"]').val();

        if (widthCrop !== '0' || heighthCrop !== '0' || top !== '0' || left !== '0') {
            $('[name=action_form]').val('crop');
        }

        $("#upload-img").submit();
    });

    //  My profile password confirmation
    $("#confirmNewPassword").keyup(function() {
        if( $(this).val() !== $("#newPassword").val() ){
            $("#confirmNewPassword").addClass('error');
        } else {
            $("#confirmNewPassword").removeClass('error');
        }
    });

});