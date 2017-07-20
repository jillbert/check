class NationsController < ApplicationController
  def index
    @credential = check_credential

    if @credential
      redirect_to landing_path
    end

  end

  def new
    @nation = Nation.new
  end

  def create
    @nation = Nation.new(nation_params)

    if @nation.save
      flash[:success] = "Nation created"
      redirect_to nations_path
    else
      render :new
    end
  end

  def edit
    @nation = Nation.find(params[:id])
  end

  def update
    @nation = Nation.find(params[:id])
    if @nation.update_attributes(nation_params)
      flash[:success] = "Nation updated"
      redirect_to nations_path
    else
      render :edit
    end
  end

  def destroy
    @nation = Nation.find(params[:id])
    @nation.destroy
    redirect_to nations_path
  end

  private
  def nation_params
    params.require(:nation).permit(:name, :url, :client_uid, :secret_key)
  end
end
