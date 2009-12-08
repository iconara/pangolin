# encoding: utf-8

module Pangolin
	module Output
	  module Formatting

      FORMATTING = {
        # colors
        :black      => "\e[30m",
        :red        => "\e[31m",
        :green      => "\e[32m",
        :yellow     => "\e[33m",
        :blue       => "\e[34m",
        :magenta    => "\e[35m",
        :cyan       => "\e[36m",
        :white      => "\e[37m",
              
        # text styles
        :bold       => "\e[1m",
        :underline  => "\e[4m",
        :blink      => "\e[5m",
        :reverse    => "\e[7m",
        :concealed  => "\e[8m",
        
        # backgrounds
        :black_bg   => "\e[40m",
        :red_bg     => "\e[41m",
        :green_bg   => "\e[42m",
        :yellow_bg  => "\e[43m",
        :blue_bg    => "\e[44m",
        :magenta_bg => "\e[45m",
        :cyan_bg    => "\e[46m",
        :white_bg   => "\e[47m"
      }
      
      FORMATTING_OFF = "\e[0m"
      
	    def format_text(text, formatting)
	      if @colorize
	        format_codes = [formatting].flatten
	        format_codes.reject! { |f| FORMATTING[f].nil? }
	        format_codes.map! { |f| FORMATTING[f] }
	        format_codes.join + text + FORMATTING_OFF
        else
          text
        end
      end
      
      def format_header(text)
        format_text(text, :bold)
      end
      
      def format_error_header(text)
        format_text(text, [:red, :bold])
      end

      def format_warning_header(text)
        format_text(text, [:yellow, :bold])
      end
      
      def format_error(text)
        format_text(text, :red)
      end
      
      def format_stack_trace(text)
        text
      end
	    
	  end
	end
end