# coding: UTF-8

require 'sinatra'
require "sinatra/reloader"
require 'json'
require 'securerandom'
require 'HyakuninIssyu'
require 'pusher'
require 'rqrcode'
require 'rqrcode_png'
require 'chunky_png'
require 'base64'


class MyApp < Sinatra::Base
  ##############################################
  # 共通事前処理
  ##############################################
  register Sinatra::Reloader

  before '/:game_id/*' do
    @game_id    = params[:game_id]
  end


  ##############################################
  # 管理者用メニュー
  ##############################################
  get '/' do
    haml :index
  end

  #新規game作成処理
  get '/new' do
    #すでに存在するディレクトリ名と重複しないgame_idを生成して、ディレクトリ作成
    game_id = nil
    dirs = Dir.glob("./tmp/**")
    while (!game_id || dirs.map{|dir| dir.split("/").last}.include?(game_id.to_s)) do
      game_id = format("%0#{6}d", SecureRandom.random_number(10**6))
    end
    Dir::mkdir("./tmp/#{game_id}")

    #プレイ枚数分の正解を決めて、ディレクトリつくっておく
    play_num = 10
    selected_cards = (1..100).to_a.sample(play_num)
    selected_cards.each.with_index(1) do |card_id, i|
      dir_name = "#{format("%03d",i)}_#{format("%03d",card_id)}"
      Dir::mkdir("./tmp/#{game_id}/#{dir_name}")
    end

    redirect "/#{game_id}/config"
  end


  #game設定画面
  get '/:game_id/config' do
    @game_url = "#{ENV['HTTP_HOST']}/#{@game_id}"

    # QRコード画像作成
    qr = RQRCode::QRCode.new( @game_url, :size => 3, :level => :h )
    png = qr.to_img
    img = png.resize(200, 200).save("./tmp/#{@game_id}.png")

    base64 = Base64.strict_encode64(open(img).read)
    mime = "image/png"
    @qr_path = "data:"+ mime + ";base64," + base64

    haml :config
  end


  get '/:game_id/ready' do
    dirs = Dir.glob("./tmp/#{@game_id}/**")
    dir = dirs.sort.first
    dir_name = dir.split("/").last
    @card_id = dir_name.split("_").last.to_i

    @play_count = (10-dirs.count)+1

    @poem = HyakuninIssyu.find(@card_id.to_i)

    @pusher_key = ENV['PUSHER_KEY']
    Pusher.url = ENV['PUSHER_URL']
    Pusher.trigger(@game_id, 'state_changed', {
      status: 'ready'
    })
    haml :ready
  end


  get '/:game_id/finish' do
    #出題が終わったディレクトリを削除
    dir = Dir.glob("./tmp/#{@game_id}/**").sort.first
    deleteall(dir) if dir

    #最後の問題だったら完了、そうじゃなかったら次の歌へ
    dirs = Dir.glob("./tmp/#{@game_id}/**")
    if dirs.count == 0
      redirect "/#{@game_id}/result"
    else
      redirect "/#{@game_id}/ready"
    end
  end


  get '/:game_id/result' do
    Pusher.url = ENV['PUSHER_URL']
    Pusher.trigger(@game_id, 'state_changed', {
      status: 'finish'
    })

    haml :result
  end


  ##############################################
  # プレイヤー用メニュー
  ##############################################
  get '/:game_id' do
    @pusher_key = ENV['PUSHER_KEY']
    haml :player, layout: false
  end


  get '/:game_id/api' do
    #ランダムで最長3秒Sleep(アクセス早い端末が毎回正解になるのを防ぐ)
    n = SecureRandom.random_number(3).to_f
    sleep(n)

    #一番番号が小さいディレクトリにアクセス
    dir = Dir.glob("./tmp/#{@game_id}/**").sort.first
    dir_name = dir.split("/").last

    correct_card_id = dir_name.split("_").last

    #どの札を表示するかを割り当てる
    if File.exist?("#{dir}/#{correct_card_id}.txt")
      #すでに正解があれば、まだ使われてない番号から割り当て
      used_ids = Dir.glob("#{dir}/**").map{|f| File.basename(f, ".txt").to_i}
      card_id = ((1..100).to_a - used_ids).sample
      @card_id = format("%03d", card_id)
    else
      #一番乗りなら正解の番号を割り当てる
      @card_id = correct_card_id
    end
    File.open("#{dir}/#{@card_id}.txt", "w").close()

    data = {
      game_id: @game_id,
      card_id: @card_id,
      result: @card_id==correct_card_id,
    }

    #一番乗りはランダムで最長1秒待つ（最初に開くのが正解ってばれないように）
    n = SecureRandom.random_number(10)/10.to_f
    sleep(n) if @card_id==correct_card_id
    data.to_json
  end


  ##############################################
  # Utilities
  ##############################################
  #指定したディレクトリを中身が空じゃなくても全削除
  def deleteall(delthem)
    if FileTest.directory?(delthem) then  # ディレクトリかどうかを判別
      Dir.foreach( delthem ) do |file|    # 中身を一覧
        next if /^\.+$/ =~ file           # 上位ディレクトリと自身を対象から外す
        deleteall( delthem.sub(/\/+$/,"") + "/" + file )
      end
      Dir.rmdir(delthem) rescue ""        # 中身が空になったディレクトリを削除
    else
      File.delete(delthem)                # ディレクトリでなければ削除
    end
  end
end
