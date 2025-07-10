extends Object
class_name Larik

## 打印标题
static func print_title(_str:String):
    print_rich("[color=#960826] ■ %s [/color]" % _str)

static  func print_content(_str:String):
    print_rich("	[color=#6b3b30] %s [/color]" % _str)


static  func warn(_str:String,_value = null):
    var output = "[color=yellow][Warn]%s[/color] " % _str
    if _value != null:
        output += ": %s" % str(_value)
    print_rich(output)
