##! This script can be used to extract either the originator's data or the 
##! responders data or both.  By default nothing is extracted, and in order 
##! to actually extract data the ``c$extract_orig`` and/or the
##! ``c$extract_resp`` variable must be set to T.  One way to achieve this
##! would be to handle the connection_established event elsewhere and set the
##! extract_orig and extract_resp options there.  However, there may be trouble
##! with the timing due the event queue delay.
##! This script does not work well in a cluster context unless it has a 
##! remotely mounted disk to write the content files to.

@load utils/files

module Conn;

export {
	## The prefix given to files as they are opened on disk.
	const extraction_prefix = "contents" &redef;
	
	## If this variable is set to T, then all contents of all files will be 
	## extracted.
	const default_extract = F &redef;
}

redef record connection += {
	extract_orig: bool &default=default_extract;
	extract_resp: bool &default=default_extract;
};

event connection_established(c: connection) &priority=-5
	{
	if ( c$extract_orig )
		{
		local orig_file = generate_extraction_filename(extraction_prefix, c, "orig.dat");
		local orig_f = open(orig_file);
		set_contents_file(c$id, CONTENTS_ORIG, orig_f);
		}
		
	if ( c$extract_resp )
		{
		local orig_file = generate_extraction_filename(extraction_prefix, c, "resp.dat");
		local resp_f = open(resp_file);
		set_contents_file(c$id, CONTENTS_RESP, resp_f);
		}
	}