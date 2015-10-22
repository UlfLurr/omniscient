root = exports ? this

serializeForm = (form) ->
    hash = {}
    for item in form.serializeArray()
        hash[item.name] = item.value
    hash


root.init_users_form = ()->
    $('#user-submit').hide();
    $('#sign-up-button').show();

root.encryptsignup = ()->
    $('#sign-up-button').hide()
    uname = $("#user_name").val()
    
    name_as_salt = uname.trim().replace(/ +/g, " ").toLowerCase();

    hmac = forge.hmac.create();
    hmac.start('sha256', name_as_salt);
    hmac.update($('#user_password').val());
    hashed1 = hmac.digest().toHex();

    publicKey1 = forge.pki.publicKeyFromPem($("#publickey").val());
    salt = $("#salt").val()
    encrypted1 = forge.util.bytesToHex(publicKey1.encrypt(hashed1 + '|' + salt));

    data = serializeForm($('form'))
    delete  data['user[password]']
    data['user[password_encrypted]'] = encrypted1

    if $('#user_password_confirmation').val()
        hmac = forge.hmac.create();
        hmac.start('sha256', name_as_salt);
        hmac.update($('#user_password_confirmation').val());
        hashed2 = hmac.digest().toHex();
        encrypted2 = forge.util.bytesToHex(publicKey1.encrypt(hashed2 + '|' + salt));
        delete  data['user[password_confirmation]']
        data['user[password_confirmation_encrypted]'] = encrypted2

    method = 'post'
    if $('input[name="_method"]').val()
        method = $('input[name="_method"]').val()

    $.ajax $('form').attr('action'),
                type: method
                dataType: 'json'
                data: data
                error: (jqXHR, textStatus, errorThrown) ->
                    alert("Ajax request failed");
                    $('#sign-up-button').show()
                success: (data, textStatus, jqXHR) ->
                        $("#sign-up-response").html(data.html)
                        if data.redirect
                            Turbolinks.visit($('#redirect-to-user').attr('href'));
                        else
                            $('#sign-up-button').show()
                            $('#user-submit').hide()
