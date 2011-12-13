#! /usr/bin/env ruby
# encoding: utf-8

# Tweep - Automatic Twitter Peeping
# Lets you rotate through tweets in a scheduled manner,
# with multiple accounts, and auto-retweet such tweets on other accounts yet.
#
# (c) 2011 Christophe Porteneuve

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'tweep/account'
require 'tweep/index'
require 'tweep/logging'

module Tweep
  @@index = Index.new
  
  def self.run!
    info 'Running…'
    Account.each &:run!
  ensure
    @@index.save!
  end

  Dir['accounts/*.yml'].each do |defn|
    Account.new(defn, @@index)
  end
end

Tweep.run! if __FILE__ == $0
