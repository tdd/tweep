#! /usr/bin/env ruby
# encoding: utf-8

# Tweep - Automatic Twitter Peeping
# Lets me rotate through tweets in a scheduled manner,
# with multiple accounts, and auto-retweet such tweets on other accounts yet.
#
# (c) 2011 Christophe Porteneuve

class Hash
  # :nodoc:
  # Inspired by ActiveSupport
  def slice(*keys)
    inject({}) do |acc, (k, v)|
      acc[k] = v if keys.include?(k)
      acc
    end
  end
end

class Object
  alias_method :try, :__send__
end

class NilClass
  # :nodoc:
  # Inspired by ActiveSupport
  def blank?; true; end
  
  def try(*args); nil; end
end

class String
  # :nodoc:
  # Inspired by ActiveSupport
  def blank?
    strip.empty?
  end
end

class Symbol
  # :nodoc:
  # For Ruby 1.8 compat, inspired by ActiveSupport
  def to_proc
    lambda { |o| o.send(self) }
  end
end

