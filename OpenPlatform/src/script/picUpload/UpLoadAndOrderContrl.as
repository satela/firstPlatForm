package script.picUpload
{	
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	
	import ui.uploadpic.UpLoadPanelUI;
	
	import utils.UtilTool;
	
	public class UpLoadAndOrderContrl extends Script
	{
		private var uiSkin:UpLoadPanelUI;
		private var fileListData:Array;

		private var allFileData:Array;
		private var curFinishNum:int = 0;
		private var file:Object; 
		public var param:Object;

		public var isUploading:Boolean = false;
		
		private var clientParam:Object;
		private var checkpoint:Object = 0;
		private var callbackparam:Object; //服务器回调参数
		private var ossFileName:String;//服务器指定的文件名
		
		private var reupTryTimes:int = 0;
		
		private var totalFileNum:int = 0;
		public function UpLoadAndOrderContrl()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as UpLoadPanelUI; 
			uiSkin.btnClose.on(Event.CLICK,this,onCloseScene);
			//uiSkin.btnBegin.on(Event.CLICK,this,onClickBegin);
			uiSkin.btnOpenFile.on(Event.CLICK,this,onClickOpenFile);

			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";

			//uiSkin.bgimg.alpha = 0.7;
			uiSkin.fileList.itemRender = FileUpLoadItem;
			uiSkin.fileList.vScrollBarSkin = "";
			uiSkin.fileList.selectEnable = false;
			uiSkin.fileList.spaceY = 4;
			uiSkin.fileList.renderHandler = new Handler(this, updateFileItem);
			initFileOpen();
			uiSkin.uploadinfo.visible = false;
			uiSkin.uploadinfo.style.font = "SimeHei";
			uiSkin.uploadinfo.style.fontSize = 32;
			uiSkin.uploadinfo.style.bold = true;
			uiSkin.uploadinfo.style.width = 800;
			
			uiSkin.errortxt.visible = false;
			uiSkin.goonbtn.visible = false;
			
			uiSkin.goonbtn.on(Event.CLICK,this,reUploadFile);

			Browser.window.uploadApp = this;
			if(param != null && (param as Array) != null)
			{
				uiSkin.fileList.array = param as Array;
				fileListData = param as Array;
				totalFileNum = fileListData.length;
				
				onClickBegin();
			}
			else
				uiSkin.fileList.array = [];

			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			EventCenter.instance.on(EventCenter.CANCAEL_UPLOAD_ITEM,this,onDeleteItem);
			EventCenter.instance.on(EventCenter.RE_UPLOAD_FILE,this,reUploadFile);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
		private function onResizeBrower():void
		{
			
			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		
		private function reUploadFile():void
		{
			uiSkin.errortxt.visible = false;
			uiSkin.goonbtn.visible = false;
			
			onClickBegin();
		}
		private function onClickOpenFile():void
		{
			Laya.timer.clearAll(this);
			file.click();
			//file.value ;
		}
		private function initFileOpen():void
		{
			 file = Browser.document.createElement("input");
			
			file.style="filter:alpha(opacity=0);opacity:0;width: 100;height:34px;left:395px;top:-248";
			
//			if(param && param.type == "License")
//				file.multiple="";
//			else
				file.multiple="multiple";

			file.accept = ".jpg,.jpeg,.tif,.tiff";
			file.type ="file";
			file.style.position ="absolute";
			file.style.zIndex = 999;
			Browser.document.body.appendChild(file);//添加到舞台
			file.onchange = function(e):void
			{
				uiSkin.uploadinfo.visible = false;
				
				if(isUploading)
					return;
				if(file.files.length <= 0)
					return;
				curFinishNum = 0;
				//allFileData = [];
				//fileReader.readAsBinaryString(file.files[0]);
				
				fileListData = [];
				for(var i:int=0;i < file.files.length;i++)
				{
					if(file.files[i].type == "image/jpg" || file.files[i].type == "image/jpeg" || file.files[i].type == "image/tif" || file.files[i].type == "image/tiff" || "image/png")
					{
						if(!UtilTool.isValidString(file.files[i].name))
						{
							ViewManager.showAlert("图片文件名不能包含特殊字符及表情，请修改后重新上传");
							return;
						}
						file.files[i].progress = 0;
						file.files[i].unNormal = false;
						fileListData.push(file.files[i]);
					}
				}
				
				uiSkin.fileList.array = fileListData;
				onClickBegin();
			};
//			var fileReader:Object = new  Browser.window.FileReader();
//			fileReader.onload = function(evt):void
//			{  
//				if(Browser.window.FileReader.DONE==fileReader.readyState)
//				{
//					allFileData.push(fileReader.result);
//					//var bytearr:ByteArray = new ByteArray();
//					//bytearr.readBytes(fileReader.result);
//				}
//			}
		}
		
		
		private function getSendRequest():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.authorUploadUrl,this,onGetAuthor,null,null);
		}
		private function onGetAuthor(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var authordata:Object = JSON.parse(data as String);
			if(authordata == null || authordata.data == null)
				return;
			clientParam = {};
			clientParam.accessKeyId = authordata.data.accessKeyId;
			clientParam.accessKeySecret = authordata.data.accessKeySecret;
			clientParam.stsToken = authordata.data.securityToken;
			//clientParam.endpoint = "oss-cn-hangzhou.aliyuncs.com";			
			//clientParam.bucket = "original-image";
			var json = Laya.loader.getRes("config.json?" + Userdata.instance.configVersion);
			
			clientParam.endpoint = "oss-cn-hangzhou.aliyuncs.com";			
			clientParam.bucket = json["bucket"];
			
			trace("oss:" + typeof(Browser.window.OSS));
			if(typeof(Browser.window.OSS) == "undefined")
			{
				script = Browser.document.createElement("script");
				script.src = "aliOss.min.js";
				script.onload = function(){
					//
					Browser.window.createossClient(clientParam);
					onClickBegin();

				}
				script.onerror = function(e){
					
					trace("error" + e);

					//加载错误函数
				}
				Browser.document.body.appendChild(script);
			}
				
			else
			{
				Browser.window.createossClient(clientParam);
				onClickBegin();
			}
		}
		
		public  function getFileImgdata(file:*):void
		{
			Browser.window.picProcess = this;
			Browser.window.getImagePixels(file);
		}
		
//		public  function getImgInfoBack(imgdata:*):void
//		{
//			
//			
//			if(imgdata.imgheight != null)
//			{
//				var picinfo:PicInfoVo = new PicInfoVo(null,1);
//				picinfo.picHeight = imgdata.imgheight;
//				picinfo.picWidth = imgdata.imgwidth;
//				picinfo.fsize = fileListData[curUploadIndex].size;
//				var arr:Array = fileListData[curUploadIndex].name.split(".");
//				picinfo.picClass = arr[arr.length - 1];
//				
//				if(UtilTool.isUnNormalPic(picinfo))
//				{
//					ViewManager.showAlert("图片大小异常，当前图片取消上传");
//					fileListData[curUploadIndex].unNormal = true;
//					uiSkin.fileList.refresh();
//					curUploadIndex++;
//					this.onBeginUpload();
//				}
//				else
//					continueUpLoad();
//			}
//			else
//			{
//				curUploadIndex++;
//				this.onBeginUpload();
//			}
//		}
		
		private function onClickBegin():void
		{
			Laya.timer.clear(this,reUploadFile);
			
			if(isUploading)
				return;
			if(clientParam == null)
			{
				getSendRequest();
				return;
			}
			isUploading = true;
			onBeginUpload();
			if(fileListData.length > 0)
			{
				uiSkin.uploadinfo.visible = true;
				uiSkin.uploadinfo.innerHTML ="<span color='#0'>(已上传成功</span>" +  "<span color='#003dc6'>" + curFinishNum +   "</span>" + "<span color='#0'>/全部文件</span>" +  "<span color='#003dc6'>" + totalFileNum + "</span>" +  "<span color='#0'>)</span>";
			}
		}
		private function onBeginUpload():void
		{
//			if(fileListData.length > curUploadIndex)
//			{
//				this.getFileImgdata(fileListData[curUploadIndex]);
//			}
//			else
//				uploadFileImmediate();
//			//return;
			if(callbackparam == null && fileListData && fileListData.length > 0)
			{
				var params:Object = {};
				params.dirId = DirectoryFileModel.instance.curSelectDir.dpath;
				params.name = fileListData[0].name;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.noticeServerPreUpload,this,onReadyToUpload,JSON.stringify(params),"post");
				
			}
			else
				uploadFileImmediate();
			
		}
		
		private function continueUpLoad():void
		{
			if(callbackparam == null && fileListData && fileListData.length > 0)
			{
				var params:Object = {};
				params.dirId = DirectoryFileModel.instance.curSelectDir.dpath;
				params.name = fileListData[0].name;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.noticeServerPreUpload,this,onReadyToUpload,JSON.stringify(params),"post");				
			}
			else
				uploadFileImmediate();
			
		}
		
		private function uploadFileImmediate():void
		{
			if(fileListData && fileListData.length > 0)
			{
				Browser.window.ossUpload({file:fileListData[0]},checkpoint,callbackparam,ossFileName);
				
				//Browser.window.uploadPic({urlpath:HttpRequestUtil.httpUrl + HttpRequestUtil.uploadPic, path:DirectoryFileModel.instance.curSelectDir.dpath,file:fileListData[curUploadIndex]});
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.uploadPic,this,onCompleteUpload,{path:"0|11|",file:file.files[0]},"post",onProgressHandler);
			}
			else
			{
				isUploading = false;	
				
				var tip:String = "总共上传" + totalFileNum + "文件,成功上传" + curFinishNum + "文件";
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"图像文件上传成功！",tips:tip,cancel:"上传更多",caller:this,callback:confirmClose});
				//Laya.timer.once(50000,this,onCloseScene);
			}
		}
		
		private function confirmClose(b:Boolean):void
		{
			if(b)
			{
				onCloseScene();
			}
			else
			{
				
			}
		}
		
		private function onReadyToUpload(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				callbackparam = {};
				
				callbackparam.url = result.data.callbackUrl;
				callbackparam.body = result.data.callbackBody;
				callbackparam.contentType = 'application/x-www-form-urlencoded';
				
				var arr:Array = (fileListData[0].name as String).split(".");
				
				ossFileName = result.data.objectName + "." + (arr[arr.length - 1] == null ?"jpg":arr[arr.length - 1]);
				uploadFileImmediate();
			}
			else if(result.code == "100")
			{
				Browser.window.alert("已存在相同文件名图片！");
				curFinishNum--;
//				curUploadIndex++;
//				checkpoint = 0;
//				callbackparam = null;
//				ossFileName = "";
//				onBeginUpload();
				onCompleteUpload(null);
			}
		}
		private function onCompleteUpload(e:Object):void
		{
			if(fileListData[0])
			fileListData[0].progress = 100;
			fileListData.splice(0,1);
			uiSkin.fileList.refresh();
			curFinishNum++;
			
			
			
			//updateProgress();
			//curUploadIndex++;
			uiSkin.uploadinfo.innerHTML ="<span color='#0'>(已上传成功</span>" +  "<span color='#003dc6'>" + curFinishNum +   "</span>" + "<span color='#0'>/全部文件</span>" +  "<span color='#003dc6'>" + totalFileNum + "</span>" +  "<span color='#0'>)</span>";
			checkpoint = 0;
			callbackparam = null;
			ossFileName = "";
			reupTryTimes = 0;
			onBeginUpload();

		}
		
		private function onProgressHandler(e:Object,pro:Object):void
		{
			checkpoint = e;
			if(Number(pro) >= 100)
				pro = "99";
			if(fileListData[0])
			fileListData[0].progress = Number(pro);
			updateProgress();
			//(this.uiSkin.fileList.cells[curUploadIndex] as FileUpLoadItem).updateProgress(e.toString());
			//trace("up progress" + JSON.stringify(e));
		}
		
		private function onUploadError(err:Object):void
		{
			
			
			isUploading = false;
			clientParam = null;
			if(fileListData[0].progress >= 99)
			{
				callbackparam = null;
				checkpoint = 0;
				trace("回调报错");
			}
			//callbackparam = null;
			//ossFileName = "";
			
			var errordata:String = "user_phone=" + Userdata.instance.userAccount + "&error_msg=" + JSON.stringify(err) + "&request_url=图片上传" + err.requestId;
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addErrorLog,null,null,errordata,"post");
			
			if(reupTryTimes < 10)
			{
				Laya.timer.once(100,this,reUploadFile);
				reupTryTimes++;
			}
			
			else {
				reupTryTimes = 0;
				uiSkin.errortxt.visible = true;
				uiSkin.errortxt.text = getErrorMsg(err);
				
				var errordata:String = "user_phone=" + Userdata.instance.userAccount + "&error_msg=" + JSON.stringify(err) + "&request_url=10图片上传" + err.requestId;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addErrorLog,null,null,errordata,"post");
				
				var cells:Vector.<Box> = uiSkin.fileList.cells;
				for(var i:int=0;i < cells.length;i++)
				{
					if(cells[i] as FileUpLoadItem != null && (cells[i] as FileUpLoadItem).fileobj == fileListData[0])
					{
						(cells[i] as FileUpLoadItem).showReUploadbtn();
						uiSkin.goonbtn.visible = true;
						break;
					}
				}
			}
		}
		private function updateProgress():void
		{
			var cells:Vector.<Box> = uiSkin.fileList.cells;
			for(var i:int=0;i < cells.length;i++)
			{
				if(cells[i] as FileUpLoadItem != null && (cells[i] as FileUpLoadItem).fileobj == fileListData[0])
				{
					(cells[i] as FileUpLoadItem).updateProgress(true);
					break;
				}
			}
		}
		private function updateFileItem(cell:FileUpLoadItem):void 
		{
			cell.setData(cell.dataSource);
		}
		
		private function onDeleteItem(delitem:FileUpLoadItem):void
		{
			var index:int = fileListData.indexOf(delitem.fileobj);
			if(index == 0)
			{
				return;
			}
			if(delitem.fileobj.progress >= 99)
				return;
			
			var index:int = fileListData.indexOf(delitem.fileobj);
//			if(index == curUploadIndex)
//			{
//				Browser.window.cancelUpload();
//				
//			}
			uiSkin.fileList.deleteItem(index);
//			callbackparam = null;
//			checkpoint = 0;
//			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.abortUpload,this,function(data:String)
//			{
//				var result:Object = JSON.parse(data as String);
//				if(result.status == 0)
//				{
//					if(isUploading)
//						onBeginUpload();
//				}
//				
//			},null ,"post");

			
		}
		private function getErrorMsg(err:Object):String
		{
			switch (err.status) {
				case 0:
					if (err.name == "cancel") { //手动点击暂停上传
						return "主动删除";
					}
					break;
				case -1: //请求错误，自动重新上传
					return "自动重新上传";
				case 203: //回调失败
					return "前端自己给后台回调";
				case 400:
					switch (err.code) {
						case 'FilePartInterity': //文件Part已改变
						case 'FilePartNotExist': //文件Part不存在
						case 'FilePartState': //文件Part过时
						case 'InvalidPart': //无效的Part
						case 'InvalidPartOrder': //无效的part顺序
						case 'InvalidArgument': //参数格式错误
							return "清空断点,重新上传;";
							
						case 'InvalidBucketName': //无效的Bucket名字
						case 'InvalidDigest': //无效的摘要
						case 'InvalidEncryptionAlgorithmError': //指定的熵编码加密算法错误
						case 'InvalidObjectName': //无效的Object名字
						case 'InvalidPolicyDocument': //无效的Policy文档
						case 'InvalidTargetBucketForLogging': //Logging操作中有无效的目标bucket
						case 'MalformedXML': //XML格式非法
						case 'RequestIsNotMultiPartContent': //Post请求content-type非法
							return "重新授权;继续上传;"
							
						case 'RequestTimeout'://请求超时
							return "请求超时，请重新上传";
					}
					break;
				case 403: 
					return "授权无效，重新授权";
				case 411: return "缺少参数"
				case 404: //Bucket/Object/Multipart Upload ID 不存在
					return "重新授权;继续上传;"
					
				case 500: //OSS内部发生错误
					return "OSS内部发生错误,重新上传;"
				default:return "未知错误，请重新上传";
					break;
			}
			return "";
		}
		private function onCloseScene():void
		{
			// TODO Auto Generated method stub
			if(isUploading)
				return;
			Browser.window.uploadApp = null;
			Laya.timer.clearAll(this);

			EventCenter.instance.event(EventCenter.UPLOAD_FILE_SUCESS);
			EventCenter.instance.off(EventCenter.CANCAEL_UPLOAD_ITEM,this,onDeleteItem);
			EventCenter.instance.off(EventCenter.RE_UPLOAD_FILE,this,reUploadFile);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

			ViewManager.instance.closeView(ViewManager.VIEW_MYPICPANEL);
			
			Browser.document.body.removeChild(file);//添加到舞台

		}		
		
		
	}
}