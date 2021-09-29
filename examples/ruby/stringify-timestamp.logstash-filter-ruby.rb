###############################################################################
# stringify-timestamp.logstash-filter-ruby.rb
# ---------------------------------
# A script for a Logstash Ruby Filter to stringify logstash timestamps using
# ISO-8601.
###############################################################################
def register(params)
  params = params.dup

  # source: the source field to convert
  @source = params.delete('source') || report_configuration_error("missing required param `source`.")

  # target: the target for the converted result
  #         if a target is not provided, conversion will be made in-place
  @target = params.delete('target') || @source
  report_configuration_error("cannot be used to convert field `#{@target}`") if %w(@timestamp [@timestamp]).include?(@target)

  params.empty? || report_configuration_error("unknown script parameter(s): #{params.keys}.")
end

def report_configuration_error(message)
  raise LogStash::ConfigurationError, message
end

def filter(event)
  source_field = event.get(@source)

  return [event] unless source_field

  case
  when source_field.respond_to?(:to_iso8601)
    event.set(@target, source_field.to_iso8601)
  when souece_field.respond_to?(:iso8601)
    event.set(@target, source_field.iso8601)
  else
    fail("source field `#{@source}` not a convertable timestamp") unless source_field.respond_to?(:to_iso8601)
  end
rescue => e
  logger.error('failed to stringify timestamp', exception: e.message)
  event.tag('_stringifytimestamperror')
ensure
  return [event]
end
