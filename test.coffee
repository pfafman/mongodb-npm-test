#!/usr/bin/env /usr/local/bin/coffee


Fiber    = require('fibers')
Future   = require('fibers/future')
Mongo    = Future.wrap(require('mongodb').MongoClient)
moment   = require('moment')
colors   = require('colors')
_        = require('underscore')


dbUrl     = 'mongodb://localhost:27017/test'


Log = (args...) ->
  console.log(moment().format(), args...)


sleep = (ms) ->
  fiber = Fiber.current
  setTimeout ->
    fiber.run()
  , ms
  Fiber.yield()


Future.task ->

  db         = Mongo.connectFuture(dbUrl).wait()
  Collection = Future.wrap(db.collection('test'))

  Log("Db setup done".green)

  try
    rtn = Collection.updateFuture
      name: "Test"
    ,
      $set:
        processId: "XXX_XXX_XXX"
        version: "1.0"
        active: true
        updated: new Date()
    ,
      upsert: true
    .wait()
  catch e
    Log("Test Upsert Failed".red, e)

  Log("Test Upsert done".green)

  count = 0

  while true


    Log("Update".green)
    Collection.update
      name: "Test"
    ,
      $set:
        updated: new Date()

    count++
    Log("Updated #{count}".green)

    sleep(200)

  Log("exit".red)
  process.exit(0)

.detach()
