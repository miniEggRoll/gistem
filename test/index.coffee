{assert}    = require 'chai'
debug       = require('debug')('gistem:test')
gistem      = require "#{__dirname}/../src/index"
{acc}       = require "#{__dirname}/../config"

fail = (param)->
    assert.fail param, null, "promise rejected, #{param}"

gist = new gistem(acc)

describe 'github gist api', ->
    describe 'prepare token', ->
        it 'get token by user password', ->
            resolver = (param)->
                assert.isString param
            gist.init()
            .then resolver, fail, debug

    describe 'read gists data', ->
        it 'list gists', ->
            @timeout 2500
            gist.list()
            .then (arr)->
                assert.isArray arr
                arr.forEach assert.isObject

        it 'get a single gist', ->
            @timeout 2500
            id = 1
            gist.get id
            .then assert.isObject

    describe 'edit gist', ->
        id = ''
        it 'create a gist', ->
            @timeout 3000
            payload =
                'public': false
                'description': 'desc'
                'files': 
                    'file2.txt': 
                        'content': 'test'

            resolver = (result)->
                id = result.id
                assert.isObject result

            gist.create payload
            .then resolver, fail, debug

        it 'edit a gist', ->
            @timeout 3000
            payload =
                'description': 'desc'
                'files': 
                    'file2.txt': null
                    'file.txt': 
                        'content': 'aa'

            gist.edit id, payload
            .then assert.isObject, fail, debug

        it 'remove a gist', ->
            @timeout 20000
            resolver = (code)-> assert.strictEqual code, 204
            gist.remove id
            .then resolver, fail, debug

