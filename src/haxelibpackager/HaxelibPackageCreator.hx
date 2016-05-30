package haxelibpackager;
import haxe.io.Path;
import sys.FileSystem;
import util.FsUtils;

/**
 * ...
 * @author duke
 */
class HaxelibPackageCreator
{

	public function new() 
	{
		
	}
	
	public function createPackage( libName:String, path:String, password:String ):Int
	{
		Sys.println("Submitting " + libName + "...");
		
		var result:Int = Sys.command( "haxelib submit " + path + " " + password );
		
		if ( result == 0 )
		{
			Sys.println(libName + " submitted successfully!");
		}
		else
		{
			Sys.println(libName + " FAILED to submit:" + result );
		}
		
		return result;
	}
	
}