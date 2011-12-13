Gem::Specification.new do |s|
  s.name          = 'tweep'
  s.version       = '0.1.0'
  s.date          = '2011-12-13'
  s.summary       = "Automatic Twitter Peeping"
  s.description   = "Tweep lets you rotate through tweets in a scheduled manner, with multiple accounts, and auto-retweet such tweets on other accounts yet.  For instance, think recent accounts for product launches versus their more established company accounts."
  s.authors       = ["Christophe Porteneuve"]
  s.email         = 'tdd@tddsworld.com'
  s.files         = Dir["lib/**/*.rb", "MIT-LICENSE.txt", "*.markdown", "accounts/your_account_1.yml"]
  s.require_path  = "lib"
  s.homepage      = 'http://github.com/tdd/tweep'
  s.license       = 'MIT'
  s.executables   << 'tweep'
  
  s.add_development_dependency 'twitter', '~> 2.0.2'
  s.add_runtime_dependency 'twitter', '~> 2.0.2'
end