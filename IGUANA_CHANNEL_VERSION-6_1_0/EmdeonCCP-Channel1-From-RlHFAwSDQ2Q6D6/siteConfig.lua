local conf = {}
local serverType = os.getenv('serverType')

conf['dev'] = {
   ['url'] = 'https://ccp329patchqa.cocentrix.com/',
   ['userName'] = [[cocentrix\biztalkservices]],
   ['passWord'] = 'Cocentrix11',
   ['htmlFolder'] = '/Users/ffarah/Desktop/MM/htmlFolder/',
   ['pdfFolder']  = '/Users/ffarah/Desktop/MM/pdfFolder/'}

conf['test'] = {
     ['url'] = 'https://ccp329patchqa.cocentrix.com/',
     ['userName'] = [[cocentrix\biztalkservices]],
     ['passWord'] = 'Cocentrix11',
     ['htmlFolder'] = '/Users/ffarah/Desktop/MM/htmlFolder/',
     ['pdfFolder']  = '/Users/ffarah/Desktop/MM/pdfFolder/'
   }

conf['prod'] = {
     ['url'] = 'https://ccp329patchqa.cocentrix.com/',
     ['userName'] = [[cocentrix\biztalkservices]],
     ['passWord'] = 'Cocentrix11',
     ['htmlFolder'] = '/Users/ffarah/Desktop/MM/htmlFolder/',
     ['pdfFolder']  = '/Users/ffarah/Desktop/MM/pdfFolder/'
   }

return conf[serverType]