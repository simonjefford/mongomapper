require 'test_helper'

class Address; end

class MongoMapperTest < Test::Unit::TestCase  
  should "be able to write and read connection" do
    conn = Mongo::Connection.new
    MongoMapper.connection = conn
    MongoMapper.connection.should == conn
  end
  
  should "default connection to new mongo ruby driver" do
    MongoMapper.connection = nil
    MongoMapper.connection.should be_instance_of(Mongo::Connection)
  end
  
  should "be able to write and read default database" do
    MongoMapper.database = 'test'
    MongoMapper.database.should be_instance_of(Mongo::DB)
    MongoMapper.database.name.should == 'test'
  end
  
  should "have document not found error" do
    lambda {
      MongoMapper::DocumentNotFound
    }.should_not raise_error
  end
  
  context "use_time_zone?" do
    should "be true if Time.zone set" do
      Time.zone = 'Hawaii'
      MongoMapper.use_time_zone?.should be_true
      Time.zone = nil
    end
    
    should "be false if Time.zone not set" do
      MongoMapper.use_time_zone?.should be_false
    end
  end

  context "configure" do
    setup do
      @configuration = {
        "development" => {
          "host" => 'development_box',
          "port" => 99999,
          "database" => 'dev'
        },
        "production" => {
          "host" => 'production_box',
          "port" => 100000,
          "database" => 'prod'
        }
      }
    end

    should "set up the connection with the default environment settings" do
      Mongo::Connection.expects(:new).with('development_box', 99999, :logger => nil)
      MongoMapper.expects(:database=).with('dev')
      MongoMapper.configure(@configuration)
    end

    should "set up an optional logger" do
      logger = mock('logger')
      connection = mock('connection')
      connection.stubs(:logger).returns(logger)
      Mongo::Connection.expects(:new).with('development_box', 99999, :logger => logger).
                                     returns(connection)
      MongoMapper.stubs(:database=)
      MongoMapper.configure(@configuration, logger)
      MongoMapper.logger.should == logger
    end

    context "with explicit environment" do
      setup do
        MongoMapper.environment = "production"
      end

      should "set up the connection with the configured environment settings" do
        Mongo::Connection.expects(:new).with('production_box', 100000, :logger => nil)
        MongoMapper.expects(:database=).with('prod')
        MongoMapper.configure(@configuration)
      end
    end
  end

  context "time_class" do
    should "be Time.zone if using time zones" do
      Time.zone = 'Hawaii'
      MongoMapper.time_class.should == Time.zone
      Time.zone = nil
    end
    
    should "be Time if not using time zones" do
      MongoMapper.time_class.should == Time
    end
  end
  
  context "normalize_object_id" do
    should "turn string into object id" do
      id = Mongo::ObjectID.new
      MongoMapper.normalize_object_id(id.to_s).should == id
    end
    
    should "leave object id alone" do
      id = Mongo::ObjectID.new
      MongoMapper.normalize_object_id(id).should == id
    end
  end
  
end
