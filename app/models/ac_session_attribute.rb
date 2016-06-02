# == Schema Information
#
# Table name: ac_session_attributes
#
#  id                    :integer          not null, primary key
#  ac_session_history_id :integer
#  name                  :string(255)
#  value                 :text
#  ac_step_id            :integer
#  attribute_type        :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#

class AcSessionAttribute < ActiveRecord::Base
  belongs_to :ac_session_history
  belongs_to :ac_step

  def wysiwyg_data?
    return false unless value.present?
    value.match(/^<p.*p>$/)
  end

  def parse_data
    ps = Nokogiri::HTML(value).search('p')
    data = []
    ps.each do |p|
      # puts '---------------------------------------' + "\n"
      # logger.debug 'parse_data p: ' + p.inspect
      data << parse_node(p)
      # data[-1]['text'] = data[-1]['text'].to_s + '\n'
    end
    logger.debug 'postparse_data' + data.inspect
    wysiwyg_text data

    # data
  end

  def get_element_styles(element, styles)
    if element.attributes['style'].present?
      element.attributes['style'].value.split(';').each do |style|
        k, v = style.split(':')
        styles[k.strip] = v.strip if k.present? && v.present?
      end
    end
    styles
  end

  def parse_node(element, data = [[{}]], parent_styles = {})
    logger.debug element.inspect + "\n\n"

    # styles = data[-1][-1]
    styles = parent_styles.dup

    logger.debug 'parse_node in        styles: ' + styles.inspect
    logger.debug 'parse_node in parent_styles: ' + parent_styles.inspect

    styles = get_element_styles element, styles

    logger.debug '     parse_node styles: ' + styles.inspect
    pre_loop_styles = styles.dup
    if element.children.count > 0
      # puts '-------------------------------------------------' + "\n"
      pre_styles = parent_styles.dup
      element.children.each do |c|
        case c.name
        when 'span'

        when 'text'
        when 'em' # italic
          styles['em'] = 1
        when 'strong' # bold
          styles['strong'] = 1
        when 'sup' # bold
          styles['sup'] = 1
        when 'sub' # bold
          styles['sub'] = 1
        end
        styles = get_element_styles c, styles

        logger.debug '            process child             ' + c.to_s
        logger.debug '            process child             ' + c.type.to_s
        logger.debug '            before  child   styles    ' + styles.to_s
        logger.debug '            before  child prestyles   ' + pre_styles.to_s
        logger.debug '            before  child parentstyle ' + parent_styles.to_s
        if c.type == 3  ## is text use parent attributes
          if parent_styles == {}
            parse_node(c, data, styles.dup)
          else
            parse_node(c, data, parent_styles.dup)
          end
          # styles = pre_styles
          styles = data[-1][-1]
        else
          parse_node(c, data, styles.dup)
          styles = pre_styles
          # styles = data[-1][-1]
        end
        # styles = pre_styles
        # styles = parent_styles if styles != pre_styles
        logger.debug '            after   child   styles   ' + styles.to_s
        logger.debug '            after   child prestyles  ' + pre_styles.to_s
      end
      styles = pre_loop_styles
      logger.debug "\n|" + '         after loop pre_loop_styles  ' + pre_loop_styles.to_s + "\n"
    else
      logger.debug 'text: ' + element.to_s
      logger.debug 'data pre text: ' + data[-1][-1].to_s
      logger.debug 'styles: ' + styles.inspect
      logger.debug 'parent_styles: ' + parent_styles.inspect
      data[-1][-1] = styles.dup
      data[-1][-1]['text'] = element.to_s
      pdup = parent_styles.dup
      pdup.delete('text-align')
      pdup['text'] = ''
      # data[-1] << pdup
      # styles = data[-1][-1]
      data[-1] << pdup
      # styles = pdup
    end
    logger.debug "\n------------------------------------------------------"
    logger.debug data.inspect
    logger.debug "------------------------------------------------------\n"
    data
  end

  def wysiwyg_text(text_data)
    text_data_count = text_data.count
    p_tags = {}
    tags = {}

    cs = ''
    ptag_id = 1
    tag_id = 1
    ps = []
    text_data.each_with_index do |p, index|
      p_text = ''
      p.each do |text|
        # paragraph variables reset on each paragraph
        # logger.debug 'p.each text: ' + text.inspect
        align = ''
        fontname = ''
        fontsize = 0
        p_formats = {}

        text.each do |word|
          next if word == {}
          # p styles
          align = word['text-align'] if word['text-align'].present?
          fontname = word['font-family'] if word['font-family'].present?

          if word['font-size'].present?
            # logger.debug 'font wordpresent: ' + word['font-size'].to_s
            fontsize = word['font-size']
            fontsize.gsub!(/pt$/, '')
          end
          # word group variables reset on each group

          puts word.inspect

          formats = { 'fontname' => fontname }

          formats['italic'] = 1 if word['em']
          formats['bold'] = 1 if word['strong']
          formats['underline'] = 1 if word['text-decoration'] == 'underline'
          formats['inferior'] = 1 if word['sub']
          formats['superior'] = 1 if word['sup']

          case word['color'].to_s.upcase
          when '#000000'
            formats['color'] = 'Black'
          when '#0000FF'
            formats['color'] = 'Blue'
          when '#888888'
            formats['color'] = '50% Gray'
          when '#FF0000'
            formats['color'] = 'Red'
          when '#FFFFFF'
            formats['color'] = 'White'
          end

          ### font-family parse
          formats['font'] = get_fontname(formats)

          word_text = '<w' + tag_id.to_s + '>' + word['text'].gsub('&amp;', '&') + '</w' + tag_id.to_s + '>'
          formats['literal'] = word_text
          tags['w' + tag_id.to_s] = formats
          p_text += word_text
          tag_id += 1
        end

        p_formats['align'] = align if align != ''
        p_formats['fontname'] = fontname || '' if fontname != ''
        p_formats['fontsize'] = fontsize if fontsize != ''
        linebreak = ''
        linebreak = '\n' if index < (text_data_count - 1)
        p_text = '<p' + ptag_id.to_s + '>' + p_text + linebreak + '</p' + ptag_id.to_s + '>'
        p_formats['literal'] = p_text
        p_tags['p' + ptag_id.to_s] = p_formats

        ps << p_text
        ptag_id += 1
      end
      cs = ps.join('')
    end
    cs.gsub! '\\n\\n$', '\n'
    # puts 'cs: ' + cs + "\n\n"
    # puts 'tags: ' + tags.to_s + "\n\n"
    # puts 'p_tags: ' + p_tags.to_s + "\n\n"
    [cs, tags, p_tags]
  end

  def get_fontname(formats)
    font_family = ''
    # font_formats: "AGaramondPro=garamond;Arial=arial;ArialNarrow=arial narrow;HandScript=handscript;Trebuchet MS=trebuchet ms;"
    logger.debug formats.inspect
    logger.debug 'fontname: >' + formats['fontname'].to_s + '<'
    case formats['fontname']
    when 'garamond'
      font_family = 'Adobe Garamond Pro'
    when 'arial', "'arial'"
      font_family = 'Arial'
    when "'arial narrow'", '"arial narrow"', 'arial narrow'
      font_family = 'Arial Narrow'
    # when 'barmeno'
    #   font_family = 'Barmeno'
    when 'constantia', "'constantia'"
      font_family = 'Constantia'
    when 'georgia', "'georgia'"
      font_family = 'Georgia'
    when 'handscript', "'handscript'"
      font_family = 'Handscript'
    when 'helvetica', "'helvetica'"
      font_family = 'Helvetica'
    when 'palatino', "'palatino'"
      font_family = 'Palatino'
    when "'trebuchet ms'", '"trebuchet ms"', 'trebuchet ms'
      font_family = 'Trebuchet MS'
    end

    font_family += ' Bold' if formats['bold']
    font_family += ' Italic' if formats['italic']
    font_family += ' Regular' unless formats['bold'] || formats['italic']

    ### fixup bad font name :(
    font_family = 'Adobe Garamond Pro Bold Regular' if font_family == 'Adobe Garamond Pro Bold'
    logger.debug 'font_family: ' + font_family.to_s

    font_family

    # truetype   :: Adobe Garamond Pro Italic                :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/AGaramondPro-Italic.ttf
    # truetype   :: Adobe Garamond Pro Regular               :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/AGaramondPro-Regular.ttf
    # truetype   :: Adobe Garamond Pro Bold Italic           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/AGaramondPro-BoldItalic.ttf
    # truetype   :: Adobe Garamond Pro Bold Regular          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/AGaramondPro-Bold.ttf
    # truetype   :: Arial Bold                               :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Arial-BoldMT.ttf
    # truetype   :: Arial Bold Italic                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Arial-BoldItalicMT.ttf
    # truetype   :: Arial Italic                             :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Arial-ItalicMT.ttf
    # truetype   :: Arial Regular                            :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/ArialMT.ttf
    # truetype   :: Arial Black Regular                      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Arial-Black.ttf
    # truetype   :: Arial Narrow Bold                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/ArialNarrow-Bold.ttf
    # truetype   :: Arial Narrow Bold Italic                 :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/ArialNarrow-BoldItalic.ttf
    # truetype   :: Arial Narrow Italic                      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/ArialNarrow-Italic.ttf
    # truetype   :: Arial Narrow Regular                     :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/ArialNarrow.ttf
    # truetype   :: Avenir Medium                            :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Avenir-Medium.ttf
    # truetype   :: Avenir 45 Regular                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LT_50342.ttf
    # truetype   :: Avenir 55 Roman Bold                     :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LT_50340.ttf
    # truetype   :: Avenir LT Std 65 Medium Black            :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/AvenirLTStd-Black.ttf
    # truetype   :: Barmeno Bold                             :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Barmeno-ExtraBold.ttf
    # truetype   :: Barmeno Bold                             :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Barmeno-Bold.ttf
    # truetype   :: Barmeno Medium                           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Barmeno-Medium.ttf
    # truetype   :: Barmeno Regular                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Barmeno-Regular.ttf
    # truetype   :: Cambria Regular                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Cambria.ttf
    # truetype   :: Constantia Bold                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/constanb.ttf
    # truetype   :: Constantia Bold Italic                   :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/constanz.ttf
    # truetype   :: Constantia Italic                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/constani.ttf
    # truetype   :: Constantia Regular                       :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/constan.ttf
    # truetype   :: David Bold                               :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/davidbd.ttf
    # truetype   :: David Regular                            :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/david.ttf
    # truetype   :: Edwardian Script ITC Regular             :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/EdwardianScriptITC.ttf
    # truetype   :: Georgia Bold                             :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/georgiab.ttf
    # truetype   :: Georgia Bold Italic                      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/georgiaz.ttf
    # truetype   :: Georgia Italic                           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/georgiai.ttf
    # truetype   :: Georgia Regular                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/georgia.ttf
    # truetype   :: HandScript Bold                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HandScript-Bold.ttf
    # truetype   :: HandScript Bold Italic                   :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HandScript-BoldItalic.ttf
    # truetype   :: HandScript Italic                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HandScript-Italic.ttf
    # truetype   :: HandScript Regular                       :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HandScript.ttf
    # truetype   :: Helvetica Black                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica-Black.ttf
    # truetype   :: Helvetica Bold                           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica-Bold.ttf
    # truetype   :: Helvetica Regular                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica.ttf
    # truetype   :: Helvetica Neue Bold                      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HelveticaNeue-Bold.ttf
    # truetype   :: Helvetica Neue Bold Italic               :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HelveticaNeue-BoldItalic.ttf
    # truetype   :: Helvetica Neue Condensed Medium          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue-Medium Cond.ttf
    # truetype   :: Helvetica Neue Italic                    :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HelveticaNeue-Italic.ttf
    # truetype   :: Helvetica Neue Light                     :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HelveticaNeue-Light.ttf
    # truetype   :: Helvetica Neue Light Italic              :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HelveticaNeue-LightItalic.ttf
    # truetype   :: Helvetica Neue Regular                   :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/HelveticaNeue.ttf
    # truetype   :: Helvetica Neue LT 37 Thin Condensed      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LTe50870.ttf
    # truetype   :: Helvetica Neue LT 37 Thin Condensed      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue LT 37.ttf
    # truetype   :: Helvetica Neue LT 37 Thin Condensed Oblique :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LTe50871.ttf
    # truetype   :: Helvetica Neue LT 37 Thin Condensed Oblique :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue LT 37O.ttf
    # truetype   :: Helvetica Neue LT 57 Condensed           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue LT 57.ttf
    # truetype   :: Helvetica Neue LT 57 Condensed           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LTe50872.ttf
    # truetype   :: Helvetica Neue LT 57 Condensed Oblique   :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue LT 57O.ttf
    # truetype   :: Helvetica Neue LT 57 Condensed Oblique   :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LTe50873.ttf
    # truetype   :: Helvetica Neue LT 77 Bold Condensed      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LTe50874.ttf
    # truetype   :: Helvetica Neue LT 77 Bold Condensed      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue LT 77.ttf
    # truetype   :: Helvetica Neue LT 77 Bold Condensed Oblique :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Helvetica Neue LT 77O.ttf
    # truetype   :: Helvetica Neue LT 77 Bold Condensed Oblique :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/LTe50875.ttf
    # truetype   :: ITC Isadora Bold                         :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Isadora-Bold.ttf
    # truetype   :: ITC Isadora Regular                      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Isadora-Regular.ttf
    # truetype   :: Impact Regular                           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Impact.ttf
    # truetype   :: MV Boli Regular                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/mvboli.ttf
    # truetype   :: Palatino Linotype Bold                   :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/palab.ttf
    # truetype   :: Palatino Linotype Bold Italic            :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/palabi.ttf
    # truetype   :: Palatino Linotype Italic                 :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/palai.ttf
    # truetype   :: Palatino Linotype Regular                :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/pala.ttf
    # truetype   :: Raavi Regular                            :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/raavi.ttf
    # truetype   :: Shruti Bold                              :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/shrutib.ttf
    # truetype   :: Shruti Regular                           :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/shruti.ttf
    # truetype   :: Trajan Pro Bold                          :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/TrajanPro-Bold.ttf
    # truetype   :: Trebuchet MS Bold                        :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Trebuchet MS Bold.ttf
    # truetype   :: Trebuchet MS Bold Italic                 :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Trebuchet MS Bold Italic.ttf
    # truetype   :: Trebuchet MS Italic                      :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Trebuchet MS Italic.ttf
    # truetype   :: Trebuchet MS Regular                     :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Trebuchet MS.ttf
    # truetype   :: Yellowtail Regular                       :: /raid/0/creator/builds/rails_cs_8_5_4/Resources/Fonts/Yellowtail.ttf
  end
end
