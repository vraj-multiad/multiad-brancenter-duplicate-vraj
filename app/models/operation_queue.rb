# == Schema Information
#
# Table name: operation_queues
#
#  id             :integer          not null, primary key
#  operable_type  :string(255)
#  operable_id    :integer
#  queue_type     :string(255)
#  operation_type :string(255)
#  operation      :string(255)
#  status         :string(255)      default("")
#  error_message  :string(255)
#  path           :string(255)
#  alt_path       :string(255)
#  scheduled_at   :datetime
#  completed_at   :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  token          :string(255)
#

class OperationQueue < ActiveRecord::Base
  include Tokenable
  belongs_to :operable, polymorphic: true

  default_scope { order(created_at: :asc) }

  scope :ready, -> { where(status: 'ready') }
  scope :locked, -> { where(status: 'locked') }
  scope :completed, -> { where(status: 'complete') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :in_process, -> { where(status: %w(in_process)) }
  scope :busy, -> { where(status: %w(in_process locked)) }
  scope :incomplete, -> { where("#{table_name}.status not in ('complete','cancelled')") }
  scope :empty, -> { where("#{table_name}.status is null or #{table_name}.status = '')") }

  # queue types
  scope :approve_users, -> { where(queue_type: 'approve_user') }
  scope :approve_documents, -> { where(queue_type: 'approve_document') }
  scope :approve_orders, -> { where(queue_type: 'approve_order') }

  def reset
    self.status = 'ready'
    self.save!
  end

  def lock
    self.status = 'locked'
    self.save!
  end

  def in_process
    self.status = 'in_process'
    self.save!
  end

  def cancel
    self.status = 'cancelled'
    self.save!
  end

  def complete
    self.status = 'complete'
    self.save!
  end
end
