// oxpeaks_test.v
module hamnn

import os
// import arrays
// import strconv
// import vplot

fn testsuite_begin() ? {
	if os.is_dir('tempfolder1') {
		os.rmdir_all('tempfolder1')?
	}
	os.mkdir_all('tempfolder1')?
}

// fn testsuite_end() ? {
// 	os.rmdir_all('tempfolder1')?
// }

fn inds(a []f64) []f64 {
	mut s := []f64{}
	for i in 0 .. a.len {
		s << i
	}
	return s
}

// test_load_file
fn test_load_file() {
	mut ds := Dataset{}
	ds = load_file('/Users/henryolders/Oxford_dataset_stuff/Oxford-train.tab')
	mut peak_rows := [][]string{}
	mut all_peak_data := [][]string{}
	mut all_peak_locs := [][]int{}
	mut all_locations := []bool{len: 917, init: false}
	mut peak_loc := 0
	for k, raw_spectrum in ds.ox_spectra[0..3] {
		println('k: $k')
		mut file_to_octave := os.open_file('tempfolder1/ox_spectrum.csv', 'w')?
		// println(fid)
		file_to_octave.write_string(raw_spectrum[3..].join(','))?
		file_to_octave.close()
		println(os.execute_or_panic('./octave_find_peaks.m tempfolder1/ox_spectrum.csv tempfolder1/peakfile.csv 3000000'))
		mut peaks_data := os.read_lines('tempfolder1/peakfile.csv')?
		// println(peaks_data)
		locs := peaks_data[0].split(',').map(it.int())
		println('locs: $locs')
		all_peak_locs << locs 
		all_peak_data << peaks_data[1..]
		println("peaks_data[1].split(','): ${peaks_data[1].split(',')}")

		// for i in locs {
		// 	all_locations[i] = true
		// }
		// for j, loc in loc
		// println(all_locations)
		// for j, b in all_locations {
		// 	if b && j < locs.len {
		// 		peak_loc = locs.index(j)
		// 		if peak_loc != -1 {
		// 			println('peak_loc: $peak_loc')
		// 			// peak_rows[k] << peaks_data[1].split(',')[peak_loc]
		// 		}
		// 	}
		// }

		// println('all_locations.filter(it).len: ${all_locations.filter(it).len}')
		// println(peak_rows[k].len)

		// peaks := peaks_data[1].split(',').map(it.f32())
		// heights := peaks_data[2].split(',').map(it.f32())
		// baselines := peaks_data[3].split(',').map(it.f32())
		// roots1 := peaks_data[4].split(',').map(it.f32())
		// roots2 := peaks_data[5].split(',').map(it.f32())
		// println('$peaks \n $locs')
		// row_data := peaks_data.join(',')
		// println('row_data: $row_data')
		// mut row := ds.ox_spectra[4][0..3].join(',') + ',' + peaks_data[1..].join(',')
		// row << row_data
		// println('row: $row')

		}
	// missing_data
	println(all_peak_data.len)
	println(all_peak_data[2].len)
	println(typeof(all_peak_data[0][0]).name)
	mut prev_loc := 0
	mut expanded_row := []string{}
	mut missing_vals_array := []string{len: 917, init: '?'}
	for i, mut row in all_peak_data {  // cycle through all instances
		println(row[0])
		for mut segment in row {    // cycle through each peak data type
			println(segment)
			// split the string and put into an array
			expanded_row = segment.split(',')
			println('expanded_row:$expanded_row')
		}
		// expand the row for only those peaks where loc has a value
		for j, loc in all_peak_locs[i] {   // this cycles through the peaks
			for k in prev_loc..loc {   // this cycles 
				// row[0].insert(loc,'')
				// println('$i $j $k')

				// row = row[0].split(',')
			}
			prev_loc = loc
		}
		peak_rows << [ds.ox_spectra[i + 1][0..3].join(',') + ',' + row.join(',')]
		// println(peak_rows[i])
		// println("row $i length: ${peak_rows[i][0].split(',').len}")
	}


	// arr := peaks_data.map(extract_words(it)).map(f32(strconv.atof_quick(it)))
	
	// mut n := os.fd_close(fid)
	// println(n)
	// mut p1 := vplot.new()
	// p1.style('lines')
	// for a in spectra {
	// 	nums = []
	// 	nums << a.map(f64(strconv.atof_quick(it)))
	// 	p1.plot2(inds(nums[3..]), nums[3..], 'Spectra') or { println('ERROR: $err.msg()') }
	// }
	// os.input('Press any key to continue')
	// p1.close()
}

// println(nums)
