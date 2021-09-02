class SessionsController < ApplicationController
  skip_before_action :login_required

  def new
  end

  def create
    user = User.find_by(email: session_params[:email])
p "------------------" + user.inspect + "------------------" # pメソッドはターミナルに標準出力をさせるメソッドで,inspectはオブジェクトの中身を文字列で表示させるメソッド
    if user.authenticate(session_params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: 'ログインしました。'
    else
      p "分岐B"
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'ログアウトしました。'
  end
  private
  def session_params
    params.require(:session).permit(:email, :password)
  end
end
