#!/usr/bin/perl -w

use strict;
use File::Find;

my $basePath = "http://shojs.github.com/graphit-static/";

##########
# GLOBAL #
##########
my $nl = "\n";
my $all = "";

sub wm {
    my ($all, $str) = @_;
    $$all.= $str . $nl;
}
    
sub want_images {
	/^.*\.(png|jpg|jpeg|gif)$/i or return;
	my $js = 'manager.add({dir: "'.$File::Find::dir.'", file: "'.$_.'"});';
    wm(\$all, $js);
}

sub write_header {
	my $str = <<END;
<!doctype html>
<html>
<head>
<script type="text/javascript">
var baseUrl = '$basePath';
function Casset_manager() {
    this.className = "CassetManager";
    if (!('_data' in Casset_manager))  {
        Casset_manager._data = {};
        Casset_manager._count_file = 0;
        Casset_manager._count_dir = 0;
    }
}

Casset_manager.prototype.add = function(o, type) {
    if (!(o.dir in Casset_manager._data)) {
        Casset_manager._data[o.dir] = {};
        Casset_manager._count_dir++;
    }
    Casset_manager._data[o.dir][o.file] = { type: type};
    Casset_manager._count_file++;
};

Casset_manager.prototype.foreach = function(callback) {
    var that = this;
    for(dir in Casset_manager._data) {
        for(file in Casset_manager._data[dir]) {
            callback.call(that, dir, file);
    
        }
    }
};

Casset_manager.prototype.to_s = function() {
    var nl = \"\\n\";
    var str = this.className + nl;
    str += 'total file: ' + Casset_manager._count_file + nl;
    str += 'total dir.: ' + Casset_manager._count_dir + nl;
    return str;
};

var manager = new Casset_manager();
</script>
</head>
END
return $str;
}
sub write_footer {
    my $str = <<END;
<body onload="run();">
</body>
</html>
END
return $str;
}
########
# MAIN #
########
wm(\$all, write_header());
wm(\$all, '<script type="text/javascript">function run() {');
find(\&want_images, qw|images|);
my $script = <<END;
var maxWidth = 200;
function info(dir, file, src, img) {
	var info = {
		directory: dir,
		fileName : file,
		width: img.dataset.orignalWidth || img.width,
		height: img.height, 
	}
	for (var k in info) {
		img.setAttribute('data-' + k, info[k]);
	}
	return "";//JSON.stringify(info);
}
manager.foreach(function(dir, file) {
    var src =  baseUrl + '/' + dir + '/' + file;
    var img = document.createElement('img');
    img.onload = function() {
    	var str_info = info(dir, file, src, img);
        img.setAttribute('alt', str_info);
        img.setAttribute('title', str_info);
        var g = document.createElement('div');
        var s = g.style;
        if (img.width > maxWidth) { 
        	img.setAttribute('data-originalwidth', img.width); 
        	img.width = maxWidth; 
        }
        var width = parseInt(img.dataset.originalwidth) || img.width;
        var height = img.height;
        s.display = 'inline';
        g.appendChild(img);
        g.onclick = function() {
        	var wwidth = maxWidth + 100;

        	if (width > maxWidth) { wwidth = width + 100; }
            console.log(wwidth);
        	var w = window.open('', 'AssetPreview', 'width='+wwidth+', height=' + (height + 100));
        	console.log(w);
        	var dw = w.document;
        	var body = dw.body;
        	body.innerHTML = '';
        	var g = document.createElement('div');
        	g.style.width = wwidth + 'px';
        	g.style.textAlign = 'center';
            g.style.marginX = 'auto';
        	var img = document.createElement('img');
        	img.src = src;
        	if ('originalWidth' in img.dataset) {
        		img.width = img.dataset.originalwidth;
        	}
        	img.setAttribute('alt', str_info);
        	img.setAttribute('title', str_info);
        	img.style.display = 'block';
        	g.appendChild(img);
        	g.appendChild(document.createTextNode(str_info));
        	body.appendChild(g);
        }
        g.onmouseover = function() {
        	this.style.backgroundColor = 'black';
        };
        g.onmouseout = function() {
        	this.style.backgroundColor = 'white';
        };
        document.body.appendChild(g);
    };
    img.src = src;
});
document.body.appendChild(document.createTextNode(manager.to_s()));
END
wm(\$all, $script);
wm(\$all, '} </script>');

wm(\$all, write_footer());
print $all;
1;
