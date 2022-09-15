package org.ddialliance.cvpublishing;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpResponse.BodyHandlers;
import java.nio.file.Path;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.json.simple.JSONArray;
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

			URL url = new URL(
					"https://vocabularies.cessda.eu/v2/search/vocabularies?agency="
							+ args[0].replaceAll( " ", "%20" ) +
							"&size=100" );

			File rootDir = new File( args[1] );
			if ( rootDir.exists() && (!rootDir.isDirectory() || !rootDir.canWrite()) )
				PublishingMain.printHelp();
			if ( !rootDir.exists() )
				rootDir.mkdirs();

			// open the stream and put it into BufferedReader
			URLConnection conn = url.openConnection();
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
			JSONArray vocabularies = (JSONArray) root.get( "vocabularies" );
			for ( Object object : vocabularies )
			{
				JSONObject vocabulary = (JSONObject) object;
				String vocabularyName = vocabulary.get( "notation" ).toString();
				String vocabularyVersion = vocabulary.get( "versionNumber" ).toString();

				// downloading RDF
				// https://vocabularies.cessda.eu/v2/vocabularies/TopicClassification/4.0
				/*
				 * <option value="application/xml">application/xml</option> <option
				 * value="application/ld+json">application/ld+json</option> <option
				 * value="text/html">text/html</option> <option
				 * value="application/json">application/json</option> <option
				 * value="application/pdf">application/pdf</option> <option
				 * value="application/xhtml+xml">application/xhtml+xml</option>
				 */
				download( rootDir, vocabularyVersion, vocabularyName, ".rdf", "application/xml" );
				download( rootDir, vocabularyVersion, vocabularyName, ".pdf", "application/pdf" );
				download( rootDir, vocabularyVersion, vocabularyName, ".html", "text/html" );

				// create DDI-XML // createDDI( vocDir, vocName, t );
			}
			/*
			 * if ( root.containsKey( args[0] ) ) { JSONObject agency = (JSONObject) root.get(
			 * args[0] ); for ( Iterator<String> iterator = agency.keySet().iterator();
			 * iterator.hasNext(); ) { String vocName = iterator.next(); System.out.println( vocName
			 * ); File vocDir = new File( rootDir, vocName ); vocDir.mkdirs(); JSONObject voc =
			 * (JSONObject) agency.get( vocName ); StringBuffer versionParameter = new
			 * StringBuffer(); String slVersion = ""; for ( Iterator<String> langIterator =
			 * voc.keySet().iterator(); langIterator.hasNext(); ) { String langText =
			 * langIterator.next(); JSONObject lang = (JSONObject) voc.get( langText );
			 * ArrayList<String> versionList = new ArrayList<String>(); Object[] versions =
			 * lang.keySet().toArray(); for ( int i = 0; i < versions.length; i++ ) {
			 * versionList.add( (String) versions[i] ); } Collections.sort( versionList );
			 * 
			 * if ( langText.contains( "(SL)" ) ) { if ( voc.keySet().size() > 1 )
			 * versionParameter.insert( 0, "_" ); versionParameter.insert( 0, versionList.get(
			 * versionList.size() - 1 ) ); versionParameter.insert( 0, "-" );
			 * versionParameter.insert( 0, langText.substring( 0, langText.indexOf( "(" ) ) );
			 * slVersion = versionList.get( versionList.size() - 1 ); } else {
			 * versionParameter.append( langText.substring( 0, langText.indexOf( "(" ) ) );
			 * versionParameter.append( "-" ); versionParameter.append( versionList.get(
			 * versionList.size() - 1 ) ); versionParameter.append( "_" ); } }
			 * 
			 * // downloading RDF String rdfURL =
			 * "https://vocabularies2-dev.cessda.eu/api/download/rdf/" + vocName + "/" + slVersion +
			 * "?lv=" + versionParameter.toString(); System.out.println( rdfURL ); // download(
			 * rdfURL, vocDir, vocName, ".rdf" );
			 * 
			 * // downloading HTML String htmlURL =
			 * "https://vocabularies2-dev.cessda.eu/api/download/html/" + vocName + "/" + slVersion
			 * + "?lv=" + versionParameter.toString(); // download( htmlURL, vocDir, vocName,
			 * ".html" );
			 * 
			 * // downloading PDF String pdfURL =
			 * "https://vocabularies2-dev.cessda.eu/api/download/pdf/" + vocName + "/" + slVersion +
			 * "?lv=" + versionParameter.toString(); // download( pdfURL, vocDir, vocName, ".pdf" );
			 * 
			 * // create DDI-XML // createDDI( vocDir, vocName, t );
			 * 
			 * } }
			 */
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

	private void download(
			File rootDir,
			String vocabularyVersion,
			String vocabularyName,
			String fileSuffix,
			String contentType ) throws IOException
	{
		try
		{
			String urlString = "https://vocabularies.cessda.eu/v2/vocabularies/"
					+ vocabularyName + "/" + vocabularyVersion;
			System.out.println( urlString );
			File vocDir = new File( rootDir, vocabularyName + "/" + vocabularyVersion );
			vocDir.mkdirs();
			File file = new File( vocDir, vocabularyName + fileSuffix );
			HttpClient client = HttpClient.newHttpClient();
			HttpRequest request = HttpRequest.newBuilder( URI.create( urlString ) )
					.header( "accept", contentType )
					.build();
			HttpResponse<Path> response = client.send( request, BodyHandlers.ofFile( file.toPath() ) );
			System.out.println( response );
		}
		catch (Exception ex)
		{

		}
		// URL source = new URL( urlString );
		// if ( !file.exists() )
		// file.createNewFile();
		// BufferedWriter writer = new BufferedWriter(
		// new OutputStreamWriter( new FileOutputStream( file ) ) );
		// URLConnection connection = source.openConnection();
		// connection.setRequestProperty( "Content-Type", contentType );
		// BufferedReader reader = new BufferedReader(
		// new InputStreamReader( connection.getInputStream() ) );
		// String rdfLine;
		// while ((rdfLine = reader.readLine()) != null)
		// {
		// writer.write( rdfLine );
		// writer.newLine();
		// }
		// reader.close();
		// writer.close();
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
