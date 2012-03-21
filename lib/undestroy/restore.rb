
class Undestroy::Restore

  attr_accessor :target, :config, :transfer

  def initialize(args={})
    validate_arguments(args)

    self.target = args[:target]
    self.config = args[:config]
    self.transfer = args[:transfer]
  end

  def transfer
    @transfer ||= config.internals[:transfer].new(
      :klass => config.source_class,
      :fields => transfer_fields
    )
  end

  def run
    transfer.run
  end

  protected

  def validate_arguments(args)
    unless (args.keys & [:target, :config]).size == 2
      raise ArgumentError, ":target and :config are required keys"
    end
  end

  def transfer_fields
    self.target.attributes.inject({}) do |hash, (key, value)|
      if config.fields.keys.include?(key)
        hash
      else
        hash.merge(key => value)
      end
    end
  end

end

