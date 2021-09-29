###############################################################################
# A script for a Logstash Ruby Filter to transform field names, possibly
# recursively.
###############################################################################

def register(params)
  params = params.dup

  # transform: the name of the transformation to apply.
  transform = params.delete('transform') || report_configuration_error("script_params must include `transform`.")
  @transformer = {
    'downcase'              => ->(field) { field.downcase },
    'underscore_whitespace' => ->(field) { field.gsub(/\s/, '_') },
  }.fetch(transform) { report_configuration_error("script_params `transform` must be one of #{transformers.keys}; got `#{transform}`." ) }

  # source: if provided, only the provided field reference (and potentially its children)
  #         will be transformed (default: entire event)
  @source = params.delete('source')

  # recursive: set to `true` to enable recusrive walking of deeply-nested hashes and arrays
  #            (default: false)
  recursive = params.delete('recursive') || 'false'
  @recursive = case recursive && recursive.downcase
               when true,  'true'  then true
               when false, 'false' then false
               else report_configuration_error("script_params `recursive` must be either `true` or `false`; got `#{recursive}`.")
               end

  params.empty? || report_configuration_error("unknown value(s) for script_params: #{params.keys}.")
end

def report_configuration_error(message)
  raise LogStash::ConfigurationError, message
end

def filter(event)
  _transform_keys(event, [@source].compact, &@transformer)
rescue => e
  log_meta = {exception: e.message}
  log_meta.update(:backtrace, e.backtrace) if logger.debug?
  logger.error('failed to transform field names', log_meta)
  event.tag('_transformfieldnameserror')
ensure
  return [event]
end

##
# runs the given transformer block on each field reference fragment
def _transform_keys(event, keypath=[], &transformer)
  if keypath.empty?
    node = event.to_hash
  else
    current_field_reference = _build_canonical_field_reference(keypath)
    return unless event.include?(current_field_reference)

    transformed_keypath = keypath.map(&transformer)
    if transformed_keypath != keypath
      target_field_reference = _build_canonical_field_reference(transformed_keypath)
      event.set(target_field_reference, event.remove(current_field_reference))
      keypath = transformed_keypath
      current_field_reference = target_field_reference
    end
    node = event.get(current_field_reference)
  end

  if @recursive || keypath.empty?
    if node.kind_of?(Array)
      node.size.times do |idx|
        _transform_keys(event, keypath + [idx.to_s], &transformer)
      end
    elsif node.kind_of?(Hash)
      node.keys.each do |subkey|
        _transform_keys(event, keypath + [subkey], &transformer)
      end
    end
  end
end

##
# builds a valid field reference from the provided components
def _build_canonical_field_reference(fragments)
  return "[#{fragments.join('][')}]"
end
