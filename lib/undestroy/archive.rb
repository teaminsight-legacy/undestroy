
class Undestroy::Archive
  attr_accessor :source, :config, :transfer

  def initialize(args={})
    validate_arguments(args)

    self.source = args[:source]
    self.config = args[:config]
    self.transfer = args[:transfer]
  end

  def transfer
    @transfer ||= self.config.internals[:transfer].new(
      :klass => self.config.target_class,
      :fields => archive_fields
    )
  end

  def run
    transfer.run
  end

  protected

  def archive_fields
    self.config.primitive_fields(self.source).merge(self.source.attributes)
  end

  def validate_arguments(args)
    unless (args.keys & [:source, :config]).size == 2
      raise ArgumentError, ":source and :config are required keys" 
    end
  end
end

