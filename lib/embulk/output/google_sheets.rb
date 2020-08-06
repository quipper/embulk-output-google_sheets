require 'google/apis/sheets_v4'
require 'googleauth'
require 'fileutils'


module Embulk
  module Output

    class GoogleSheets < OutputPlugin
      Plugin.register_output("google_sheets", self)

      # To support configuration like below as org.embulk.spi.unit.LocalFile
      #
      # json_keyfile:
      #   content: |
      class LocalFile
        # @return JSON string
        def self.load(v)
          if v.is_a?(String) # path
            File.read(File.expand_path(v))
          elsif v.is_a?(Hash)
            v['content']
          end
        end
      end

      def self.transaction(config, schema, count, &control)
        task = {
          "spreadsheet_id" => config.param("spreadsheet_id", :string),
          "credentials_file_path" => config.param("credentials_file_path", LocalFile, :default => nil),
          "range" => config.param("range", :string, :default => 'Sheet1!A1'),
          "mode" => config.param("mode", :string, :default => 'REPLACE'),
          "header_line" => config.param("header_line", :bool, :default => true)
        }
        task_reports = yield(task)
        next_config_diff = {}
        return next_config_diff
      end

      def init
        @spreadsheet_id = task['spreadsheet_id']
        @credentials_file_path = task['credentials_file_path']
        @range = task['range']
        @mode = task['mode']
        @header_line = task['header_line']
        @service = Google::Apis::SheetsV4::SheetsService.new
        @service.client_options.application_name = "embulk-output-google_sheets"
        @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: StringIO.new(task['credentials_file_path']),
          scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
        )
        @values = []
        if @header_line == true and @mode.downcase == 'replace'
          @values << schema.map(&:name)
        end
      end

      def close
      end

      def add(page)
        page.each do |record|
          @values << record
        end
      end

      def finish
      end

      def abort
      end

      def commit
        target_sheet_title = @range.split("!")[0]

        add_sheet_request = Google::Apis::SheetsV4::AddSheetRequest.new
        add_sheet_request.properties = Google::Apis::SheetsV4::SheetProperties.new(title: target_sheet_title)
        batch_update_spreadsheet_request = [{ add_sheet: add_sheet_request }]
        request_body = Google::Apis::SheetsV4::BatchUpdateSpreadsheetRequest.new(requests: batch_update_spreadsheet_request)

        begin
          @service.batch_update_spreadsheet(@spreadsheet_id, request_body)
        rescue => e
          Embulk.logger.info(e.message)
        end


        if @mode.downcase == 'append'
            request_body = Google::Apis::SheetsV4::ValueRange.new
            request_body.major_dimension = 'ROWS'
            request_body.range = @range
            begin
              @service.append_spreadsheet_value(@spreadsheet_id, @range, request_body, value_input_option: 'USER_ENTERED')
            rescue => e
              Embulk.logger.info(e.message)
            end
        elsif @mode.downcase == 'replace'
            # clear all cells
            request_body = Google::Apis::SheetsV4::BatchClearValuesRequest.new
            request_body.ranges = [@range + ':ZZ']
            begin
              @service.batch_clear_values(@spreadsheet_id, request_body)
            rescue => e
              Embulk.logger.info(e.message)
            end

            # update the worksheet
            request_body = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new
            request_body.value_input_option = 'USER_ENTERED'
            request_body.data = [
                                    {
                                        range: @range,
                                        majorDimension: 'ROWS',
                                        values: @values
                                    }
                                ]
            begin
              @service.batch_update_values(@spreadsheet_id, request_body)
            rescue => e
              Embulk.logger.info(e.message)
            end
        end

        task_report = {}
        return task_report
      end
    end

  end
end
