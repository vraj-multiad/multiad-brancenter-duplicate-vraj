# sdf
module HtmlToCreator
  extend ActiveSupport::Concern

  def convert_html_to_creator(html, config = {})
    if html.is_a? String
      doc = HtmlToCreatorDocument.new(config)
      creator = doc.parse(doctor_html(html)) # returns HTML tags converted to creator tags

      # convert named entities to real characters
      coder = HTMLEntities.new
      coder.decode(creator) # returns converted string
    else
      ''
    end
  end

  def doctor_html(html)
    # find ampersands that are not part of a named entity and convert to &amp;
    html.gsub(/&(?![_a-zA-Z]\w*;)(?!#\d+;)/,'&amp;')
  end

  # convert a very limited subset of HTML font attribute tags to specially named
  # creator tags
  class HtmlToCreatorDocument < Nokogiri::XML::SAX::Document
    attr_reader :ret_string

    @@bullet_chars = %w(• ◦)

    def initialize(params = {})
      @default_type_style = params.fetch(:default_type_style, 'normal')
      @default_paragraph_style = params.fetch(:default_paragraph_style, 'normal')
      @prefix = params.fetch(:prefix, '')
      # add trailing underscore to prefix if one is defined, so we end up with
      # prefix_normal instead of prefixnormal
      @prefix += '_' if @prefix.present?
    end

    def parse(document)
      parser = Nokogiri::XML::SAX::Parser.new(self)
      document = '<root>' + document + '</root>'

      # convert things that look like URLs to an anchor tag
      document = document.gsub(%r{([^"])((?:https?|ftp|mailto)://\S+[a-z/])}i, '\1<a href="\2">\2</a>')
      # convert newline characters into literal backslash+n for creator
      document = document.gsub(%r{\n}i, '\n')
      # puts document
      parser.parse(document)
      @ret_string
    end

    def start_document
      # (re)initialize stack
      @stack = []
      @ret_string = type_style(@default_type_style) + paragraph_style(@default_paragraph_style)
      @list_level = 0
    end

    def type_style(name)
      "«T:#{@prefix}#{name}»"
    end

    def paragraph_style(name)
      "«P:#{@prefix}#{name}»"
    end

    def bullet_style
      if @list_level > 0
        paragraph_style("bullet_#{@list_level}_normal") + type_style("bullet_#{@list_level}_normal")
      else
        # no longer in a list, revert to default
        paragraph_style(@default_paragraph_style)
      end
    end

    # <P:rbc_detail_bullet_1><T:rbc_detail_bullet_1>O\t<T:rbc_detail_normal>

    def start_element(name, attrs = [])
      name = name.downcase
      case name
      when 'br'
        @ret_string += '\n'
      when 'ul'
        @list_level += 1
        # @ret_string += '\n'
        # @ret_string += '\n' if @ret_string[-2, 2] != '\n'
        # @ret_string += '\n' if @ret_string.last(2) != '\n'
      when 'li'
        ll = @list_level - 1
        # @ret_string += '\n' if @ret_string[-2, 2] != '\n'
        @ret_string +=
          bullet_style +
          "\t" * ll +
          @@bullet_chars[ll] +
          "\t" +
          type_style(@default_type_style)
      when 'b', 'i', 'a', 'sup', 'sub'
        # Handle all other expected tags
        prev_style = @stack != [] ? @stack[-1].split('_') : []
        prev_style.push(name)
        style = prev_style.sort.join('_')

        @stack.push(style)
        @ret_string += type_style(style)
      end
    end

    # TODO: May need to regex out creator tags to see if last 2 chars are \n

    def end_element(name)
      case name
      when 'ul'
        @list_level -= 1
        @ret_string += bullet_style
      when 'li'
        # @ret_string += '\n'
        # puts @ret_string[-2, 2]
        # puts @ret_string.last(2)
        @ret_string += '\n' if @ret_string.last(2) != '\n'
        # @ret_string += '\n' if @ret_string[-2, 2] != '\n'
      when 'b', 'i', 'a', 'sup', 'sub'
        # if @stack.present?
        @stack.pop if @stack != []
        # if @stack.present?
        if @stack != []
          tag = @stack[-1]
        else
          tag = @default_type_style
        end
        @ret_string += type_style(tag)
      end
    end

    def characters(str)
      @ret_string += str
    end
  end # class
end
