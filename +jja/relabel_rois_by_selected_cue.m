function labs = relabel_rois_by_selected_cue(labs)

looks_to_info_left = find( labs, {'info_location_left', 'left-cue'} );
looks_to_info_right = find( labs, {'info_location_right', 'right-cue'} );

looks_to_info = union( looks_to_info_left, looks_to_info_right );

looks_to_random_left = find( labs, {'random_location_left', 'left-cue'} );
looks_to_random_right = find( labs, {'random_location_right', 'right-cue'} );

looks_to_random = union( looks_to_random_left, looks_to_random_right );

setcat( labs, 'roi', 'looks-to-info', looks_to_info );
setcat( labs, 'roi', 'looks-to-random', looks_to_random );

end