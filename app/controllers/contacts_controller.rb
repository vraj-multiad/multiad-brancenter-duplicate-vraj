class ContactsController < ApplicationController
  before_action :set_contact, only: [:show, :edit, :update, :destroy]
  before_action :logged_in?
  before_action :superuser?, except: [:new_contact, :create_contact, :edit_contact, :remove_contact, :save_contact, :search_form, :search]

  def new_contact
    @contact ||= Contact.new
    @contact_types = ContactType.all
    @contact_action = contact_create_path
    render partial: 'contact_form'
  end

  def create_contact
    @contact = Contact.new(contact_params)
    if @contact.save
      current_user.contacts << @contact
      @notice = t('__saved__')
      return edit_contact
    else
      @notice = t('__failed_to_save__')
      return new_contact
    end
  end

  def edit_contact
    @contact ||= current_user.contacts.find(params[:id])
    if @contact
      @contact_types = ContactType.all
      @contact_action = contact_save_path
      render partial: 'contact_form'
    else
      # cannot find your contact.
      fail
    end
  end

  def remove_contact
    @contact = current_user.contacts.find(params[:id])
    if @contact
      @contact.destroy
      render nothing: true
    else
      # cannot find your contact.
      fail
    end
  end

  def save_contact
    @contact ||= current_user.contacts.find(params[:id])
    if @contact.update(contact_params)
      @notice = t('__saved__')
      return edit_contact
    end
  end

  def search_form
    @user ||= current_user
    @contact_types = ContactType.all
    render partial: 'search_form'
  end

  def search
    @user ||= current_user
    @contacts = @user.contacts
    if params['search'].present?
      search = params['search'].downcase
      field_exceptions = %w()
      contact_search_fields = []
      Contact.columns.each do |c|
        next if field_exceptions.include?(c.name.to_s)
        next unless %w(text string).include?(c.type.to_s)
        contact_search_fields << c.name.to_s
      end
      contact_search_fields.map! do |field|
        "lower(\"contacts\".\"#{field}\") LIKE ?"
      end

      @contacts = @contacts.where(contact_search_fields.join(' OR '), *(["%#{search}%"] * contact_search_fields.size))
    end

    render partial: 'search_results'
  end

  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.all
  end

  # GET /contacts/1
  # GET /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @contact = Contact.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts
  # POST /contacts.json
  def create
    @contact = Contact.new(contact_params)

    respond_to do |format|
      if @contact.save
        format.html { redirect_to @contact, notice: 'Contact was successfully created.' }
        format.json { render action: 'show', status: :created, location: @contact }
      else
        format.html { render action: 'new' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    respond_to do |format|
      if @contact.update(contact_params)
        format.html { redirect_to @contact, notice: 'Contact was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html { redirect_to contacts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @contact = Contact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contact_params
      params.require(:contact).permit(:contact_type_id, :first_name, :last_name, :title, :company_name, :address_1, :address_2, :city, :state, :zip_code, :country, :alt_address, :phone_number, :fax_number, :mobile_number, :website, :email_address, :custom_contact_id, :facebook_id, :twitter_id, :comments, :map_link, :shared_flag, :user_id, :display_name)
    end
end
