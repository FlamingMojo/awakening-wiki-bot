# frozen_string_literal: true

# require './base_matcher'

module DiscordBot::Commands::Admin
  class AutoBlock
    class EvenOdd
      include BaseMatcher

      def match?
        # Every spam account has been created with a username matching the following criteria
        #  - 4-9 characters, a-z, no spaces
        #  - First character is a vowel, then alternating consonant, vowel, consonant (counting y as a vowel)
        # So this auto-detects and blocks those usernames. They can be unblocked manually by admin afterwards if in error.
        return false unless username.match?(/\A[a-z]{4,9}\z/i)
        even, odd = *(username.chars.partition.each_with_index { |_v, i| i.even? })

        even.join('').match?(/^[aeiouy]+$/i) && odd.join('').match?(/^[^aeiouy]+$/i)
      end
    end
  end
end
