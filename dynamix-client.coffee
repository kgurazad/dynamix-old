$(document).ready ->

    room = window.location.pathname.substring(1)
    try
        name = JSON.parse(document.cookie).username
    catch error
        name = 'comrade popov'
    finally
        if name == ''
            name = 'comrade popov'
    
    ws = new WebSocket('wss://dynamix-coordinator.herokuapp.com')
    $('#right').prepend '<ul id="users">users</ul>'
    $('#right').prepend '<input type="text" placeholder="name" id="namebox" class="form-control">'

    $(document).keypress ->
        
        if name == ''
            name = 'comrade popov'

        if event.which == 13
            if document.getElementById('chatbox') != null
                ws.send JSON.stringify({
                    room: room,
                    msgContent: {
                        category: 'chat',
                        value: document.getElementById('chatbox').value,
                        person: name
                    }
                })
                $('#chatbox').remove()
      
            else if document.getElementById('buzzbox') != null
                ws.send JSON.stringify({
                    room: room
                    msgContent: {
                        person: name
                        category: 'buzz'
                        value: document.getElementById('buzzbox').value
                    }
                })
                $('#buzzbox').remove()
      
            else
                oname = name
                name = document.getElementById('namebox').value
                document.cookie = JSON.stringify({username:name})
                ws.send(JSON.stringify({room:room, msgContent:{category:"name change", value:name, old:oname}}))
            
            $('body').focus()
    
        else if document.activeElement.tagName != 'BODY'
            # do nothing! yay
    
        else if event.which == 32
            $('#main').prepend '<input type="text" placeholder="buzz" id="buzzbox" class="form-control">'
            setTimeout (->
                $('#buzzbox').focus()
            ), 120
    
        else if event.which == 110
            ws.send JSON.stringify({
                room: room
                msgContent: {
                    person: name
                    category: 'next'
                    value: 'this is for sure not the correct answer'
                }
            })
            
        else if event.which == 47
            $('#main').prepend '<input type="text" placeholder="chat" id="chatbox" class="form-control">'
            setTimeout (->
                $('#chatbox').focus()
            ), 120

    ws.onmessage = (event) ->
        return if event.data == 'pong'
        return if JSON.parse(event.data).room != room
        x = JSON.parse(event.data).msgContent
        if x.category == 'chat'
            x = '<span style="font-weight: bold;">' + x.person + '</span> ' + x.value
        else if x.category == 'buzz'
            x = '<span style="font-weight: bold;">' + x.person + '</span> ' + x.value + ' ' + x.ver
        else if x.category == 'entry'
            y = x.users
            x = '<span style="font-style: italic;">' + x.person + ' joined the room</span>'
        else if x.category == 'exit'
            y = x.users
            x = '<span style="font-style: italic;">' + x.person + ' left the room</span>'
        else if x.category == 'name change'
            y = x.users
            x = '<span style="font-style: italic;">' + x.old + ' changed name to ' + x.value + '</span>'
        else if x.category == 'kick'
            y = x.users;
            x = '<span style="font-style: italic;">' + x.person + ' was kicked from the room</span>'
            
        $('#main').prepend '<div class="container-fluid">' + x + '</div>'
        if y?
            $('#users').empty()
            $('#users').append 'users'
            for user in y
                $('#users').append '<li>'+user+'</li>'

    ws.onopen = (event) ->
        ws.send(JSON.stringify({greeting:'hello world!', room:room, msgContent:{person:name, category:'greeting'}}))
        pinger = setInterval ping, 45000
        
    ws.onclose = (event) ->
        $('#main').prepend '<div class="container-fluid">you have been disconnected from the server</div>'
        
    ping = ->
        ws.send('ping')