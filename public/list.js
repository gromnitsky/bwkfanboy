/*
  Display plugin info on click.
 */

function List() {}

List.INFO = '#info'
List.FORM = 'form'
List.OPTS = 'form input[name="opts"]'

List.prototype.mybind = function() {
    var o = this
    $('li > span').click(function() {
		o.getInfo(this)
	})
	$(List.FORM).submit(function() {
		o.getInfo($('li > span[class="pluginSelected"]'))
		return false;
	})
}

// Select current plugin, sent GET request & fill List.INFO.
List.prototype.getInfo = function(plugin) {
	if (!plugin || plugin.length == 0) return
	
	this.selectCurrent(plugin)
	var name =  $(plugin).text()
	var url = '/info' + this.atom(name)

	o = this
	r = $.getJSON(url, function(json) {
		o.drawPluginInfo(name, json)
	})
	    .error(function() {
			$(List.INFO).text('Error: ' + r.responseText)
        })

}

List.prototype.selectCurrent = function(e) {
    $('li > span').each(function(idx) {
		if ($(e).text() == $(this).text()) {
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

	var opts = this.getOpts()
	var atom = '/' + plugin + (opts ? '?o='+opts : '')
	
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

List.prototype.getOpts = function() {
	var opts = $(List.OPTS).val()
	if (!opts) return ''
	return opts.replace(/\s+/g, ' ').trim()
}

// Return a proper URL to a atom feed of [plugin]
List.prototype.atom = function(plugin) {
	var opts = this.getOpts()
	return '/' + plugin + (opts ? '?o='+opts : '')
}


// main

$(function() {
    var list = new List()
	list.mybind()
})
