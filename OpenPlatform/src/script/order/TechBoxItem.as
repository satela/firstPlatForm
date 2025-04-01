package script.order
{
	import laya.events.Event;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	import model.Constast;
	import model.orderModel.AttchCatVo;
	import model.orderModel.ConstraintTool;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProcessCatVo;
	
	import script.ViewManager;
	
	import ui.order.TechorItemUI;
	
	import utils.TipImgUtils;
	import utils.TipsUtil;
	import utils.UtilTool;
	
	public class TechBoxItem extends TechorItemUI
	{
		public var techmainvo:MaterialItemVo;		
		
		
		public var isSelected:Boolean = false;
		
		public var processCatVo:ProcessCatVo;
		
		public var attachVo:AttchCatVo;
		public function TechBoxItem()
		{
			super();			
			TipsUtil.getInstance().addTips(this.tipImg,"点击查看工艺效果图");
			this.tipImg.on(Event.CLICK,this,showEffectImg);
		}
		
		public function setData(tvo:MaterialItemVo):void
		{
			processCatVo = null;
			techmainvo = tvo;
			initView();
			
			if(tvo.selected)
				setSelected(true);
			else
				setSelected(false);
			
//			if(techmainvo.attachmentList.indexOf(OrderConstant.AVERAGE_CUTOFF) >=0)
//			{
//				if(UtilTool.hasChaofuProcess(PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>) || PaintOrderModel.instance.checkIslongerForDfcq())
//				{
//					this.techBtn.disabled = true;
//					this.mouseEnabled = !this.techBtn.disabled;
//					//this.grayimg.visible = !this.mouseEnabled;
//					return;
//				}				
//				
//			}
			
			if((techmainvo.parentMaterialVo != null && techmainvo.parentMaterialVo.nextProcRequired) || techmainvo.attachmentList.indexOf(OrderConstant.CUTOFF_H_V ) >=0 )
			{
				startshine();
			}
			
//			this.techBtn.disabled = false;
//			this.mouseEnabled = true;
			this.grayimg.visible = false;

			if(techmainvo.showType == ConstraintTool.RESULT_VALUE_FREEZE)
				this.filters = [UtilTool.grayscaleFilter];
			else
				this.filters = null;
			
			this.techBtn.disabled = techmainvo.showType == ConstraintTool.RESULT_VALUE_FREEZE;
			if(techmainvo.showType == ConstraintTool.RESULT_VALUE_SELETED)
			{
				startshine();
			}
			this.mouseEnabled = techmainvo.showType != ConstraintTool.RESULT_VALUE_FREEZE;
			this.grayimg.visible = techmainvo.showType == ConstraintTool.RESULT_VALUE_FREEZE;
			if(this.grayimg.visible)
				this.techBtn.labelColors="#b1b1b1";
			this.shineimg.visible = false;
			this.tipImg.visible = techmainvo.procImage != null && techmainvo.procImage != "";
			//this.on(Event.MOUSE_OVER,this,onShowTips);
			//this.on(Event.MOUSE_OUT,this,onHideTips);
			//this.on(Event.MOUSE_MOVE,this,onMoveTips);

		}
		
		private function showEffectImg(e:Event):void
		{
			e.stopPropagation();
			var postdata:Object = {};
			postdata.title = techmainvo.procName;
			postdata.url = techmainvo.procImage;
			
			ViewManager.instance.openView(ViewManager.PRODUCT_PROC_EFFECT_PANEL,false,postdata);
		}
		private function onShowTips(e:Event):void
		{
			TipImgUtils.getInstance().setTipsContent("<span color='#FF0000' size='18'>请直接选择</span>","bigImg/firstAct.jpg");
		}
		private function onMoveTips(e:Event):void
		{
			TipImgUtils.getInstance().showTips(e);
		}
		private function onHideTips(e:Event):void
		{
			TipImgUtils.getInstance().removeTips(e);
		}
		
		public function updateState():void
		{
			this.techBtn.disabled = techmainvo.showType == ConstraintTool.RESULT_VALUE_FREEZE;
			this.mouseEnabled = techmainvo.showType != ConstraintTool.RESULT_VALUE_FREEZE;
			this.grayimg.visible = techmainvo.showType == ConstraintTool.RESULT_VALUE_FREEZE;
			if(techmainvo.showType == ConstraintTool.RESULT_VALUE_SELETED)
			{
				startshine();
			}
		}
		public function startshine():void
		{
			this.shineimg.visible = true;
			startTween();
		}
		
		private function startTween():void
		{
			Tween.to(this.shineimg,{alpha:0},300,Ease.elasticIn,new Handler(this,onCompleteShine));

		}
		public function onCompleteShine():void
		{
			Tween.to(this.shineimg,{alpha:1},300,Ease.elasticIn,new Handler(this,startshine));

		}
		
		public function stopshine():void
		{
			this.shineimg.visible = false;
			Tween.clearAll(this.shineimg);
		}
		public function setAttachVo(attachvo:AttchCatVo):void
		{
			processCatVo = null;
			techmainvo = null;
			
			attachVo = attachvo;
			this.techBtn.label = attachVo.accessory_name;
			setSelected(false);
		}
		
		public function setProcessData(pvo:ProcessCatVo):void
		{
			techmainvo = null;
			processCatVo = pvo;
			this.techBtn.label = pvo.procCat_Name.split("-")[0];
//			if(pvo.isMandatory)
//			{
//				setSelected(true);
//			}
//			else
//				setSelected(false);
		}
		
		private function initView():void
		{
			this.techBtn.label = techmainvo.procName;
			
			this.techBtn.width = this.techBtn.text.textWidth + 30;
			this.width = this.techBtn.width;
			
		}
		
		public function setSelected(sel:Boolean):void
		{
			this.techBtn.selected = sel;;
			isSelected = sel;
			
		}
		
		public function setTechSelected(sel:Boolean):void
		{
			if(techmainvo != null)
			{
				techmainvo.selected = sel;

					techmainvo.attchMentFileId = "";
					techmainvo.attchFileId = "";
					techmainvo.selectAttachVoList = null;
				//}
			}
			else
				processCatVo.selected = sel;
			
		}
		private function onClickTech(index:int):void
		{
//			if(lastSelectIndex >= 0 && lastSelectIndex != index)
//			{
//				allItems[index].txt.borderColor = "#FF0000";
//				allItems[lastSelectIndex].txt.borderColor = "#445544";
//				lastSelectIndex = index;
//			}
//			else if(lastSelectIndex < 0)
//			{
//				allItems[index].txt.borderColor = "#FF0000";
//				lastSelectIndex = index;
//			}
//			else if(lastSelectIndex == index)
//			{
//				allItems[lastSelectIndex].txt.borderColor = "#445544";
//				lastSelectIndex = -1;
//			}
		}
	}
}