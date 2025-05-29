package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Point;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	import model.users.CustomVo;
	
	import script.ViewManager;
	import script.picUpload.PicInfoItem;
	
	import ui.inuoView.OrderPicManagerPanelUI;
	import ui.inuoView.OrderTypePanelUI;
	import ui.inuoView.SetMaterialPanelUI;
	import ui.lailiao.LailiaoOrderPanelUI;
	
	import utils.TipsUtil;
	import utils.UtilTool;
	import utils.WaitingRespond;
	
	public class OrderSelectPicController extends Script
	{
		private var uiSkin:OrderPicManagerPanelUI;
		
		//private var isCreateTopDir:Boolean = true; //是否创建一级目录
		
		private var directTree:Array = [];
		public var param:Object;
		
		private var fileListData:Array;
		
		private var file:Object;
		
		
		private var curFileList:Array;
		
		private var autoFreshTime:int = 0;
		
		private var curCustomer:CustomVo;
		private var mulitSelect:Boolean = false;

		public function OrderSelectPicController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			directTree = [];
			uiSkin = this.owner as OrderPicManagerPanelUI; 
			uiSkin.btnNewFolder.on(Event.CLICK,this,onCreateNewFolder);
			
			curCustomer = param as CustomVo;
			
			uiSkin.customListPanel.visible = false;
			if(curCustomer != null && curCustomer.id  != "0")
				uiSkin.curCustomName.text = curCustomer.customerName;
			else
				uiSkin.curCustomName.text = Userdata.instance.company;
			uiSkin.curCustomName.editable = false;
			
			uiSkin.showCustomList.on(Event.CLICK,this,function(){
				
				uiSkin.customListPanel.visible = !uiSkin.customListPanel.visible;
			})
			
				
			//uiSkin.btnorder.on(Event.CLICK,this,onshowOrder);
			//			createbox = uiSkin.boxNewFolder;
			//			createbox.visible = false;
			//			
			//			
			//			uiSkin.input_folename.maxChars = 10;
			//			uiSkin.btnCloseInput.on(Event.CLICK,this,onCloseCreateFolder);
			
			
			DirectoryFileModel.instance.selectFolders = [];
			updateSelectFolderNum();
			
			uiSkin.picList.itemRender = PicInfoItem;
			//uiSkin.picList.scrollBar.autoHide = true;
			uiSkin.picList.selectEnable = false;
			uiSkin.picList.spaceY = 20;
			uiSkin.picList.renderHandler = new Handler(this, updatePicInfoItem);
			
			uiSkin.flder0.visible = false;
			uiSkin.flder1.visible = false;
			uiSkin.flder2.visible = false;
			
			uiSkin.upgradestore.on(Event.CLICK,this,onShowBuyStorage);
			
			//if(PaintOrderModel.instance.orderType == OrderConstant.KAILIAO_ORDER)
				uiSkin.title.text = OrderConstant.orderName[PaintOrderModel.instance.orderType] + "下单";
			//else
			//	uiSkin.title.text = "喷印下单";

			
			for(var i=0;i < 3;i++)
				uiSkin["flder" + i].on(Event.CLICK,this,onClickTopDirectLbl,[i+1]);
			
			//uiSkin.btnprevfolder.on(Event.CLICK,this,onClickParentFolder);
			
			uiSkin.btnroot.on(Event.CLICK,this,backToRootDir);
			uiSkin.btnUploadPic.on(Event.CLICK,this,onShowUploadView);
			
			//uiSkin.filetypeRadio.visible = false;
			uiSkin.radiosel.on(Event.CLICK,this,onSelectAllPic);
			uiSkin.radiosel.selected = false;
			
			uiSkin.freshbtn.on(Event.CLICK,this,onFreshList);
			uiSkin.refreshTxt.on(Event.CLICK,this,onFreshList);

			uiSkin.nextBtn.on(Event.CLICK,this,function(){
				
				var hassrgb:Boolean = false;
				
				for each(var pic:PicInfoVo in DirectoryFileModel.instance.haselectPic)
				{
					if(UtilTool.isValidPic(pic) == false)
					{
						ViewManager.showAlert("只有格式为JPG,JPEG,TIF,TIFF,并且颜色格式为CMYK的图片才能下单");
						return;
					}
				}
				
				var newnum:int = 0;
				for each(var fvo in DirectoryFileModel.instance.haselectPic)
				{
					newnum++;
				}
				if( newnum > OrderConstant.MAX_ORDER_NUMER)
				{
					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"下单图片不能超过100个，请分批下单。"});
					return;
				}
				
				if(PaintOrderModel.instance.orderType == OrderConstant.PAINTING)
					EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[SetMaterialPanelUI,0]);
				else
					EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[LailiaoOrderPanelUI,0]);


				
			});
			uiSkin.batchDelete.on(Event.CLICK,this,onClickAllSelectedFolders);
			uiSkin.picList.array = [];
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList,this,onGetTopDirListBack,"path=0|","post");
			if(curCustomer == null || curCustomer.id == "0")
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + Userdata.instance.dirId,this,onGetTopDirListBack,null,null);	
				DirectoryFileModel.instance.curSelectDir = new PicInfoVo({dirName:"根目录",dpath:"",dirId:Userdata.instance.dirId},0); 
			}
			else
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + curCustomer.dirId,this,onGetTopDirListBack,null,null);
				DirectoryFileModel.instance.curSelectDir = new PicInfoVo({dirName:"根目录",dpath:"",dirId:curCustomer.dirId},0); 
			}

			initFileOpen();
			
			//uiSkin.selectNum.text = 0 + "";
			
			//uiSkin.selectzipainum.text = 0 + "";
			
			//uiSkin.btnSureCreate.on(Event.CLICK,this,onSureCreeate);
			EventCenter.instance.on(EventCenter.SELECT_FOLDER,this,onSelectChildFolder);
			EventCenter.instance.on(EventCenter.UPDATE_FILE_LIST,this,getFileList);
			
			EventCenter.instance.on(EventCenter.SELECT_PIC_ORDER,this,seletPicToOrder);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			
			EventCenter.instance.on(EventCenter.START_SELECT_YIXING_PIC,this,showRelatedPanel);
			EventCenter.instance.on(EventCenter.START_SELECT_BACK_PIC,this,showRelatedPanel);
			EventCenter.instance.on(EventCenter.START_SELECT_PARTWHITE_PIC,this,showRelatedPanel);
			
			//EventCenter.instance.on(EventCenter.STOP_SELECT_RELATE_PIC,this,stopSelectRelate);
			
			EventCenter.instance.on(EventCenter.PAY_ORDER_SUCESS,this,onBuyStorageSucess);
			EventCenter.instance.on(EventCenter.UPDATE_SELECT_FOLDER,this,updateSelectFolderNum);
			EventCenter.instance.on(EventCenter.CREATE_FOLDER_SUCESS,this,onCreateDirBack);
			EventCenter.instance.on(EventCenter.SELECT_CUSTOMER,this,onSelectCustomer);

			Laya.stage.on(Event.KEY_DOWN,this,onKeyDownHandler);
			Laya.stage.on(Event.KEY_UP,this,onKeyUPHandler);
			
			
			uiSkin.picList.on(Event.MOUSE_DOWN,this,onMouseDwons);
			
			uiSkin.picList.on(Event.MOUSE_UP,this,onMouseUpHandler);
			uiSkin.picList.on(Event.MOUSE_OVER,this,onMouseDwons);
			uiSkin.picList.on(Event.MOUSE_OUT,this,onMouseUpHandler);
			uiSkin.tifAi.on(Event.CLICK,this,onSetTifAi);

			DirectoryFileModel.instance.haselectPic = {};
			uiSkin.searchInput.on(Event.INPUT,this,onSearchInput);
			uiSkin.on(Event.REMOVED,this,onRemovedFromStage);
			
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			
						
			DirectoryFileModel.instance.curFileList = [];
			//DirectoryFileModel.instance.curSelectDir = DirectoryFileModel.instance.rootDir;
			directTree.push(DirectoryFileModel.instance.curSelectDir);
			
		}
		
		private function updatePicInfoItem(cell:PicInfoItem):void 
		{
			cell.setData(cell.dataSource);
		}
		
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;
			
			
			uiSkin.picList.refresh();
		}
		
		
		
		
		private function showRelatedPanel():void
		{
			var validFiles:Array = filtUnFitImage();
			var paramData:Object = {};
			for(var i:int=0;i < validFiles.length;i++)
			{
				validFiles[i].relatedTimes = 0;
				for(var j:int=0;j < DirectoryFileModel.instance.curFileList.length;j++)
				{
					if(DirectoryFileModel.instance.curFileList[j].yixingFid == validFiles[i].fid || DirectoryFileModel.instance.curFileList[j].backFid == validFiles[i].fid || DirectoryFileModel.instance.curFileList[j].partWhiteFid == validFiles[i].fid)
						validFiles[i].relatedTimes++;
				}
			}
			validFiles.sort(function(a:PicInfoVo,b:PicInfoVo){
				
				if(a.relatedTimes < b.relatedTimes)
					return -1;
				else
					return 1;
				
			})
			
			paramData.files = validFiles;
			var originFiles:Array = [];
			
			if(DirectoryFileModel.instance.curOperateFile != null && !DirectoryFileModel.instance.haselectPic.hasOwnProperty(DirectoryFileModel.instance.curOperateFile.fid))
			{
				DirectoryFileModel.instance.haselectPic[DirectoryFileModel.instance.curOperateFile.fid] = DirectoryFileModel.instance.curOperateFile;
			}
			for each(var picvo in DirectoryFileModel.instance.haselectPic)
			{
				var xdif:Number = Math.abs(DirectoryFileModel.instance.curOperateFile.picPhysicWidth - picvo.picPhysicWidth)/DirectoryFileModel.instance.curOperateFile.picPhysicWidth;
				var ydif:Number = Math.abs(DirectoryFileModel.instance.curOperateFile.picPhysicHeight - picvo.picPhysicHeight)/DirectoryFileModel.instance.curOperateFile.picPhysicHeight;
				
				if(xdif < 0.01 && ydif < 0.01)
					originFiles.push(picvo);
			}
			paramData.originfiles = originFiles;
			
			ViewManager.instance.openView(ViewManager.RELATED_PIC_CHOOSE_PANEL,false,paramData);
		}
		
		private function stopLast(picInfo:PicInfoVo):void
		{
			var arr:Vector.<Box> = uiSkin.picList.cells;
			for(var i:int=0;i < arr.length;i++)
			{
				if((arr[i] as PicInfoItem) != null)
				{
					if((arr[i] as PicInfoItem).picInfo != picInfo)
						(arr[i] as PicInfoItem).resetRelatedBtn();
				}
			}
		}
		
		private function filtUnFitImage():Array
		{
			
			var curfile:PicInfoVo = DirectoryFileModel.instance.curOperateFile;
			if(curfile == null)
				return;
			var curOperateType:int = DirectoryFileModel.instance.curOperateSelType;

			var files:Array = [];
			
			for(var i:int=0;i < DirectoryFileModel.instance.curFileList.length;i++)
			{
				var pinvo:PicInfoVo = DirectoryFileModel.instance.curFileList[i];
				if(pinvo != null && pinvo.picType == 1)
				{
					var xdif:Number = Math.abs(curfile.picPhysicWidth - pinvo.picPhysicWidth)/curfile.picPhysicWidth;
					var ydif:Number = Math.abs(curfile.picPhysicHeight - pinvo.picPhysicHeight)/curfile.picPhysicHeight;
					if(xdif >0.01 || ydif > 0.01)
					{
						//(this.uiSkin.picList.cells[i] as PicInfoItem).disableItem(true);
					}
					else if(curOperateType == 0 || curOperateType == 2)
					{
						if(pinvo.colorspace.toLocaleUpperCase() != "GRAY" && !pinvo.isCdr)
						{
							//(this.uiSkin.picList.cells[i] as PicInfoItem).disableItem(true);
							
						}
						else
							files.push(DirectoryFileModel.instance.curFileList[i]);
					}
					else if(curOperateType == 1 && pinvo.colorspace != "CMYK")
					{
						
						//(this.uiSkin.picList.cells[i] as PicInfoItem).disableItem(true);
					}
					
					else
					{
						//(this.uiSkin.picList.cells[i] as PicInfoItem).disableItem(false);
						files.push(DirectoryFileModel.instance.curFileList[i]);

					}
				}
				
				
			}
			return files;
			
		}
		
		private function stopRightSelectRelate(e:Event):void
		{
			//trace(e.target);
			
			//if(e != null && this.uiSkin.picList.hitTestPoint(e.stageX,e.stageY))
			//	return;
			Laya.stage.off(Event.CLICK,this,stopSelectRelate);
			TipsUtil.getInstance().stopGlobalTips(); 

			//uiSkin.seltips.visible = false;
			cancelSelected();
			stopLast(null);
			DirectoryFileModel.instance.curOperateFile = null;
			Laya.stage.off(Event.RIGHT_CLICK,this,stopSelectRelate);
			Laya.stage.off(Event.DOUBLE_CLICK,this,stopRightSelectRelate);
			
			
		}
		
		private function stopSelectRelate(e:Event):void
		{
			//trace(e.target);
			
			if(e != null && this.uiSkin.picList.hitTestPoint(e.stageX,e.stageY))
				return;
			Laya.stage.off(Event.CLICK,this,stopSelectRelate);
			//uiSkin.seltips.visible = false;
			cancelSelected();
			TipsUtil.getInstance().stopGlobalTips(); 

			stopLast(null);
			DirectoryFileModel.instance.curOperateFile = null;
			Laya.stage.off(Event.RIGHT_CLICK,this,stopSelectRelate);
			Laya.stage.off(Event.DOUBLE_CLICK,this,stopRightSelectRelate);
			
			
		}
		
		private function cancelSelected():void
		{
			if(DirectoryFileModel.instance.curOperateFile != null)
			{
				for(var i:int=0;i < uiSkin.picList.cells.length;i++)
				{
					var picinfoitem:PicInfoItem = uiSkin.picList.cells[i] as PicInfoItem;
					if(picinfoitem != null)
					{
						if(picinfoitem.picInfo == DirectoryFileModel.instance.curOperateFile)
						{
							picinfoitem.canCelSelected();
							break;
						}
					}
				}
			}
			for(var i:int=0;i < this.uiSkin.picList.cells.length;i++)
			{
				var pinvo:PicInfoVo = (this.uiSkin.picList.cells[i] as PicInfoItem).picInfo;
				if(pinvo != null)
				{
					(this.uiSkin.picList.cells[i] as PicInfoItem).disableItem(false);
				}
			}
		}
		
		private function onBuyStorageSucess():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,onGetLeftCapacitBack,null,"post");
			
		}
		private function onGetLeftCapacitBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(uiSkin == null || uiSkin.destroyed)
				return;
			
			//if(result.status == 0)
			if(result.code == "0")
			{
				var  size:Number = parseInt(result.data.storageUsedSize)/1024/1024;
				var maxsize:int = parseInt(result.data.storageDefaultSize)/1000/1000;
				Userdata.instance.hasBuySorage = result.data.storageSize;
				
				if(Userdata.instance.hasBuySorage > 0)
					maxsize = Userdata.instance.hasBuySorage;
				
				if( parseInt(result.data.storageUsedSize) < parseInt(result.data.storageDefaultSize))
					uiSkin.prgcap.value = parseInt(result.data.storageUsedSize)/parseInt(result.data.storageDefaultSize);
				else
					uiSkin.prgcap.value = 1;
				
				uiSkin.leftcapacity.text = size.toFixed(0) + "M/" + maxsize + "G";
				
				if(Userdata.instance.hasBuySorage > 0)
				{
					Userdata.instance.storageBuyDate = new Date(Date.parse(UtilTool.convertDateStr(result.data.storageDate))).getTime();
					
					Userdata.instance.storageExpiredDate = new Date(Date.parse(UtilTool.convertDateStr(result.data.storageExpireDate))).getTime();
				}
			}
		}
		private function onSelectAllPic():void
		{
			//var allfilse:Array = DirectoryFileModel.instance.curFileList;
			
			var allfilse:Array = curFileList;
			
			if(allfilse == null)
				return;
			
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
				else
				{
					if(uiSkin.radiosel.selected)
					{
						if(DirectoryFileModel.instance.selectFolders.indexOf(allfilse[i].dpath) < 0)
						{
							DirectoryFileModel.instance.selectFolders.push(allfilse[i].dpath);
						}							
					}
					else
						DirectoryFileModel.instance.selectFolders = [];
				}
			}
			for(var i:int=0;i < uiSkin.picList.cells.length;i++)
			{
				if((uiSkin.picList.cells[i] as PicInfoItem).picInfo != null && UtilTool.checkFileIsImg((uiSkin.picList.cells[i] as PicInfoItem).picInfo) && (uiSkin.picList.cells[i] as PicInfoItem).picInfo.picPhysicWidth != 0)
				{
					//(uiSkin.picList.cells[i] as PicInfoItem).sel.visible = uiSkin.radiosel.selected;
					(uiSkin.picList.cells[i] as PicInfoItem).sel.selected = uiSkin.radiosel.selected;
				}
				else if((uiSkin.picList.cells[i] as PicInfoItem).picInfo != null && (uiSkin.picList.cells[i] as PicInfoItem).picInfo.picType == 0)
				{
					//(uiSkin.picList.cells[i] as PicInfoItem).sel.visible = uiSkin.radiosel.selected;
					(uiSkin.picList.cells[i] as PicInfoItem).sel.selected = uiSkin.radiosel.selected;
				}
			}
			var num:int = 0;
			for each(var picvo in DirectoryFileModel.instance.haselectPic)
			{
				num++;
			}
//			if(num>0)
//				uiSkin.btnorder.label = "我要下单" + "(" + num + "张)";
//			else
//				uiSkin.btnorder.label = "我要下单";
			
			//uiSkin.selectzipainum.text = num + "";
			updateSelectFolderNum();
			
		}
		
		private function updateSelectFolderNum():void
		{
			//uiSkin.selectFolderNum.text = DirectoryFileModel.instance.selectFolders.length.toString();
		}
		
		private function onClickAllSelectedFolders():void
		{
			//if(DirectoryFileModel.instance.selectFolders.length <= 0)
			//	return;
			ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"是否批量删除所选文件？",caller:this,callback:confirmDeleteFolder});
		}
		private function confirmDeleteFolder(b):void
		{
			if(b)
			{
				deleteFolder();
			}
		}
		private function deleteFolder():void
		{
			//var path:String = DirectoryFileModel.instance.selectFolders.shift();
			//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deleteDirectory,this,onDeleteFileBack,JSON.stringify({"dirId" :path}),"post");
			
			var fid:String = "";
			for(var picfid in DirectoryFileModel.instance.haselectPic)
			{
				fid = picfid;
			}
			
			if(fid != "")
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deletePic,this,onDeleteFileBack,JSON.stringify({"fileID": fid}),"post");
				delete DirectoryFileModel.instance.haselectPic[fid];
			}
			else
			{
				getFileList();
				
				
			}
			
			
		}
		
		private function onDeleteFileBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//if(DirectoryFileModel.instance.selectFolders.length > 0)
				deleteFolder();
				//else
				//	getFileList();
				
			}
		}
		private function initFileOpen():void
		{
			file = Browser.document.createElement("input");
			
			file.style="filter:alpha(opacity=0);opacity:0;width: 100;height:34px;left:395px;top:-248";
			
			//			if(param && param.type == "License")
			//				file.multiple="";
			//			else
			file.multiple="multiple";
			
			file.accept = ".jpg,.jpeg,.tif,.tif,.png";
			file.type ="file";
			file.style.position ="absolute";
			file.style.zIndex = 999;
			Browser.document.body.appendChild(file);//添加到舞台
			file.onchange = function(e):void
			{			
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
						fileListData.push(file.files[i]);
					}
					
				}
				WaitingRespond.instance.showWaitingView(1000);
				ViewManager.instance.openView(ViewManager.VIEW_MYPICPANEL,false,fileListData);
			};
			
			Browser.window.uploadHandle = this;							
			
		}
		
		private function dragFileToUpload():void
		{
			fileListData = [];
			WaitingRespond.instance.showWaitingView();
			
			Laya.timer.once(1000,this,function(){
				WaitingRespond.instance.hideWaitingView();
				
				if(ViewManager.instance.getTopViewName() != ViewManager.VIEW_MYPICPANEL)
				{
					console.log("打开 上传界面");
					ViewManager.instance.openView(ViewManager.VIEW_MYPICPANEL,false,fileListData);
				}});
		}
		private function addFile(file:Object):void
		{
			fileListData.push(file);
			
			//ViewManager.instance.openView(ViewManager.VIEW_MYPICPANEL,false,fileListData);
		}
		private function onshowOrder():void
		{
			// TODO Auto Generated method stub
			var hassrgb:Boolean = false;
			
			for each(var pic:PicInfoVo in DirectoryFileModel.instance.haselectPic)
			{
				if(UtilTool.isValidPic(pic) == false)
				{
					ViewManager.showAlert("只有格式为JPG,JPEG,TIF,TIFF,并且颜色格式为CMYK的图片才能下单");
					return;
				}
			}
			
			var newnum:int = 0;
			for each(var fvo in DirectoryFileModel.instance.haselectPic)
			{
				newnum++;
			}
			if( newnum > OrderConstant.MAX_ORDER_NUMER)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"下单图片不能超过100个，请分批下单。"});
				return;
			}
			
			PaintOrderModel.instance.orderType = OrderConstant.PAINTING;
			
			//			ViewManager.showAlert("服务器升级中，预计14:00恢复，请谅解！");
			//			return;
			ViewManager.instance.openView(ViewManager.VIEW_PAINT_ORDER,true);
		}
		
		private function onshowZipaiOrder():void
		{
			
			var hassrgb:Boolean = false;
			
			PaintOrderModel.instance.orderType = OrderConstant.CUTTING;
			
			for each(var pic:PicInfoVo in DirectoryFileModel.instance.haselectPic)
			{
				if(UtilTool.isValidPicZipai(pic) == false)
				{
					ViewManager.showAlert("有图片不能用于字牌下单，请重新上传或选择其他图片");
					return;
				}
			}
			
			
			ViewManager.instance.openView(ViewManager.VIEW_CHARACTER_DEMONSTRATE_PANEL,true);
			
		}
		private function confirmOrderNow(b:Boolean):void
		{
			if(b)
			{
				ViewManager.instance.openView(ViewManager.VIEW_PAINT_ORDER,true);
				
			}
		}
		
		private function onKeyDownHandler(e:Event):void
		{
			if(e.keyCode == Keyboard.SHIFT)
				mulitSelect = true;
		}
		
		private function onKeyUPHandler(e:Event):void
		{
			//if(e.keyCode == Keyboard.SHIFT)
			mulitSelect = false;
		}
		
		
		private function seletPicToOrder(data:Array):void
		{
			var fvo:PicInfoVo = data[0];
			
			if(UtilTool.checkFileIsImg(fvo) && fvo.picPhysicWidth != 0)
			{
				var hasfic:Boolean = DirectoryFileModel.instance.haselectPic.hasOwnProperty(fvo.fid)
				if( hasfic)
				{
					delete DirectoryFileModel.instance.haselectPic[fvo.fid];
				}
				else
				{
					DirectoryFileModel.instance.haselectPic[fvo.fid] = fvo;
					if(mulitSelect)
					{
						var arr:Array = uiSkin.picList.array;
						
						var minIndex:int = arr.indexOf(fvo);
						var maxIndex:int = arr.indexOf(fvo);
						for each(var picinfo in DirectoryFileModel.instance.haselectPic)
						{
							if(arr.indexOf(picinfo) < minIndex)
							{
								minIndex = arr.indexOf(picinfo);
							}
							if(arr.indexOf(picinfo) > maxIndex)
							{
								maxIndex = arr.indexOf(picinfo);
							}
						}
						if(maxIndex > minIndex)
						{
							for(var i:int=minIndex; i< maxIndex;i++)
							{
								var picinfoVo:PicInfoVo = arr[i];
								hasfic = DirectoryFileModel.instance.haselectPic.hasOwnProperty(picinfoVo.fid)
								if(!hasfic)
								{
									DirectoryFileModel.instance.haselectPic[picinfoVo.fid] = picinfoVo;
									if(uiSkin.picList.cells[i] != null)
										(uiSkin.picList.cells[i] as PicInfoItem).sel.selected = true;
									
								}
							}
						}
					}
				}
				var num:int = 0;
				for each(var picvo in DirectoryFileModel.instance.haselectPic)
				{
					num++;
				}
				
				
//				var picname:String = getSetRelatedTips();
//				if(DirectoryFileModel.instance.curOperateSelType == 1)
//					var tips:String = "<span color='#FF0000' size='18'>请直接选择”</span>" + "<span color='#86B639' size='18'>" + picname + "</span>" + "<span color='#FF0000' size='18'>“需要关联的”</span>" + "<span color='#003dc6' size='18'>反面图片。”</span>";
//				else if(DirectoryFileModel.instance.curOperateSelType == 0)
//					tips = "<span color='#FF0000' size='18'>请直接选择”</span>" + "<span color='#86B639' size='18'>" + picname + "</span>" + "<span color='#FF0000' size='18'>“需要关联的”</span>" + "<span color='#003dc6' size='18'>反面图片。”</span>";
//				else if(DirectoryFileModel.instance.curOperateSelType == 2)
//					tips = "<span color='#FF0000' size='18'>请直接选择”</span>" + "<span color='#86B639' size='18'>" + picname + "</span>" + "<span color='#FF0000' size='18'>“需要关联的”</span>" + "<span color='#003dc6' size='18'>局部铺白图片。”</span>";
//				
//				if(DirectoryFileModel.instance.curOperateFile != null)
//				{
//					TipsUtil.getInstance().updateTips(tips);
//				}
				
//				if(num>0)
//					uiSkin.btnorder.label = "我要下单" + "(" + num + "张)";
//				else
//					uiSkin.btnorder.label = "我要下单";
				
			}
			
		}
		private function onGetTopDirListBack(data:Object):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			//if(result.status == 0)
			if(result.code == "0")
			{
				DirectoryFileModel.instance.initCurDirFiles(result);
				
				//uiSkin.folderList.array = DirectoryFileModel.instance.topDirectList;
				uiSkin.radiosel.selected = false;
				uiSkin.picList.array = DirectoryFileModel.instance.curFileList;
				curFileList = DirectoryFileModel.instance.curFileList;
				//DirectoryFileModel.instance.curFileList = [];
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,onGetLeftCapacitBack,null,null);
				
				//				if(DirectoryFileModel.instance.topDirectList.length > 0)
				//				{
				//					//curDirect += (DirectoryFileModel.instance.topDirectList[0] as PicInfoVo).directName + "|";
				//					DirectoryFileModel.instance.curSelectDir = DirectoryFileModel.instance.topDirectList[0] as PicInfoVo;
				//					directTree.push(DirectoryFileModel.instance.curSelectDir);
				//					
				//					updateCurDirectLabel();
				//					//uiSkin.flder0.visible = true;
				//					//uiSkin.flder0.text = (DirectoryFileModel.instance.topDirectList[0] as PicInfoVo).directName + ">";
				//					(uiSkin.folderList.cells[0] as DirectFolderItem).ShowSelected = true;
				//					getFileList();
				//				}
			}
			else if(result.status == 205)
			{
				ViewManager.instance.openView(ViewManager.VIEW_USERCENTER,true);
			}
			
		}
		
		private function getFileList():void
		{
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + DirectoryFileModel.instance.curSelectDir.dpath,this,onGetDirFileListBack,null,null);
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo,this,onGetLeftCapacitBack,null,null);
			
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
			DirectoryFileModel.instance.selectFolders = [];
			updateSelectFolderNum();
		}
		private function onBackToMain():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
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
				uiSkin.radiosel.selected = false;
				
				uiSkin.picList.array = temparr;
			}
			
		}
		
		private function onSelectCustomer(custom:CustomVo):void
		{
			uiSkin.curCustomName.text = custom.customerName;
			curCustomer = custom;
			if(curCustomer == null || curCustomer.id == "0")
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + Userdata.instance.dirId,this,onGetTopDirListBack,null,null);
				DirectoryFileModel.instance.curSelectDir = new PicInfoVo({dirName:"根目录",dpath:"",dirId:Userdata.instance.dirId},0); 

			}
			else
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + curCustomer.dirId,this,onGetTopDirListBack,null,null);
				DirectoryFileModel.instance.curSelectDir = new PicInfoVo({dirName:"根目录",dpath:"",dirId:curCustomer.dirId},0); 

			}
			directTree = [];
			directTree.push(DirectoryFileModel.instance.curSelectDir);
			updateCurDirectLabel();

		}
		override public function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.SELECT_FOLDER,this,onSelectChildFolder);
			EventCenter.instance.off(EventCenter.UPDATE_FILE_LIST,this,getFileList);
			EventCenter.instance.off(EventCenter.SELECT_PIC_ORDER,this,seletPicToOrder);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			//EventCenter.instance.off(EventCenter.START_SELECT_YIXING_PIC,this,onStartSelectRelate);
			//EventCenter.instance.off(EventCenter.START_SELECT_BACK_PIC,this,onStartSelectBackRelate);
			EventCenter.instance.off(EventCenter.PAY_ORDER_SUCESS,this,onBuyStorageSucess);
			EventCenter.instance.off(EventCenter.UPDATE_SELECT_FOLDER,this,updateSelectFolderNum);
			//EventCenter.instance.off(EventCenter.START_SELECT_PARTWHITE_PIC,this,onStartSelectPartWhiteRelate);
			EventCenter.instance.off(EventCenter.CREATE_FOLDER_SUCESS,this,onCreateDirBack);
			//EventCenter.instance.off(EventCenter.UPLOAD_FILE_SUCESS,this,uploadFileSucess);
			EventCenter.instance.off(EventCenter.SELECT_CUSTOMER,this,onSelectCustomer);


			EventCenter.instance.off(EventCenter.STOP_SELECT_RELATE_PIC,this,stopSelectRelate);
			Browser.document.body.removeChild(file);//添加到舞台
			file = null;
			Browser.window.uploadHandle = null;							
			Browser.window.canupload = false;
			TipsUtil.getInstance().stopGlobalTips();
			//uiSkin.seltips.visible = false;
			DirectoryFileModel.instance.curOperateFile = null;
			
		}
		private function onRemovedFromStage():void
		{
			EventCenter.instance.off(EventCenter.SELECT_FOLDER,this,onSelectChildFolder);
			EventCenter.instance.off(EventCenter.UPDATE_FILE_LIST,this,getFileList);
			EventCenter.instance.off(EventCenter.SELECT_PIC_ORDER,this,seletPicToOrder);
			
		}
		private function onShowUploadView():void
		{
			// TODO Auto Generated method stub
			if(DirectoryFileModel.instance.curSelectDir == null || DirectoryFileModel.instance.curSelectDir.directId == "0")
			{
				//ViewManager.showAlert("请先创建一个目录");
				//return;
			}
			file.click();
			file.value;
		}
		
		private function onSureCreeate():void
		{
			//			if(uiSkin.input_folename.text == "")
			//				return;
			//				
			//			else
			//			{
			//				if(directTree.length > 0)
			//				{
			//					if(DirectoryFileModel.instance.curSelectDir == null)
			//					{
			//						ViewManager.showAlert("请选择一个父目录");
			//						return;
			//					}
			//					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createDirectory,this,onCreateDirBack,"path=" + DirectoryFileModel.instance.curSelectDir.dpath + "&name=" + uiSkin.input_folename.text,"post");
			//				}
			//				else
			//					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.createDirectory,this,onCreateDirBack,"path=0|" + "&name=" + uiSkin.input_folename.text,"post");
			//				
			//				createbox.visible = false;
			//			}
		}
		
		private function onCreateDirBack(picInfo:PicInfoVo):void
		{
			
			uiSkin.picList.addItem(picInfo);
			uiSkin.radiosel.selected = false;				
			curFileList = uiSkin.picList.array;
			
		}
		
		
		private function onSelectChildFolder(filedata:PicInfoVo):void
		{
			DirectoryFileModel.instance.curSelectDir = filedata;
			
			directTree.push(DirectoryFileModel.instance.curSelectDir);
			updateCurDirectLabel();
			getFileList();
		}
		private function backToRootDir():void
		{
			if(directTree.length <= 0)
				return;
			//DirectoryFileModel.instance.curSelectDir = DirectoryFileModel.instance.rootDir;
			directTree = [];
			var dirid:String;
			if(curCustomer == null || curCustomer.id == "0")
			{
				dirid = Userdata.instance.dirId;
			}
			else
			{
				dirid = curCustomer.dirId;

			}
			DirectoryFileModel.instance.curSelectDir = new PicInfoVo({dirName:"根目录",dpath:"",dirId:dirid},0); 
			directTree.push(DirectoryFileModel.instance.curSelectDir);

			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDirectoryList + "dirId=" + dirid,this,onGetTopDirListBack,null,null);
			updateCurDirectLabel();
			
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
		
	
		private function onFreshList():void
		{
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
		private function updateCurDirectLabel():void
		{
			this.uiSkin.flder0.visible = false;
			this.uiSkin.flder1.visible = false;
			this.uiSkin.flder2.visible = false;
			
			//var dirstr:Array = (DirectoryFileModel.instance.curSelectDir.parentDirect + DirectoryFileModel.instance.curSelectDir.directName).split("|");
			for(var i:int=1;i < directTree.length;i++)
			{
				if(i < 4)
				{
					this.uiSkin["flder" + (i-1)].text = directTree[i].directName + ">";
					this.uiSkin["flder" + (i-1)].visible = true;
					if(i > 1)
					{
						this.uiSkin["flder" + (i-1)].x = this.uiSkin["flder" + (i - 2)].x + (this.uiSkin["flder" + (i - 2)] as Label).textField.textWidth + 2;
					}
				}
			}
			
		}
		
		private function onSetTifAi():void
		{
			var fileId:Array = [];
			for each(var file:PicInfoVo in DirectoryFileModel.instance.haselectPic)
			{
				if(file.picClass.toUpperCase() == "TIF" || file.picClass.toUpperCase() == "TIFF")
				{
					if(!file.hasTifAi)
						fileId.push(file.fid);
				}
				
			}
			if(fileId.length <= 0)
			{
				ViewManager.showAlert("未选择tif文件或者tif文件已处理");
				return;
			}
			var post:Object = {"fileId":fileId[0]};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.tifAiSetting ,this,onTifAiBack,JSON.stringify(post),"post");
			
		}
		
		private function onTifAiBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			//if(result.status == 0)
			if(result.code == "0")
			{
				ViewManager.showAlert("请求处理成功，请等待AI处理完成");
			}
		}
		
		
		
		private function onShowBuyStorage():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_BUY_STORAGE_PANEL);
		}
		
		private function onMouseDwons(e:Event):void{
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,false);
			
		}
		private function onMouseUpHandler(e:Event):void{
			
			EventCenter.instance.event(EventCenter.PAUSE_SCROLL_VIEW,true);
			
		}
		private function onCreateNewFolder():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_CREATE_FOLDER_PANEL,false,directTree);
		}
	}
}