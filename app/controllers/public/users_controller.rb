class Public::UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :is_matching_login_user, only: [:edit, :update]

  def show
    @user = User.find(params[:id])
    @item = Item.new
    @items = @user.items.order(created_at: :desc).page(params[:page])  # created_at を降順で並び替え
    @tag_list = @item.item_tags.pluck(:name).join(',')
  end

  def index
    @users = User.all.where(status: 1)
    @item = Item.new
  end

  def new
    flash[:notice]="Welcome! You have signed up successfully."
    @user == current_user
  end

  def edit
    @user = User.find(params[:id])
    if @user == current_user
      render "edit"
    else
      redirect_to user_path(current_user)
    end
  end

  def update
    @user = current_user
    if @user.update!(user_params)
      redirect_to public_user_path(@user), notice: "プロフィールを更新しました"
    else
      render "edit"
    end
  end

  # フォロー一覧
  def follows
    user = User.find(params[:id])
    @users = user.following_users
  end
  # フォロワー一覧
  def followers
    user = User.find(params[:id])
    @user = user.follower_users
  end
  # ユーザーの公開
  def update_release
    @user =  User.find(params[:user_id])
    @user.released! unless @user.released?
    redirect_to  "/public/users/#{@user.id}/edit", notice: 'このアカウントを公開しました'
  end
  # ユーザーの非公開
  def update_nonrelease
    @user =  User.find(params[:user_id])
    @user.nonreleased! unless @user.nonreleased?
    redirect_to "/public/users/#{@user.id}/edit", notice: 'このアカウントを非公開にしました'
  end


  private

  def user_params
    params.require(:user).permit(:last_name, :first_name, :introduction, :profile_image)
  end

  def is_matching_login_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to user_path(current_user)
    end
  end
end
