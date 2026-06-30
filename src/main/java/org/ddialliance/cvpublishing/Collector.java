package org.ddialliance.cvpublishing;

import java.io.*;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.net.http.HttpResponse.BodyHandlers;
import java.nio.file.Path;
import java.util.HashMap;
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
			InputStream xslStreamRDF = this.getClass().getClassLoader()
					.getResourceAsStream( "transformation/SKOSCleanup.xsl" );
			Transformer tRDF = tf.newTransformer( new StreamSource( xslStreamRDF ) );
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
				System.out.println( vocabularyName );
				if ( true )
				{
					Set<String> allSlVersionsForVoc = ((JSONObject) ((JSONObject) allPublishedVocabularies.get( vocabularyName ))
							.get( "en(SL)" )).keySet();
					Set<String> allLangsForVoc = ((JSONObject) allPublishedVocabularies.get( vocabularyName )).keySet();
					HashMap<String, HashMap<String, VersionStructure>> allVersionsToProcess = new HashMap<String, HashMap<String, VersionStructure>>();
					for ( Iterator<String> iterator = allSlVersionsForVoc.iterator(); iterator.hasNext(); )
					{
						String vocabularyVersion = iterator.next();
						String[] versionParts = vocabularyVersion.split( "\\." );
						Integer subminor = Integer.valueOf( versionParts[2] );
						if ( subminor == 0 )
						{
							subminor = Integer.valueOf( 1 );
						}
						if ( !allVersionsToProcess.containsKey( vocabularyVersion ) )
							allVersionsToProcess.put(
									versionParts[0] + "." + versionParts[1] + "." + subminor,
									new HashMap<String, VersionStructure>() );
					}
					for ( Iterator<String> iterator = allLangsForVoc.iterator(); iterator.hasNext(); )
					{
						String lang = iterator.next();
						Set<String> langVersions = ((JSONObject) ((JSONObject) allPublishedVocabularies.get( vocabularyName ))
								.get( lang )).keySet();
						for ( Iterator<String> versionIterator = langVersions.iterator(); versionIterator.hasNext(); )
						{
							String vocabularyVersion = versionIterator.next();
							String[] versionParts = vocabularyVersion.split( "\\." );
							VersionStructure vs = new VersionStructure( versionParts[0], versionParts[1], versionParts[2], lang );
							Integer subminor = Integer.valueOf( versionParts[2] );
							if ( lang.startsWith( "en" ) && subminor.intValue() == 0 )
							{
								subminor = Integer.valueOf( 1 );
							}
							Integer slSubminor = Integer.valueOf( 20 );
							for ( Iterator<String> slVersionIterator = allVersionsToProcess.keySet().iterator(); slVersionIterator
									.hasNext(); )
							{
								String aSlVersion = slVersionIterator.next();
								if ( aSlVersion.startsWith( vs.getMajorMinor() ) )
								{
									Integer aSubminor = Integer.valueOf( aSlVersion.substring( aSlVersion.indexOf( ".", 2 ) + 1 ) );
									if ( subminor <= aSubminor && subminor < slSubminor )
									{
										slSubminor = aSubminor;
									}
								}
							}
							HashMap<String, VersionStructure> version = allVersionsToProcess.get( vs.getMajorMinor() + "." + slSubminor );
							if ( slSubminor < 20 )
							{
								if ( version.containsKey( lang ) )
								{
									version.replace( lang, vs );
								}
								else
								{
									version.put( lang, vs );
								}
							}
						}
					}
					for ( Iterator<String> iterator = allVersionsToProcess.keySet().iterator(); iterator.hasNext(); )
					{
						String aVersionNr = iterator.next();
						String allLangsQuery = "";
						HashMap<String, VersionStructure> allLangVersions = allVersionsToProcess.get( aVersionNr );
						String versionNr = allLangVersions.get( "en(SL)" ).getVersion();
						for ( Iterator<String> langIterator = allLangVersions.keySet().iterator(); langIterator.hasNext(); )
						{
							String lang = langIterator.next();
							VersionStructure aLang = allLangVersions.get( lang );
							allLangsQuery += lang.substring( 0, lang.indexOf( "(" ) );
							allLangsQuery += "-";
							allLangsQuery += aLang.getMajor();
							allLangsQuery += ".";
							allLangsQuery += aLang.getMinor();
							allLangsQuery += ".";
							allLangsQuery += aLang.getSubminor();
							if ( langIterator.hasNext() )
							{
								allLangsQuery += "_";
							}
						}
						boolean available = downloadRDF( rootDir, versionNr, vocabularyName, allLangsQuery, ".rdf",
								"application/rdf+xml", tRDF );
						Thread.sleep( 3000 );
						if ( available )
						{
							// download PDF from CVS
							//download( rootDir, versionNr, vocabularyName, allLangsQuery, ".pdf",
							//		"application/pdf" );
							// create HTML from RDF
							System.out.println( "transforming to DDI" );
							transformRDF( rootDir, versionNr, vocabularyName, tDDI, ".rdf", ".xml" );
							// create DDI-XML
							System.out.println( "transforming to HTML" );
							transformRDF( rootDir, versionNr, vocabularyName, tHTML, ".rdf", ".html" );
							Thread.sleep( 9000 );
						}
						else
						{
							System.out.println( "unavailable" );
						}
						System.out.println( versionNr + ": " + allLangsQuery );
					}

					/*
					 * for ( Iterator<String> iterator = allSlVersionsForVoc.iterator();
					 * iterator.hasNext(); ) { String vocabularyVersion = iterator.next();
					 * 
					 * downloadRDF( rootDir, vocabularyVersion, vocabularyName, ".rdf",
					 * "application/rdf+xml" ); Thread.sleep( 3000 ); download( rootDir,
					 * vocabularyVersion, vocabularyName, ".pdf", "application/pdf" ); //
					 * Thread.sleep( 3000 ); // downloadHTML( rootDir, vocabularyVersion,
					 * vocabularyName, ".html", // "application/xhtml+xml" );
					 * 
					 * // create HTML from RDF transformRDF( rootDir, vocabularyVersion,
					 * vocabularyName, tDDI, ".rdf", ".xml" ); // create DDI-XML transformRDF(
					 * rootDir, vocabularyVersion, vocabularyName, tHTML, ".rdf", ".html" );
					 * Thread.sleep( 9000 ); }
					 */
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
			String langQuery,
			String outputFileSuffix,
			String contentType ) throws IOException
	{
		try
		{
			String urlString = "https://vocabularies.cessda.eu/v2/vocabularies/"
					+ vocabularyName + "/" + vocabularyVersion + "?languageVersion=" + langQuery;
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
			String langQuery,
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
					+ vocabularyName + "/" + vocabularyVersion + "?languageVersion=" + langQuery;
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

	private boolean downloadRDF(
			File rootDir,
			String vocabularyVersion,
			String vocabularyName,
			String langQuery,
			String outputFileSuffix,
			String contentType,
			Transformer t ) throws IOException
	{
		String vocabularyVersionShort = vocabularyVersion.substring( 0, vocabularyVersion.indexOf( ".", 2 ) );

		String toReplace = "http://rdf-vocabulary.ddialliance.org/cv/"
				+ vocabularyName + "/" + vocabularyVersionShort + "/";

		String replacement = "http://rdf-vocabulary.ddialliance.org/cv/"
				+ vocabularyName + "/" + vocabularyVersion + "/";
		try
		{
			String urlString = "https://vocabularies.cessda.eu/v2/vocabularies/"
					+ vocabularyName + "/" + vocabularyVersion + "?languageVersion=" + langQuery;
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
			System.out.println( response );
			if ( response.statusCode() != 200 )
				return false;
			String body = response.body();
			/*
			body = body.replaceAll( toReplace, replacement );

			FileWriter writer = new FileWriter( file );
			writer.write( body );
			writer.close();
			*/
			FileOutputStream fos = new FileOutputStream( file );
			StringReader reader = new StringReader(body);
			t.setParameter("name", vocabularyName);
			t.setParameter("version", vocabularyVersion);
			t.transform( new StreamSource( reader ), new StreamResult( fos ) );
			fos.close();

		}
		catch (Exception ex)
		{
			ex.printStackTrace();
			return false;
		}
		return true;
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

	private class VersionStructure
	{
		private Integer major = Integer.valueOf( 0 );
		private Integer minor = Integer.valueOf( 0 );
		private Integer subminor = Integer.valueOf( 0 );
		private String lang = "";

		public VersionStructure( String major, String minor, String subminor, String lang )
		{
			this.major = Integer.valueOf( major );
			this.minor = Integer.valueOf( minor );
			this.subminor = Integer.valueOf( subminor );
			this.lang = lang;
		}

		public Integer getMajor()
		{
			return major;
		}

		public Integer getMinor()
		{
			return minor;
		}

		public Integer getSubminor()
		{
			return subminor;
		}

		public String getLang()
		{
			return lang;
		}

		public String getMajorMinor()
		{
			return major + "." + minor;
		}

		public String getVersion()
		{
			return major + "." + minor + "." + subminor;
		}
	}
}
