package haxelibpackager;
import haxe.ds.StringMap;
import haxe.xml.Fast;
import sys.io.File;

/**
 * ...
 * @author duke
 */
class XmlConfigReader
{
	public var releaseInfoList = new StringMap<String>();
	public var libraryList = new StringMap<String>();
	public var excludedFileList = new Array<String>();
	public var tempPath:String = "temp";
	public var combinedName:String;
	public var password:String = "";

	public function new() 
	{
		
	}
	
	public function readConfig( url:String ):Bool
	{
		
		var content:String;
		try
		{
			content = File.getContent(url);
			
		}
		catch ( e:Dynamic )
		{
			Sys.println("Unable to load " + url + " file. Please check the config file or give the path in an argument!");
			return false;
		}
		
		var xml:Xml;
		var fastXml:Fast;
		
		try 
		{
			xml = Xml.parse( content );
			fastXml = new Fast(xml.firstElement());
			
			this.parseLibraryList( fastXml );
			this.parseReleaseInfoList( fastXml );
			this.parseExcludedFileList( fastXml );
			this.parseTempPath( fastXml );
			this.parseCombinedData( fastXml );
			this.parsePassword( fastXml );
		}
		catch ( e:Dynamic )
		{
			Sys.println("The following configuration has invalid syntax: " + url + "  ---  " + e);
		}
		
		return true;
	}
	
	function parseLibraryList( xml:Fast ):Void
	{
		for (library in xml.node.libraries.nodes.library) 
		{
			this.libraryList.set(library.att.name, library.att.url);
		}
	}
	
	function parseReleaseInfoList( xml:Fast ):Void
	{
		if ( !xml.hasNode.libraries )
		{
			throw "<libraries> are not defined and it's required.";
			return;
		}
		for (elem in xml.node.replaceparams.elements) 
		{
			this.releaseInfoList.set(elem.name, elem.innerData);
		}
		
	}
	
	function parseExcludedFileList( xml:Fast ):Void
	{
		if ( xml.hasNode.excludefiles )
		{
			for (file in xml.node.excludefiles.nodes.file) 
			{
				this.excludedFileList.push( file.att.name );
			}
		}
	}
	
	function parseTempPath( xml:Fast ):Void
	{
		if ( xml.hasNode.temppath )
		{
			this.tempPath = this.replaceVariables( xml.node.temppath.att.name );
		}
	}
	
	function parsePassword( xml:Fast ):Void
	{
		if ( xml.hasNode.password )
		{
			this.password = this.replaceVariables( xml.node.password.att.value );
		}
	}
	
	function parseCombinedData( xml:Fast ) 
	{
		if ( xml.hasNode.combinedname )
		{
			this.combinedName = this.replaceVariables( xml.node.combinedname.att.value );
		}
	}
	
	function replaceVariables( str:String ):String
	{
		for ( i in releaseInfoList.keys() )
		{
			str = str.split("$(" + i + ")").join(releaseInfoList.get(i));
		}
		
		return str;
	}
	
}