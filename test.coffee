#!/usr/bin/env /usr/local/bin/coffee


Fiber    = require('fibers')
Future   = require('fibers/future')
Mongo    = Future.wrap(require('mongodb').MongoClient)
ObjectId = require('mongodb').ObjectID
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


insertOptions = {}

Future.task ->

  db       = Mongo.connectFuture(dbUrl).wait()
  Tests    = Future.wrap(db.collection('tests'))
  TestLogs = Future.wrap(db.collection('testLogs'))

  Log("Db setup done".green)

  try
    Collection.update
      name: "Test"
    ,
      $set:
        processId: "XXX_XXX_XXX"
        version: "1.0"
        active: true
        updated: new Date()
    ,
      upsert: true
  catch e
    Log("Test Upsert Failed".red, e)

  Log("Test Upsert done".green)

  count = 0

  while true

    starttime = new Date()

    Log("Tests Update".green)
    Tests.update
      name: "Test"
    ,
      $set:
        updated: new Date()

    count++
    Log("Tests Updated #{count}".green)

    sleep(20)

    Log("Logs insert")
    TestLogs.insertFuture
      _id: (new ObjectId()).toHexString()
      processId: 'test'
      starttime: starttime
      count: count
      status: 'running'
      date: new Date()
    , insertOptions
    .wait()  # ?
    Log("Logs inserted")

    sleep(100)

  Log("exit".red)
  process.exit(0)

.detach()
