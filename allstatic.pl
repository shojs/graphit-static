#!/usr/bin/perl -w

use strict;
use File::Find;

my $basePath = "http://shojs.github.com/graphit-static";

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
	if (!('_data' in Casset_manager))  {
		Casset_manager._data = {};
	}
}

Casset_manager.prototype.add = function(o, type) {
	if (!(o.dir in Casset_manager._data)) {
		Casset_manager._data[o.dir] = {};
	}
	Casset_manager._data[o.dir][o.file] = { type: type};
};

Casset_manager.prototype.foreach = function(callback) {
	var that = this;
	for(dir in Casset_manager._data) {
		for(file in Casset_manager._data[dir]) {
			callback.call(that, dir, file);
	
		}
	}
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
manager.foreach(function(dir, file) {
var img = document.createElement('img');
img.setAttribute('alt', dir + ' - ' + file);
img.onload = function() {
    document.body.appendChild(img);
};
img.src = baseUrl + '/' + dir + '/' + file;
});
END
wm(\$all, $script);
wm(\$all, '} </script>');

wm(\$all, write_footer());
print $all;
1;
