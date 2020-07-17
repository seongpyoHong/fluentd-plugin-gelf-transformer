#
# Fluentd
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

require 'socket'
require 'json'
require 'ostruct'

require 'fluent/plugin/filter'
require 'fluent/config/error'
require 'fluent/event'
require 'fluent/time'


# TODO
# 1. time to unit timestamp (integer) - convertToUnix (Done)
# 2. create short message - createShortMessage (Done)
# 3. null handling (Done)
# 4. modify host field 
module Fluent::Plugin
    class GelfTransformerFilter < Fluent::Plugin::Filter
        Fluent::Plugin.register_filter("gelf_transformer", self)

        helpers :record_accessor

        desc 'The version of GELF payload specification [Mandantory]'
        config_param :version, :string, default: "1.1"
        desc 'A full descriptive message by storing full record'
        config_param :enable_full_message, :bool, default: false
        desc 'The level equal to the standard syslog levels [Optional]'
        config_param :level, :integer, default: 5

        def configure(conf)
            super
        end

        def filter_stream(tag, es)
            new_es = Fluent::MultiEventStream.new
            es.each do |time, record|
                new_record = set_necessary_field(record)
                set_optional_field(record, time, new_record)
                set_custom_field(record ,new_record)
            new_es.add(time, new_record)
            end
            new_es
        end
        
        def set_necessary_field(record)
            new_record = {}
            add_field("version", @version, new_record)
            add_field("host",record['host'], new_record)
            add_field("short_message", record['origin_log'], new_record)
            new_record
        end
        
        def set_optional_field(record, time, new_record) 
            unix_time = convert_to_unix_timestamp(time)     
            if @enable_full_message
                add_field("full_message", record['origin_log'], new_record)
            end
            add_field("timestamp", unix_time, new_record)
            add_field("level", @level, new_record)
        end
        
        def add_field(key, value, new_record) 
            new_record[key] = value
        end

        def set_custom_field(record, new_record)
            prefix = "_"
            record.each do |k,v|
                if k.eql?('host') || k.eql?('origin_log')
                    next
                else
                    new_record[prefix+k] = v
                end
            end
        end
        
        def convert_to_unix_timestamp(time)
            time.to_i
        end
        
    end
end