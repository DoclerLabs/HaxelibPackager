package haxelibpackager;
import haxe.ds.StringMap;
import haxe.io.Path;
import util.FsUtils;
import util.Vcs;

/**
 * ...
 * @author duke
 */
class LibraryCloner
{
	static var vcsMatcher:EReg = ~/(git|hg):(.+)/;
	

	public function new() 
	{
		
	}
	
	public function installLibrary( libName:String, url:String, path:String ):Bool
	{
		
		if ( vcsMatcher.match( url ) )
		{
			var vcs:Vcs;
			switch ( vcsMatcher.matched(1) )
			{
				case VcsID.Git: vcs = this.useVcs( Git );
				case VcsID.Hg: vcs = this.useVcs( VcsID.Hg );
				default: throw "Invalid VCS version. Please check library syntax.";
			}
			 
			this.installVcs( vcs, libName, vcsMatcher.matched(2), path );
			
			return true;
		}
		else
		{
			return false;
		}
	}
	
	inline function useVcs(id:VcsID):Vcs {
		// Prepare check vcs.available:
		var vcs = Vcs.get(id, {});
		if(vcs == null || !vcs.available)
			throw 'Could not use $id, please make sure it is installed and available in your PATH.';
			
		return vcs;
	}
	
	function installVcs(vcs:Vcs, libName:String, url:String, path:String):Void
	{

		var libPath = Path.join([path,libName]);

		// prepare for new repo
		FsUtils.deleteRec(libPath);
		
		var urlArr:Array<String> = url.split("#");
		
		var url = urlArr.shift();
		var branch:String = urlArr.length > 0 ? urlArr.shift() : null;


		Sys.println("Installing " +libName + " from " +url);
		
		try {
			vcs.clone(libPath, url, branch);
		} 
		catch (error:VcsError) 
		{
			FsUtils.deleteRec(libPath);
			
			var message = switch(error) 
			{
				case VcsUnavailable(vcs):
					'Could not use ${vcs.executable}, please make sure it is installed and available in your PATH.';
				case CantCloneRepo(vcs, repo, stderr):
					'Could not clone ${vcs.name} repository' + (stderr != null ? ":\n" + stderr : ".");
				case CantCheckoutBranch(vcs, branch, stderr):
					'Could not checkout branch, tag or path "$branch": ' + stderr;
				case CantCheckoutVersion(vcs, version, stderr):
					'Could not checkout tag "$version": ' + stderr;
			};
			
			throw message;
		}

		if (branch != null)
		{
			Sys.println('  Branch/Tag/Rev: $branch');
		}
	}
	
}