local conf = require('siteConfig')
local retry = require('retry')

local ccpAuth = {}

function ccpAuth.prepHeader() 
      
   -- (1) Gets the URL of AD FS server
   local adfsUrl = ccpAuth.getADFS(conf.url)
   
   -- (2) Get tokens from server
   local token1,token2,keyId,x509IssuerName,x509SerialNum,binarySecret = 
                        ccpAuth.getTokens(conf.url,adfsUrl,conf.userName,conf.passWord)
   
   -- (3) Prep elements of the Soap Header
   local now = os.ts.gmtime()
   local created = now - 60*1
   local expires = now + 60*60
   local created = os.ts.gmdate('%Y-%m-%dT%XZ',created)
   local expires = os.ts.gmdate('%Y-%m-%dT%XZ',expires)
   local timestamp = "<u:Timestamp xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" u:Id=\"_0\"><u:Created>"
                      ..created.."</u:Created><u:Expires>"..expires.."</u:Expires></u:Timestamp>"
   local utfStamp    = iconv.ascii.enc(timestamp)
   local hashedBytes = crypto.digest{data=timestamp,algorithm='SHA1'}
   local digestValue = filter.base64.enc(hashedBytes)
   local signedInfo = ccpAuth.getSignedInfo(digestValue)
   local binarySecretBytes = filter.base64.dec(binarySecret)
   local hmacHash = crypto.hmac{data=signedInfo,key=binarySecretBytes,algorithm='sha1'}
   local signatureValue = filter.base64.enc(hmacHash)
   
   -- (4) Create the header 
  
   local header = ccpAuth.createSoapHeaderOnPremise(conf.url,keyId, token1, token2, x509IssuerName,
                    x509SerialNum, signatureValue, digestValue, created, expires)
   local urnAddress = conf.url..'XRMServices/2011/Organization.svc'
  
   return urnAddress,header
end

-- Gets the name of the ADFS server CRM uses for authenticaion
-- Parameter = The url of the CRM
-- Returns   = The AD FS server URL
function ccpAuth.getADFS(url) 
   local newUrl = url..'XrmServices/2011/Organization.svc?wsdl=wsdl0'
  -- local newUrl2 = 'https://ccp329qa.cocentrix.com/XRMServices/2011/Organization.svc?singleWsdl'
   trace(newUrl)
   local Res = retry.call{func=net.http.get,arg1={url=newUrl,live=true},retry=3,pause=30}
   local xrm = xml.parse{data=Res}
   local adfsServer = xrm["wsdl:definitions"]["wsp:Policy"]["wsp:ExactlyOne"]
                         ["wsp:All"]["ms-xrm:AuthenticationPolicy"]
                         ["ms-xrm:SecureTokenService"]["ms-xrm:Identifier"]:nodeText():gsub('http','https')
   return adfsServer
end

function ccpAuth.getTokens(url,adfsUrl,username,password)
   -- (1) Build out initial request to get tokens
   local now = os.ts.gmtime()
   local inhour = now + 60*60
   local nowform = os.ts.gmdate('%Y-%m-%dT%XZ',now)
   local inhourform = os.ts.gmdate('%Y-%m-%dT%XZ',inhour)
   
   local urnAddress = url..'XRMServices/2011/Organization.svc'
   local usernameMixed = adfsUrl..'/13/usernamemixed'
   local xmlTable = {}
   xmlTable[1] = "<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:a=\"http://www.w3.org/2005/08/addressing\">"
   xmlTable[2] = "<s:Header>"
   xmlTable[3] = "<a:Action s:mustUnderstand=\"1\">http://docs.oasis-open.org/ws-sx/ws-trust/200512/RST/Issue</a:Action>"
   xmlTable[4] = "<a:MessageID>urn:uuid:"..util.guid(128).."</a:MessageID>"  
   xmlTable[5] = "<a:ReplyTo>"
   xmlTable[6] = "<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>"
   xmlTable[7] = "</a:ReplyTo>"
   xmlTable[8] = "<Security s:mustUnderstand=\"1\" xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\">"
   xmlTable[9] = "<u:Timestamp  u:Id=\""..util.guid(128).."\">"
   xmlTable[10] = "<u:Created>"..nowform.."</u:Created>"
   xmlTable[11] = "<u:Expires>"..inhourform.."</u:Expires>" 
   xmlTable[12] = "</u:Timestamp>"
   xmlTable[13] = "<UsernameToken u:Id=\""..util.guid(128).."\">"
   xmlTable[14] = "<Username>"..username.."</Username>"
   xmlTable[15] = "<Password Type=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText\">"
                        ..password.."</Password>"
   xmlTable[16] = "</UsernameToken>"
   xmlTable[17] = "</Security>"
   xmlTable[18] = "<a:To s:mustUnderstand=\"1\">"..usernameMixed.."</a:To>"
   xmlTable[19] = "</s:Header>"
   xmlTable[20] = "<s:Body>"
   xmlTable[21] = "<trust:RequestSecurityToken xmlns:trust=\"http://docs.oasis-open.org/ws-sx/ws-trust/200512\">"
   xmlTable[22] = "<wsp:AppliesTo xmlns:wsp=\"http://schemas.xmlsoap.org/ws/2004/09/policy\">"
   xmlTable[23] =  "<a:EndpointReference>"
   xmlTable[24] = "<a:Address>"..urnAddress.."</a:Address>"
   xmlTable[25] = "</a:EndpointReference>"
   xmlTable[26] = "</wsp:AppliesTo>"
   xmlTable[27] = "<trust:RequestType>http://docs.oasis-open.org/ws-sx/ws-trust/200512/Issue</trust:RequestType>"
   xmlTable[28] = "</trust:RequestSecurityToken>"
   xmlTable[29] = "</s:Body>"
   xmlTable[30] = "</s:Envelope>"
   
   local xmlStr = ''
   for k,v in pairs(xmlTable) do 
      xmlStr = xmlStr..v
   end
   trace(usernameMixed,xmlStr)
   -- (2) Make the call to get the tokens 
   local resp1 = retry.call{func=net.http.post,arg1={url = usernameMixed,headers={['content-type'] = 'application/soap+xml; charset=UTF-8'},body=xmlStr,live=true},retry=3,pause=30}
  
   -- (3) Extract tokens
   local resp1xml = xml.parse{data = resp1}
   
   local token1 = resp1xml["s:Envelope"]["s:Body"]["trust:RequestSecurityTokenResponseCollection"]["trust:RequestSecurityTokenResponse"]
                 ["trust:RequestedSecurityToken"]["xenc:EncryptedData"].KeyInfo["e:EncryptedKey"]
                 ["e:CipherData"]["e:CipherValue"]:nodeText()
   
   local token2 = resp1xml["s:Envelope"]["s:Body"]["trust:RequestSecurityTokenResponseCollection"]["trust:RequestSecurityTokenResponse"]
                 ["trust:RequestedSecurityToken"]["xenc:EncryptedData"]["xenc:CipherData"]["xenc:CipherValue"]:nodeText()
   
   local keyId  = resp1xml["s:Envelope"]["s:Body"]["trust:RequestSecurityTokenResponseCollection"]["trust:RequestSecurityTokenResponse"]
                 ["trust:RequestedAttachedReference"]["o:SecurityTokenReference"]["o:KeyIdentifier"]:nodeText() 
   
   local x509IssuerName = resp1xml["s:Envelope"]["s:Body"]["trust:RequestSecurityTokenResponseCollection"]["trust:RequestSecurityTokenResponse"]
                 ["trust:RequestedSecurityToken"]["xenc:EncryptedData"].KeyInfo["e:EncryptedKey"].KeyInfo["o:SecurityTokenReference"]
                 .X509Data.X509IssuerSerial.X509IssuerName:nodeText()   
   
   local x509SerialNum = resp1xml["s:Envelope"]["s:Body"]["trust:RequestSecurityTokenResponseCollection"]["trust:RequestSecurityTokenResponse"]
                 ["trust:RequestedSecurityToken"]["xenc:EncryptedData"].KeyInfo["e:EncryptedKey"].KeyInfo["o:SecurityTokenReference"]
                 .X509Data.X509IssuerSerial.X509SerialNumber:nodeText()   
   
   local binarySecret = resp1xml["s:Envelope"]["s:Body"]["trust:RequestSecurityTokenResponseCollection"]["trust:RequestSecurityTokenResponse"]
                 ["trust:RequestedProofToken"]["trust:BinarySecret"]:nodeText()
   
   return token1,token2,keyId,x509IssuerName,x509SerialNum,binarySecret
end

function ccpAuth.createSoapHeaderOnPremise(url,keyId,token1,token2,issuerNameX509,serialNumberX509,signatureValue,digestValue,created,expires) 
   local xmlTable = {}
   xmlTable[1] = "<s:Header>"
   xmlTable[2] = "<a:Action s:mustUnderstand=\"1\">http://schemas.microsoft.com/xrm/2011/Contracts/Services/IOrganizationService/Execute</a:Action>"
   xmlTable[3] = "<a:MessageID>urn:uuid:"..util.guid(128).."</a:MessageID>"
   xmlTable[4] = "<a:ReplyTo>"
   xmlTable[5] = "<a:Address>http://www.w3.org/2005/08/addressing/anonymous</a:Address>"
   xmlTable[6] = "</a:ReplyTo>"
   xmlTable[7] = "<a:To s:mustUnderstand=\"1\">"..url.."XRMServices/2011/Organization.svc</a:To>"
   xmlTable[8] = "<o:Security xmlns:o=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\">"
   xmlTable[9] = "<u:Timestamp xmlns:u=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" u:Id=\"_0\">"
   xmlTable[10] = "<u:Created>"..created.."</u:Created>"
   xmlTable[11] = "<u:Expires>"..expires.."</u:Expires>"
   xmlTable[12] = "</u:Timestamp>"
   xmlTable[13] = "<xenc:EncryptedData Type=\"http://www.w3.org/2001/04/xmlenc#Element\" xmlns:xenc=\"http://www.w3.org/2001/04/xmlenc#\">"
   xmlTable[14] = "<xenc:EncryptionMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#aes256-cbc\"/>"
   xmlTable[15] = "<KeyInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\">"
   xmlTable[16] = "<e:EncryptedKey xmlns:e=\"http://www.w3.org/2001/04/xmlenc#\">"
   xmlTable[17] = "<e:EncryptionMethod Algorithm=\"http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p\">"
   xmlTable[18] = "<DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/>"
   xmlTable[19] = "</e:EncryptionMethod>"
   xmlTable[20] = "<KeyInfo>"
   xmlTable[21] = "<o:SecurityTokenReference xmlns:o=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\">"
   xmlTable[22] = "<X509Data>"
   xmlTable[23] = "<X509IssuerSerial>"
   xmlTable[24] = "<X509IssuerName>"..issuerNameX509.."</X509IssuerName>"
   xmlTable[25] = "<X509SerialNumber>"..serialNumberX509.."</X509SerialNumber>"
   xmlTable[26] = "</X509IssuerSerial>"
   xmlTable[27] = "</X509Data>"
   xmlTable[28] = "</o:SecurityTokenReference>"
   xmlTable[29] = "</KeyInfo>"
   xmlTable[30] = "<e:CipherData>"
   xmlTable[31] = "<e:CipherValue>"..token1.."</e:CipherValue>"
   xmlTable[32] = "</e:CipherData>"
   xmlTable[33] = "</e:EncryptedKey>"
   xmlTable[34] = "</KeyInfo>"
   xmlTable[35] = "<xenc:CipherData>"
   xmlTable[36] = "<xenc:CipherValue>"..token2.."</xenc:CipherValue>"
   xmlTable[37] = "</xenc:CipherData>"
   xmlTable[38] = "</xenc:EncryptedData>"
   xmlTable[39] = "<Signature xmlns=\"http://www.w3.org/2000/09/xmldsig#\">"
   xmlTable[40] = "<SignedInfo>"
   xmlTable[41] = "<CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/>"
   xmlTable[42] = "<SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#hmac-sha1\"/>"
   xmlTable[43] = "<Reference URI=\"#_0\">"
   xmlTable[44] = "<Transforms>"
   xmlTable[45] = "<Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"/>"
   xmlTable[46] = "</Transforms>"
   xmlTable[47] = "<DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"/>"
   xmlTable[48] = "<DigestValue>"..digestValue.."</DigestValue>"
   xmlTable[49] = "</Reference>"
   xmlTable[50] = "</SignedInfo>"
   xmlTable[51] = "<SignatureValue>"..signatureValue.."</SignatureValue>"
   xmlTable[52] = "<KeyInfo>"
   xmlTable[53] = "<o:SecurityTokenReference xmlns:o=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\">"
   xmlTable[54] = "<o:KeyIdentifier ValueType=\"http://docs.oasis-open.org/wss/oasis-wss-saml-token-profile-1.0#SAMLAssertionID\">"..keyId.."</o:KeyIdentifier>"
   xmlTable[55] = "</o:SecurityTokenReference>"
   xmlTable[56] = "</KeyInfo>"
   xmlTable[57] = "</Signature>"
   xmlTable[58] = "</o:Security>"
   xmlTable[59] = "</s:Header>"
   
   local xmlStr = ''
   for k,v in pairs(xmlTable) do 
      xmlStr = xmlStr..v
   end
   
   return xmlStr
end

function ccpAuth.getSignedInfo(digestValue) 
   local signedInfo = "<SignedInfo xmlns=\"http://www.w3.org/2000/09/xmldsig#\"><CanonicalizationMethod Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></CanonicalizationMethod><SignatureMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#hmac-sha1\"></SignatureMethod><Reference URI=\"#_0\"><Transforms><Transform Algorithm=\"http://www.w3.org/2001/10/xml-exc-c14n#\"></Transform></Transforms><DigestMethod Algorithm=\"http://www.w3.org/2000/09/xmldsig#sha1\"></DigestMethod><DigestValue>"..digestValue.."</DigestValue></Reference></SignedInfo>"
   return signedInfo
end

return ccpAuth