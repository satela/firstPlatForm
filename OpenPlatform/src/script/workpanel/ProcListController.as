package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	import script.order.MaterialItem;
	import script.order.TechBoxItem;
	
	import ui.inuoView.ProcListPanelUI;
	
	import utils.UtilTool;
	
	public class ProcListController extends Script
	{
		private var uiSkin:ProcListPanelUI;
		
		private var curProcess:MaterialItemVo;
		
		private var procItemList:Array;
		
		private var procItemSpaceX:int = 10;
		
		private var procItemSpaceY:int = 36;

		private var curselectMaterialVo:MaterialItemVo;
		
		public function ProcListController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as ProcListPanelUI; 
			
			showProclist(PaintOrderModel.instance.curSelectMat.procTreeList);
			EventCenter.instance.on(EventCenter.CLOSE_PANEL_VIEW,this,onUpdateTechDes);
			EventCenter.instance.on(EventCenter.SELECT_NEW_PROCESS,this,showProclist);

		}
		
		private function showProclist(materialVoList:Array):void
		{
			while(uiSkin.proclist.numChildren > 0)
				uiSkin.proclist.removeChildAt(0);
			
			procItemList = [];
			var startY:int = 0;
			
			for(var i:int=0;i < materialVoList.length;i++)
			{
				var proceItem:TechBoxItem = new TechBoxItem();
				proceItem.setData(materialVoList[i]);
				uiSkin.proclist.addChild(proceItem);
				proceItem.techBtn.on(Event.CLICK,this,onSelectProcess,[materialVoList[i],i]);
				if(i==0)
				{
					proceItem.x = 0;
					proceItem.y = 0;
				}
				else
				{
					if((proceItem.width + procItemList[i - 1].x + procItemList[i - 1].width  + procItemSpaceX ) > uiSkin.proclist.width)
					{
						proceItem.x = 0;
						startY += proceItem.height + procItemSpaceY;
						proceItem.y = startY;
						
					}
					else
					{
						proceItem.x =  procItemList[i - 1].x + procItemList[i - 1].width + procItemSpaceX;
						proceItem.y = startY;
						
					}
				}
				
				if(materialVoList[i].selected)
					curselectMaterialVo = materialVoList[i];
				
				procItemList.push(proceItem);
			}
			
			
			
		}
		
		private function onSelectProcess(matvo:MaterialItemVo,index:int):void
		{
			
			if(OrderConstant.yiXingCutProcess((matvo as MaterialItemVo).procCode))
			{
				if(!PaintOrderModel.instance.checkCanSelYixing())
				{
					ViewManager.showAlert("图片未关联异形切割图片或者关联的异形切割图片不符合下单要求，请重新关联异形切割图片");
					return;
				}
			}
			if(matvo is MaterialItemVo && OrderConstant.backSideUnSame((matvo as MaterialItemVo).procCode))
			{
				if(!PaintOrderModel.instance.checkCanDoubleSide())
				{
					ViewManager.showAlert("图片未关联反面图片，请关联后再下单");
					return;
				}
			}
			if(matvo is MaterialItemVo && OrderConstant.whitePartProcess((matvo as MaterialItemVo).procCode))
			{
				if(!PaintOrderModel.instance.checkCanPartWhite())
				{
					ViewManager.showAlert("图片未关联局部铺白图片，请关联后再下单");
					return;
				}
			}
			
			curselectMaterialVo = matvo;
			
			
			if(matvo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN) >=0 || matvo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT) >=0)
			{
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_ATTACH,false,matvo);			
				return;
			}
			else if(matvo.attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0)
			{
				ViewManager.instance.openView(ViewManager.INPUT_CUT_NUM,false,false);
				//return;

			}				
			else if(matvo.attachmentList.indexOf(OrderConstant.AVERAGE_CUTOFF) >=0)
			{
				ViewManager.instance.openView(ViewManager.AVG_CUT_VIEW,false,matvo);
				//return;
			}
			else if(matvo.attachmentList.indexOf(OrderConstant.FEIBIAO_DAKOU) >=0)
			{
				ViewManager.instance.openView(ViewManager.VIEW_DAKOU_PANEL,false,matvo);
				//return;

			}
			
			
			if(UtilTool.needChooseAttachPic(matvo as MaterialItemVo))
			{
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_PIC_TO_ORDER,false,matvo);
				//return;
			}
			var parentitem:TechBoxItem = procItemList[index];
			//parentitem.setSelected(true);
			parentitem.setTechSelected(true);
			showProclist(matvo.nextMatList);

			EventCenter.instance.event(EventCenter.SELECT_PROCESS,[matvo]);
			
			
			//updateSelectedTech();
		}
		
		private function onUpdateTechDes(viewname:String):void
		{
			if(viewname == ViewManager.VIEW_SELECT_ATTACH && curselectMaterialVo != null)
			{
				if(curselectMaterialVo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN) >=0 || curselectMaterialVo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT) >=0)
				{
					if(curselectMaterialVo.attachList == null || curselectMaterialVo.attachList.length == 0)
					{
						return;
					}
					else
					{
						curselectMaterialVo.selected = true;
						curselectMaterialVo.attchFileId = "";
						curselectMaterialVo.attchMentFileId = "";
						showProclist(curselectMaterialVo.nextMatList);
						EventCenter.instance.event(EventCenter.SELECT_PROCESS,[curselectMaterialVo]);

					}
						
				}
				//updateSelectedTech();
				
			}
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.CLOSE_PANEL_VIEW,this,onUpdateTechDes);
			EventCenter.instance.off(EventCenter.SELECT_NEW_PROCESS,this,showProclist);

		}
		
	}
}