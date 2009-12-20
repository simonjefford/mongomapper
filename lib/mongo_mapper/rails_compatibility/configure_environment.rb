if Object.const_defined?(:Rails)
  MongoMapper.environment = Rails.env
  MongoMapper.configure(Rails.configuration.database_configuration)
end
