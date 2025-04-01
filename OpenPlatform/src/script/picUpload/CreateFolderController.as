package script.picUpload
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	
	import ui.inuoView.CreateFolderPanelUI;
	
	public class CreateFolderController extends Script
	{
		private var uiSkin:CreateFolderPanelUI;
		public var param:Object;

		public function CreateFolderController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as CreateFolderPanelUI;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onClosePanel);
			uiSkin.input_folename.maxChars = 10;
			
			uiSkin.btnSureCreate.on(Event.CLICK,this,onSureCreeate);
			
			uiSkin.height =  Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
		private function onResizeBrower():void
		{
			
			uiSkin.height = Browser.clientHeight * Laya.stage.width/Browser.clientWidth;
			
		}
		private function onSureCreeate():void
		{
			if(uiSkin.input_folename.text == "")
				return;
				
			else
			{
				if(param.length > 0)
				{
					if(DirectoryFileModel.instance.curSelectDir == null)
					{
						ViewManager.showAlert("请选择一个父目录");
						return;
					}
					var params:Object = {"dirId": DirectoryFileModel.instance.curSelectDir.dpath,"dirName":uiSkin.input_folename.text};
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createDirectory,this,onCreateDirBack,JSON.stringify(params),"post");

					//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createDirectory,this,onCreateDirBack,"path=" + DirectoryFileModel.instance.curSelectDir.dpath + "&name=" + uiSkin.input_folename.text,"post");
				}
				else
				{
					var params:Object = {"dirId":"0","dirName":uiSkin.input_folename.text};
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createDirectory,this,onCreateDirBack,JSON.stringify(params),"post");
				}
					//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createDirectory,this,onCreateDirBack,"path=0|" + "&name=" + uiSkin.input_folename.text,"post");
				
			}
		}
		
		private function onCreateDirBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				
				var picinfo:PicInfoVo = new PicInfoVo(result.data,0);
				EventCenter.instance.event(EventCenter.CREATE_FOLDER_SUCESS,picinfo);
				onClosePanel();
			}
		}
		private function onClosePanel():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_CREATE_FOLDER_PANEL);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
	}
}