# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'erb'
require 'securerandom'
require 'sinatra/reloader'

## 仮想マシンで実行時、有効化
## set :bind, '0.0.0.0'

MEMO_FILE = 'public/memos.json'

helpers do
  include ERB::Util

  def load_memos
    File.exist?(MEMO_FILE) ? JSON.parse(File.read(MEMO_FILE)) : []
  end

  def save_memos(memos)
    File.write(MEMO_FILE, JSON.pretty_generate(memos))
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  memos = load_memos
  new_memo = {
    'id' => SecureRandom.uuid,
    'title' => params[:title],
    'content' => params[:content]
  }
  memos << new_memo
  save_memos(memos)

  redirect '/memos'
end

get '/memos/:id' do
  @memo = load_memos.find { |m| m['id'] == params[:id] }
  halt 404, 'Memo not found' unless @memo
  erb :show
end

get '/memos/:id/edit' do
  @memo = load_memos.find { |m| m['id'] == params[:id] }
  halt 404, 'Memo not found' unless @memo

  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  memo = memos.find { |m| m['id'] == params[:id] }
  halt 404, 'Memo not found' unless memo

  memo['title'] = params[:title]
  memo['content'] = params[:content]
  save_memos(memos)

  redirect '/memos'
end

delete '/memos/:id' do
  memos = load_memos
  memo = memos.find { |m| m['id'] == params[:id] }
  halt 404, 'Memo not found' unless memo

  memos.delete(memo)
  save_memos(memos)

  redirect '/memos'
end
