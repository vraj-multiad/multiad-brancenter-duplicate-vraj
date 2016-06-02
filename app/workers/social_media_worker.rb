class SocialMediaWorker
  include Sidekiq::Worker

  def perform(method, klass, id, *params)
    klass.classify.constantize.find(id).send(method.to_sym, *params)
  end
end
