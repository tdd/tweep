#! /usr/bin/env ruby
# encoding: utf-8
#
# (c) 2011 Christophe Porteneuve

require 'tweep/config'
require 'rubygems'
require 'twitter'

module Tweep
  class Account
    @@registry = {}

    def self.each(&block)
      @@registry.values.each(&block)
    end

    def self.find(nick)
      @@registry[nick]
    end
  
    def initialize(yml, index)
      return unless load_config(yml, index)
      @index = index
      @@registry[@config.nick] = self
    end
  
    def retweet!(status_id)
      Tweep.info "#{@config.nick} retweets #{status_id.inspect}"
      execute :retweet, status_id
    end
  
    def run!
      return unless @config.has_tweets? && @config.now_is_a_good_time?
      tweet!
    end
  
  private
    def execute(call, *args)
      Twitter.configure do |config|
        @config.auth.each do |k, v|
          config.send("#{k}=", v)
        end
      end
      Twitter.send(call, *args)
    end

    def load_config(file, index)
      return unless File.file?(file) && File.readable_real?(file)
      @config = Config.new(file, index)
      @config.has_auth?
    end
    
    def tweet!
      status, idx = @config.next_tweet
      return if status.blank?
      Tweep.info "#{@config.nick} tweets: #{status}"
      st = execute(:update, status)
      @index.tweeted! @config.nick, idx
      @config.retweeters.each do |retweeter, _|
        if @config.should_get_retweeted_by?(retweeter)
          self.class.find(retweeter).try(:retweet!, st.id)
        end
      end
    end
  end
end
