###############################################################################
# estimate-serialized-size.logstash-filter-ruby.rb
# ---------------------------------
# A script for a Logstash Ruby Filter to estimate the serialized size of an
# event or one of its fields.
###############################################################################

def register(original_params)
  params = original_params.dup

  # source: if provided, only the value at the provided field reference will
  #         be estimated (default: entire event)
  @source = params.delete('source')

  # target: where to place the size estimate. Because setting this field changes
  #         the size of the event, it is stored in a @metadata field by default
  @target = params.delete('target') || '[@metadata][serialized_size_estimate]'

  # metadata: whether to include metadata in size estimate. Because most
  #           outputs do NOT include metadata, it is skipped by default.
  #           Option is not available when specifying `source`.
  @metadata = params.delete('metadata')
  @metadata = case @metadata && @metadata.downcase
              when      true,  'true'  then true
              when nil, false, 'false' then false
              else report_configuration_error("script parameter `metadata` must be either `true` or `false`; got `#{@metadata}`.")
              end

  if original_params.include?('source') && original_params.include?('metadata')
    report_configuration_error("script may provide EITHER `source` XOR `metadata`; both were provided.")
  end

  params.empty? || report_configuration_error("unknown script parameter(s): #{params.keys}.")
end

def report_configuration_error(message)
  raise LogStash::ConfigurationError, message
end

def filter(event)
  event.set(@target, estimate_size(event))
rescue => e
  logger.error('failed to estimate serialized size', exception: e.message)
  event.tag('_estimateserializedsizeerror')
ensure
  return [event]
end

def estimate_size(event)
  if @source
    LogStash::Json.dump(event.get(@source)).size
  elsif @metadata
    LogStash::Json.dump(event.to_hash_with_metadata).size
  else
    event.to_json.size
  end
end

# These tests ensure that our serialization estimate is "close enough" to
# expected baselines. Serialization length may vary slightly depending on
# factors such as the version of Logstash being run.
test 'default' do
  parameters { Hash.new }

  in_event do
    {
      "int" => 1,
      "str" => "banana",
      "array" => [
        {"int" => 12},
        {"str" => "baNAna"},
        {"empty_hash" => {}},
        {"empty_array" => []}
      ],
      "hash" => {
        "int" => 123,
        "str" => "FUBAR",
        "empty_hash" => {},
        "empty_array" => [],
        "non-empty_hash" => {"a"=>"b"}
      },
      '@metadata' => { "str" => ("a"*1024) }
    }
  end

  expect("estimates serialized size without metadata") do |events|
    events.size == 1 && (events.first.get("[@metadata][serialized_size_estimate]") - 247).abs <= 10
  end
end

test 'source' do
  parameters { {"source" => "[hash]"} }

  in_event do
    {
      "int" => 1,
      "str" => "banana",
      "array" => [
        {"int" => 12},
        {"str" => "baNAna"},
        {"empty_hash" => {}},
        {"empty_array" => []}
      ],
      "hash" => {
        "int" => 123,
        "str" => "FUBAR",
        "empty_hash" => {},
        "empty_array" => [],
        "non-empty_hash" => {"a"=>"b"}
      },
      '@metadata' => { "str" => ("a"*1024) }
    }
  end

  expect("estimates serialized size of source field only") do |events|
    events.size == 1 && (events.first.get("[@metadata][serialized_size_estimate]") - 85).abs <= 10
  end
end

test 'metadata' do
  parameters { {"metadata" => "true"} }

  in_event do
    {
      "int" => 1,
      "str" => "banana",
      "array" => [
        {"int" => 12},
        {"str" => "baNAna"},
        {"empty_hash" => {}},
        {"empty_array" => []}
      ],
      "hash" => {
        "int" => 123,
        "str" => "FUBAR",
        "empty_hash" => {},
        "empty_array" => [],
        "non-empty_hash" => {"a"=>"b"}
      },
      '@metadata' => { "str" => ("a"*1024) }
    }
  end

  expect("estimates serialized size with metadata") do |events|
    events.size == 1 && (events.first.get("[@metadata][serialized_size_estimate]") - 1294).abs <= 10
  end
end
