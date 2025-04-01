package model.picmanagerModel
{
	import eventUtil.EventCenter;
	
	import model.HttpRequestUtil;
	
	import script.ViewManager;
	
	import utils.UtilTool;
	
	public class DirectoryFileModel
	{
		private static var _instance:DirectoryFileModel;
		
		//public var topDirectList:Array = [];//一级目录
		public var directoryList:Array;
		
		public var curFileList:Array = [];
				
		public var curSelectDir:PicInfoVo;
		
		public var haselectPic:Object = {};
		
		public var selectFolders:Array;

		
		public var rootDir:PicInfoVo;
		
		public var curOperateFile:PicInfoVo;
		public var curOperateSelType:int = 0; //0选择异形 1 选择反面  2 选择局部铺白
		

		public static function get instance():DirectoryFileModel
		{
			if(_instance == null)
				_instance = new DirectoryFileModel();
			return _instance;
		}
		
		public function DirectoryFileModel()
		{
			rootDir = new PicInfoVo({dirName:"根目录",dpath:"",dirId:"0"},0);
		}
		

		
		public function addNewTopDir(dir:Object):void
		{
			curFileList.push(new PicInfoVo(dir,0));
		}
		
		public function initCurDirFiles(fileinfo:Object):void
		{
			curFileList = [];
			var dirList:Array = fileinfo.data.subDir;
			for(var i:int=0;i < dirList.length;i++)
			{
				curFileList.push(new PicInfoVo(dirList[i],0));
			}
			
			var picList:Array = fileinfo.data.files;
			for( i=0;i < picList.length;i++)
			{
				curFileList.push(new PicInfoVo(picList[i],1));
			}
			
		
			for( i=0;i < curFileList.length;i++)
			{
				curFileList[i].initYixingData();
			}
			for(var picfid in haselectPic)
			{
				for( var j:int=0;j < curFileList.length;j++)
				{
					if(curFileList[j].fid == picfid)
						haselectPic[picfid] = curFileList[j];
				}
				
			}
			
		}
		
		//当面目录下是否有未处理的图片
		public function hasUnDealPic():void
		{
			if(curFileList != null)
			{
				for(var i:int=0;i < curFileList.length;i++)
				{
					if((curFileList[i] as PicInfoVo).picType == 1 && (curFileList[i] as PicInfoVo).isProcessing)
						return true;
				}
			}
			return false;
		}
		public function getQiegeData(fid:String):Array
		{
			var curfiles:Array = this.curFileList;
			//if(fid.indexOf(".") >= 0)
			//	curfiles = this.curAiFileList;
			
			if(curfiles != null)
			{
				for(var i:int=0;i < curfiles.length;i++)
				{
					if(curfiles[i].fid == fid)
					{
						return [curfiles[i].roadNum,curfiles[i].roadLength,curfiles[i].picWidth,curfiles[i].picClass,curfiles[i].unwhiteratio];
					}
				}
			}
			
			return [0,0];
		}
		
		public function setYingxingImg(picInfo:PicInfoVo,originFile:PicInfoVo):void
		{
			var num:int = 0;
			
			if(curOperateFile != null && !haselectPic.hasOwnProperty(curOperateFile.fid))
			{
				haselectPic[curOperateFile.fid] = curOperateFile;
			}
			var fitOne:Boolean = false;
			var tempOriginFile:Object = {};
			if(originFile != null)
				tempOriginFile[originFile.fid]=originFile;
			else
				tempOriginFile = haselectPic;
			
			for each(var picvo in tempOriginFile)
			{
				if(picvo.fid == picInfo.fid)
					continue;
				//trace("nums:" + num++);
				if(DirectoryFileModel.instance.curOperateSelType == 0 && UtilTool.isFitYixing(picvo,picInfo) && (picvo.yixingFid == "0" || picvo.yixingFid == ""))
				{
					//trace("sel fid:" + this.picInfo.fid);
					
					//var params:String = "fid=" + picvo.fid + "&fmaskid=" + picInfo.fid;	
					
					var params:Object = {"fileId":picvo.fid,"targetId": picInfo.fid};	
					
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setYixingRelated,this,onSetRelatedBack,JSON.stringify(params),"post");
					
					DirectoryFileModel.instance.curOperateFile = null;
					fitOne = true;
					///EventCenter.instance.event(EventCenter.STOP_SELECT_RELATE_PIC);
					
				}
				else if(DirectoryFileModel.instance.curOperateSelType == 1 && UtilTool.isFitFanmain(picvo,picInfo) && (picvo.backFid == "0" || picvo.backFid == ""))
				{
					//trace("sel fid:" + this.picInfo.fid);
				
					var params:Object = {"fileId":picvo.fid,"targetId": picInfo.fid};	
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setFanmianRelated,this,onSetRelatedBack,JSON.stringify(params),"post");
					
					DirectoryFileModel.instance.curOperateFile = null;
					fitOne = true;

					//EventCenter.instance.event(EventCenter.STOP_SELECT_RELATE_PIC);
					
				}
				else if(DirectoryFileModel.instance.curOperateSelType == 2 && UtilTool.isFitYixing(picvo,picInfo,2) && (picvo.partWhiteFid == "0" || picvo.partWhiteFid == ""))
				{
					//trace("sel fid:" + this.picInfo.fid);
					
					var params:Object = {"fileId":picvo.fid,"targetId": picInfo.fid};	
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setPartWhiteRelated,this,onSetRelatedBack,JSON.stringify(params),"post");
					
					DirectoryFileModel.instance.curOperateFile = null;
					fitOne = true;

					//EventCenter.instance.event(EventCenter.STOP_SELECT_RELATE_PIC);
					
				}
				
			}
			if(!fitOne)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"图片尺寸不匹配"});
			}
		}
		
		
		private function onSetRelatedBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				trace("设置成功");
				//ViewManager.showAlert("设置成功");
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);
				
			}
		}
		
	}
}