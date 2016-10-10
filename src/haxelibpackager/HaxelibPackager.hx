package haxelibpackager;

import haxe.ds.StringMap;
import haxe.io.Path;
import neko.Lib;
import util.FsUtils;
import util.Vcs;

/**
 * ...
 * @author duke
 */
class HaxelibPackager 
{
	var xmlConfigReader:XmlConfigReader;
	var args:Array<String>;
	var checkOnly:Bool = false;
	var configFile:String;
	
	
	static function main() 
	{
		new HaxelibPackager();
	}
	
	public function new( )
	{
		if ( !this.parseArgs() )
		{
			return;
		}
		
		Sys.println("Haxelib Packager started" + (this.checkOnly ? " in CHECK ONLY mode" : " in DEPLOY mode") + " ...");
		Sys.println(" ");
		
		this.xmlConfigReader = new XmlConfigReader();
		this.xmlConfigReader.readConfig( this.configFile );
		
		var releaseInfoGenerator = new ReleaseInfoGenerator();
		var packageCleaner = new PackageCleaner();
		var haxelibPackageCreator = new HaxelibPackageCreator();
		
		var dependencyList = new StringMap<Array<String>>();
		
			
		var libraryCloner = new LibraryCloner();
		
		FsUtils.deleteRec(xmlConfigReader.tempPath);
		
		var combinedPackageCreator = new CombinedPackageCreator( Path.join([this.xmlConfigReader.tempPath, CombinedPackageCreator.DEFAULT_COMBINED_PATH ]) );
		
		
		for ( i in this.xmlConfigReader.libraryList.keys() ) 
		{
			if ( libraryCloner.installLibrary( i, this.xmlConfigReader.libraryList.get(i), this.xmlConfigReader.tempPath ) )
			{
				var path:String = Path.join([this.xmlConfigReader.tempPath, i]);
				var currentDependencyList:Array<String> = releaseInfoGenerator.generateReleaseInfo( path, this.xmlConfigReader.releaseInfoList, this.xmlConfigReader.libraryList );
				dependencyList.set( i, currentDependencyList );
				Sys.println(" ");
			}
			else
			{
				Sys.println("There was an ERROR during installing " + i + " library. Process terminated");
				return;
			}
			
		}
		
		Sys.println("All libraries are prepared! Starting to submit them...");
		Sys.println(" ");
		
		var orderedDependencyList:Array<String> = this.getDependencyOrder( dependencyList );
		Sys.println(" ");
		
		var haxelibSuccessCount:Int = 0;
		var combinedSuccessCount:Int = 0;
		
		for ( i in orderedDependencyList ) 
		{
			var path:String = Path.join([this.xmlConfigReader.tempPath, i]);
			
			packageCleaner.removeExcludedFiles( path, this.xmlConfigReader.excludedFileList );
			if ( this.checkOnly || (haxelibPackageCreator.createPackage( i, path, this.xmlConfigReader.password ) == 0) )
			{
				haxelibSuccessCount++;
			}
			
			if ( this.xmlConfigReader.combinedName != null && combinedPackageCreator.addCombinedPackage( path ) )
			{
				combinedSuccessCount++;
			}
			
			Sys.println(" ");
			
		}
			
		Sys.println(" ");
		Sys.println( "[" + haxelibSuccessCount + "/" + orderedDependencyList.length + "] LIBRARIES PUSHED SUCCESSFULLY!");
		
		if ( this.xmlConfigReader.combinedName != null && 
			combinedSuccessCount == orderedDependencyList.length &&
			combinedPackageCreator.compressCombinedPackage( xmlConfigReader.combinedName ))
		{
			Sys.println( "COMBINED PACKAGE SAVED SUCCESSFULLY: " + xmlConfigReader.combinedName );
		}
		
	}
	
	function parseArgs():Bool
	{
		this.args = Sys.args();
		
		if ( this.args.indexOf("-check") > -1 )
		{
			this.checkOnly = true;
		}
		
		if ( this.args.indexOf("-help") > -1 || this.args.length == 0 )
		{
			Sys.println( "Usage: haxelibpackager [-check] [-help] configfile.xml" );
			Sys.println( " " );
			Sys.println( "-check:          Don't publish packages, but does everything else" );
			Sys.println( "-help:           Shows this help" );
			Sys.println( "configfile.xml:  The input configuration file. See the attached example one for syntax." );
			return false;
		}
		
		if ( this.args[this.args.length - 1].indexOf("-") != 0 )
		{
			this.configFile = this.args[this.args.length - 1];
		}
		
		return true;
	}
	
	function getDependencyOrder( dependencyList:StringMap<Array<String>> ):Array<String>
	{
		var orderedList = new Array<String>();
		
		for ( i in dependencyList.keys() )
		{
			var actDependencyList:Array<String> = dependencyList.get(i);
			
			var found:Bool = false;
			
			for ( j in 0...orderedList.length )
			{
				if ( dependencyList.get(orderedList[j]).indexOf(i) > -1 )
				{
					found = true;
					orderedList.insert( j, i );
					break;
				}
			}
			
			if ( !found )
			{
				orderedList.push( i );
			}
			
		}
		
		Sys.println("Determinated dependency order: " + orderedList);
		
		return orderedList;
	}
	
	
	
}