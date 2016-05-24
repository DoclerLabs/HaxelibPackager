package haxelibpackager;
import haxe.io.Path;
import sys.FileSystem;
import util.FsUtils;

/**
 * ...
 * @author duke
 */
class PackageCreator
{

	public function new() 
	{
		
	}
	
	public function createPackage( libName:String, path:String, password:String, ?excludeFileList:Array<String> )
	{
		Sys.println("Submitting " + libName + "...");
		this.removeExcludedFiles( path, excludeFileList );
		
		
		var result:Int = Sys.command( "haxelib submit " + path + " " + password );
		
		if ( result == 0 )
		{
			Sys.println(libName + " submitted successfully!");
		}
		else
		{
			Sys.println(libName + " FAILED to submit:" + result );
		}
	}
	
	function removeExcludedFiles(path:String, excludeFileList:Array<String>):Void
	{
		if ( excludeFileList != null )
		{
			for ( i in excludeFileList )
			{
				var file:String = Path.join([path, i]);
				
				if ( FileSystem.exists(file) )
				{
					if ( FileSystem.isDirectory(file) )
					{
						FsUtils.deleteRec(file);
					}
					else
					{
						FsUtils.safeDelete(file);
					}
				}
			}
			
		}
	}
	
}