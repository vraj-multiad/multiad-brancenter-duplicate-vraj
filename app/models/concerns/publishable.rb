# app/models/concerns/publishable.rb
module Publishable
  extend ActiveSupport::Concern

  included do
    before_create :set_default_publish_dates

    def migrate_pub_dates
      puts 'migrate_pub_dates'
      if expired
        self.publish_at = created_at unless publish_at
        self.unpublish_at = updated_at unless unpublish_at
        self.status = 'complete'
      end
      puts status.to_s
      case status
      when %w(unstaged unpublished complete)
        self.publish_at = created_at unless publish_at
        self.unpublish_at = updated_at unless unpublish_at
      when %w(staged processed pre-publish)
        self.status = 'complete'
        self.status = 'unpublished' if self.class.name == 'AcCreatorTemplate'
        self.publish_at = created_at unless publish_at
        self.unpublish_at = updated_at unless unpublish_at
        self.expired = true
        # We are not going to auto publish... just clear them out.
        # self.publish_at = Time.zone.now.beginning_of_day + 45.days unless publish_at
        # self.unpublish_at = Time.zone.now.beginning_of_day + DEFAULT_PUBLISH_DURATION.years unless unpublish_at
      when 'production'
        self.publish_at = created_at unless publish_at
        self.unpublish_at = Time.zone.now.beginning_of_day + DEFAULT_PUBLISH_DURATION.years unless unpublish_at
      end
    end

    def set_default_publish_dates
      self.publish_at = Time.zone.now.beginning_of_day + DEFAULT_PUBLISH_AT.days
      self.unpublish_at = Time.zone.now.beginning_of_day + DEFAULT_PUBLISH_DURATION.years
    end

    def publish_now
      today = Time.zone.now.beginning_of_day
      self.publish_at = today unless publish_at.present? && publish_at < today
      unpublish_date = today + DEFAULT_PUBLISH_DURATION.years
      self.unpublish_at = unpublish_date unless unpublish_at.present? && unpublish_at > today
    end

    def unpublish_now
      today = Time.zone.now.beginning_of_day
      yesterday = today - 1.day
      self.unpublish_at = today unless unpublish_at.present? && unpublish_at < today
      self.publish_at = yesterday unless publish_at.present? && publish_at < yesterday
    end

    def pub_expire
      unpublish_now
      self.expired = true
      self.status = 'complete'
    end

    def publish
      published = set_status
      publish_keywords
      update_dl_image_groups if self.class.name == 'DlImage'
      published
    end

    def published?
      return false unless publish_at.present?
      Time.zone.now > publish_at && Time.zone.now < unpublish_at
    end

    def calc_status
      return 'unstaged' if status == 'unstaged' # purposely removed
      # return 'staged' if status == 'staged' # purposely removed
      return 'production' if published?
      return 'unpublished' if unpublish_at.present? && Time.zone.now > unpublish_at
      return 'pre-publish' if publish_at.present? && Time.zone.now < publish_at
      'processed'
    end

    def set_status
      return if expired
      orig_status = status
      self.status = calc_status
      save unless orig_status == status
    end

    def republish!
      # future support for keyword removal of expired assets would go here.
      publish_keywords
      self.expired = false
      set_status
    end

    def publish_keywords
      prefix = keyword_prefix
      keywords.each do |k|
        orig_keyword_type = k.keyword_type
        case k.keyword_type
        when 'pre-category', 'category', 'unpublished-category'
          k.keyword_type = prefix + 'category'
        when 'pre-system', 'system', 'unpublished-system'
          k.keyword_type = prefix + 'system'
        when 'pre-search', 'search', 'unpublished-search'
          k.keyword_type = prefix + 'search'
        when 'pre-media_type', 'media_type', 'unpublished-media_type'
          k.keyword_type = prefix + 'media_type'
        when 'pre-topic', 'topic', 'unpublished-topic'
          k.keyword_type = prefix + 'topic'
        else
          # not need to save
          next
        end
        k.save unless k.keyword_type == orig_keyword_type
      end
    end
  end
end
