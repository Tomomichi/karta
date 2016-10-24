<play>
  <div id='container'>
    <div class='ui segment ichimatsu subheader attached'>
      <h1>
        <img class='ui centered image small' src='/assets/images/logo.png' />
      </h1>
    </div>
    <div class='ui inverted segment attached center aligned'>
      <h4 class='ui inverted header'>
        第{ current_num }首目
      </h4>
    </div>
    <div class="ui hidden divider"></div>
    <div class="ui center aligned three column stackable grid">
      <div class='ui column'>
        <div class='ui centered card'>
          <div class='image'>
            <img class='ui image medium' id='karta' src='/assets/components/hyakunin-issyu/images/yomifuda/{ answer_num }.jpg' />
          </div>
        </div>
        <div>
          <audio controls preload='auto' src='/assets/components/hyakunin-issyu/audios/{ answer_num }.mp3'>
            <p>お使いのブラウザが音声再生に対応していないようです。現在のURLをコピーして、他のブラウザでアクセスしてみてください。。</p>
          </audio>
        </div>
      </div>
      <div class='ui basic segment center aligned attached padded seigaiha'>
        <div class='ui divider hidden'></div>
        <div>
          <a onclick={ next }>
            <button class='ui huge right labeled icon red button'>
              <i class='right arrow icon'></i>
              次の句へ
            </button>
          </a>
        </div>
        <br />
        <br />
        <div>
          <a onclick={ finish }>
            <button class='ui small basic black button'>
              <i class='remove icon'></i>
              ゲームを終了する
            </button>
          </a>
        </div>
        <div class='ui divider hidden'></div>
      </div>
    </div>
  </div>

  <footer></footer>


  <script>
    var that = this
    var room_id = opts.__proto__.room_id
		var storage = JSON.parse(sessionStorage.getItem(room_id))

    current_num = 1
    var answer = storage.answers[current_num]
    answer_num = ('000'+answer).slice(-3)

    next() {
      $('.red.button').addClass('loading disabled')
      var new_num = current_num + 1

      var new_answer = storage.answers[new_num]
			var nums = [] , max = 100
			for( var i=1; i <= max;){
        if(i!=new_answer){ nums.push(i) }
        i++
      }
      var wrong_nums = randomItem(nums, storage.players.length-1)
      wrong_nums.push(new_answer)
      var cards = shuffleAry(wrong_nums)

      var distributions = {}
      for(i in cards) {
        distributions[storage.players[i]] = {
          card: cards[i],
          answer: cards[i]==new_answer
        }
      }

      var updates = {};
      updates['/plays/' + room_id + '/distributions/' + new_num] = distributions;
      updates['/plays/' + room_id + '/status'] = { current: new_num };
    	firebase.database().ref().update(updates).then(function(){
        current_num = new_num
        answer_num = ('000'+new_answer).slice(-3)
        that.update()
        $('.red.button').removeClass('loading disabled')
      })
    }

    finish() {
      $('.black.button').addClass('loading disabled')
      var updates = {};
      updates['/plays/' + room_id + '/status'] = { current: 'finished' };
    	firebase.database().ref().update(updates).then(function(){
        $('.black.button').removeClass('loading disabled')
        riot.route('/'+room_id+'/result')
      })
    }
  </script>
</play>
