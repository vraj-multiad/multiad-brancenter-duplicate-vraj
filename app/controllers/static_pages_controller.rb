class StaticPagesController < ApplicationController
  include KeywordTermsAdmin
  include KeywordSearchInit

  before_action :logged_in?
  before_action :contributor?, only: [:my_contributions]
  before_action :admin?, only: [:admin]

  def login_redirect
    render nothing: true, layout: 'login_redirect'
  end

  def home
    redirect_to profile_path if current_user.update_profile_flag
    @role_name = ''
    @role_name = current_user.role.name if current_user.role.present?
    @video = InternalVideo.where(status: 'processed').last
    access_ids = current_user.permissions.pluck(:id)
    searchable_type = %w(DlImage DlImageGroup AcCreatorTemplate KwikeeProduct)
    term = 'whatspopular-' + current_language.to_s
    keyword_results = Keyword.where(keyword_type: 'search', searchable_type: searchable_type, term: term).pluck(:searchable_type, :searchable_id)
    access_level_results = AssetAccessLevel.where(access_level_id: access_ids).pluck('distinct restrictable_type, restrictable_id')
    bundle_only_images = DlImage.where(group_only_flag: true).pluck(:id).map! { |id| ['DlImage', id] }
    keyword_index = KeywordIndex.get_index 'date_desc'
    keyword_results -= bundle_only_images
    @whats_popular = keyword_index & keyword_results & access_level_results

    _uncategorized, _no_access_levels = keyword_search_init
    @no_search = true
    @update_search_filters = true
  end

  def help
  end

  def my_library
  end

  def my_documents
  end

  def my_contributions
  end

  def admin
    render_admin_keyword_terms('static_pages', 0, nil, nil)
  end

  def admin_ac_images
  end

  def s3_result
    render xml: { 'Key' => params[:key] }, root: 'PostResponse'
  end

  private

end
