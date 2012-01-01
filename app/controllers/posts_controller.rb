class PostsController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:show]
  load_and_authorize_resource
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    if user_signed_in?
      format.html {
        @sidebar = {:post => true, :news => false, :posts => true}
        render "noaccess"
      }
      format.gm { render "noaccess"  }
      format.iframe { render "noaccess" }
      format.json { render "noaccess" }
    else
      respond_to do |format|
        format.html {
          redirect_to new_user_session_path, :message => "You might have access to that post if you log in."
        }
        format.gm { render "login"  }
        format.iframe { render "login" }
        format.json { render "login" }
      end
    end
  end
  
  # GET /posts
  # GET /posts.json
  def index
    @sidebar = {:news => false, :posts => true}
    @posts = @posts.page(params[:page]).order('created_at DESC')
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @posts }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @email_share = EmailShare.new
    respond_to do |format|
      format.html {
        @sidebar = {:post => true, :news => false, :posts => true}
        render
      }
      format.gm { render }
      format.iframe { render }
      format.json { render :json => @post, :callback => params[:callback] }
    end
  end

  # GET /posts/new
  # GET /posts/new.json
  def new
    #@post = Post.new
    @sidebar = {:markdown => true, :posts => true, :news => false}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @post }
    end
  end

  # GET /posts/1/edit
  def edit
    @sidebar = {:markdown => true, :post => true, :news => false}
  end

  # POST /posts
  # POST /posts.json
  def create
    
    if current_user
      params[:post].merge!({:user => current_user})
    end
    
    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, :notice => 'Post was successfully created.' }
        format.json { render :json => @post, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to @post, :notice => 'Post was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :ok }
    end
  end
  
  # DELETE /posts/destroy_all
  def destroy_all
    posts = current_user.posts

    posts.each do |post|
      post.destroy
    end

    redirect_to posts_url, :notice => "Destroyed all Posts."

  end
  
end
