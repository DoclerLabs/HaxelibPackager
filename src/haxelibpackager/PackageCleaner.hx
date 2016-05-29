package haxelibpackager;
import haxe.io.Path;
import sys.FileSystem;
import util.FsUtils;

/**
 * ...
 * @author duke
 */
class PackageCleaner
{

	public function new() 
	{
		
	}
	
	public function removeExcludedFiles(path:String, excludeFileList:Array<String>):Void
	{
		Sys.println("Removing excluded files from " + path + "...");
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