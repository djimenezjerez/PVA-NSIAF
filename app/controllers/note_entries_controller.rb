class NoteEntriesController < ApplicationController
  before_action :set_note_entry, only: [:show, :edit, :update, :destroy]

  # GET /note_entries
  def index
    @note_entries = NoteEntry.all
  end

  # GET /note_entries/1
  def show
  end

  # GET /note_entries/new
  def new
    @note_entry = NoteEntry.new
  end

  # POST /note_entries
  def create
    @note_entry = NoteEntry.new(note_entry_params)

    if @note_entry.save
      redirect_to @note_entry, notice: 'Note entry was successfully created.'
    else
      render :new
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note_entry
      @note_entry = NoteEntry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def note_entry_params
      params.require(:note_entry).permit(:delivery_note_number, :delivery_note_date, :invoice_number, :invoice_date)
    end
end
