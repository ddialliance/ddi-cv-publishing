package org.ddialliance.cvpublishing;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

public class PublishingMain
{

	private PublishingMain()
	{

	}

	private void doJob( String[] args )
	{
		try
		{
			TransformerFactory tf = TransformerFactory.newInstance();
			InputStream xslStream = this.getClass().getClassLoader()
					.getResourceAsStream( "transformation/SKOS2CodeList.xsl" );
			Transformer t = tf.newTransformer( new StreamSource( xslStream ) );

			URL url = new URL( "https://vocabularies.cessda.eu/v1/vocabulary" );
			URLConnection conn = url.openConnection();

			File rootDir = new File( args[1] );
			if ( rootDir.exists() && (!rootDir.isDirectory() || !rootDir.canWrite()) )
				PublishingMain.printHelp();
			if ( !rootDir.exists() )
				rootDir.mkdirs();

			// open the stream and put it into BufferedReader
			BufferedReader br = new BufferedReader(
					new InputStreamReader( conn.getInputStream(), "UTF-8" ) );

			StringBuffer buffer = new StringBuffer();
			String inputLine;
			while ((inputLine = br.readLine()) != null)
			{
				buffer.append( inputLine );
			}
			br.close();
			JSONParser parser = new JSONParser();
			JSONObject root = (JSONObject) parser.parse( buffer.toString() );
			if ( root.containsKey( args[0] ) )
			{
				JSONObject agency = (JSONObject) root.get( args[0] );
				for ( Iterator<String> iterator = agency.keySet().iterator(); iterator.hasNext(); )
				{
					String vocName = iterator.next();
					System.out.println( vocName );
					File vocDir = new File( rootDir, vocName );
					vocDir.mkdirs();
					JSONObject voc = (JSONObject) agency.get( vocName );
					StringBuffer versionParameter = new StringBuffer();
					String slVersion = "";
					for ( Iterator<String> langIterator = voc.keySet().iterator(); langIterator.hasNext(); )
					{
						String langText = langIterator.next();
						JSONObject lang = (JSONObject) voc.get( langText );
						ArrayList<String> versionList = new ArrayList<String>();
						Object[] versions = lang.keySet().toArray();
						for ( int i = 0; i < versions.length; i++ )
						{
							versionList.add( (String) versions[i] );
						}
						Collections.sort( versionList );

						if ( langText.contains( "(SL)" ) )
						{
							if ( voc.keySet().size() > 1 )
								versionParameter.insert( 0, "_" );
							versionParameter.insert( 0, versionList.get( versionList.size() - 1 ) );
							versionParameter.insert( 0, "-" );
							versionParameter.insert( 0, langText.substring( 0, langText.indexOf( "(" ) ) );
							slVersion = versionList.get( versionList.size() - 1 );
						}
						else
						{
							versionParameter.append( langText.substring( 0, langText.indexOf( "(" ) ) );
							versionParameter.append( "-" );
							versionParameter.append( versionList.get( versionList.size() - 1 ) );
							versionParameter.append( "_" );
						}
					}

					// downloading RDF
					String rdfURL = "https://vocabularies2-dev.cessda.eu/api/download/rdf/" + vocName + "/" + slVersion
							+ "?lv=" + versionParameter.toString();
					System.out.println( rdfURL );
					// download( rdfURL, vocDir, vocName, ".rdf" );

					// downloading HTML
					String htmlURL = "https://vocabularies2-dev.cessda.eu/api/download/html/" + vocName + "/"
							+ slVersion
							+ "?lv=" + versionParameter.toString();
					// download( htmlURL, vocDir, vocName, ".html" );

					// downloading PDF
					String pdfURL = "https://vocabularies2-dev.cessda.eu/api/download/pdf/" + vocName + "/" + slVersion
							+ "?lv=" + versionParameter.toString();
					// download( pdfURL, vocDir, vocName, ".pdf" );

					// create DDI-XML
					// createDDI( vocDir, vocName, t );

				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
			PublishingMain.printHelp();
		}
	}

	public static void main( String[] args )
	{
		if ( args.length != 2 )
			printHelp();
		PublishingMain pm = new PublishingMain();
		pm.doJob( args );

		System.exit( 0 );
	}

	private static void printHelp()
	{
		System.out.println( "This program needs two arguments:" );
		System.out.println( "1) The agency the dump is applied for." );
		System.out.println( "   Please remind that this should be put in quotes whe containing whitespace." );
		System.out.println( "2) The path to the destination directory." );
		System.out.println( "   The user needs write access to the destination directory." );
		System.out.println();
		System.out
				.println( "A complete run will create a directory for each CV containing RDF, HTML, PDF and DDI-XML." );
		System.exit( 0 );
	}

	private void download( String urlString, File vocDir, String vocName, String format ) throws IOException
	{
		System.out.println( urlString );
		URL rdfSource = new URL( urlString );
		File file = new File( vocDir, vocName + format );
		if ( !file.exists() )
			file.createNewFile();
		BufferedWriter writer = new BufferedWriter(
				new OutputStreamWriter( new FileOutputStream( file ) ) );
		BufferedReader reader = new BufferedReader(
				new InputStreamReader( rdfSource.openConnection().getInputStream() ) );
		String rdfLine;
		while ((rdfLine = reader.readLine()) != null)
		{
			writer.write( rdfLine );
			writer.newLine();
		}
		reader.close();
		writer.close();
	}

	private void createDDI( File vocDir, String vocName, Transformer t ) throws IOException, TransformerException
	{
		File file = new File( vocDir, vocName + ".xml" );
		File rdfFile = new File( vocDir, vocName + ".rdf" );
		if ( !file.exists() )
			file.createNewFile();
		FileInputStream fis = new FileInputStream( rdfFile );
		FileOutputStream fos = new FileOutputStream( file );
		t.transform( new StreamSource( fis ), new StreamResult( fos ) );
		fis.close();
		fos.close();
	}
}
