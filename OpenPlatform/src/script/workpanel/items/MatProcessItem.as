package script.workpanel.items
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	
	import model.orderModel.MaterialItemVo;
	import model.orderModel.ProductVo;
	
	import script.order.MaterialItem;
	
	import ui.inuoView.items.MatProcessItemUI;
	
	public class MatProcessItem extends MatProcessItemUI
	{
		private var uiskin:MatProcessItemUI;
		
		private var type:int = 0;// 0 :材料  1：工艺 2 ： 不可点击，单纯提示文字
		
		private var vo:*;
		public function MatProcessItem(btnType:int,data:*,text:String=null)
		{
			super();
			type = btnType;
			vo = data;
			this.arrow.visible = true;

			updateView(text);
			this.on(Event.MOUSE_OVER,this,function(){
				
				if(this.btn.selected)
					return;
				this.arrow.skin = "iconsNew/bigArrowGreen.png";
				
			});
			this.on(Event.MOUSE_OUT,this,function(){
				
				if(this.btn.selected)
					return;
				this.arrow.skin = "iconsNew/bigArrow.png";
				
			});
			
			
			
			this.btn.on(Event.CLICK,this,onClickHandler);
		}
		
		private function updateView(text:String):void
		{
			
			if(type == 2)
			{
				this.btn.label = text + "     ";	
				this.btn.selected = true;
				this.arrow.skin = "iconsNew/bigArrowGreen.png";
				
			}
			else if(type == 0)
			{
				this.btn.label = (vo as ProductVo).prodName + "   ";
				this.btn.selected = false;
				this.arrow.skin = "iconsNew/bigArrow.png";

			}
			else if(type == 1)
			{
				var matvo:MaterialItemVo = vo as MaterialItemVo;
				var labelname:String = matvo.procName;
				
				if(matvo.selectAttachVoList != null && matvo.selectAttachVoList.length > 0)
					labelname += "(" + matvo.selectAttachVoList[0].accessory_name + ")";
				if((vo as MaterialItemVo).nextMatList.length > 0)
					this.btn.label = labelname + "   ";
				else
				{
					this.btn.label = labelname;
					this.arrow.visible = false;
				}
				this.btn.selected = false;

				this.arrow.skin = "iconsNew/bigArrow.png";

			}
			this.btn.width = 500;
			
			this.btn.width = this.btn.text.textWidth + 40;
			this.width = this.btn.width;

		}
		public function updateData(btnType:int,data:*,text:String=null):void
		{
			type = btnType;
			vo = data;
			this.arrow.visible = true;
			
			updateView(text);
		}
		private function onClickHandler():void
		{
			if(this.type == 2)
				return;
			if(this.btn.selected)
				return;
			
			if(this.type == 0)
			{
				EventCenter.instance.event(EventCenter.SHOW_MATERIAL_LIST_PANEL);
			}
			else if(this.type == 1)
			{
				EventCenter.instance.event(EventCenter.CHOOSE_PROCESS_ITEM,[vo]);
			}
		}
		
		public function getVo():*
		{
			return vo;
		}
		
		public function getType():int
		{
			return type;
		}
				
		
	}
}