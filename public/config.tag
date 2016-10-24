<config>
  <div id='container'>
    <div class='ui segment ichimatsu subheader attached'>
      <h1>
        <img class='ui centered image small' src='/assets/images/logo.png'>
      </h1>
    </div>
    <div class='ui inverted segment attached center aligned'>
      <h4 class='ui inverted header'>
        専用URLをメンバーに共有してください
      </h4>
    </div>
    <section>
      <div class='ui main text container'>
        <div class="ui basic very padded center aligned segment">
          <div class='center aligned'>
            <h4>LINEで送る</h4>
            <a href='http://line.me/R/msg/text/?%E3%82%B9%E3%83%9E%E3%83%9Bde%E7%99%BE%E4%BA%BA%E4%B8%80%E9%A6%96%E3%81%AF%E3%81%98%E3%81%BE%E3%82%8B%E3%82%88%EF%BC%81http%3A%2F%2Fkarta.notsobad.jp%2F051973'>
              <div class='ui green labeled icon big button'>
                <i class='comment icon'></i>
                LINEで送る
              </div>
            </a>
          </div>
          <div class='ui horizontal divider'>
            OR
          </div>
          <div class='center aligned'>
            <h4>QRコードを見せない</h4>
            <div id="qrcode"></div>
          </div>
          <div class='ui horizontal divider'>
            OR
          </div>
          <div class='center aligned'>
            <h4>直接URLを伝える</h4>
            <div class='ui icon small info message'>
              <div class='content'>
                <div class='header'>
                  https://karta.notsobad.jp/{opts.__proto__.room_id}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class='ui basic segment center aligned attached padded seigaiha'>
        <div class='ui divider hidden'></div>
        <p>
          全員アクセスできたら
          「ゲーム開始」を押してください。
        </p>
        <a onclick={ play }>
          <button class='ui huge right labeled icon red button'>
            <i class='right arrow icon'></i>
            ゲーム開始
          </button>
        </a>
        <p>
          <small>※まだ音は流れません</small>
        </p>
        <div class='ui divider hidden'></div>
      </div>
    </section>
  </div>

  <footer></footer>

  <div class="ui small modal">
    <i class="close icon"></i>
    <div class="header">Error</div>
    <div class="content">
      <p>
        まだ誰も参加者がいないようです。メンバーが全員共有URLにアクセスしたことを確認してからスタートしてください。
      </p>
    </div>
  </div>


  <script>
    var room_id = opts.__proto__.room_id
		var storage = JSON.parse(sessionStorage.getItem(room_id))

    var current_num = 1
    var answer = storage.answers[current_num]

    $(function(){
      $('#qrcode').qrcode({width: 200, height: 200, text: 'https://karta.notsobad.jp/'+room_id});
    })

    play() {
      $('.red.button').addClass('loading disabled')

      //Distribute cards
      firebase.database().ref('/plays/'+ opts.__proto__.room_id+ '/players').once('value').then(function(data) {
        if(!data.val()) {
          $('.small.modal').modal('show')
          $('.red.button').removeClass('loading disabled')
          return
        }
        var players = Object.keys(data.val())
        storage['players'] = players
				sessionStorage.setItem(room_id, JSON.stringify(storage));

        var answer = storage.answers[current_num]
  			var nums = [] , max = 100
  			for( var i=1; i <= max;){
          if(i!=answer){ nums.push(i) }
          i++
        }
        var wrong_nums = randomItem(nums, players.length-1)
        wrong_nums.push(answer)
        var cards = shuffleAry(wrong_nums)

        var distributions = {}
        for(i in cards) {
          distributions[players[i]] = {
            card: cards[i],
            answer: cards[i]==answer
          }
        }

        var updates = {};
        updates['/plays/' + room_id + '/distributions/' + current_num] = distributions;
        updates['/plays/' + room_id + '/status'] = { current: current_num };
      	firebase.database().ref().update(updates)

        $('.red.button').removeClass('loading disabled')
        riot.route('/'+room_id+'/play')
      },function(error){
        console.log(error)
      });
    }
  </script>
</config>
