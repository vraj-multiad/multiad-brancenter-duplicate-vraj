class AcExportEmailWorker
  include Sidekiq::Worker

  sidekiq_options retry: false

  def perform(method, id, *params)
    AcExport.find(id).send(method.to_sym, *params)
  end
end
