#! /usr/bin/env ruby
# encoding: utf-8

# Tweep - Automatic Twitter Peeping
# Lets me rotate through tweets in a scheduled manner,
# with multiple accounts, and auto-retweet such tweets on other accounts yet.
#
# (c) 2011 Christophe Porteneuve

require 'tweep/core_exts'

module Tweep
  class Config
    attr_reader :auth, :nick, :schedule, :tweets
    
    def initialize(file)
      config = YAML::load(File.read(file))
    
      @nick = File.basename(file, '.*')
      
      load_auth config
      load_schedule config
      load_retweeters config

      @tweets = (config['tweets'] || []).map(&:strip)
    end
    
    def has_auth?
      4 == @auth.values.reject(&:blank?).size
    end
    
    def has_tweets?
      @tweets.any?
    end

    def now_is_a_good_time?
      now = Time.now
      (@schedule[now.wday] || []).include?(now.strftime('%H:%M'))
    end
  
  private
    DOWS = %w(sunday monday tuesday wednesday thursday friday saturday)

    TIME_REGEX = %r(
      (?:
      # 12-hour format - groups 1 and 2
      ((?:0?[1-9]|1[012])(?::[0-5][0-9])?)
      ([ap]m?)
      |
      # 24-hour format - group 3
      ((?:[01]?[0-9]|2[0-3])(?:[0-5][0-9]?))
      )
    )ix
    
    def load_auth(config)
      @auth = config.slice('consumer_key', 'consumer_secret', 'oauth_token', 'oauth_token_secret')
    end
    
    def load_retweeters(config)
      @retweeters = {}
      if (shortcut = config['retweeter'])
        @retweeters[shortcut.to_s] = :always
      end
      @retweeters.update(config['retweeters'] || {})
    end

    def load_schedule(config)
      @schedule = (config['schedule'] || {}).inject({}) do |acc, (dow, hours)|
        key = DOWS.index(dow.to_s.downcase)
        if !key && dow.to_s[/^(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/]
          key = Date.civil($1.to_i, $2.to_i, $3.to_i) rescue nil
        end
        if key
          hours = hours.split(',').map(&:strip).reject(&:empty?)
          hours = hours.map { |hour| self.class.read_hour(hour) }.compact
          acc[key] = hours if hours
        end
        acc
      end
      
    end

    def self.read_hour(hour)
      return unless hour =~ TIME_REGEX
      h, m = if $1 && $2
        h, m = $1.split(':').map(&:to_i)
        h = 0 if 12 == h
        h += 12 if 'P' == $2.upcase[0, 1]
        [h, m]
      else
        $3.split(':').map(&:to_i)
      end
      m ||= 0
      "%02d:%02d" % [h, m]
    end
  end
end