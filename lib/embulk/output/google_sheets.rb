require 'google/apis/sheets_v4'
require 'googleauth'
require 'fileutils'


module Embulk
  module Output

    class GoogleSheets < OutputPlugin
      Plugin.register_output("google_sheets", self)

      def self.transaction(config, schema, count, &control)
        task = {
          "spreadsheet_id" => config.param("spreadsheet_id", :string),
          "credentials_file_path" => config.param("credentials_file_path", :string),
          "range" => config.param("range", :string),
        }
        task_reports = yield(task)
        next_config_diff = {}
        return next_config_diff
      end

      def init
        @spreadsheet_id = task['spreadsheet_id']
        @credentials_file_path = task['credentials_file_path']
        @range = task['range']
        @service = Google::Apis::SheetsV4::SheetsService.new
        @service.client_options.application_name = "embulk-output-google_sheets"
        @service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
          json_key_io: File.open(@credentials_file_path),
          scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
        )
        @values = []
        @values << schema.map(&:name)
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
          response = @service.batch_update_spreadsheet(@spreadsheet_id, request_body)
          p response
        rescue => e
          Embulk.logger.info(e.message)
        end

        data = [
          {
            range: @range,
            majorDimension: 'ROWS',
            values: @values
          }
        ]

        request_body = Google::Apis::SheetsV4::BatchUpdateValuesRequest.new(value_input_option: 'USER_ENTERED', insert_data_option: 'OVERWRITE', data: data)
        begin
          @service.batch_update_values(@spreadsheet_id, request_body)
        rescue => e
          Embulk.logger.info(e.message)
        end

        task_report = {}
        return task_report
      end
    end

  end
end
