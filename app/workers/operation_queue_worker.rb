class OperationQueueWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(method, id, *params)
    OperationQueue.find(id).send(method.to_sym, *params)
  end
end
