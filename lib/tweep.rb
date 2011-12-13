#! /usr/bin/env ruby
# encoding: utf-8

# Tweep - Automatic Twitter Peeping
# Lets me rotate through tweets in a scheduled manner,
# with multiple accounts, and auto-retweet such tweets on other accounts yet.
#
# (c) 2011 Christophe Porteneuve

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'tweep/account'
require 'tweep/logging'

module Tweep
  def self.run!
    info 'Running…'
    Dir['accounts/*.yml'].each do |defn|
      Account.new(defn)
    end
    Account.each &:run!
  end
end

Tweep.run!
