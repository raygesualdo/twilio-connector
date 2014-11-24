# Requires
express = require 'express'
watchr  = require 'watchr'
xml     = require 'xml'

# Grab numbers
numbers = require './numbers'
watchr.watch
  path: './numbers.coffee'
  listener: (changeType, filePath, fileCurrentStat, filePreviousStat) ->
    console.log "#{filePath} has been #{changeType}d on " + new Date().toUTCString()

# Start server
app = module.exports = express()

# Handle getting number and parsing XML
prepareResponse = (resId) ->
  # Account for ".xml"
  resId = resId.replace /\.xml$/, ''
  
  # Return false if resId doens't exist
  return false if numbers[resId] is undefined

  xmlObject = 
    Response: [
      Dial: [
        _attr:
          callerId: numbers[resId].first
          record: true
        {
          'Number': numbers[resId].second
        }
      ]
    ]

  # Log access
  console.log "#{resId} was successfully requested on " + new Date().toUTCString()
  
  # Return XML
  xml xmlObject, true

# Typical route
app.get '/:resId', (req, res) ->
  response = prepareResponse req.param 'resId'
  if response is false 
    errorOut req, res 
  else 
    res.header 'Content-Type', 'text/xml'
       .send response

# Catchall route
app.get '/*', (req, res) ->
  errorOut req, res

# No results function
errorOut = (req, res) ->
  res.status 404
     .send 'Not all who wander are lost...but you are'
  
# Start server
server = app.listen 3000
console.log "Express server listening on port %d in %s mode", server.address().port, app.settings.env