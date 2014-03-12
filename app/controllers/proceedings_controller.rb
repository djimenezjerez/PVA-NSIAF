class ProceedingsController < ApplicationController
  before_action :set_proceeding, only: [:show]

  # GET /proceedings
  def index
    format_to('proceedings', ProceedingsDatatable, ['user', 'admin', 'proceeding_type', 'created_at'])
  end

  # GET /proceedings/1
  def show
    respond_to do |format|
      format.html
      format.pdf do
        filename = @proceeding.user_name.parameterize || 'acta'
        render pdf: "VSIAF-#{filename}",
               disposition: 'attachment',
               template: 'proceedings/show.html.haml',
               show_as_html: params[:debug].present?,
               orientation: 'Portrait',
               layout: 'pdf.html',
               page_size: 'Letter',
               margin: {
                 top: 15,
                 bottom: 15,
                 left: 20,
                 right: 15
               }
      end
    end
  end

  # POST /proceedings
  def create
    @proceeding = Proceeding.new(proceeding_params)
    @proceeding.admin_id = current_user.id
    respond_to do |format|
      if @proceeding.asset_ids.present? && @proceeding.save
        format.js
      else
        format.js
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_proceeding
      @proceeding = Proceeding.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def proceeding_params
      params.require(:proceeding).permit(:user_id, { asset_ids: [] }, :proceeding_type)
    end
end
