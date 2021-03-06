# (uses listen.bro just to ensure input sources are more reliably fully-read).
# @TEST-SERIALIZE: comm
#
# @TEST-EXEC: btest-bg-run bro bro -b %INPUT
# @TEST-EXEC: btest-bg-wait -k 5
# @TEST-EXEC: btest-diff out

@TEST-START-FILE input.log
#separator \x09
#fields	i	c
#types	int	count
9223372036854775800	18446744073709551612
-9223372036854775800	18446744073709551612
@TEST-END-FILE

@load frameworks/communication/listen

global outfile: file;

module A;

type Idx: record {
	i: int;
};

type Val: record {
	c: count;
};

global servers: table[int] of Val = table();

event bro_init()
	{
	outfile = open("../out");
	# first read in the old stuff into the table...
	Input::add_table([$source="../input.log", $name="ssh", $idx=Idx, $val=Val, $destination=servers]);
	Input::remove("ssh");
	}

event Input::end_of_data(name: string, source:string)
	{
	print outfile, servers;
	close(outfile);
	terminate();
	}
