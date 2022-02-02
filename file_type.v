module hamnn

import os

pub fn file_type(path string) string {
	header := os.read_lines(path.trim_space()) or { panic('failed to open $path') }
	if header[0].contains('#') {
		return 'orange_newer'
	} else {
		return 'orange_older'
	}
}
