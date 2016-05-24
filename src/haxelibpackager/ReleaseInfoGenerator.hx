package haxelibpackager;
import haxe.Json;
import haxe.ds.HashMap;
import haxe.ds.StringMap;
import haxe.io.Path;
import sys.io.File;
import util.Cli;

/**
 * ...
 * @author duke
 */
class ReleaseInfoGenerator
{
	var releaseInfoList:StringMap<String>;
	
	public function new( ) 
	{
	}
	
	
	public function generateReleaseInfo( libraryPath:String, releaseInfoList:StringMap<String>, ?replaceDependecyList:StringMap<String> ):Array<String>
	{
		this.releaseInfoList = releaseInfoList;
		var filePath:String = Path.join([libraryPath, "haxelib.json"]);
		
		var haxelib:Dynamic = Json.parse( File.getContent(filePath));
		
		Sys.println("Writing " + filePath + " release info...");
		
		this.replaceReleaseInfoVariables( haxelib, this.releaseInfoList );
		var dependencyList:Array<String> = this.replaceDependecyListToVersion( haxelib, replaceDependecyList );
		
		File.saveContent( filePath, Json.stringify(haxelib, null, "  " ) );
		
		return dependencyList;
	}
	
	function replaceReleaseInfoVariables(haxelib:Dynamic, releaseInfoList:StringMap<String>):Void
	{
		for ( i in releaseInfoList.keys() )
		{
			Reflect.setField(haxelib, i, releaseInfoList.get(i) );
		}
	}
	
	function replaceDependecyListToVersion(haxelib:Dynamic, replaceDependecyList:StringMap<String>):Array<String>
	{
		var version:String = this.releaseInfoList.get("version");
		version = version == null ? "" : version;
		
		var dependencyList = new Array<String>();
		
		if ( haxelib.dependencies != null )
		{
			for ( i in Reflect.fields(haxelib.dependencies) )
			{
				if ( replaceDependecyList.get( i ) != null )
				{
					Reflect.setField(haxelib.dependencies, i, version);
				}
				
				dependencyList.push( i );
			}
		}
		
		return dependencyList;
	}
}