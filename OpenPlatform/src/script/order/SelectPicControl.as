package script.order
{
	import eventUtil.EventCenter;
		
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.display.cmd.DrawTextureCmd;
	import laya.events.Event;
	import laya.resource.Texture;
	import laya.ui.Image;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.webgl.resource.BaseTexture;
	import laya.webgl.resource.Texture2D;
	
	import model.HttpRequestUtil;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.picUpload.DirectFolderItem;
	import script.picUpload.PicInfoItem;
	import script.picUpload.PicPaintItem;
	
	import ui.order.SelectPicPanelUI;
	
	import utils.TipsUtil;
	import utils.UtilTool;
	
	public class SelectPicControl extends Script
	{
		private var uiSkin:SelectPicPanelUI;
		
		private var directTree:Array = [];
	
		public var param:Object;
		private var curFileList:Array;

		private var texture:Image;
		public function SelectPicControl()
		{
			super();
		}
		override public function onStart():void
		{
			
			uiSkin = this.owner as SelectPicPanelUI; 
			
			directTree = [];

//			uiSkin.folderList.itemRender = DirectFolderItem;
//			uiSkin.folderList.vScrollBarSkin = "";
//			uiSkin.folderList.selectEnable = true;
//			uiSkin.folderList.spaceY = 2;
//			uiSkin.folderList.renderHandler = new Handler(this, updateDirectItem);
//			
//			uiSkin.folderList.selectHandler = new Handler(this,onSlecteDirect);
			uiSkin.filetypeRadio.visible = false;

			uiSkin.mainpanel.vScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBarSkin = "";

			//uiSkin.mainpanel.height = Browser.height;
			//uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			uiSkin.picList.itemRender = PicPaintItem;
			//uiSkin.picList.vScrollBarSkin = "";
			uiSkin.picList.selectEnable = false;
			uiSkin.picList.spaceY = 10;
			uiSkin.picList.renderHandler = new Handler(this, updatePicInfoItem);
			uiSkin.flder0.visible = false;
			uiSkin.flder1.visible = false;
			uiSkin.flder2.visible = false;
			for(var i=0;i < 3;i++)
				uiSkin["flder" + i].on(Event.CLICK,this,onClickTopDirectLbl,[i]);
			
			uiSkin.btnroot.on(Event.CLICK,this,backToRootDir);
			uiSkin.btnprevfolder.on(Event.CLICK,this,onClickParentFolder);

			uiSkin.radiosel.on(Event.CLICK,this,onSelectAllPic);

			//Laya.timer.once(10,this,function():void
			//{
				//uiSkin.folderList.array =  ["南京","武打片","日本","电视","你妹的"];
				//uiSkin.folderList.array = [];
				uiSkin.picList.array = [];
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=0",this,onGetTopDirListBack,null,null);
				
			//});
			
			uiSkin.htmltext.style.fontSize = 20;
			uiSkin.htmltext.innerHTML =  "<span color='#222222' size='20'>已选择</span>" + "<span color='#FF0000' size='20'>0</span>" + "<span color='#222222' size='20'>张图片</span>";
			
			uiSkin.btncancel.on(Event.CLICK,this,onCancelChoose);
			uiSkin.btnok.on(Event.CLICK,this,onConfirmSelect);
			uiSkin.searchInput.on(Event.INPUT,this,onSearchInput);
			uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);
			
			EventCenter.instance.on(EventCenter.SELECT_FOLDER,this,onSelectChildFolder);
			EventCenter.instance.on(EventCenter.UPDATE_FILE_LIST,this,getFileList);
			
			EventCenter.instance.on(EventCenter.SELECT_PIC_ORDER,this,seletPicToOrder);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
		
		private function startDragPanel(e:Event):void
		{			
			
			(uiSkin.dragImg.parent as Image).startDrag();//new Rectangle(0,0,Browser.width,Browser.height));
			e.stopPropagation();
		}
		private function stopDragPanel():void
		{
			(uiSkin.dragImg.parent as Image).stopDrag();
		}
		
		private function onResizeBrower():void
		{
			
//			uiSkin.mainpanel.height = Browser.height;
//			uiSkin.mainpanel.width = Browser.width;
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

		}
		
		private function onConfirmSelect():void
		{
			// TODO Auto Generated method stub
			if(param != null  && param.customer)
			{
				for each(var pic:PicInfoVo in DirectoryFileModel.instance.haselectPic)
				{
					(param.callback as Function).call(param.caller,pic);
					break;
				}
				DirectoryFileModel.instance.haselectPic = {};
			}
			else if(!(param is MaterialItemVo))
			{
				//var hassrgb:Boolean = false;
				
				
				for each(var pic:PicInfoVo in DirectoryFileModel.instance.haselectPic)
				{
					if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING && UtilTool.isValidPic(pic) == false)
					{
						ViewManager.showAlert("只有格式为JPG,JPEG,TIF,TIFF,并且颜色格式为CMYK的图片才能下单");
						return;
					}
					if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING && UtilTool.isUnNormalPic(pic))
					{
						ViewManager.showAlert("有图片大小异常，请尝试更换图片处理软件或另存图片，再重新上传。");
						return;
					}
					else if(PaintOrderModel.instance.orderType == OrderConstant.CUTTING && UtilTool.isValidPicZipai(pic) == false)
					{
						ViewManager.showAlert("有图片不能用于字牌下单，请重新上传或选择其他图片");
						return;
					}
				}
				
				
				
				EventCenter.instance.event(EventCenter.ADD_PIC_FOR_ORDER);
			}
			else if((param as MaterialItemVo).attchFileId == null || (param as MaterialItemVo).attchFileId == "")
			{
				//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{"msg":"请选择合适的附件"});
				ViewManager.showAlert("请选择合适的附件");

				return;
			}
			
			onCloseView();
		}
		private function confirmOrderNow(b:Boolean):void
		{
			if(b)
			{
				EventCenter.instance.event(EventCenter.ADD_PIC_FOR_ORDER);
				onCloseView();
			}
		}
		private function checkIsValidYixing(text:Image):Boolean
		{
					
//			if(text != null && text.source != null)
//			{
//				//(text.source.bitmap as Texture2D).
//				var pixel:Array= text.source.getPixels(0,0,text.width,text.height);
//				var blackpixel:int = 0;
//				var colorNum:int = 0;
//				var whiteNum:int = 0;
//				for(var i:int=0;i < pixel.length;i+=4)
//				{
//					var r:int = pixel[i];
//					var g:int = pixel[i+1];
//					var b:int = pixel[i+2];
//					
//					trace("rgb=" + r +"," +g +"," + b);
//					if(r >= 250)
//					{
//						blackpixel++;
//					}
//					else if(r > 0 )
//					{
//						colorNum++;
//					}
//					else
//					{
//						whiteNum++;
//					}
//					
//				}
//				
//				trace(" 黑色 ：" + blackpixel + ",白色:" + whiteNum);
//				
//				if ( colorNum/(pixel.length/4) > 0.01)
//					return false;
//				return true;
//			}
			
			return true;
		}
		private function confirmChoose(b:Boolean):void
		{
			if(b)
			{
				texture = null;
				onCloseView();
			}
		}
		private function onCloseView():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.closeView(ViewManager.VIEW_SELECT_PIC_TO_ORDER);
			EventCenter.instance.event(EventCenter.HIDE_U3D_DIV,true);

		}
		
		private function onCancelChoose():void
		{
			if(param is MaterialItemVo)
				EventCenter.instance.event(EventCenter.CANCEL_CHOOSE_ATTACH,param);
			this.onCloseView();

		}
		private function onSelectAllPic():void
		{
			var allfilse:Array = DirectoryFileModel.instance.curFileList;
			if(allfilse == null)
				return;
			if(param is MaterialItemVo)
			{
				return;
			}
			for(var i:int=0;i < allfilse.length;i++)
			{
				if(allfilse[i].picType == 1)
				{
					if(uiSkin.radiosel.selected)
					{
						var hasfic:Boolean = DirectoryFileModel.instance.haselectPic.hasOwnProperty(allfilse[i].fid)
						if( !hasfic && UtilTool.checkFileIsImg(allfilse[i]) && allfilse[i].picPhysicWidth != 0)
						{
							//delete DirectoryFileModel.instance.haselectPic[fvo.fid];
							DirectoryFileModel.instance.haselectPic[allfilse[i].fid] = allfilse[i];
						}
						
					}
					else
					{
						var hasfic:Boolean = DirectoryFileModel.instance.haselectPic.hasOwnProperty(allfilse[i].fid)
						if( hasfic)
						{
							delete DirectoryFileModel.instance.haselectPic[allfilse[i].fid];
						}
					}
				}
			}
			for(var i:int=0;i < uiSkin.picList.cells.length;i++)
			{
				if((uiSkin.picList.cells[i] as PicInfoItem).picInfo != null && UtilTool.checkFileIsImg((uiSkin.picList.cells[i] as PicInfoItem).picInfo) && (uiSkin.picList.cells[i] as PicInfoItem).picInfo.picPhysicWidth != 0)
				{
					(uiSkin.picList.cells[i] as PicInfoItem).sel.visible = uiSkin.radiosel.selected;
					(uiSkin.picList.cells[i] as PicInfoItem).sel.selected = uiSkin.radiosel.selected;
				}
			}
			var num:int = 0;
			for each(var picvo in DirectoryFileModel.instance.haselectPic)
			{
				num++;
			}
			uiSkin.htmltext.innerHTML =  "<span color='#222222' size='20'>已选择</span>" + "<span color='#FF0000' size='20'>" + num + "</span>" + "<span color='#222222' size='20'>张图片</span>";
			
			
		}
		
		private function seletPicToOrder(data:Array):void
		{
			var fvo:PicInfoVo = data[0];
			if(!UtilTool.checkFileIsImg(fvo) ||  fvo.picPhysicWidth == 0)
				return;
			if(param is MaterialItemVo)
			{
				if((param as MaterialItemVo).attchFileId == fvo.fid)
				{
					(param as MaterialItemVo).attchMentFileId = "";
					(param as MaterialItemVo).attchFileId = "";
					if(data[2] != null)
						data[2].canCelSelected();
					texture = null;
				}
				else
				{
					if(PaintOrderModel.instance.curSelectOrderItem != null)
						var picinfo:PicInfoVo = PaintOrderModel.instance.curSelectOrderItem.ordervo.picinfo;
					if(picinfo != null)
					{
						var xdif:Number = Math.abs(picinfo.picPhysicWidth - fvo.picPhysicWidth)/picinfo.picPhysicWidth;
						var ydif:Number = Math.abs(picinfo.picPhysicHeight - fvo.picPhysicHeight)/picinfo.picPhysicHeight;
						if(xdif >0.01 || ydif > 0.01)
						{
							ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"图片尺寸和当前下单图片尺寸不匹配"});
							if(data[2] != null)
								data[2].canCelSelected();
							return;
						}

					}
					if(OrderConstant.yiXingCutProcess(param.preProc_Code) && this.checkIsValidYixing(data[1]))
					{
						texture = data[1];
					}
					else if(OrderConstant.yiXingCutProcess(param.preProc_Code) && !this.checkIsValidYixing(data[1]))
					{
						ViewManager.showAlert("该图片不符合异形切割要求")
						if(data[2] != null)
							data[2].canCelSelected();
						return
					}
						
					
					(param as MaterialItemVo).attchMentFileId = HttpRequestUtil.originPicPicUrl + fvo.fid + "." + fvo.picClass;
					(param as MaterialItemVo).attchFileId = fvo.fid;
					
					if(OrderConstant.yiXingCutProcess(param.preProc_Code))
						(param as MaterialItemVo).picInfoVo = fvo;
				}
				return;
			}
			var hasfic:Boolean = DirectoryFileModel.instance.haselectPic.hasOwnProperty(fvo.fid)
			if( hasfic)
			{
				delete DirectoryFileModel.instance.haselectPic[fvo.fid];
			}
			else
				DirectoryFileModel.instance.haselectPic[fvo.fid] = fvo;
			var num:int = 0;
			for each(var picvo in DirectoryFileModel.instance.haselectPic)
			{
				num++;
			}
			uiSkin.htmltext.innerHTML =  "<span color='#222222' size='20'>已选择</span>" + "<span color='#FF0000' size='20'>" + num + "</span>" + "<span color='#222222' size='20'>张图片</span>";
			
			
		}
		private function onGetTopDirListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				DirectoryFileModel.instance.initCurDirFiles(result);
				
				uiSkin.radiosel.selected = false;
				uiSkin.picList.array = DirectoryFileModel.instance.curFileList;
				curFileList = DirectoryFileModel.instance.curFileList;
				
			}
			else if(result.status == 205)
			{
				ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true);
			}
			
		}
		
		private function getFileList():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + DirectoryFileModel.instance.curSelectDir.dpath,this,onGetDirFileListBack,null,null);
			
		}
		
		private function onGetDirFileListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				uiSkin.radiosel.selected = false;
				
				DirectoryFileModel.instance.initCurDirFiles(result);
				uiSkin.picList.array = DirectoryFileModel.instance.curFileList;
				curFileList = DirectoryFileModel.instance.curFileList;
			}
			
		}
		private function onSearchInput():void
		{
			if(curFileList != null)
			{
				var temparr:Array = [];
				for(var i:int=0;i < curFileList.length;i++)
				{
					if((curFileList[i].directName as String).indexOf(uiSkin.searchInput.text) >= 0)
						temparr.push(curFileList[i]);
				}
				uiSkin.picList.array = temparr;
			}
			
		}
		
		override public function onDestroy():void
		{
			EventCenter.instance.event(EventCenter.CLOSE_PANEL_VIEW,ViewManager.VIEW_SELECT_PIC_TO_ORDER);

			EventCenter.instance.off(EventCenter.SELECT_FOLDER,this,onSelectChildFolder);
			EventCenter.instance.off(EventCenter.UPDATE_FILE_LIST,this,getFileList);
			EventCenter.instance.off(EventCenter.SELECT_PIC_ORDER,this,seletPicToOrder);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);

		}
	
	
		private function onSlecteDirect(index:int):void
		{
//			for each(var item:DirectFolderItem in uiSkin.folderList.cells)
//			{
//				item.ShowSelected = item.directData == uiSkin.folderList.array[index];
//			}
//			//(uiSkin.folderList.cells[index] as DirectFolderItem).ShowSelected = true;
//			var picinfo:PicInfoVo =  uiSkin.folderList.array[index];
			//curDirect = picinfo.parentDirect + picinfo.directName + "|";
//			DirectoryFileModel.instance.curSelectDir = picinfo;
//			
//			directTree = [];
//			directTree.push(DirectoryFileModel.instance.curSelectDir);
//			
//			
//			updateCurDirectLabel();
//			getFileList();
			
		}
		
		private function onSelectChildFolder(filedata:PicInfoVo):void
		{
			DirectoryFileModel.instance.curSelectDir = filedata;
			
			directTree.push(DirectoryFileModel.instance.curSelectDir);
			
			updateCurDirectLabel();
			getFileList();
		}
		
		private function onClickTopDirectLbl(index:int):void
		{
			if(index == directTree.length - 1)
				return;
			DirectoryFileModel.instance.curSelectDir = directTree[index];
			directTree.splice(index+1,directTree.length - index -1);
			updateCurDirectLabel();
			getFileList();
		}
		
		private function onClickParentFolder():void
		{
			if(directTree.length > 1)
			{
				DirectoryFileModel.instance.curSelectDir = directTree[directTree.length - 2];
				directTree.splice(directTree.length - 1,1);
				updateCurDirectLabel();
				getFileList();
			}
			else
			{
				backToRootDir();
				
			}
		}
		
		private function backToRootDir():void
		{
			if(directTree.length <= 0)
				return;
			DirectoryFileModel.instance.curSelectDir = DirectoryFileModel.instance.rootDir;
			directTree = [];
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=0",this,onGetTopDirListBack,null,null);
			updateCurDirectLabel();
		}
		
		private function updateCurDirectLabel():void
		{
			this.uiSkin.flder0.visible = false;
			this.uiSkin.flder1.visible = false;
			this.uiSkin.flder2.visible = false;
			
			//var dirstr:Array = (DirectoryFileModel.instance.curSelectDir.parentDirect + DirectoryFileModel.instance.curSelectDir.directName).split("|");
			for(var i:int=0;i < directTree.length;i++)
			{
				if(i < 3)
				{
					this.uiSkin["flder" + i].text = directTree[i].directName + ">";
					this.uiSkin["flder" + i].visible = true;
				}
			}
			
		}
		private function updateDirectItem(cell:DirectFolderItem):void 
		{
			cell.setData(cell.dataSource);
		}
		
		private function updatePicInfoItem(cell:PicInfoItem):void 
		{
			cell.setData(cell.dataSource);
		}
		
		
	}
}