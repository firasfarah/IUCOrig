-- This file contains the site configurations related to this interface
-- Make modifications to the configurations in development before 
--    deploying. 
-- Add the serverType variable as 'dev', 'test', or 'prod' in your 
--    settings > environment variables
-- Upon deployment, you will need to bring in MM.xml into your Iguana
--    working directory so that the password can be unencrypted

local encrypt    = require('encrypt.password')
local serverType = os.getenv('serverType')

--encrypt.save{config='MM.xml', password='REPLACEME', key='KJHwASkj2d3j3n'}

local conf = {}

conf['dev'] = {
   ['url'] = 'https://ccp329patchqa.cocentrix.com/',
   ['userName'] = [[cocentrix\biztalkservices]],
   ['passWord'] = encrypt.load{config='MM.xml', key='KJHwASkj2d3j3n'},
   ['htmlFolder'] = '/Users/ffarah/Desktop/MM/htmlFolder/',
   ['pdfFolder']  = '/Users/ffarah/Desktop/MM/pdfFolder/'}

conf['test'] = {
   ['url'] = 'https://ccp329patchqa.cocentrix.com/',
   ['userName'] = [[cocentrix\biztalkservices]],
   ['passWord'] = encrypt.load{config='MM.xml', key='KJHwASkj2d3j3n'},
   ['htmlFolder'] = '/Users/ffarah/Desktop/MM/htmlFolder/',
   ['pdfFolder']  = '/Users/ffarah/Desktop/MM/pdfFolder/'
}

conf['prod'] = {
   ['url'] = 'https://ccp329patchqa.cocentrix.com/',
   ['userName'] = [[cocentrix\biztalkservices]],
   ['passWord'] = encrypt.load{config='MM.xml', key='KJHwASkj2d3j3n'},
   ['htmlFolder'] = '/Users/ffarah/Desktop/MM/htmlFolder/',
   ['pdfFolder']  = '/Users/ffarah/Desktop/MM/pdfFolder/'
}

return conf[serverType]