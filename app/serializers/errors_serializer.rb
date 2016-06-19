class ErrorsSerializer < ActiveModel::Serializer
  return object.full_messages
  # root 'error'
  # attributes :message, :code, :status

  # def message
  #   "Validation failed: #{object.full_messages.join(', ')}"
  # end

  # def code
  #   0
  # end

  # def status
  #   422
  # end
end
