package org.ddialliance.cvpublishing;

public class Application
{

	public static void main( String[] args )
	{
		if ( args.length != 2 )
			printHelp();
		Collector coll = new Collector();
		coll.doJob( args );

		System.exit( 0 );
	}

	private static void printHelp()
	{
		System.out.println( "This program needs two arguments:" );
		System.out.println( "1) The agency the dump is applied for, usually \"DDI Alliance\"." );
		System.out.println( "   Please remind that this should be put in quotes when containing whitespace. No encoding wanted" );
		System.out.println( "2) The path to the destination directory." );
		System.out.println( "   The user needs write access to the destination directory." );
		System.out.println();
		System.out
				.println( "A complete run will create a directory for each CV containing RDF, HTML, PDF and DDI-XML." );
		System.exit( 0 );
	}

}
