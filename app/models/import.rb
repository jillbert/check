class Import < ActiveRecord::Base
mount_uploader :csv, CsvUploader

end
