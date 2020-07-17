require "timecop"
require "helper"
require "fluent/plugin/filter_gelf_transformer.rb"

class GelfTransformerFilterTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
    @tag = 'test.tag'
    @time = event_time('2020/03/18:00:59:59', format: '%Y/%m/%d:%T')
    @unix_time = 1584460799
    @origin_log_with_ua = '1.2.3.4 - testUser123 [2020/03/18:00:59:59] "POST /test/url/test.url123!@# HTTP/1.1" 200 1048 "https://www.testexample/test1=example1" "Mozilla/5.0 (Linux; Android 8.1.0; SM-G611K Build/M1AJQ) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.128 Whale/1.0.0.0 Crosswalk/23.69.602.0 Mobile Safari/537.36" "-" "1.2.3.4" 6095'
    @origin_log_with_no_ua ='1.2.3.4 - testUser123 [2020/03/18:00:59:59] "POST /test/url/test.url123!@# HTTP/1.1" 200 1048 "https://www.testexample/test1=example1" "axios/0.18.1" "-" "1.2.3.4" 6095'
    @parsed_record_with_ua= {
      'host'              => '1.2.3.4',
      'origin_log'      => @origin_log_with_ua,
      'user'              => 'testUser123',
      'method'            => 'POST',
      'url'               => '/test/url/test.url123!@#',
      'protocol'          => 'HTTP/1.1',
      'code'              => 200,
      'size'              => 1048,
      'referer'           => 'https://www.testexample/test1=example1',
      'remote_address'    => nil,
      'x_forwarded_for'   => '1.2.3.4',
      'processing_time'   => 6095,
      'agent_name'        => 'CrosswalkApp',
      'agent_full_version'=> '23.69.602.0',
      'agent_os_name'     => 'Android',
      'agent_os_full_version' => '8.1.0',
      'agent_device_name'     => 'SM-G611K',
      'agent_device_type'     => 'smartphone'
    }

    @parsed_record_with_no_ua = {
      'host'              => '1.2.3.4',
      'origin_log'        => @origin_log_with_no_ua,
      'user'              => 'testUser123',
      'method'            => 'POST',
      'url'               => '/test/url/test.url123!@#',
      'protocol'          => 'HTTP/1.1',
      'code'              => 200,
      'size'              => 1048,
      'referer'           => 'https://www.testexample/test1=example1',
      'remote_address'    => nil,
      'x_forwarded_for'   => '1.2.3.4',
      'processing_time'   => 6095
    }

    @expected_with_ua = {
      'version'               => '1.1',
      'host'                  => '1.2.3.4',
      'short_message'         => @origin_log_with_ua,
      'timestamp'             => nil,
      'level'                 => 5,
      '_user'                  => 'testUser123',
      '_method'                => 'POST',
      '_url'                   => '/test/url/test.url123!@#',
      '_protocol'              => 'HTTP/1.1',
      '_code'                  => 200,
      '_size'                  => 1048,
      '_referer'               => 'https://www.testexample/test1=example1',
      '_remote_address'        => nil,
      '_x_forwarded_for'       => '1.2.3.4',
      '_processing_time'       =>  6095,
      '_agent_name'            => 'CrosswalkApp',
      '_agent_full_version'    => '23.69.602.0',
      '_agent_os_name'         => 'Android',
      '_agent_os_full_version' => '8.1.0',
      '_agent_device_name'     => 'SM-G611K',
      '_agent_device_type'     => 'smartphone'
    }

    @expected_with_no_ua = {
      'version'               => '1.1',
      'host'                  => '1.2.3.4',
      'short_message'         => @origin_log_with_no_ua,
      'timestamp'             => nil,
      'level'                 => 5,
      '_user'                  => 'testUser123',
      '_method'                => 'POST',
      '_url'                   => '/test/url/test.url123!@#',
      '_protocol'              => 'HTTP/1.1',
      '_code'                  => 200,
      '_size'                  => 1048,
      '_referer'               => 'https://www.testexample/test1=example1',
      '_remote_address'        => nil,
      '_x_forwarded_for'       => '1.2.3.4',
      '_processing_time'       =>  6095
    }

    @expected_with_full_msg_ua = {
      'version'               => '1.1',
      'host'                  => '1.2.3.4',
      'short_message'         => @origin_log_with_ua,
      'full_message'          => @origin_log_with_ua,
      'timestamp'             => nil,
      'level'                 => 5,
      '_user'                  => 'testUser123',
      '_method'                => 'POST',
      '_url'                   => '/test/url/test.url123!@#',
      '_protocol'              => 'HTTP/1.1',
      '_code'                  => 200,
      '_size'                  => 1048,
      '_referer'               => 'https://www.testexample/test1=example1',
      '_remote_address'        => nil,
      '_x_forwarded_for'       => '1.2.3.4',
      '_processing_time'       =>  6095,
      '_agent_name'            => 'CrosswalkApp',
      '_agent_full_version'    => '23.69.602.0',
      '_agent_os_name'         => 'Android',
      '_agent_os_full_version' => '8.1.0',
      '_agent_device_name'     => 'SM-G611K',
      '_agent_device_type'     => 'smartphone'
    }

    @expected_with_full_msg_no_ua = {
      'version'               => '1.1',
      'host'                  => '1.2.3.4',
      'short_message'         => @origin_log_with_no_ua,
      'full_message'          => @origin_log_with_no_ua,
      'timestamp'             => nil,
      'level'                 => 5,
      '_user'                  => 'testUser123',
      '_method'                => 'POST',
      '_url'                   => '/test/url/test.url123!@#',
      '_protocol'              => 'HTTP/1.1',
      '_code'                  => 200,
      '_size'                  => 1048,
      '_referer'               => 'https://www.testexample/test1=example1',
      '_remote_address'        => nil,
      '_x_forwarded_for'       => '1.2.3.4',
      '_processing_time'       =>  6095
    }

    Timecop.freeze(@time)
  end

  CONFIG_WITH_ENABLE_FULL_MESSAGE = %[
    enable_full_message  true   
  ]  

  CONFIG_NOTHING = ''
  
  teardown do
    Timecop.return
  end

  def create_driver(conf)
    Fluent::Test::Driver::Filter.new(Fluent::Plugin::GelfTransformerFilter).configure(conf)
  end

  def filter(config,record)
    driver = create_driver(config)
    driver.run {
      driver.feed(@tag, @time, record)
    }
    driver.filtered
  end
  
  sub_test_case 'configuration' do
    test 'unix_time' do 
      assert_equal(@time.to_i, @unix_time)
    end
  end

  sub_test_case 'no_parameter_case' do
    test 'timestamp' do
      filtered_records = filter(CONFIG_NOTHING, @parsed_record_with_ua)
      filtered_records.each { |t,r|
        assert_equal(r['timestamp'], @unix_time)
      }
    end

    test 'record by transforming to gelf format with valid user-agent' do
      filtered_records = filter(CONFIG_NOTHING, @parsed_record_with_ua)
      filtered_records.each { |t,r|
        @expected_with_ua['timestamp'] = @unix_time
        assert_equal(t, @time)
        assert_equal(r, @expected_with_ua)
      } 
    end

    test 'record by transforming to gelf format with invalid user-agent' do
      filtered_records = filter(CONFIG_NOTHING, @parsed_record_with_no_ua)
      filtered_records.each { |t,r|
        @expected_with_no_ua['timestamp'] = @unix_time
        assert_equal(t, @time)
        assert_equal(r, @expected_with_no_ua)
      } 
    end
  end

  sub_test_case 'enable_full_message_case' do
    test 'timestamp' do
      filtered_records = filter(CONFIG_WITH_ENABLE_FULL_MESSAGE, @parsed_record_with_ua)
      filtered_records.each { |t,r|
        assert_equal(r['timestamp'], @unix_time)
      }
    end
    
    test 'record by transforming to gelf format with valid user-agent' do
      filtered_records = filter(CONFIG_WITH_ENABLE_FULL_MESSAGE, @parsed_record_with_ua)
      filtered_records.each { |t,r|
        
        @expected_with_full_msg_ua['timestamp'] = @unix_time
        assert_equal(t, @time)
        assert_equal(r, @expected_with_full_msg_ua)
      } 
    end

    test 'record by transforming to gelf format with invalid user-agent' do 
      filtered_records = filter(CONFIG_WITH_ENABLE_FULL_MESSAGE, @parsed_record_with_no_ua)
      filtered_records.each { |t,r|
        
        @expected_with_full_msg_no_ua['timestamp'] = @unix_time
        assert_equal(t, @time)
        assert_equal(r, @expected_with_full_msg_no_ua)
      } 
    end
  end

end
