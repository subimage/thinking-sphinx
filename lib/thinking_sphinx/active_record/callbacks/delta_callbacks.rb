class ThinkingSphinx::ActiveRecord::Callbacks::DeltaCallbacks <
  ThinkingSphinx::Callbacks

  callbacks :after_commit, :before_save

  def after_commit
    return unless !suspended? && delta_indices? && processors.any? { |processor|
      processor.toggled?(instance)
    }

    delta_indices.each do |index|
      index.delta_processor.index index
    end

    core_indices.each do |index|
      index.delta_processor.delete index, instance
    end
  end

  def before_save
    return unless !ThinkingSphinx::Callbacks.suspended? && delta_indices?

    processors.each { |processor| processor.toggle instance }
  end

  private

  def config
    ThinkingSphinx::Configuration.instance
  end

  def core_indices
    @core_indices ||= indices.reject { |index| index.delta? }
  end

  def delta_indices
    @delta_indices ||= indices.select { |index| index.delta? }
  end

  def delta_indices?
    delta_indices.any?
  end

  def indices
    @indices ||= ThinkingSphinx::IndexSet.new [instance.class], []
  end

  def processors
    delta_indices.collect &:delta_processor
  end

  def suspended?
    ThinkingSphinx::Callbacks.suspended? || ThinkingSphinx::Deltas.suspended?
  end
end
