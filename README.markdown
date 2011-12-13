Tweep - Automatic Twitter Peeping.  Lets you rotate through tweets in a scheduled manner, with multiple accounts, and auto-retweet such tweets on other accounts yet.  For instance, think recent accounts for product launches versus their more established company accounts.

# Installing

Tweep is in Ruby, so you need Ruby and RubyGems installed.  It’s probably already there on your OSX or Linux box, and on Windows you can use the nifty [Ruby Installer](http://rubyinstaller.org/downloads/).  Then just install the gem to get the `tweep` command:

```
$ gem install tweep
```

# Configuring your accounts

Accounts are detected by inspecting YAML files in the `accounts` subdirectory in the current working path.  The base name of the file can be anything, as the actual account is identified by the authentication information inside.

To tweet on behalf of an account, Tweep needs this account’s **consumer key and secret**, along with **OAuth token and secret** for an app you setup on that account with Read/Write access (no DM access is necessary).

## Creating custom applications for your accounts for Tweep to use

Tweep is no central application that could prompt Twitter to authorize it, otherwise open-sourcing it with its OAuth tokens would be quite problematic: any user would be able to tweet as any other!

You will need to create a custom app on your account for Tweep to use on your behalf. Here’s how:

1. Sign in to [Twitter Developers](http://dev.twitter.com) using your regular Twitter account. This should get you to the "My Applications" screen.
2. Click the "Create an app" link
3. Give it a name (say, "Tweep").  This is the name that will show up as "the source" (the app you use to tweet) in your Tweep-sent tweets.
4. description (anything) and website (your own perhaps).
5. If you're brave and have some spare time, read the terms of use, cheekily renamed "Developer Rules of the Road."  Then check the "Yes, I agree" box.
6. Type the CAPTCHA.  If it's unreadable, use the circular arrow icon on the right-hand side until you can manage it.
7. Finally, click the "Create your Twitter application" button.

OK, almost there.  Your app starts out as read-only: it won't let you *send tweets* to Twitter.  You're now on the app's screen.

8. Click the Settings tab
9. In Application Type, choose Read and Write
10. At the bottom of the form, click "Update this Twitter application’s settings"
11. Get back to the Details tab, and at the bottom, click "Create my access token"

Yay, you’re done!  Click the OAuth tool tab and you’ll see the 4 pieces of authentication configuration you’ll need to put in your account’s YAML file.  Use the `your_account_1.yml` file as a template and copy-paste the 4 values in the proper places.  Make sure you keep the values wrapped in the quotes originally placed in the YAML file.

## Why can't I just put in my login and password?

First, because that's quite unsafe.  Your password is likely one you use in a number of other places;  having it lie around in some script somewhere isn't the best idea.

Second, because login and password are primarily meant for direct human use.  A growing number of APIs do not allow them for program-based authentication, and Twitter's API is certainly headed that way.  So OAuth it is!  I realize this requires a bit of extra work on your part when setting up your access, but security and privacy are worth it.

# Scheduling your tweets

Your tweets are just a series of items in the `tweets` part of your YAML file.  Use one tweet per line, surrounded by double quotes (see examples in `your_account_1.yml`).  If you do need a double-quote in there, escape it by putting a backslash (`\`) before it, as you’ll see in the demo YAML file.

Then your tweet schedule uses the `schedule` key.  You can provide one sub-key per day of the week, using their English lowercase name (e.g. `tuesday`).  Every such key lists hours of the day when to tweet.  These hours use the time zone of the machine you’ll run Tweep on.  You can use 24-hour or 12-hour format for times, and Tweep uses the hour and the (optional) minute part.  Seconds are overkill, so we don't want them.

In 12-hour format, you can use 'am' or 'a', 'pm' or 'p' indifferently, using whatever case (upper or lower) you like best.  Also, stick to US format: `12am` is midnight, `12pm` is noon, and there is no such thing as `0am` or `0pm`…

You can use multiple hours on the same day by separating hours with commas.

If you want to schedule tweets on specific dates besides (or instead of) recurring weekdays, you can use specific dates as schedule keys, in the form `YYYY-MM-DD`, for instance `2011-12-25` for December 25, 2011.

All this is nice and well, but the way you'll schedule the running of Tweep may end up launching it a few minutes late (perhaps because other, long tasks are run before it).  So you can allow a maximum delay for running Tweep, using the `allowed_delay` key in `schedule`, expressed in minutes.  For instance, setting `allowed_delay: 15` will let a task scheduled as `1p` be run until 01:15pm.

# Controlling automatic retweets

To define accounts that auto-retweet your tweets, you need two things:

1. Setup these accounts in their own files, with at minimum their authentication info so Tweep can make them retweet stuff.
2. List these accounts as retweeters in the "source" accounts’ YAML files.

The listing part is done through the `retweeters` key, which contains one subkey per retweeter.  Subkeys are named **exactly** like the YAML files for these accounts (without the `.yml` extension).

## Retweeting every tweet

For an account to retweet *every single tweet* you write, you would use `always` as its definition.  For instance, to make `mygroupie` retweet everything your `me` account tweets through Tweep, you would need the following in your `me.yml` file:

```yaml
retweeters:
  mygroupie: always
```

This can be a bit extreme, so you may want to have such accounts retweet only every other tweet, or one tweet in three, or one in four…  Just say so:

```yaml
retweeters:
  mygroupie: every 3 tweets
  mysupergroupe: every other tweet
```

We don't care about whether you actually say "tweet" or "tweets" at the end, and provide `other` as a nice-reading synonym for `2`.  Should you say "every one," it'll be treated as a synonym to
"always".

# Executing your tweeting campaign

To run Tweep, just run the `tweep` command that is provided by the gem, in a directory that has the proper `accounts` subdirectory.

In order to keep track of where it stands in rotating your accounts’ tweets and observing the
"every so many tweets" policies, Tweep needs to be able to write to a `tweeping.idx` file in
the directory it’s running at.

You should then take steps to run the `tweep` command in the proper directory at regular intervals, frequently enough to honor your `schedule` settings.  Linux and OSX have Crontab for this, and Windows has Scheduled Tasks.

# Contributing

Tweep intends to serve a rather simple need: doing basic Twitter campaigns and making sure
your tweets get added visibility from retweets by more prominent accounts of yours until
your originally-tweeting accounts get enough followers on their own.  It's more of a
product- or service-launch thing, and for the relatively short term (a few months, perhaps
up to a year?).

If you have massively complex social media needs, you’re probably better off using an online
service such as [SocialOomph](https://www.socialoomph.com/) or
[CoTweet](http://cotweet.com/).

Still, if you discover a bug, or feel you can improve the user experience in a way
consistent with the initial design goals of Tweep, just fork the project on
[Github](https://github.com/tdd/tweep), patch it, test it, and submit a pull request.
I'll be happy to check these out and merge them in if I like them!

# License

Tweep is made available under the MIT license.  Check the [MIT-LICENSE.txt](MIT-LICENSE.txt)
file in the soure code for details.  TL;DR: as long as you keep the license in there with
due author and copyright info, you’re free to do whatever you want with Tweep, including
commercial uses.  Just Don't Be Evil™.