#! /usr/bin/env ruby
# encoding: utf-8
#
# (c) 2011 Christophe Porteneuve

module Tweep
  class Index
    FILE_NAME = 'tweeping.idx'
    
    def initialize
      @states = {}
      @states = YAML::load(File.read(FILE_NAME)) if File.exists?(FILE_NAME)
    end
    
    def next_retweet_in!(nick, retweeter, wait)
      ((@states[nick] ||= {})[:waits] ||= {})[retweeter] = wait
    end
    
    def next_tweet_index(nick)
      (@states[nick] ||= {})[:next].to_i
    end
    
    def retweet_timely?(nick, retweeter)
      ((@states[nick] ||= {})[:waits] ||= {})[retweeter].to_i.zero?
    end
    
    def retweet_will_wait!(nick, retweeter)
      wait = ((@states[nick] ||= {})[:waits] ||= {})[retweeter].to_i
      @states[nick][:waits][retweeter] = [wait - 1, 0].max
    end
    
    def save!
      File.open(FILE_NAME, 'w') { |f| f.write(YAML::dump(@states)) }
    rescue Exception => e
      Tweep.error "Could not save index to #{FILE_NAME} (#{e.class.name}: #{e.message})"
    end
    
    def tweeted!(nick, idx)
      (@states[nick] ||= {})[:next] = idx + 1
    end
  end
end
