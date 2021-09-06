require "byebug"

class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result(distinct: true)

    respond_to do |format|
      format.html
      format.csv { send_data @tasks.generate_csv, filename: "tasks-#{Time.zone.now.strftime('%Y%m%d%s')}.csv" }
    end
  end

  def show
    # @task = current_user.tasks.find(params[:id])
  end

  def new
    @task = Task.new
  end
  def create
    # @task = Task.new(tas_params)
    @task = current_user.tasks.new(task_params)
    if params[:back].present?
      render :new
      return
    end

    if @task.save
      TaskMailer.creation_email(@task).deliver_now
      redirect_to @task, notice: "タスク 「#{@task.name}」を登録しました"
    else
      render :new
    end
  end
  def index
    @tasks = current_user.tasks.order(created_at: :desc)
    # @tasks = Task.all 複数のタスクだからら
  end
  def edit
    # @task = current_user.tasks.find(params[:id])
  end
  def update
    task = current_user.tasks.find(params[:id])
    @task.update!(task_params)
    redirect_to tasks_url, notice: "タスク「#{task.name}」を更新しました。"
  end

  def destroy
    task = current_user.tasks.find(params[:id])
    @task.destroy
    redirect_to tasks_url, notice: "タスク「#{task.name}」を削除しました。"
  end
  private

  def task_params
    params.require(:task).permit(:name, :description, :image)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  end
  # def confirm_new
  #   @task = current_user.tasks.new(task_params)
  #   render :new unless @task.valid?
  # end

  def import
    current_user.tasks.import(params[:file])
    redirect_to tasks_url, notice: "タスクを登録しました"
  end
end