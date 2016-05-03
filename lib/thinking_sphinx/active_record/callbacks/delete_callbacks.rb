class ThinkingSphinx::ActiveRecord::Callbacks::DeleteCallbacks <
  ThinkingSphinx::Callbacks

  callbacks :after_destroy

  def after_destroy
    return if ThinkingSphinx::Callbacks.suspended? || instance.new_record?
    indices.each { |index| ThinkingSphinx::Deletion.perform index, instance }
  end

  private

  def config
    ThinkingSphinx::Configuration.instance
  end

  def indices
    config.preload_indices
    config.indices_for_references instance.class.name.underscore.to_sym
  end
end
