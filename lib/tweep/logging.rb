#! /usr/bin/env ruby
# encoding: utf-8

# Tweep - Automatic Twitter Peeping
# Lets me rotate through tweets in a scheduled manner,
# with multiple accounts, and auto-retweet such tweets on other accounts yet.
#
# (c) 2011 Christophe Porteneuve

require 'logger'

module Tweep
  %w(error warn info).each do |level|
    module_eval <<-EOC
      def self.#{level}(*args)
        logger.#{level}(*args)
      end
    EOC
  end
  
  def self.logger
    return @logger if @logger
    @logger = ARGV.include?('--log') ?
      Logger.new('tweep.log', 5, 1_024 ** 2) :
      Logger.new(STDOUT)
    @logger.formatter = proc { |sev, datetime, progname, msg|
      "[Tweep #{datetime} #{sev.to_s.upcase}] #{msg}\n"
    }
    @logger
  end
  
  private_class_method :logger
end
