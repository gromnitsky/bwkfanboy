/*
  Display plugin info on click.
 */

function List() {}

List.INFO = '#info'

List.prototype.selectCurrent = function(e) {
    $('li > span').each(function(idx) {
		if (this == e) {
//			console.log(idx + ' ' + $(this).text())
			$(this).addClass('pluginSelected')
			$(this).removeClass('pluginUnselected')
		} else {
			$(this).removeClass('pluginSelected')
			$(this).addClass('pluginUnselected')
		}
	})
}

List.prototype.drawPluginInfo = function(plugin, json) {
	$(List.INFO).html('')
	
	var atom = '/' + plugin
	var t = '<table border="1" cellpadding="3">'
	t += '<tr><td>Atom</td><td>' + '<a href="'+atom+'">RSS reader link</a>' + '</td></tr>'
	t += '<tr><td>Title</td><td>' + json["title"] + '</td></tr>'
	t += '<tr><td>Version</td><td>' + json["version"] + '</td></tr>'
	t += '<tr><td>Copyright</td><td>' + json["copyright"] + '</td></tr>'

	// list of URI's
	t += '<tr><td>URI (' + json['uri'].length  + ')</td><td><ul>'
	for (i in json['uri']) {
		t += '<li> <a href="' + json['uri'][i] + '">'+ json['uri'][i] + '</a></li>'
	}
	t += '</ul></td>'
	
	t += '</table>'

	$(List.INFO).html(t)
}

// Select current plugin, sent GET request & fill List.INFO.
List.prototype.getInfo = function(plugin) {
	this.selectCurrent(plugin)
	var name =  $(plugin).text()
	var url = '/info/' + name

	o = this
	r = $.getJSON(url, function(json) {
		o.drawPluginInfo(name, json)
	})
	    .error(function() {
//			console.log(r)
			$(List.INFO).text('Error: ' + r.responseText)
        })

}


List.prototype.mybind = function() {
    var o = this
    $('li > span').click(function() {
		o.getInfo(this)
	})
}


// main

$(function() {
    var list = new List()
	list.mybind()
})
