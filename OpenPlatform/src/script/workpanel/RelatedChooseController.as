package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	import model.picmanagerModel.RelatedChooseModel;
	
	import script.ViewManager;
	import script.workpanel.items.OriginFileCell;
	import script.workpanel.items.SimpleFilePicCell;
	
	import ui.inuoView.RelatedPicChoosePanelUI;
	
	public class RelatedChooseController extends Script
	{
		private var uiSkin:RelatedPicChoosePanelUI;
		
		private var param:Object;
		
		public function RelatedChooseController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as RelatedPicChoosePanelUI; 
			
			uiSkin.piclist.itemRender = SimpleFilePicCell;
			//uiSkin.picList.scrollBar.autoHide = true;
			uiSkin.piclist.selectEnable = true;
			uiSkin.piclist.spaceY = 20;
			uiSkin.piclist.spaceX = 30;
			uiSkin.piclist.renderHandler = new Handler(this, updatePicInfoItem);
			uiSkin.piclist.selectHandler = new Handler(this,onselected);
			
			uiSkin.piclist.array = param.files;
			
			
			uiSkin.originList.itemRender = OriginFileCell;
			//uiSkin.picList.scrollBar.autoHide = true;
			uiSkin.originList.selectEnable = true;
			uiSkin.originList.spaceX = 5;
			uiSkin.originList.renderHandler = new Handler(this, updateOriginInfoItem);
			uiSkin.originList.selectHandler = new Handler(this,onselectedOriginFile);
			
			uiSkin.title.text = ["异形","反面","局部铺白"][DirectoryFileModel.instance.curOperateSelType] + "关联图片选择";
			uiSkin.originList.array = param.originfiles;
			if(param.originfiles.length > 0)
			{
				setOriginImg(param.originfiles[0]);
			}
			Browser.window.uploadApp = this;
			
			uiSkin.closeBtn.on(Event.CLICK,this,onCloseView);
			uiSkin.cancelBtn.on(Event.CLICK,this,onCloseView);
			uiSkin.btnok.on(Event.CLICK,this,onConfirmRelated);
			uiSkin.batchOk.on(Event.CLICK,this,onConfirmBatchRelated);

			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			
		}
		private function setOriginImg(picInfo:PicInfoVo):void
		{
			RelatedChooseModel.instance.curOriginFile = picInfo;
			
			this.uiSkin.originFileName.text = picInfo.directName;
			
			this.uiSkin.originPic.skin =  HttpRequestUtil.smallerrPicUrl + picInfo.fid + ".jpg";
			this.uiSkin.effectPic.skin =  HttpRequestUtil.smallerrPicUrl + picInfo.fid + ".jpg";
			this.uiSkin.yixingPic.skin =  HttpRequestUtil.smallerrPicUrl + picInfo.fid + ".jpg";
			
			this.uiSkin.effectPic.alpha = DirectoryFileModel.instance.curOperateSelType == 1 ? 0.5:1;
			
			if(picInfo.picWidth > picInfo.picHeight)
			{
				this.uiSkin.originPic.width = 280;					
				this.uiSkin.originPic.height = 280/picInfo.picWidth * picInfo.picHeight;
				
				
			}
			else
			{
				this.uiSkin.originPic.height = 280;
				this.uiSkin.originPic.width = 280/picInfo.picHeight * picInfo.picWidth;
								
			}
			this.uiSkin.effectPic.width = this.uiSkin.originPic.width;
			this.uiSkin.effectPic.height = this.uiSkin.originPic.height;

		}
		
		private function updatePicInfoItem(cell:SimpleFilePicCell):void 
		{
			cell.setData(cell.dataSource);
		}
		private function onselected(index:int):void 
		{
			for(var i:int=0;i < uiSkin.piclist.cells.length;i++)
			{
				(uiSkin.piclist.cells[i] as SimpleFilePicCell).setChoose(i == index);
			}
			selectRelatedPic(param.files[index]);
		}
		
		private function updateOriginInfoItem(cell:OriginFileCell):void 
		{
			cell.setData(cell.dataSource);
		}
		private function onselectedOriginFile(index:int):void 
		{
			for(var i:int=0;i < uiSkin.originList.cells.length;i++)
			{
				(uiSkin.originList.cells[i] as OriginFileCell).setChoose(i == index);
			}
			
			setOriginImg(param.originfiles[index]);
		}
		
		private function readImageBack(imgdata:*):void
		{
			uiSkin.yixingPic.skin = imgdata;
		}
		
		private function selectRelatedPic(picinfo:PicInfoVo):void
		{
			if(picinfo == null)
				return;
			
			RelatedChooseModel.instance.curRelatedFile = picinfo;
			if(DirectoryFileModel.instance.curOperateSelType == 0)
			{
				Browser.window.getYixingTransparent(HttpRequestUtil.smallerrPicUrl + picinfo.fid + ".jpg",true,readImageBack);
			}
			else if(DirectoryFileModel.instance.curOperateSelType == 1)
			{
				uiSkin.backPartPic.skin =  HttpRequestUtil.smallerrPicUrl + picinfo.fid + ".jpg";
				uiSkin.backPartPic.alpha = 0.6;
				uiSkin.backPartPic.scaleX = -1;
			}
			else
			{
				Browser.window.getYixingTransparent(HttpRequestUtil.smallerrPicUrl + RelatedChooseModel.instance.curOriginFile.fid + ".jpg",false,readOriginImageBack);
				Browser.window.getYixingTransparent(HttpRequestUtil.smallerrPicUrl + picinfo.fid + ".jpg",true,readPartWhiteImageBack);


			}
			
		}
		
		private function readOriginImageBack(imgdata:*):void
		{
			uiSkin.effectPic.skin = imgdata;
		}
		private function readPartWhiteImageBack(imgdata:*):void
		{
			uiSkin.backPartPic.skin = imgdata;
		}
		private function onConfirmRelated():void
		{
			if(RelatedChooseModel.instance.curRelatedFile == null)
			{
				ViewManager.showAlert("请选择关联图片");
				return;
			}
			
			if(DirectoryFileModel.instance.curOperateFile != null)
			{
				if(DirectoryFileModel.instance.curOperateFile.fid == RelatedChooseModel.instance.curRelatedFile.fid)
				{
					return;
				}
				
				DirectoryFileModel.instance.setYingxingImg(RelatedChooseModel.instance.curRelatedFile,RelatedChooseModel.instance.curOriginFile);
				
				DirectoryFileModel.instance.curOperateFile = null;
				//EventCenter.instance.event(EventCenter.STOP_SELECT_RELATE_PIC);
				
				//ViewManager.instance.openView(ViewManager.VIEW_SET_RELATED_CONFIRM_PANEL,false,[DirectoryFileModel.instance.curOperateFile,picInfo,DirectoryFileModel.instance.curOperateSelType,this,confirmSetRelated]);					
				
			}
			onCloseView();
		}
		
		private function onConfirmBatchRelated():void
		{
			if(RelatedChooseModel.instance.curRelatedFile == null)
			{
				ViewManager.showAlert("请选择关联图片");
				return;
			}
			
			if(DirectoryFileModel.instance.curOperateFile != null)
			{
				if(DirectoryFileModel.instance.curOperateFile.fid == RelatedChooseModel.instance.curRelatedFile.fid)
				{
					return;
				}
				
				DirectoryFileModel.instance.setYingxingImg(RelatedChooseModel.instance.curRelatedFile);
				
				DirectoryFileModel.instance.curOperateFile = null;
				//EventCenter.instance.event(EventCenter.STOP_SELECT_RELATE_PIC);
				
				//ViewManager.instance.openView(ViewManager.VIEW_SET_RELATED_CONFIRM_PANEL,false,[DirectoryFileModel.instance.curOperateFile,picInfo,DirectoryFileModel.instance.curOperateSelType,this,confirmSetRelated]);					
				
			}
			onCloseView();
		}
		private function onCloseView():void
		{
			ViewManager.instance.closeView(ViewManager.RELATED_PIC_CHOOSE_PANEL);
		}
		
		public override function  onDestroy():void
		{
			RelatedChooseModel.instance.resetData();
		}
		
		
	}
}