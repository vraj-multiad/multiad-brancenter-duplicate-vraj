class ClickEventsController < ApplicationController
  before_action :set_click_event, only: [:show, :edit, :update, :destroy]
  before_action :superuser?, only: [:index, :show, :edit, :create, :update, :destroy]

  def create_user_event
    clickable_item = LoadAsset.load_asset(type: params[:clickable_type], token: params[:token])
    if clickable_item
      _create_clickable_item_click_event(current_user, clickable_item)
    else
      # generic page view
      current_user.click_events.create(click_event_type: 'page_view', event_name: params[:event_name], event_details: params[:event_details])
    end

    render nothing: true
  end

  def _create_clickable_item_click_event(user, clickable_item)
    click_event_type = ''
    case clickable_item.class.name
    when 'DlImage'
      # Only have external links currently
      click_event_type += 'external_link'
      user.click_events.create(clickable_type: clickable_item.class.name, clickable_id: clickable_item.id, click_event_type: click_event_type, event_name: clickable_item.external_link_label, event_details: clickable_item.external_link )
    else
    end
  end

  # GET /click_events
  # GET /click_events.json
  def index
    @click_events = ClickEvent.all
  end

  # GET /click_events/1
  # GET /click_events/1.json
  def show
  end

  # GET /click_events/new
  def new
    @click_event = ClickEvent.new
  end

  # GET /click_events/1/edit
  def edit
  end

  # POST /click_events
  # POST /click_events.json
  def create
    @click_event = ClickEvent.new(click_event_params)

    respond_to do |format|
      if @click_event.save
        format.html { redirect_to @click_event, notice: 'Click event was successfully created.' }
        format.json { render action: 'show', status: :created, location: @click_event }
      else
        format.html { render action: 'new' }
        format.json { render json: @click_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /click_events/1
  # PATCH/PUT /click_events/1.json
  def update
    respond_to do |format|
      if @click_event.update(click_event_params)
        format.html { redirect_to @click_event, notice: 'Click event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @click_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /click_events/1
  # DELETE /click_events/1.json
  def destroy
    @click_event.destroy
    respond_to do |format|
      format.html { redirect_to click_events_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_click_event
      @click_event = ClickEvent.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def click_event_params
      params.require(:click_event).permit(:clickable_type, :clickable_id, :click_event_type, :event_name, :event_details, :user_id)
    end
end
