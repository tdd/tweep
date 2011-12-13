#! /usr/bin/env ruby
# encoding: utf-8

# Tweep - Automatic Twitter Peeping
# Lets me rotate through tweets in a scheduled manner,
# with multiple accounts, and auto-retweet such tweets on other accounts yet.
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
  
    def initialize(yml)
      return unless load_config(yml)
      @@registry[@config.nick] = self
    end
  
    def retweet!(status_id)
      execute :retweet, :id => status_id
    end
  
    def run!
      return unless @config.has_tweets? && @config.now_is_a_good_time?
      tweet!
    end
  
  private
    def execute(call, *args)
      puts "#{call}(#{args.map(&:inspect).join(',')})"
      return # TEMP/DEBUG/FIXME

      # Twitter.configure do |config|
      #   @config.auth.each do |k, v|
      #     config.send("#{k}=", v)
      #   end
      # end
      # Twitter.send(call, *args)
    end

    def load_config(file)
      return unless File.file?(file) && File.readable_real?(file)
      @config = Config.new(file)
      @config.has_auth?
    end

    def tweet!
      status = @config.tweets.first
      return if status.blank?
      Tweep.info "#{@nick} tweets: #{status}"
      st = execute(:update, :status => status)
      @config.retweeters.each do |retweeter|
        # FIXME: grab status ID!
        self.class.find(retweeter).try(:retweet!, :foobar)
      end
    end
  end
end
