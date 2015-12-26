$(document).ready(function(){
  var game_id = location.href.split("/").pop();

  var pusher_key = $("#pusher").text();
  var pusher = new Pusher(pusher_key);
  var channel = pusher.subscribe(game_id);
   channel.bind('state_changed', function(data) {
     switch(data.status){
     //詠み上げ前画面。取り札はまだ結果表示しない
     case 'ready' :
       //表示する歌情報をAjaxで取得
       $.ajax({
         url: "/"+game_id+"/api"
       }).done(function(data){ //ajaxの通信に成功した場合
         var json = $.parseJSON(data);
         $("#poem").html(json.poem);  //取り札の文言をセット
         //正解か不正解かをclassで付与
         if(json.result){
           $("#icon_result").removeClass("blue remove").addClass("orange trophy");
           $("#text_result").text("正解！");
         }else{
           $("#icon_result").addClass("blue remove").removeClass("orange trophy");
           $("#text_result").text("はずれ！");
         }
       }).fail(function(data){ //ajaxの通信に失敗した場合
         alert("エラーが発生しました。通信環境を確認してください。");
       });
       $("#pre").hide();
       $("#main").show();
       $("#finish").hide();

       $("#karta").removeClass("active");
       break;
     //詠み上げ開始。取り札を結果表示できるようにする
     case 'play' :
     /*
       $("#pre").hide();
       $("#main").show();
       $("#finish").hide();

       $("#karta").addClass("active");
     */
       break;
     //全ゲーム終了。終了画面を表示する
     case 'finish' :
       $("#pre").hide();
       $("#main").hide();
       $("#finish").show();
       $("#karta").removeClass("active");
       break;
     }
   });

   //最初に非表示にする
   $("#main").hide();
   $("#finish").hide();

   $("#karta").click(function(){
     $("#main .dimmer").dimmer("toggle");
   });
});
