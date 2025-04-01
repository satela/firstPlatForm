package script.picUpload
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.ui.Button;
	import laya.utils.Ease;
	import laya.utils.Tween;
	import laya.utils.Utils;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	
	import org.osmf.net.StreamingURLResource;
	
	import script.ViewManager;
	
	import ui.inuoPicStore.PicShortItemNuoUI;
	
	import utils.UtilTool;
	
	public class PicInfoItem extends PicShortItemNuoUI
	{
		public var picInfo:PicInfoVo;
		public function PicInfoItem()
		{
			super();
		}
		
		public function setData(filedata:PicInfoVo):void
		{
			
			picInfo = filedata;
			this.offAll();
			this.on(Event.DOUBLE_CLICK,this,onDoubleClick);

			this.on(Event.CLICK,this,onClickHandler);
			this.on(Event.MOUSE_OVER,this,onMouseOverHandler);
			this.on(Event.MOUSE_OUT,this,onMouseOutHandler);
			
			//this.img.on(Event.CLICK,this,onClickImg);

			this.btndelete.visible = false;
			this.frame.visible = false;

			this.disableImg.visible = false;
			
			this.selYixingBtn.on(Event.CLICK,this,onSelectYixingImg);
			this.selBackBtn.on(Event.CLICK,this,onSelectBackImg);
			this.selpart.on(Event.CLICK,this,onSelectPartImg);
			//this.previewCbcBtn.on(Event.CLICK,this,onShowCbcEffect);
			
			this.delBack.on(Event.CLICK,this,onSelectBackImg);
			this.delYixing.on(Event.CLICK,this,onSelectYixingImg);
			this.delPart.on(Event.CLICK,this,onSelectPartImg);

			disableItem(false);
			this.btndelete.on(Event.CLICK,this,onDeleteHandler);
			this.sel.selected = DirectoryFileModel.instance.haselectPic.hasOwnProperty(picInfo.fid) || DirectoryFileModel.instance.curOperateFile == picInfo;
			
			if(picInfo.picType == 0)
			{
				this.sel.selected = DirectoryFileModel.instance.selectFolders.indexOf(picInfo.dpath) >= 0;
			}
			
			//this.sel.selected = this.sel.visible;
			this.yixingimg.visible = false;

			this.backimg.visible = false;
			this.partImg.visible = false;

			this.warningimg.visible = false;
			//this.previewCbcBtn.visible = false;
			this.filename.y = 232;
			this.fileinfo.y = 257;
			
			this.delBack.visible = false;
			this.delYixing.visible = false;
			this.delPart.visible = false;

			this.yixingimg.on(Event.MOUSE_OVER,this,onShowDelButton,[this.delYixing]);
			this.backimg.on(Event.MOUSE_OVER,this,onShowDelButton,[this.delBack]);
			this.partImg.on(Event.MOUSE_OVER,this,onShowDelButton,[this.delPart]);

			this.yixingimg.on(Event.MOUSE_OUT,this,onHideDelButton,[this.delYixing]);
			this.backimg.on(Event.MOUSE_OUT,this,onHideDelButton,[this.delBack]);
			this.partImg.on(Event.MOUSE_OUT,this,onHideDelButton,[this.delPart]);
			
			this.aiBtn.visible = false;
			this.aiBtn.on(Event.CLICK,this,onShowCbcEffect);

			if(picInfo.picType == 0 || !UtilTool.checkFileIsImg(picInfo))
			{
				this.img.skin = "upload1/fold.png";
				this.filename.text = picInfo.directName;
				this.fileinfo.visible = false;
				
				this.aiBtn.visible = false;

				this.img.width = 180;
				this.img.height = 180;
				
				this.selYixingBtn.visible = false;
				this.selBackBtn.visible = false;
				this.selpart.visible = false;
				
				this.img.y = 133;
				
				this.countdown.visible = false;
				
			}
			else
			{
				this.fileinfo.visible = true;
				this.filename.text =  picInfo.directName;
				this.img.y = 133;
				this.countdown.visible = !Userdata.instance.storageNoDel();

				this.autodellabel.text = picInfo.leftDeleteDays + "天";
				if( picInfo.isProcessing)
				{
					this.fileinfo.text = "处理中...";
					this.img.skin = "upload1/fold.png";
					
					this.img.width = 180;
					this.img.height = 180;
					return;
				}
				

				if(picInfo.picWidth > picInfo.picHeight)
				{
					this.img.width = 180;					
					this.img.height = 180/picInfo.picWidth * picInfo.picHeight;
					
					this.yixingimg.width = 56;
					
					this.yixingimg.height = 56/picInfo.picWidth * picInfo.picHeight;
					
					this.backimg.width = 56;
					this.backimg.height = this.yixingimg.height;
					this.partImg.width = 56;
					this.partImg.height = this.yixingimg.height;
					
				}
				else
				{
					this.img.height = 180;
					this.img.width = 180/picInfo.picHeight * picInfo.picWidth;
					
					this.yixingimg.height = 56;
					
					this.yixingimg.width = 56/picInfo.picHeight * picInfo.picWidth;
					
					this.backimg.height = 56;
					this.backimg.width = this.yixingimg.width;
					
					this.partImg.height = 56;
					this.partImg.width = this.yixingimg.width;

				}
				this.backlbl.y = 59 - (56 - this.backimg.height)/2;
				this.yinglbl.y = 59 - (56 - this.yixingimg.height)/2;
				this.partlbl.y = 59 - (56 - this.partImg.height)/2;
				this.delYixing.y = (this.yixingimg.height - 20)/2;
				this.delBack.y = (this.yixingimg.height - 20)/2;
				this.delPart.y = (this.yixingimg.height - 20)/2;

				
				this.warningimg.visible = UtilTool.isUnNormalPic(picInfo);

				if(this.img.skin != "iconsNew/defaultImg.png" && this.img.skin != "upload1/fold.png")
					Laya.loader.clearTextureRes(this.img.skin);

				this.img.skin = null;				
				this.img.skin = HttpRequestUtil.smallerrPicUrl + picInfo.fid + picInfo.tailFix;
			
				
			
				
				if(picInfo.yixingFid != "" && picInfo.yixingFid != "0")
				{
					this.yixingimg.visible = true;
					this.yixingimg.skin = HttpRequestUtil.smallerrPicUrl + picInfo.yixingFid + ".jpg";
					
					
					this.selYixingBtn.visible = false;
					//this.selYixingBtn.skin = "upload1/deletbtn.png";
					//this.btnyxtxt.text = "取消异形";
					//this.btnyxtxt.color = "#FFFFFF";

				}
				else
				{
					this.selYixingBtn.visible = true;
					//this.btnyxtxt.text = "选择异形";
					//this.selYixingBtn.skin = "upload1/addimg.png";
					//this.btnyxtxt.color = "#444A4E";

				}
				if(picInfo.backFid != "" && picInfo.backFid != "0")
				{
					this.backimg.visible = true;
					this.backimg.skin = HttpRequestUtil.smallerrPicUrl + picInfo.backFid + ".jpg";
					this.selBackBtn.visible = false;
					//this.btnfmtxt.text = "取消反面";
					//this.selBackBtn.skin = "upload1/deletbtn.png";
					//this.btnfmtxt.color = "#FFFFFF";

				}
				else
				{
					this.selBackBtn.visible = true;
					//this.btnfmtxt.text = "选择反面";
					
					//this.selBackBtn.skin = "upload1/addimg.png";
					//this.btnfmtxt.color = "#444A4E";
				}
				
				if(picInfo.partWhiteFid != "" && picInfo.partWhiteFid != "0")
				{
					this.partImg.visible = true;
					this.partImg.skin = HttpRequestUtil.smallerrPicUrl + picInfo.partWhiteFid + ".jpg";
					

					this.selpart.visible = false;
					//this.btnparttxt.text = "取消局部";
					//this.previewCbcBtn.visible = true;

					//this.selpart.skin = "upload1/deletbtn.png";
					//this.btnparttxt.color = "#FFFFFF";
					
				}
				else
				{
					this.selpart.visible = true;
					//this.btnparttxt.text = "局部铺白";
					
					//this.selpart.skin = "upload1/addimg.png";
					//this.btnparttxt.color = "#444A4E";
				}
				if(this.yixingimg.visible || this.backimg.visible || this.partImg.visible)
					this.moveImgUp();
				
				//this.picClassTxt.visible = true;
				//if(this.picInfo.colorspace)  
				
				//this.colorspacetxt.visible = true;
				
				var str:String ;//= "宽:" + picInfo.picPhysicWidth + ";高:" +  picInfo.picPhysicHeight + "\n";
				
				
				
				
				if(picInfo.isCdr)
					str = "CDR";
				else
					str = picInfo.picClass.toLocaleUpperCase();
				
				if(picInfo.colorspace.toLocaleUpperCase() == "GRAY")
					str += "|灰度";
				else
					str += "|" + picInfo.colorspace.toLocaleUpperCase();
				
				str += "|"+picInfo.dpi + "DPI|";
				str += picInfo.picPhysicWidth + "×" + picInfo.picPhysicHeight;
				
				this.fileinfo.text = str;
				//checkCanbeSelected();
				
				//this.fileinfo.text = picInfo.directName;

			}
		}
		
//		private function checkCanbeSelected():void
//		{
//			var curfile:PicInfoVo = DirectoryFileModel.instance.curOperateFile;
//			var curOperateType:int = DirectoryFileModel.instance.curOperateSelType;
//			if(curfile == null)
//				return;
//			
//			
//			if(picInfo != null)
//			{
//				var xdif:Number = Math.abs(curfile.picPhysicWidth - picInfo.picPhysicWidth)/curfile.picPhysicWidth;
//				var ydif:Number = Math.abs(curfile.picPhysicHeight - picInfo.picPhysicHeight)/curfile.picPhysicHeight;
//				if(xdif >0.01 || ydif > 0.01)
//				{
//					disableItem(true);
//					return;
//				}
//				if(curOperateType == 0 || curOperateType == 2)
//				{
//					if(picInfo.colorspace.toLocaleUpperCase() != "GRAY" && !picInfo.isCdr)
//					{
//						disableItem(true);
//						return;
//					}
//				}
//				else if(curOperateType == 1 && picInfo.colorspace != "CMYK")
//				{
//					
//					disableItem(true);
//					return;
//				}
//				
//			}
//			disableItem(false);
//
//								
//			
//		}
		
		private function onShowDelButton(btn:Button,btn1:Button):void
		{
			if(btn)
				btn.visible = true;
			if(btn1)
				btn1.visible = true;
		}
		
		private function onHideDelButton(btn:Button,btn1:Button):void
		{
			if(btn)
				btn.visible = false;
			if(btn1)
				btn1.visible = false;
		}
		
		private function moveImgUp():void
		{
			this.img.y = 106;
			this.filename.y = 178;
			this.fileinfo.y = 203;

			if(picInfo.picWidth > picInfo.picHeight)
			{
				this.img.width = 126;					
				this.img.height = 126/picInfo.picWidth * picInfo.picHeight;
										
			}
			else
			{
				this.img.height = 126;
				this.img.width = 126/picInfo.picHeight * picInfo.picWidth;
							
				
			}
		}
		private function onDeleteHandler(e:Event):void
		{
			// TODO Auto Generated method stub
			e.stopPropagation();
			if(picInfo.picType == 1)
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除该图片吗？",caller:this,callback:confirmDelete});
			else
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"确定删除该目录吗？",caller:this,callback:confirmDelete});

		
		}
		
		private function confirmDelete(result:Boolean):void
		{
			if(result)
			{
				if(this.sel.selected)
				{
					var datainfo:Array = [];
					datainfo.push(picInfo);
					datainfo.push(this.img);
					datainfo.push(this);
					
					EventCenter.instance.event(EventCenter.SELECT_PIC_ORDER,[datainfo]);
				}
				if(picInfo.picType == 1)
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deletePic,this,onDeleteFileBack,JSON.stringify({"fileID": picInfo.fid}),"post");
				else
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.deleteDirectory,this,onDeleteFileBack,JSON.stringify({"dirId":picInfo.dpath}),"post");
			}
		}
		
		private function onDeleteFileBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);

			}
		}
		private function onMouseOutHandler():void
		{
			// TODO Auto Generated method stub
			this.btndelete.visible = false;
			this.frame.visible = false;

			this.aiBtn.visible = false;
			
			//this.selYixingBtn.visible = false;
			//this.selBackBtn.visible = false;
			
			if(picInfo.yixingFid != "" && picInfo.yixingFid != "0")
			{			
				
				this.selYixingBtn.visible = false;
				
			}
			
			if(picInfo.backFid != "" && picInfo.backFid != "0")
			{
				this.selBackBtn.visible = false;
			}
			
			if(picInfo.partWhiteFid != "" && picInfo.partWhiteFid != "0")
			{
				this.selpart.visible = false;
			}
		}
		
		public function canCelSelected():void
		{
			//this.sel.visible = false;
			this.sel.selected = false;
		}
		
		private function onMouseOverHandler():void
		{
			// TODO Auto Generated method stub
			this.btndelete.visible = true;
			this.frame.visible = true;
			if(this.picInfo.picType == 1)
			{
				this.aiBtn.y = -20;
				this.aiBtn.visible = true;
				if(this.aiBtn.visible)
				Tween.to(this.aiBtn,{y:10},300,Ease.backOut);
			}


		}
		
		public function showYixingImg(fid:String):void
		{
			this.yixingimg.visible = true;
			this.yixingimg.skin = HttpRequestUtil.smallerrPicUrl + fid + ".jpg";
		}
		private function onClickHandler():void
		{
			// TODO Auto Generated method stub
			
			//if(this.picInfo.picType == 1 && this.picInfo.picClass.toLocaleUpperCase() == "PNG")
			//	return;
			
			if(this.picInfo.picType == 0)
			{
				if(DirectoryFileModel.instance.selectFolders.indexOf(picInfo.dpath) >= 0)
				{
					//this.sel.visible= false;
					this.sel.selected = false;
					var index:int = DirectoryFileModel.instance.selectFolders.indexOf(picInfo.dpath);
					DirectoryFileModel.instance.selectFolders.splice(index,1);
				}
				else
				{
					//this.sel.visible= true;
					this.sel.selected = true;
					
					DirectoryFileModel.instance.selectFolders.push(picInfo.dpath);
				}
				EventCenter.instance.event(EventCenter.UPDATE_SELECT_FOLDER);

				return;
			}
			if(this.picInfo.picType == 1  && this.picInfo.picPhysicWidth > 0)
			{
				if(DirectoryFileModel.instance.curOperateFile != null && DirectoryFileModel.instance.curOperateFile.fid == this.picInfo.fid)
				{					
					
					return;

				}
				
				if(UtilTool.isUnNormalPic(picInfo))
				{
					ViewManager.showAlert("图片大小异常，请尝试更换图片处理软件或另存图片，再重新上传。");
					return
				}
				
				if(!DirectoryFileModel.instance.haselectPic.hasOwnProperty(picInfo.fid))
				{
					//this.sel.visible = true;
					this.sel.selected = true;
				}
				else
				{
					//this.sel.visible = false;
					this.sel.selected = false;
				}
				
				var datainfo:Array = [];
				datainfo.push(picInfo);
				datainfo.push(this.img);
				datainfo.push(this);

				EventCenter.instance.event(EventCenter.SELECT_PIC_ORDER,[datainfo]);
				

			}
		}
		
		private function onClickImg(e:Event):void
		{
			if(this.picInfo.picType == 1  && this.picInfo.picPhysicWidth > 0)
			{
				if(DirectoryFileModel.instance.curOperateFile != null)
				{
					e.stopPropagation();
					if(DirectoryFileModel.instance.curOperateFile.fid == picInfo.fid)
					{
						return;
					}
					
					DirectoryFileModel.instance.setYingxingImg(this.picInfo);
					
					DirectoryFileModel.instance.curOperateFile = null;
					EventCenter.instance.event(EventCenter.STOP_SELECT_RELATE_PIC);
					
					//ViewManager.instance.openView(ViewManager.VIEW_SET_RELATED_CONFIRM_PANEL,false,[DirectoryFileModel.instance.curOperateFile,picInfo,DirectoryFileModel.instance.curOperateSelType,this,confirmSetRelated]);					
															
				}
			}
		}
		
		
		private function onSetYixingBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.showAlert("设置成功");
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);

			}
		}
		private function onSetFanmianBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.showAlert("设置成功");
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);

			}
		}
		private function onSelectYixingImg(e:Event):void
		{
			//if(DirectoryFileModel.instance.curOperateFile != null)
			//	return;
			
			if(this.picInfo.yixingFid == "0")
			{
				DirectoryFileModel.instance.curOperateFile = this.picInfo;
				DirectoryFileModel.instance.curOperateSelType = 0;
				this.sel.selected = true;
				EventCenter.instance.event(EventCenter.START_SELECT_YIXING_PIC,[picInfo]);
				//this.selBackBtn.selected = false;
				//this.selpart.selected = false;
				
				//this.selYixingBtn.selected = true;
				
				//this.sel.visible = true;
			}
			else
			{
				//this.picInfo.yixingFid = "";
				this.yixingimg.visible = false;
				
				//var params:String = "fid=" + picInfo.fid + "&fmaskid=0";
				var params:Object = {"fileId":picInfo.fid,"targetId": "0"};	

				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setYixingRelated,this,onSetYixingBack,JSON.stringify(params),"post");

			}
			e.stopPropagation();
		}
		private function onSelectBackImg(e:Event):void
		{
			//if(DirectoryFileModel.instance.curOperateFile != null)
			//	return;
			
			if(this.picInfo.backFid == "0")
			{
				DirectoryFileModel.instance.curOperateFile = this.picInfo;
				DirectoryFileModel.instance.curOperateSelType = 1;
				this.sel.selected = true;
				//this.selBackBtn.selected = true;
				EventCenter.instance.event(EventCenter.START_SELECT_BACK_PIC,[picInfo]);
//				this.selYixingBtn.selected = false;
//				this.selpart.selected = false;
//				
//				
				//this.sel.visible = true;
			}
			else
			{
				//this.picInfo.yixingFid = "";
				this.backimg.visible = false;
				
				var params:Object = {"fileId":picInfo.fid,"targetId": "0"};	
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setFanmianRelated,this,onSetFanmianBack,JSON.stringify(params),"post");
				
			}
			e.stopPropagation();
		}
		
		private function onSelectPartImg(e:Event):void
		{
			//if(DirectoryFileModel.instance.curOperateFile != null)
			//	return;
			
			if(this.picInfo.partWhiteFid == "0")
			{
				DirectoryFileModel.instance.curOperateFile = this.picInfo;
				DirectoryFileModel.instance.curOperateSelType = 2;
				//this.selpart.selected = true;
				EventCenter.instance.event(EventCenter.START_SELECT_PARTWHITE_PIC,[picInfo]);

//				this.selYixingBtn.selected = false;
//				this.selBackBtn.selected = false;
//				
				this.sel.selected = true;
				//this.sel.visible = true;
			}
			else
			{
				//this.picInfo.yixingFid = "";
				this.partImg.visible = false;
				
				var params:Object = {"fileId":picInfo.fid,"targetId": "0"};	
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.setPartWhiteRelated,this,onSetPartWhiteBack,JSON.stringify(params),"post");
				
			}
			e.stopPropagation();
		}
		
		public function resetRelatedBtn():void
		{
			this.selYixingBtn.selected = false;
			this.selBackBtn.selected = false;
			this.selpart.selected = false;

		}
		
		public function disableItem(disable:Boolean):void
		{
			this.disableImg.visible = disable;
			this.mouseEnabled = !disable;
			
		}
		private function onShowCbcEffect(e:Event):void
		{
			e.stopPropagation();
			
			var arr:Array = [];
			arr.push(this.picInfo.fid);
			arr.push(this.picInfo.partWhiteFid);
			if(this.picInfo.backFid == "0")
				arr.push(this.picInfo.fid);
			else
				arr.push(this.picInfo.backFid);
			arr.push(this.picInfo.yixingFid);
			arr.push(this.picInfo);
			
			ViewManager.instance.openView(ViewManager.VIEW_CBC_PREVIEW_PANEL,false,arr);
		}
		private function onSetPartWhiteBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//ViewManager.showAlert("设置成功");
				EventCenter.instance.event(EventCenter.UPDATE_FILE_LIST);
				
			}
		}
		
		private function getPixelInfo(pixel:Object):void
		{
			var imgdata = pixel;
			UtilTool.getCutCountLength(imgdata);
		}
		private function onDoubleClick():void
		{
			if(this.picInfo.picType == 0)
			{
				EventCenter.instance.event(EventCenter.SELECT_FOLDER,picInfo);
			}
			else
			{
				
				ViewManager.instance.openView(ViewManager.VIEW_PICTURE_CHECK,false,this.picInfo);
			}
		}
		
	
		
	}
}