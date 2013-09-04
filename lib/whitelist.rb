require "whitelist/version"

module WhitelistError
  class NoConfigAvailable < StandardError; end

  def self.not_array_msg(cfg)
    "WARNING: Config result was not an array, #{cfg.inspect}"
  end

  def self.trying_again_msg
    "WARNING: Trying again with previous config"
  end

  def self.check(cfg, config_working)
    #puts "Checker: #{cfg.inspect}, #{config_working.inspect}"
    if !cfg.respond_to?(:each) || cfg.respond_to?(:keys)
      warn self.not_array_msg(cfg)
      warn self.trying_again_msg
      self.check_working(config_working)
      return config_working
    end
    return cfg
  end

  def self.check_working(config_working)
    if config_working
      warn "WARNING: Unable to update new config, using previous version"
    else
      raise NoConfigAvailable, "No working config available, cannot proceed"
    end
  end

end

module Whitelist
  class List
    def initialize(config)
      @config = @config_working = nil
      @config = procize(config)
      @config_working = check_config
    end

    def check_config

      cfg = nil
      begin
        cfg = @config.call
      rescue
        cfg= nil
      end

      WhitelistError.check(cfg, @config_working)

    end

    def check(checkee)
      #puts "checking #{check_config}"
      check_config.each do |check_str|
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
