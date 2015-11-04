package xt3d.utils.general;

/**
	Standardization of ISO 8601 profiles and their lexical representation.<br/>
	<a href="http://xmpp.org/extensions/xep-0082.html">XMPP Date and Time Profiles</a>
*/
class DateTime {

	static function __init__() {
		ereg_date = ~/^([0-9]{4})-([0-9]{2})-([0-9]{2})(T([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]{3})?(Z|(-[0-9]{2}:[0-9]{2}))?)?$/;
		ereg_time = ~/^([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]{3}Z?)?$/;
	}

	public static var ereg_date(default,null) : EReg;
	public static var ereg_time(default,null) : EReg;

	public static inline function isValidDate( t : String ) : Bool {
		return ereg_date.match( t );
	}

	public static inline function isValidTime( t : String ) : Bool {
		return ereg_time.match( t );
	}

	public static inline function now( ?offset : Int ) : String {
		return fromDate( Date.now(), offset );// utc( Date.now().toString(), offset );
	}

	public static inline function fromDate( d : Date, ?offset : Int ) : String {
		return utc( d.toString(), offset );
	}

	public static inline function fromTime( t : Float, ?offset : Int ) {
		return utc( Date.fromTime( t ).toString(), offset );
	}

	/**
		Formats a (regular) date string to a XMPP compatible UTC date string (CCYY-MM-DDThh:mm:ss[.sss]TZD)<br>
		For example: 2008-11-01 18:45:47 gets 2008-11-01T18:45:47Z<br>
		Optionally a timezone offset could be attached.<br>
	*/
	public static function utc( t : String, ?offset : Null<Int> ) : String {
		var k = t.split( " " );
		if( k.length == 1 )
			return t;
#if (flash||php)
		var b = k[0]+"T"+k[1];
		if( offset == null )
			b += "Z";
		else {
			b += "-";
			if( offset > 9 )
				b += Std.string( offset );
			else {
				b += "0"+Std.string( offset );
			}
			b += ":00";
		}
		return b;
#else
		var b = new StringBuf();
		b.add( k[0] );
		b.add( "T" );
		b.add( k[1] );
		if( offset == null )
			b.add( "Z" );
		else {
			b.add( "-" );
			if( offset > 9 )
				b.add( Std.string( offset ) );
			else {
				b.add( "0" );
				b.add( Std.string( offset ) );
			}
			b.add( ":00" );
		}
		return b.toString();
#end
	}

}