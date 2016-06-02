module Sheetable
  extend ActiveSupport::Concern

  included do
    def sheet_data
      sheet.cache_stored_file!
      row_data = []
      case File.extname(sheet.full_cache_path).downcase
      when '.csv', '.xls', '.xlsx', '.ods'
        spreadsheet = Roo::Spreadsheet.open(sheet.full_cache_path)
        header = spreadsheet.row(1)
        (2..spreadsheet.last_row).each do |i|
          row = Hash[[header, spreadsheet.row(i)].transpose]
          row_data << row
        end
      else
        logger.debug 'unsupported extension'
      end
      row_data
    end
  end
end
