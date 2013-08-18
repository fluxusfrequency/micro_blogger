require 'jumpstart_auth'
require 'klout'
require 'bitly'


class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing"
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q' then puts "Goodbye!"
      when 't' then tweet(parts[1..-1].join(" "))
      when 'dm' then dm(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_followers parts [1..-1].join(" ")
      when 'elt' then everyones_last_tweet
      when 's' then shorten(parts[1..-1])
      when 'turl' then tweet(parts[1..-1]).join(" ") + " " + shorten(parts[-1]).to_s
      else
        puts "Sorry, I don't know how to #{command}."
      end
    end
  end

  def tweet(message)
     if message.length <= 140
      @client.update(message)
     else
      puts "Sorry, your tweet length was greater than 140 characters. Please compose a shorter message and try again."
    end
  end

  def dm(target, message)
    if message.length <= 140
      puts "Trying to send #{target} this direct message: "
      puts message

      screen_names = @client.followers.collect{ |follower| follower.screen_name}
      if screen_names.include? target
        @client.update(message)
      else
        puts "Sorry, you can only send direct messages to someone who is following you. Please try messaging someone who is following you."
      end
    else
      puts "Sorry, your tweet length was greater than 140 characters. Please compose a shorter message and try again."
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << follower["screen_name"]
    end
    return screen_names
  end

  def spam_my_followers(message)
    followers_list
    screen_names.each do
      dm(message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends.sort_by { |friend| friend.screen_name.downcase }
    last_tweets = []
    friends.each do |friend|
      timestamp = friend.status.created_at# find each friend's last message
      puts "#{friend.screen_name} said this on #{timestamp.strftime ("%A, %b %d")}:" # print each friend's screen_name
      puts "#{friend.status.text}" # print each friend's last message
      puts ""  # Just print a blank line to separate people
    end
  end

  def shorten(original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url
    puts "Shortening this URL: #{original_url}"
  end

  def klout_score
    friends = @client.friends.collect{|f| f.screen_name}
    friends.sort.each do |friend|
      begin
        identity = Klout::Identity.find_by_screen_name(friend)
        user = Klout::User.new(identity.id)
        puts "My friend #{friend} has a Klout score of: #{user.score.score}"
        puts ""
      rescue
        puts "#{friend} has no Klout!"
      end
    end
  end

end



blogger = MicroBlogger.new
# blogger.run
# blogger.klout_score
