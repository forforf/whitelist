require "whitelist/version"

module Whitelist
  class List
    def initialize(config)
      @config = procize(config)
    end

    def check(checkee)
      @config.call().each do |check_str|
        check_regex = regexize(check_str)
        #if we get one match break the loop and return
        return checkee if checkee =~ check_regex
      end
      false
    end

    private
    def procize(obj)
      return obj if obj.is_a? Proc
      ->(){ obj }
    end

    def regexize(str)
      #escape domain dots so regex doesn't interpret them
      rstr = str.gsub('.','\\.')

      #chang asterisk to regex equivalent
      rstr = rstr.gsub('*', '.*')

      #convert to regex
      /#{rstr}/
    end

  end
end
