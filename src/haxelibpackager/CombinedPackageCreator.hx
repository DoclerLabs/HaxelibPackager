package haxelibpackager;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Path;
import haxe.zip.Entry;
import haxe.zip.Tools;
import haxe.zip.Writer;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author duke
 */
class CombinedPackageCreator
{
	static var DEFAULT_NAME:String = "combined.zip";
	public static var DEFAULT_COMBINED_PATH:String = "__combined__";
	
	var combinedPath:String;
	

	public function new( combinedPath:String ) 
	{
		this.combinedPath = combinedPath;
		
		FileSystem.createDirectory( this.combinedPath );
		
	}
	
	public function addCombinedPackage( packagePath:String ):Bool
	{
		Sys.println("Copying package: " + packagePath + " to " + this.combinedPath + " ..." );
		return this.copyDirectory( packagePath, this.combinedPath );
		
	}
	
	public function compressCombinedPackage( fileName:String ):Bool
	{
		Sys.println("Saving combined package: " + fileName + " ..." );
		fileName = fileName != null ? fileName : DEFAULT_NAME;
		
		var data:Bytes;
		
		if (FileSystem.isDirectory(this.combinedPath)) 
		{
			var zip:List<Entry> = this.zipDirectory(this.combinedPath);
			var out = new BytesOutput();
			new Writer(out).write(zip);
			data = out.getBytes();
			
			try
			{
				var file = File.write( fileName );
				file.write( data );
				file.close();
			}
			catch ( e:Dynamic )
			{
				Sys.println("Failed to write combined zip file: " + fileName + " " + e.toString() );
				return false;
			}
			
			return true;
		}
		
		return false;
		
	} 
	
	function copyDirectory(source:String, target:String ):Bool
	{
		function seek(dir:String) 
		{
			for (name in FileSystem.readDirectory(dir)) 
			{
				var full = '$dir/$name';
				var targetPath = target + "/" + full.substr(source.length + 1);
				
				if (FileSystem.isDirectory(full))
				{
					FileSystem.createDirectory( targetPath );
					seek(full);
				}
				else 
				{
					File.copy( full, targetPath ); 
				}
			}
		}
		
		try
		{
			seek(source);
		}
		catch ( e:Dynamic )
		{
			Sys.println("Failed to copy source directory " + source + " to combined path: " + target + " " + e );
			return false;
		}
		
		return true;
	}
	
	function zipDirectory(root:String):List<Entry> 
	{
		var ret = new List<Entry>();
		
		function seek(dir:String) 
		{
			for (name in FileSystem.readDirectory(dir)) 
			{
				var full = '$dir/$name';
				if (FileSystem.isDirectory(full))
				{
					seek(full);
				}
				else 
				{
					var blob = File.getBytes(full);
					var entry:Entry = 
					{
						fileName: full.substr(root.length+1),
						fileSize : blob.length,
						fileTime : FileSystem.stat(full).mtime,
						compressed : false,
						dataSize : blob.length,
						data : blob,
						crc32: Crc32.make(blob),
					};
					Tools.compress(entry, 9);
					ret.push(entry);
				}
			}
		}
		
		seek(root);
		
		return ret;
	}
	
}