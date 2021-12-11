###############################################################################
# precision-timestamp-parse.logstash-filter-ruby.rb
# ---------------------------------
# A script for a Logstash Ruby Filter to parse timestamps at high precision
# using Ruby's `Time` library and Logstash 8's nano-precise timestamps.
# 
# This is _NOT_ meant to be a performant parser, and is meant as a temporary,
# low-throughput proof-of-concept to stand-in until a better and more
# performant option becomes available.
#
# When run on Logstash < 8, precision will be truncated to miliseconds.
#
###############################################################################
#
# Provide a path to this script to the ruby filter's `path` option,
# and provide the following parameters to its `script_params` option:
#
# source: a reference to the field containing the unparsed high-precision timestamp
# format: one or more format strings.
#    - `ISO8601`: a well-formatted ISO8601 string
#    - `UNIX`: the number of seconds since the unix epoch
#    - `UNIX_MS`: the number of milliseconds since the unix epoch
#    - a valid Ruby `Time#strptime` format string (see: https://apidock.com/ruby/v2_5_5/Time/strptime/class)
# target: a reference to the field in which to place the result (default: `@timestamp`)
#
###############################################################################
#
# Copyright 2021 Ry Biesemeyer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
def register(original_params)
  params = original_params.dup

  source = params.delete('source') { report_configuration_error("script_params must include `source`.") }
  @source = source.dup.freeze

  target = params.delete('target') { '@timestamp' }
  @target = target.dup.freeze

  format = params.delete('format') { report_configuration_error("script_params must include `format`") }
  @formats = Array(format).map(&:freeze).freeze
  report_configuration_error("script_params `format` must not be empty") if @formats.empty?

  params.empty? || report_configuration_error("unknown script_params: #{params.inspect}.")

  require 'time' # Time#iso8601, etc.
  if LOGSTASH_VERSION.start_with?('7.','6.','5.')
    logger.warn("Logstash < 8.0 is limited to millisecond timestamp precision; " +
                "additional precision in timestamps parsed by this filter will be truncated " +
                "(#{__FILE__})")
  end
end

def report_configuration_error(message)
  raise LogStash::ConfigurationError, message
end

def filter(event)
  source = event.get(@source)

  return [event] if source.nil?

  rubytime = @formats.lazy
                     .map { |format| _parse_to_rubytime(source, format) }
                     .reject(&:nil?)
                     .first

  if rubytime.nil?
    event.tag('_precision_timestamp_parse_failure')
  else
    event.set(@target, ::LogStash::Timestamp.new(rubytime.iso8601(9)))
  end

rescue => e
  log_meta = {exception: e.message}
  log_meta.update(:backtrace, e.backtrace) # if logger.debug?
  log_meta.update(:source, source.inspect) if defined?(source) && !source.nil?
  log_meta.update(:format, @formats.to_s )
  logger.error('error parsing timestamp', log_meta)
  event.tag('_precision_timestamp_parse_error')
ensure
  return [event]
end

def _parse_to_rubytime(input, format)
  case format
  when 'ISO8601' then Time.iso8601(input)
  when 'UNIX'    then Time.new(Rational(input))
  when 'UNIX_MS' then Time.new(Rational(input) / 1000)
  else                Time.strptime(input, format)
  end.tap do |rubytime|
    logger.trace("parsed input `#{input}` with format `#{format}` to `#{rubytime.iso8601(9)}`") if logger.trace?
  end
rescue
  logger.trace("Failed to parse input `#{input}` with format `#{format}`") if logger.trace?
  nil
end
