#! /usr/bin/env ruby
# encoding: utf-8
#
# (c) 2011 Christophe Porteneuve

require 'tweep/core_exts'

module Tweep
  class Config
    attr_reader :auth, :nick, :schedule, :retweeters, :tweets
    
    def initialize(file, index)
      config = YAML::load(File.read(file))

      @nick = File.basename(file, '.*')
      @index = index
      
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

    def next_tweet
      idx = @index.next_tweet_index(@nick)
      idx = 0 if idx.to_i >= @tweets.size
      [@tweets[idx], idx]
    end

    def now_is_a_good_time?
      now = Time.now
      (0..@allowed_delay.to_i).any? do |offset|
        time = now - offset * 60
        (@schedule[time.wday] || []).include?(time.strftime('%H:%M'))
      end
    end
  
    def should_get_retweeted_by?(retweeter)
      if (result = @index.retweet_timely?(@nick, retweeter))
        @index.next_retweet_in! @nick, retweeter, @retweeters[retweeter]
      else
        @index.retweet_will_wait! @nick, retweeter
      end
      result
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
        @retweeters[shortcut.to_s] = 0
      end
      (config['retweeters'] || {}).each do |nick, pattern|
        wait = 0
        if pattern[/^\s*every\s+(\d+|other)(?:\s+tweets?)\s*$/i]
          wait = 'other' == $1 ? 1 : [$1.to_i - 1, 0].max
        end
        @retweeters[nick] = wait
      end
    end

    def load_schedule(config)
      @schedule = (config['schedule'] || {}).inject({}) do |acc, (dow, hours)|
        key = DOWS.index(dow.to_s.downcase)
        if !key && dow.to_s[/^(\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/]
          key = Date.civil($1.to_i, $2.to_i, $3.to_i) rescue nil
        end
        if !key && 'allowed_delay' == dow
          @allowed_delay = hours.to_i
        elsif key
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
        mark = $2
        h, m = $1.split(':').map(&:to_i)
        h = 0 if 12 == h
        h += 12 if 'P' == mark.upcase[0, 1]
        [h, m]
      else
        $3.split(':').map(&:to_i)
      end
      m ||= 0
      "%02d:%02d" % [h, m]
    end
  end
end