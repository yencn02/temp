class SpammableGenerator < Rails::Generator::Base
  attr_reader :spammable_class_name, :spammable_table_name
  
  def initialize(runtime_args, runtime_options={})
    super
    @spammable_class_name = eval runtime_args[0].singularize.capitalize
    @spammable_table_name = @spammable_class_name.table_name
  end
  
  def manifest
    record do |m|
      m.directory 'app/models'
      m.file 'spam_report.rb', 'app/models/spam_report.rb'
      m.migration_template "create_spam_reports.rb", "db/migrate"
    end
  end
  
  def file_name
    "create_spam_reports"
  end
end
