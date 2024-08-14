package org.ddialliance.cvpublishing;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileWriter;
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
import java.util.Iterator;
import java.util.Set;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;

public class Collector
{

	public void doJob( String[] args )
	{
		try
		{
			TransformerFactory tf = TransformerFactory.newInstance( "net.sf.saxon.TransformerFactoryImpl", null );
			InputStream xslStreamDDI = this.getClass().getClassLoader()
					.getResourceAsStream( "transformation/SKOS2CodeList.xsl" );
			Transformer tDDI = tf.newTransformer( new StreamSource( xslStreamDDI ) );
			InputStream xslStreamHTML = this.getClass().getClassLoader()
					.getResourceAsStream( "transformation/SKOS2HTML.xsl" );
			Transformer tHTML = tf.newTransformer( new StreamSource( xslStreamHTML ) );

			URL allCurrentURL = new URL(
					"https://vocabularies.cessda.eu/v2/search/vocabularies?agency="
							+ args[0].replaceAll( " ", "%20" ) +
							"&size=100" );
			System.out.println( allCurrentURL );
			URL allPublishedURL = new URL( "https://vocabularies.cessda.eu/v2/vocabularies-published" );

			File rootDir = new File( args[1] );
			if ( !rootDir.exists() )
				rootDir.mkdirs();

			URLConnection allCurrentConn = allCurrentURL.openConnection();
			BufferedReader br = new BufferedReader(
					new InputStreamReader( allCurrentConn.getInputStream(), "UTF-8" ) );

			StringBuffer buffer = new StringBuffer();
			String inputLine;
			while ((inputLine = br.readLine()) != null)
			{
				buffer.append( inputLine );
			}
			br.close();
			JSONParser parser = new JSONParser();
			JSONObject allCurrentRoot = (JSONObject) parser.parse( buffer.toString() );
			JSONArray allCurrentVocabularies = (JSONArray) allCurrentRoot.get( "vocabularies" );

			URLConnection allPublishedConn = allPublishedURL.openConnection();
			br = new BufferedReader(
					new InputStreamReader( allPublishedConn.getInputStream(), "UTF-8" ) );

			buffer = new StringBuffer();
			while ((inputLine = br.readLine()) != null)
			{
				buffer.append( inputLine );
			}
			br.close();
			JSONObject allPublishedRoot = (JSONObject) parser.parse( buffer.toString() );
			JSONObject allPublishedVocabularies = (JSONObject) allPublishedRoot.get( args[0] );
			for ( Object object : allCurrentVocabularies )
			{
				JSONObject vocabulary = (JSONObject) object;
				String vocabularyName = vocabulary.get( "notation" ).toString();
				if ( true )
				{
					Set<String> allSlVersionsForVoc = ((JSONObject) ((JSONObject) allPublishedVocabularies.get( vocabularyName ))
							.get( "en(SL)" )).keySet();

					for ( Iterator<String> iterator = allSlVersionsForVoc.iterator(); iterator.hasNext(); )
					{
						String vocabularyVersion = iterator.next();

						downloadRDF( rootDir, vocabularyVersion, vocabularyName, ".rdf", "application/xml" );
						Thread.sleep( 3000 );
						if ( !vocabularyName.equals( "ModeOfCollection" ) || !vocabularyVersion.startsWith( "4.0." ) )
							download( rootDir, vocabularyVersion, vocabularyName, ".pdf", "application/pdf" );
						// Thread.sleep( 3000 );
						// downloadHTML( rootDir, vocabularyVersion, vocabularyName, ".html",
						// "application/xhtml+xml" );

						// create HTML from RDF
						transformRDF( rootDir, vocabularyVersion, vocabularyName, tDDI, ".rdf", ".xml" );
						// create DDI-XML
						transformRDF( rootDir, vocabularyVersion, vocabularyName, tHTML, ".rdf", ".html" );
						Thread.sleep( 9000 );
					}
				}
			}
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
	}

	private void download(
			File rootDir,
			String vocabularyVersion,
			String vocabularyName,
			String outputFileSuffix,
			String contentType ) throws IOException
	{
		try
		{
			String urlString = "https://vocabularies.cessda.eu/v2/vocabularies/"
					+ vocabularyName + "/" + vocabularyVersion;
			File vocDir = new File( rootDir, vocabularyName + "/" + vocabularyVersion );
			vocDir.mkdirs();
			File toDeleteFile = new File( vocDir, vocabularyName + outputFileSuffix );
			toDeleteFile.delete();
			File file = new File( vocDir, vocabularyName + outputFileSuffix );

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
	}

	private void downloadHTML(
			File rootDir,
			String vocabularyVersion,
			String vocabularyName,
			String outputFileSuffix,
			String contentType ) throws IOException
	{
		String vocabularyVersionShort = vocabularyVersion.substring( 0, vocabularyVersion.indexOf( ".", 2 ) );

		String toReplaceShort = "<a rel=\"canonical URN this version\" href=\"http:\\/\\/vocabularies.cessda.eu:80\\/urn\\/urn:ddi:int.ddi.cv:"
				+
				vocabularyName + ":" + vocabularyVersionShort + "\">urn:ddi:int.ddi.cv:" + vocabularyName + ":" + vocabularyVersionShort
				+ "<\\/a>";

		String toReplaceSL = "<a rel=\"canonical URN this version\" href=\"http:\\/\\/vocabularies.cessda.eu:80\\/urn\\/urn:ddi:int.ddi.cv:"
				+
				vocabularyName + ":" + vocabularyVersionShort + ".0\">urn:ddi:int.ddi.cv:" + vocabularyName + ":" + vocabularyVersionShort
				+ ".0<\\/a>";

		String toReplaceTL = "<a rel=\"canonical URN this version\" href=\"http:\\/\\/vocabularies.cessda.eu:80\\/urn\\/urn:ddi:int.ddi.cv:"
				+
				vocabularyName + ":" + vocabularyVersion + "\">urn:ddi:int.ddi.cv:" + vocabularyName + ":" + vocabularyVersion + "<\\/a>";

		String replacement = "<a rel=\"canonical URI this version\" href=\"http://rdf-vocabulary.ddialliance.org/cv/" +
				vocabularyName + "/" + vocabularyVersion + "/\">http://rdf-vocabulary.ddialliance.org/cv/" + vocabularyName +
				"/" + vocabularyVersion + "/</a>\n" +
				"				</dd>\n" +
				"				<dt>Canonical URN:</dt>\n" +
				"				<dd>\n" +
				"					urn:ddi:int.ddi.cv:" + vocabularyName + ":" + vocabularyVersion;
		try
		{
			String urlString = "https://vocabularies.cessda.eu/v2/vocabularies/"
					+ vocabularyName + "/" + vocabularyVersion;
			File vocDir = new File( rootDir, vocabularyName + "/" + vocabularyVersion );
			vocDir.mkdirs();
			File toDeleteFile = new File( vocDir, vocabularyName + outputFileSuffix );
			toDeleteFile.delete();
			File file = new File( vocDir, vocabularyName + outputFileSuffix );

			HttpClient client = HttpClient.newHttpClient();
			HttpRequest request = HttpRequest.newBuilder( URI.create( urlString ) )
					.header( "accept", contentType )
					.build();
			HttpResponse<String> response = client.send( request, BodyHandlers.ofString() );
			String body = response.body();

			int versionLabelIndex = body.indexOf( "<dt>Version:</dt>" );
			int versionStartIndex = body.indexOf( "<dd>", versionLabelIndex ) + 4;
			int versionEndIndex = body.indexOf( "</dd>", versionLabelIndex );
			String vocabularyVersionCurrent = body.substring( versionStartIndex, versionEndIndex );

			String toReplaceCurrent = "<a rel=\"canonical URN this version\" href=\"http:\\/\\/vocabularies.cessda.eu:80\\/urn\\/urn:ddi:int.ddi.cv:"
					+
					vocabularyName + ":" + vocabularyVersionCurrent + "\">urn:ddi:int.ddi.cv:" + vocabularyName + ":"
					+ vocabularyVersionCurrent + "<\\/a>";

			body = body.replaceAll( toReplaceCurrent, replacement );
			body = body.replaceAll( toReplaceShort, replacement );
			body = body.replaceAll( toReplaceSL, replacement );
			body = body.replaceAll( toReplaceTL, replacement );
			FileWriter writer = new FileWriter( file );
			writer.write( body );
			writer.close();
			System.out.println( response );
		}
		catch (Exception ex)
		{

		}
	}

	private void downloadRDF(
			File rootDir,
			String vocabularyVersion,
			String vocabularyName,
			String outputFileSuffix,
			String contentType ) throws IOException
	{
		String vocabularyVersionShort = vocabularyVersion.substring( 0, vocabularyVersion.indexOf( ".", 2 ) );

		String toReplace = "http://rdf-vocabulary.ddialliance.org/cv/"
				+ vocabularyName + "/" + vocabularyVersionShort + "/";

		String replacement = "http://rdf-vocabulary.ddialliance.org/cv/"
				+ vocabularyName + "/" + vocabularyVersion + "/";
		try
		{
			String urlString = "https://vocabularies.cessda.eu/v2/vocabularies/"
					+ vocabularyName + "/" + vocabularyVersion;
			File vocDir = new File( rootDir, vocabularyName + "/" + vocabularyVersion );
			vocDir.mkdirs();
			File toDeleteFile = new File( vocDir, vocabularyName + outputFileSuffix );
			toDeleteFile.delete();
			File file = new File( vocDir, vocabularyName + outputFileSuffix );

			HttpClient client = HttpClient.newHttpClient();
			HttpRequest request = HttpRequest.newBuilder( URI.create( urlString ) )
					.header( "accept", contentType )
					.build();
			HttpResponse<String> response = client.send( request, BodyHandlers.ofString() );
			String body = response.body();

			body = body.replaceAll( toReplace, replacement );
			FileWriter writer = new FileWriter( file );
			writer.write( body );
			writer.close();
			System.out.println( response );
		}
		catch (Exception ex)
		{

		}
	}

	private void transformRDF(
			File rootDir,
			String vocabularyVersion,
			String vocabularyName,
			Transformer t,
			String inputFileSuffix,
			String outputFileSuffix ) throws IOException, TransformerException
	{
		File vocDir = new File( rootDir, vocabularyName + "/" + vocabularyVersion );
		File file = new File( vocDir, vocabularyName + outputFileSuffix );
		File rdfFile = new File( vocDir, vocabularyName + inputFileSuffix );
		if ( !file.exists() )
			file.createNewFile();
		FileInputStream fis = new FileInputStream( rdfFile );
		FileOutputStream fos = new FileOutputStream( file );
		t.transform( new StreamSource( fis ), new StreamResult( fos ) );
		fis.close();
		fos.close();
	}

}
