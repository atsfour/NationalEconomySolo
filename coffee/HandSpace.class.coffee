class HandSpace extends SpaceBase
  @DIV_ID = "hand"

  # バルーンにつけるクラス
  @BALLOON_CLASS_NAME = 'balloon_hand'

  # 選択状態
  @SELECT_NOT   = 0
  @SELECT_LEFT  = 1
  @SELECT_RIGHT = 2
  @SELECT_LEFT2 = 3

  @cards : []
  @select : []

  @init:->
    super()
    @cards  = []
    @select = []

  # 選択状態を取得
  @getSelect:(index)->
    @select[index]
  # 選択状態を変更
  @clickLeft:(index, left2 = false)->
    # 左クリックが2段階の時
    if left2
      if @select[index] is @SELECT_LEFT
        @select[index] = @SELECT_LEFT2
      else
        @select[index] = @SELECT_LEFT
    # 左クリックが1段階の時
    else
      if @select[index] is @SELECT_LEFT
        @select[index] = @SELECT_NOT
      else
        @select[index] = @SELECT_LEFT
  @clickRight:(index)->
    if @select[index] is @SELECT_RIGHT
      @select[index] = @SELECT_NOT
    else
      @select[index] = @SELECT_RIGHT
  # 選択状態を全解除
  @selectReset:->
    @select = []
    @select.push @SELECT_NOT for i in [0...@cards.length]    

  # ソートする
  @sort:->
    @cards.sort()
    @select = []
    @selectReset()

  # カード番号の取得
  @getCardNum:(index)->
    @cards[index]

  # カードクラスの取得
  @getCardClass:(index)->
    Card.getClass @getCardNum index

  # 手札の数を取得
  @getAmount:->
    @cards.length

  # 手札を捨てる
  @trash:(cardIndexs)->
    newCards = []
    for index in [0...@cards.length]
      newCards.push @cards[index] unless cardIndexs.in_array index
    @cards = newCards

  # 手札を増やす
  @push:(cardNum)->
    @cards.push Number cardNum
    @select.push @SELECT_NOT

  # 描画
  @redraw:->
    me = @getElement()

    me.html('')
    # バルーンも削除
    $('.'+@BALLOON_CLASS_NAME).remove()
    for index in [0...@cards.length]
      e = @createElement index
      me.append e if e isnt false
      e.addClass "select_left"  if @select[index] is @SELECT_LEFT
      e.addClass "select_left2" if @select[index] is @SELECT_LEFT2
      e.addClass "select_right" if @select[index] is @SELECT_RIGHT

  # 要素作成
  @createElement:(index)->
    # ハンドになければ脱出
    return false unless @cards[index]?

    # カードのクラス
    cardClass = Card.getClass @cards[index]
    # カード名
    name = cardClass.getName()
    # カテゴリ
    cat = cardClass.getCategory()
    # コスト
    cost = cardClass.getCost()
    # 売却価格
    price = cardClass.getPrice()
    # 得点
    point = cardClass.getPoint()
    # 説明文
    desc = cardClass.getDescription()

    # カードの外側
    e = $('<div>').attr('data-index', index).addClass('hand')

    # ヘッダ
    # [コスト]カード名
    header = $('<span>').addClass('hand_header').html('['+cost+']'+cardClass.getName())

    # 画像
    img = cardClass.getImageObj().addClass('hand_image')

    # フッタ
    # カテゴリ
    catStr = if cat? then '['+cat+']' else ''
    categorySpan = $('<span>').addClass('hand_footer hand_category').html(catStr)
    # 得点
    pointSpan = $('<span>').addClass('hand_footer hand_point').html('[$'+point+']')

    # 2段階目の選択であることを示す数字
    number = $('<span>').html('２').addClass('order')

    # 説明の吹き出し
    catBalloon = if cat? then cat else 'なし'
    balloonStr = """
    #{desc}
    --------------------
    カテゴリ：#{catBalloon}
    コスト：#{cost}
    売却価格：#{price}
    得点：#{point}
    """.replace /\n/g, '<br>'
    e.attr('data-tooltip', balloonStr).darkTooltip(
      addClass : @BALLOON_CLASS_NAME
    )

    # 選択状態にする
    e.on 'click', ->
      index = $(this).attr('data-index')
      Game.handClickLeft Number index
    e.on 'contextmenu', ->
      index = $(this).attr('data-index')
      Game.handClickRight Number index
    # ダブルクリックにする
    e.dblclick ->
      index = $(this).attr('data-index')
      Game.handDoubleClick Number index

    e.append header
    e.append img
    e.append categorySpan
    e.append pointSpan
    e.append number
    e


  @isHandOver:->
    @getAmount() > @getMax()

  # 所持できる最大枚数
  @getMax:->
    # 手札の最大枚数
    handMax = 5
    # 倉庫の数
    soukoNum = Game.objs.private.getAmountExistSouko()

    handMax + soukoNum*4