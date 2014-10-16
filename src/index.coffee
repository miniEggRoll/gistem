Q           = require 'q'
https       = require 'https'
debug       = require('debug')('gistem:api')
{chunk}     = require 'goodLuckChunk'

class gistem
    constructor: ({@user, @password})->
    init: ->
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: '/authorizations'
            auth: "#{@user}:#{@password}"
            method: 'GET'
            headers: 
                'User-Agent': @user
        debug @user, @password
        Q.Promise (resolve, reject, notify)=>
            req = https.request reqOpts, (res)=>
                if res.statusCode is 200
                    notify 'get token ok'
                    res.pipe new chunk()
                    .on 'data', (data)=>
                         result = JSON.parse data.toString()
                         .filter((a)-> a.app.name is 'gistem (API)')[0]
                         
                         if result
                            @token = result.token
                            resolve @token 
                         else 
                            @_createToken({@user, @password}).then resolve, reject, notify
                else 
                    reject res.statusCode
                    do res.abort
            do req.end
    get: (id)->
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: "/gists/#{id}"
            auth: "#{@token}:x-oauth-basic" if @token
            method: 'GET'
            headers: 
                'User-Agent': @user

        Q.Promise (resolve, reject, notify)=>
            req = https.request reqOpts, (res)=>
                if res.statusCode is 200
                    notify "get gist #{id}"
                    res.pipe new chunk()
                    .on 'data', (data)->
                        resolve JSON.parse data.toString()
                else
                    reject res.statusCode
                    do res.abort
            do req.end
    create: (payload)->
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: "/gists"
            auth: "#{@token}:x-oauth-basic" if @token
            method: 'POST'
            headers: 
                'User-Agent': @user

        Q.Promise (resolve, reject, notify)=>
            req = https.request reqOpts, (res)=>
                if res.statusCode is 201
                    notify "gist created"
                    res.pipe new chunk()
                    .on 'data', (data)->
                        debug JSON.parse data.toString()
                        resolve JSON.parse data.toString()
                else
                    reject res.statusCode
                    do req.abort
            req.end JSON.stringify payload
    edit: (id, payload)->
        body = JSON.stringify payload
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: "/gists/#{id}"
            auth: "#{@token}:x-oauth-basic"
            method: 'PATCH'
            headers: 
                'User-Agent': @user
                'Content-Length': body.length
        debug reqOpts

        Q.Promise (resolve, reject, notify)=>
            notify id, payload
            req = https.request reqOpts, (res)=>
                if res.statusCode is 200
                    notify "gist edited"
                    res.pipe new chunk()
                    .on 'data', (data)=>
                        debug JSON.parse data.toString()
                        resolve JSON.parse data.toString()
                else
                    reject res.statusCode
                    do req.abort
            req.end body
    remove: (id)->
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: "/gists/#{id}"
            auth: "#{@token}:x-oauth-basic"
            method: 'DELETE'
            headers: 
                'User-Agent': @user

        Q.Promise (resolve, reject, notify)=>
            notify id
            req = https.request reqOpts, (res)=>
                code = res.statusCode
                do req.abort
                if code is 204
                    notify 'gist removed'
                    resolve code
                else
                    reject code
            do req.end
    _createToken: ->
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: '/authorizations'
            auth: "#{@user}:#{@password}"
            method: 'POST'
            headers: 
                'User-Agent': @user
        Q.Promise (resolve, reject, notify)=>
            req = https.request reqOpts, (res)=>
                if res.statusCode is 201
                    notify 'token created'
                    res.pipe new chunk()
                    .on 'data', (data)->
                        {token} = JSON.parse data.toString()
                        resolve token
                else 
                    reject res.statusCode
                    do req.abort

            req.end JSON.stringify {note: 'gistem', scopes: ['gist']}
    list: ->
        reqOpts = 
            hostname: 'api.github.com'
            port: '443'
            path: "/gists"
            auth: "#{@token}:x-oauth-basic" if @token
            method: 'GET'
            headers: 
                'User-Agent': @user
        Q.Promise (resolve, reject, notify)=>
            req = https.request reqOpts, (res)=>
                if res.statusCode is 200
                    notify 'list gist ok'
                    res.pipe new chunk()
                    .on 'data', (data)->
                        resolve JSON.parse data.toString()
                else 
                    reject res.statusCode
                    do res.abort
            do req.end

module.exports = gistem
