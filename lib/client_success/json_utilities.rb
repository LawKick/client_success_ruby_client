module ClientSuccess
  # Module with methods to convert to and from both
  # camel case and snake case.
  #
  module JsonUtilities
    # Returns a string in camel case.
    #
    def camel_case_for(word)
      camelize(word.to_s, false)
    end

    def camelize(snake_word, first_upper = true)
      if first_upper
        snake_word.to_s
                  .gsub(/\/(.?)/) { "::" + $1.upcase }
                  .gsub(/(^|_)(.)/) { $2.upcase }
      else
        snake_word.chars.first + camelize(snake_word)[1..-1]
      end
    end

    def underscore_for(word)
      underscore(word.to_s)
    end

    def underscore(string)
      @__memoize_underscore ||= {}
      return @__memoize_underscore[string] if @__memoize_underscore[string]
      @__memoize_underscore[string] =
        string.gsub(/::/, '/')
              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
              .tr('-', '_')
              .downcase
      @__memoize_underscore[string]
    end
  end
end
