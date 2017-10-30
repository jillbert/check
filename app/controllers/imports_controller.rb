class ImportsController < ApplicationController

  def create
  end

  def update
  end

  private

  def imports_params
    params.require(:import).permit(:csv)
  end

end
