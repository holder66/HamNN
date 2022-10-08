// oxpeaks_test.v
module hamnn

import os

fn testsuite_begin() ? {
	if os.is_dir('tempfolder1') {
		os.rmdir_all('tempfolder1')?
	}
	os.mkdir_all('tempfolder1')?
}

// test_load_file
fn test_load_file() {
	// set up a new training file
	mut new_train_file := os.open_file('/Users/henryolders/vlang/vhamnn/datasets/new2500000p_Oxford-train.tab', 'w+')?
	mut ds := Dataset{}
	ds = load_file('/Users/henryolders/Oxford_dataset_stuff/Oxford-train.tab')
	mut peak_rows := [][]string{}
	mut all_peak_data := [][]string{}
	mut all_peak_locs := [][]int{}
	mut all_locations := []bool{len: 917, init: false}
	mut peak_loc := 0
	for k, raw_spectrum in ds.ox_spectra {
		println('k: $k')
		mut file_to_octave := os.open_file('tempfolder1/ox_spectrum.csv', 'w')?
		// println(fid)
		file_to_octave.write_string(raw_spectrum[3..].join(','))?
		file_to_octave.close()
		println(os.execute_or_panic('./octave_find_peaks.m tempfolder1/ox_spectrum.csv tempfolder1/peakfile.csv 2500000'))
		mut peaks_data := os.read_lines('tempfolder1/peakfile.csv')?
		// println(peaks_data)
		locs := peaks_data[0].split(',').map(it.int())
		println('locs: $locs')
		all_peak_locs << locs 
		all_peak_data << peaks_data[1..]
		println("peaks_data[1].split(','): ${peaks_data[1].split(',')}")
		}

	println(all_peak_data.len)
	println(all_peak_data[2].len)
	println(typeof(all_peak_data[0][0]).name)
	mut split_segment := []string{}
		
	for i, mut row in all_peak_data {  // cycle through all instances
		mut expanded_row := []string{}
		println(row[0])
		for mut segment in row[..1] {    // cycle through each peak data type
			// println(segment)
			// split the string and put into an array
			split_segment = segment.split(',')
			// println('expanded_row:$expanded_row')
			mut missing_vals_array := []string{len: 917, init: '?'}
			// println(missing_vals_array)
			// replace the values in missing_vals_array with values from segment
			for j, loc in all_peak_locs[i] {

				missing_vals_array[loc] = split_segment[j]
			}
			// println(missing_vals_array)
			expanded_row << missing_vals_array.join('\t')
			// println('case: $i expanded_row: $expanded_row')	
		}
		peak_rows << [ds.ox_spectra[i][0..3].join('\t') + '\t' + expanded_row.join(',')]
		// println(peak_rows[i])
		println("row $i length: ${peak_rows[i][0].split(',').len}")
		new_train_file.writeln(peak_rows[i][0])?
	}
	new_train_file.close()
}


