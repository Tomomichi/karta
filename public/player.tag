<player>
  <div id='pre'>
    <div class='ui page dimmer active'>
      <div class='content'>
        <div class='center'>
          <h3 class='ui inverted icon header'>
            <i class='notched circle loading icon'></i>
            他のメンバーを待っています
            <div class='sub header'>ゲーム開始まで、このまましばらくお待ちください</div>
          </h3>
        </div>
      </div>
    </div>
  </div>

  <div id="main" class='ui basic segment attached padded seigaiha' style="display:none;">
    <img class='ui centered image' id='karta' src="/assets/components/hyakunin-issyu/images/torifuda/{card_num}.png" />
    <div class='ui page dimmer'>
      <div class='content'>
        <div class='center'>
          <h1 class='ui inverted icon header'>
            <i class="circular icon inverted {answer ? 'orange trophy' : 'blue remove' }" id='icon_result'></i>
            <span id='text_result'>{answer ? '正解！' : 'はずれ！'}</span>
            <div class='ui divider hidden'></div>
          </h1>
          <div>
            <button class='ui inverted big button' onclick="$('#main .dimmer').dimmer('hide');">
              <i class='remove icon'></i>
              閉じる
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>

  <div id='finish' style="display:none;">
    <div class='ui page dimmer active'>
      <div class='content'>
        <div class='center'>
          <h3 class='ui inverted icon header'>
            <i class='circular icon inverted teal checkmark'></i>
            ゲーム終了
          </h3>
        </div>
      </div>
    </div>
  </div>


  <script>
    var that = this
    var room_id = opts.__proto__.room_id
    card_num = '001'

    firebase.auth().onAuthStateChanged(function(user) {
      if(!user){
        firebase.auth().signInAnonymously().catch( function(error) { alert(error.message) } )
      }else {
        var ref = '/plays/'+room_id+'/players/'+user.uid
      	firebase.database().ref(ref).update({uid: user.uid})

        firebase.database().ref('plays/' + room_id + '/distributions').on('child_added', function(data) {
          var distributed = data.val()[user.uid]
          card_num = ('000'+distributed['card']).slice(-3)
          answer = distributed['answer']
          that.update()
        })
      }
    })

    firebase.database().ref('plays/' + room_id + '/status').on('value', function(data) {
      var status = data.val()['current']
      if(status=='finished') {
        $("#finish").show()
        $("#pre").hide()
        $("#main").hide()
      }else if(status=='pre') {
        //pre
      }else {
        $("#pre").hide()
        $("#main").show()
      }
    })


    $(document).ready(function(){
      $("#karta").click(function(){
        $("#main .dimmer").dimmer("toggle")
      })
    })
  </script>
</player>
