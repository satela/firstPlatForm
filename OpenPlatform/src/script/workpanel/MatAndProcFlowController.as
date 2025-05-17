package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.View;
	import laya.utils.Browser;
	
	import model.HttpRequestUtil;
	import model.orderModel.ConstraintTool;
	import model.orderModel.MatProcEffectVo;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.order.PicOrderItem;
	import script.workpanel.items.MatProcessItem;
	
	import ui.inuoView.MaterialAdProcFlowPanelUI;
	import ui.inuoView.MaterialListPanelUI;
	import ui.inuoView.ProcListPanelUI;
	
	public class MatAndProcFlowController extends Script
	{
		private var uiSkin:MaterialAdProcFlowPanelUI;
		public var param:PicInfoVo;

		private var materialPanel:View;
		
		private var procListPanel:View;
		
		
		private var startx:int = 24;
		private var starty:int = 20;
		
		private var matAndProceItemList:Array;
		
		private var processItemSpaceX:int = 10;
		private var processItemSpaceY:int = 26;

		private var curSelectProcess:MaterialItemVo;
		
		public function MatAndProcFlowController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as MaterialAdProcFlowPanelUI; 
			
			uiSkin.mainpanel.vScrollBarSkin = "";
			
			initLeftPanel();
			
			matAndProceItemList = [];
			var matprocessItem:MatProcessItem = new MatProcessItem(2,null,"选择材料");
			uiSkin.matProcContainer.addChild(matprocessItem);
			matAndProceItemList.push(matprocessItem);
			matprocessItem.x = startx;
			matprocessItem.y = starty;
			
			uiSkin.confirmBtn.on(Event.CLICK,this,onConfirmMatProcess);
			uiSkin.closeBtn.on(Event.CLICK,this,closeView);
			uiSkin.effectBtn.on(Event.CLICK,this,showEffectPanel);
			
			EventCenter.instance.on(EventCenter.SHOW_SELECT_TECH,this,initTechView);
			//EventCenter.instance.on(EventCenter.SELECT_PIC_ORDER,this,checkShowEffectImg);
			//EventCenter.instance.on(EventCenter.CLOSE_PANEL_VIEW,this,checkShowEffectImg);
			EventCenter.instance.on(EventCenter.CANCEL_CHOOSE_ATTACH,this,onCancaleChooseAttach);
			EventCenter.instance.on(EventCenter.SHOW_MATERIAL_LIST_PANEL,this,showMaterialPanel);
			EventCenter.instance.on(EventCenter.SELECT_PROCESS,this,selectProcess);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.CHOOSE_PROCESS_ITEM,this,onChooseProcess);

			uiSkin.operateArea.vScrollBarSkin = "";
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

			showMaterialPanel();
			
		}
		private function onResizeBrower():void
		{
			uiSkin.height = Browser.clientHeight *Laya.stage.width/Browser.clientWidth;

		}
		private function initLeftPanel():void
		{
			uiSkin.originimg.skin = "";
			
			uiSkin.backimg.skin = "";
			
			uiSkin.yixingimg.skin = "";
			
			uiSkin.partImg.skin = "";
			
			if(param != null)
			{
				if(param.picWidth > param.picHeight)
				{
					uiSkin.originimg.width = 280;					
					uiSkin.originimg.height = 280/param.picWidth * param.picHeight;
					
					uiSkin.yixingimg.width = 128;					
					uiSkin.yixingimg.height = 128/param.picWidth * param.picHeight;
					
				}
				else
				{
					uiSkin.originimg.height = 280;
					uiSkin.originimg.width = 280/param.picHeight * param.picWidth;
					
					uiSkin.yixingimg.width = 128;					
					uiSkin.yixingimg.height = 128/param.picWidth * param.picHeight;
					
				}
				
				
				
				uiSkin.backimg.width = uiSkin.originimg.width;
				uiSkin.backimg.height = uiSkin.originimg.height;
				
				uiSkin.partImg.width = uiSkin.yixingimg.width;
				uiSkin.partImg.height = uiSkin.yixingimg.height;	
				
				if(param.fid == "-1")
					return;
				
				uiSkin.originimg.visible = true;
				uiSkin.originimg.skin = HttpRequestUtil.biggerPicUrl + param.fid + param.tailFix;
				
				uiSkin.backimg.visible = (param.backFid  != "0" && param.backFid != "")
				if(param.backFid !="0" && param.backFid != "")
					uiSkin.backimg.skin = HttpRequestUtil.biggerPicUrl + param.backFid + param.tailFix;

				uiSkin.yixingimg.visible = (param.yixingFid != "0" && param.yixingFid != "")
				if(param.yixingFid != "0" && param.yixingFid != "")
				{
					uiSkin.yixingimg.skin = HttpRequestUtil.biggerPicUrl + param.yixingFid + param.tailFix;
					
					
				}
				
				uiSkin.partImg.visible = (param.partWhiteFid  != "0" && param.partWhiteFid  != "")
				if(param.partWhiteFid != "0" && param.partWhiteFid != "")
				{
					uiSkin.partImg.skin = HttpRequestUtil.biggerPicUrl + param.partWhiteFid + param.tailFix;
										
				}
				
				//uiSkin.qiegeoriginimg.width = uiSkin.originimg.width;
				//uiSkin.qiegeoriginimg.height = uiSkin.originimg.height;
				
			}
		}
		private function showMaterialPanel():void
		{
			if(materialPanel == null)
				materialPanel = new MaterialListPanelUI();
			
			removeProclistPanel();
			this.uiSkin.operateArea.addChild(materialPanel);
		}
		
		private function removeMatlistPanel():void
		{
			if(materialPanel != null)
				materialPanel.removeSelf();
		}
		
		private function showProcPanel():void
		{
			removeMatlistPanel();
			if(procListPanel == null)
				procListPanel = new ProcListPanelUI();
			
			this.uiSkin.operateArea.addChild(procListPanel);
			if(PaintOrderModel.instance.curSelectMat)
				EventCenter.instance.event(EventCenter.SELECT_NEW_PROCESS,[PaintOrderModel.instance.curSelectMat.procTreeList]);
		}
		
		private function removeProclistPanel():void
		{
			if(procListPanel != null)
				procListPanel.removeSelf();
		}
		
		private function initTechView():void
		{
			if(PaintOrderModel.instance.curSelectMat != null)
			{
				var matAndProceItem:MatProcessItem = matAndProceItemList[0];
				matAndProceItem.updateData(0,PaintOrderModel.instance.curSelectMat);
				for(var i:int=1;i < matAndProceItemList.length;i++)
				{
					matAndProceItemList[i].removeSelf();
				}
				matAndProceItemList.splice(1,matAndProceItemList.length - 1);
				
				starty = 20;
				showProcPanel();
				//if(matVo.nextMatList.length > 0)
					addProcessItem(2,null);
				 
			}
		}
		
		private function addProcessItem(type:int,materialItemVo:MaterialItemVo):void
		{
			if(type == 2 && materialItemVo == null)
			{
				var matprocessItem:MatProcessItem = new MatProcessItem(2,null,"选择工艺");
			}
			else
			{
				 matprocessItem = new MatProcessItem(1,materialItemVo);

			}
			uiSkin.matProcContainer.addChild(matprocessItem);
			
			
			if((matprocessItem.width + matAndProceItemList[matAndProceItemList.length - 1].x + matAndProceItemList[matAndProceItemList.length - 1].width  + processItemSpaceX ) > uiSkin.matProcContainer.width)
			{
				matprocessItem.x = startx;
				starty += matprocessItem.height + processItemSpaceY;
				matprocessItem.y = starty;
				
			}
			else
			{
				matprocessItem.x =  matAndProceItemList[matAndProceItemList.length - 1].x + matAndProceItemList[matAndProceItemList.length - 1].width + processItemSpaceX;
				matprocessItem.y = starty;
				
			}
			matAndProceItemList.push(matprocessItem);
			updatePanelheight();
			
			
		}
		
		private function selectProcess(matVo:MaterialItemVo):void
		{
			 var matprocessItem:MatProcessItem = matAndProceItemList[matAndProceItemList.length - 1];
			 if(matprocessItem != null)
			 {
				 matprocessItem.updateData(1,matVo);
				 curSelectProcess = matVo;
				 if((matprocessItem.width + matprocessItem.x) > uiSkin.matProcContainer.width)
				 {
					 matprocessItem.x = startx;
					 starty += matprocessItem.height + processItemSpaceY;
					 matprocessItem.y = starty;
					 
				 }		
				 if(matVo.nextMatList.length > 0)
				 	addProcessItem(2,null);
				 updatePanelheight();
			 }
			
		}
		
		private function onChooseProcess(matvo:MaterialItemVo):void
		{
			if(matvo)
			{
				if(materialPanel.parent != null)
					removeMatlistPanel();
				if(procListPanel.parent == null)
					this.uiSkin.operateArea.addChild(procListPanel);
				
				if(matAndProceItemList[matAndProceItemList.length - 1].getType() == 2)
				{
					matAndProceItemList[matAndProceItemList.length - 1].removeSelf();
					matAndProceItemList.splice(matAndProceItemList.length - 1,1);
				
				}
				
				for(var i:int=1;i < matAndProceItemList.length;i++)
				{
					var matproItem:MatProcessItem = matAndProceItemList[i] as MatProcessItem;
					var materialItemvo:MaterialItemVo = matproItem.getVo() as MaterialItemVo;
					
					if(materialItemvo != null && matvo.nextMatList.indexOf(materialItemvo)>= 0)
					{
						for(var j=i;j < matAndProceItemList.length;j++)
						{
							var materialItemData:MaterialItemVo = matAndProceItemList[j].getVo() as MaterialItemVo;
							if(materialItemData != null)
								materialItemData.selected = false;
							matAndProceItemList[j].removeSelf();
						}
						matAndProceItemList.splice(i,matAndProceItemList.length - i);
						
						break;
					}
				}
				
				starty = matAndProceItemList[matAndProceItemList.length - 1].y;
				updatePanelheight();
				
				if(matvo.parentMaterialVo != null)
				{
					EventCenter.instance.event(EventCenter.SELECT_NEW_PROCESS,[matvo.parentMaterialVo.nextMatList]);
				}
				else
				{
					if(PaintOrderModel.instance.curSelectMat)
						EventCenter.instance.event(EventCenter.SELECT_NEW_PROCESS,[PaintOrderModel.instance.curSelectMat.procTreeList]);
				}
			}
		}
		
		private function updatePanelheight():void
		{
			uiSkin.matProcContainer.height = starty + 96 + 20;
			
			uiSkin.operateArea.y = uiSkin.matProcContainer.height;
			
			uiSkin.operateArea.height = uiSkin.rightbox.height - uiSkin.matProcContainer.height - 20;

			
		}
		
		private function onCancaleChooseAttach():void
		{
			
		}
		
		private function onConfirmMatProcess():void
		{
			if(PaintOrderModel.instance.curSelectMat == null || PaintOrderModel.instance.curSelectMat.getTechDes(true) == "")
			{
				ViewManager.showAlert("请选择一个工艺");
				return;
				
			}
			if(curSelectProcess == null)
				return;
			
//			if(curSelectProcess.nextProcRequired && (curSelectProcess.nextMatList.length > 0 && curSelectProcess.nextMatList[0].parentMaterialVo ==  curSelectProcess))
//			{
//				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"后置工艺必须选一个"});
//				return;
//			}
			
			var hasSelectedTech:Array = PaintOrderModel.instance.curSelectMat.getAllSelectedTech();
			var picOrderItem:PicOrderItem = PaintOrderModel.instance.curSelectOrderItem;
			if(picOrderItem == null)
				picOrderItem= PaintOrderModel.instance.batchChangeMatItems[0];
			
			for(var i:int=0;i < hasSelectedTech.length;i++)
			{
				if(hasSelectedTech[i].attachmentList.indexOf(OrderConstant.FEIBIAO_DAKOU) >= 0)
				{
					if(picOrderItem != null && picOrderItem.ordervo.holeList.length == 0)
					{
						ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"非标打扣工艺未设置打孔信息，请重新设置"});
						
						return ;
					}
				}
			}
			if(hasSelectedTech.length > 0 && hasSelectedTech[hasSelectedTech.length - 1].is_mandatory)
			{
				if(hasSelectedTech[hasSelectedTech.length - 1].nextMatList.length > 0 && hasSelectedTech[hasSelectedTech.length - 1].nextMatList[0].parentMaterialVo == hasSelectedTech[hasSelectedTech.length - 1])
				{
					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"后置工艺必须选一个"});
					return;
					
				}
			}
			
			
			for(var i:int=0;i < hasSelectedTech.length;i++)
			{
				if(hasSelectedTech[i].attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN) >=0 || hasSelectedTech[i].attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT) >=0)
				{
					if(hasSelectedTech[i].selectAttachVoList == null || hasSelectedTech[i].selectAttachVoList.length == 0 )
					{
						ViewManager.showAlert("未选择配件");
						return;
					}
				}
			}
			
			var nextmatlist:Vector.<MaterialItemVo> = curSelectProcess.nextMatList;
			if(nextmatlist != null)
			{
				for(var i:int=0;i < nextmatlist.length;i++)
				{
					if(nextmatlist[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0)
					{
						ViewManager.showAlert("当前有必选工艺，请选择");
						return;
					}
					else if(nextmatlist[i].showType == ConstraintTool.RESULT_VALUE_SELETED)
					{
						ViewManager.showAlert("当前有必选工艺，请选择");
						return;
					}
					else if(nextmatlist[i].parentMaterialVo.nextProcRequired)
					{
						ViewManager.showAlert("当前有必选工艺，请选择");
						return;
					}
				}
			}
			
			PaintOrderModel.instance.curSelectMat.getProductDiscount(updatePicOrderProduct,this);

			
			ViewManager.instance.closeView(ViewManager.VIEW_SET_MATERIAL_PROCESS_PANEL);
		}
		private function updatePicOrderProduct():void
		{
			if(PaintOrderModel.instance.curSelectOrderItem)
				PaintOrderModel.instance.curSelectOrderItem.changeProduct(PaintOrderModel.instance.curSelectMat);
			else if(PaintOrderModel.instance.batchChangeMatItems && PaintOrderModel.instance.batchChangeMatItems.length > 0)
			{
				for(var i:int=0;i < PaintOrderModel.instance.batchChangeMatItems.length;i++)
					PaintOrderModel.instance.batchChangeMatItems[i].changeProduct(PaintOrderModel.instance.curSelectMat);
			}
			
			EventCenter.instance.event(EventCenter.UPDATE_ORDER_ITEM_TECH);
			
		}
		
		private function showEffectPanel():void
		{
			if(PaintOrderModel.instance.curSelectMat != null)
			{
				var matProc:MatProcEffectVo = new MatProcEffectVo();
				
				var picorderItem:PicOrderItem;
				if(PaintOrderModel.instance.curSelectOrderItem != null)
				{
					picorderItem = PaintOrderModel.instance.curSelectOrderItem;
					
				}
				else if(PaintOrderModel.instance.batchChangeMatItems != null && PaintOrderModel.instance.batchChangeMatItems.length > 0)
				{
					picorderItem = PaintOrderModel.instance.batchChangeMatItems[0];
					
				}
				
				if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("车贴") >=0)
				{
					if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("白胶") >=0)
						matProc.matType = 1;
					else if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("黑胶") >=0)
						matProc.matType = 4;
					else if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("灰胶") >=0)
						matProc.matType = 5;
					
				}
				else if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("磨砂") >=0)
					matProc.matType = 3;
				else if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("超透") >=0 || PaintOrderModel.instance.curSelectMat.prodName.indexOf("透明") >=0)
					matProc.matType = 2;
				else if(PaintOrderModel.instance.curSelectMat.prodName.indexOf("双喷布") >=0)
				{
					matProc.matType = 6;
					matProc.backImageUrl = HttpRequestUtil.biggerPicUrl + picorderItem.ordervo.picinfo.fid + picorderItem.ordervo.picinfo.tailFix;

				}
				
				
				matProc.imageUrl = HttpRequestUtil.biggerPicUrl + picorderItem.ordervo.picinfo.fid + picorderItem.ordervo.picinfo.tailFix;
				matProc.finalWidth = picorderItem.finalWidth;
				matProc.finalHeighth = picorderItem.finalHeight;
				if(picorderItem.ordervo.picinfo.tailFix == ".png")
					matProc.imageType = MatProcEffectVo.IMAGE_TYPE_PNG;
				else
					matProc.imageType = MatProcEffectVo.IMAGE_TYPE_JPG;

				var curselectProcess:Array = PaintOrderModel.instance.curSelectMat.getAllSelectedTech();
				for(var i:int=0;i < curselectProcess.length;i++)
				{
					var matitem:MaterialItemVo = curselectProcess[i] as MaterialItemVo;
					if(OrderConstant.yiXingCutProcess(matitem.procCode))
					{
						matProc.yixingImageUrl = HttpRequestUtil.biggerPicUrl + picorderItem.ordervo.picinfo.yixingFid + ".jpg";
					}
					else if(matitem.procName.indexOf("局部铺白") >= 0)
					{
						matProc.partWhiteImageUrl = HttpRequestUtil.biggerPicUrl + picorderItem.ordervo.picinfo.partWhiteFid + ".jpg";
						matProc.whiteFillType = MatProcEffectVo.WHITE_FILL_TYPE_PART_WHITE;
					}
					else if(matitem.procName.indexOf("满铺白") >= 0)
					{
						matProc.whiteFillType = MatProcEffectVo.WHITE_FILL_TYPE_FULL_WHITE;
					}
					else if(matitem.procName.indexOf("有色铺白") >= 0)
					{
						matProc.whiteFillType = MatProcEffectVo.WHITE_FILL_TYPE_COLOR_WHITE;
					}
					else if(matitem.procName.indexOf("全彩") >= 0)
					{
						matProc.colorType = MatProcEffectVo.COLOR_TYPE_FULL_COLOR;
					}
					
					else if(matitem.procName.indexOf("彩白彩") >= 0)
					{
						matProc.colorType = MatProcEffectVo.COLOR_TYPE_COLOR_WHITE_COLOR;
					}
					else if(matitem.procName.indexOf("彩白") >= 0)
					{
						matProc.colorType = MatProcEffectVo.COLOR_TYPE_COLOR_WHITE;
					}
					else if(matitem.procName.indexOf("白彩") >= 0)
					{
						matProc.colorType = MatProcEffectVo.COLOR_TYPE_WHITE_COLOR;
					}
					else if(matitem.procName.indexOf("纯白") >= 0)
					{
						matProc.colorType = MatProcEffectVo.COLOR_TYPE_PURE_WHITE;
					}
					else if(matitem.procName.indexOf("镜像") >= 0)
					{
						matProc.mirrorImage = -1;
					}
				}
				

			}
			else
			{
				ViewManager.showAlert("请先选择材料");
				return;
			}
			ViewManager.instance.openView(ViewManager.EFFECT_PREVIEW_PANEL,false,matProc);
		}
		
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_SET_MATERIAL_PROCESS_PANEL);

		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.SHOW_SELECT_TECH,this,initTechView);
			//EventCenter.instance.on(EventCenter.SELECT_PIC_ORDER,this,checkShowEffectImg);
			//EventCenter.instance.on(EventCenter.CLOSE_PANEL_VIEW,this,checkShowEffectImg);
			EventCenter.instance.off(EventCenter.CANCEL_CHOOSE_ATTACH,this,onCancaleChooseAttach);
			EventCenter.instance.off(EventCenter.SHOW_MATERIAL_LIST_PANEL,this,showMaterialPanel);
			EventCenter.instance.off(EventCenter.SELECT_PROCESS,this,selectProcess);
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.CHOOSE_PROCESS_ITEM,this,onChooseProcess);

		}
	}
}