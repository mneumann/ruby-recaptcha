#
# ReCaptcha (http://recaptcha.net) verification. 
#
# Copyright (c) 2007 by Michael Neumann (mneumann@ntecs.de)
#

require 'uri'
require 'net/http'

class ReCaptcha
  API_SERVER     = 'http://api.recaptcha.net'
  API_SERVER_SSL = 'https://api-secure.recaptcha.net'
  VERIFY_SERVER  = 'http://api-verify.recaptcha.net'
  VERIFY_URL     = VERIFY_SERVER + "/verify"

  class Failure < Exception; end 

  def self.verify(params)
    headers = Hash.new
    [:privatekey, :remoteip, :challenge, :response].each do |k|
      headers[k] = params[k] || raise(ArgumentError, "#{k} missing")
    end

    begin
      uri = URI.parse(VERIFY_URL)
      response = Net::HTTP.post_form(uri, headers)
      success, error, *a = response.body.split.map{|l| l.chomp}
      raise Failure unless a.empty?

      case success
      when 'true'
        return true
      when 'false'
        return false, error 
      else
        raise Failure 
      end
    rescue Exception => e
      raise Failure, e
    end
  end
end
