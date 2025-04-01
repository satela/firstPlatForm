package script.order
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	import laya.ui.RadioGroup;
	import laya.utils.Handler;
	
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	
	import ui.order.DeliverySelItemUI;
	
	public class DeliverySelCell extends DeliverySelItemUI
	{
		private var deliveryData:Object;
		
		public function DeliverySelCell()
		{
			super();
		}
		
		public function setData(data:*):void
		{
			deliveryData = data;
			commondelType.labels = PaintOrderModel.instance.getDeliveryTypeStr(deliveryData.deliveryVoArr,false);
			
			urgentdeltype.labels = PaintOrderModel.instance.getDeliveryTypeStr(deliveryData.deliveryVoArr,true);
			
			//this.manufacturerName.text = deliveryData.manufacturer_name;
			//PaintOrderModel.instance.curCommmonDeliveryType = "";
			//PaintOrderModel.instance.curUrgentDeliveryType = "";
			
			this.backsp.graphics.drawRect(0,0, 1280,48,OrderConstant.OUTPUT_COLOR[PaintOrderModel.instance.getManuFactureIndex(deliveryData.manufacturer_code)]);

			//commondelType.on(Event.CHANGE,this,selectCommonDelType);
			
			//urgentdeltype.on(Event.CHANGE,this,selectUrgentDelType);
			
			if(PaintOrderModel.instance.hasCommonOrderItem(deliveryData.manufacturer_code))
			{
			
				var deltypelist:Array = commondelType.labels.split(",");
				
				for(var i:int=0;i < deltypelist.length;i++)
				{
					if(deltypelist[i].indexOf(OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER) >= 0)
					{
						commondelType.selectedIndex = i;
						PaintOrderModel.instance.curCommmonDeliveryType[deliveryData.manufacturer_code] = OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER;
						break;
					}
				}
				
				if(PaintOrderModel.instance.curCommmonDeliveryType[deliveryData.manufacturer_code] == null && deltypelist.length > 0)
				{
					PaintOrderModel.instance.curCommmonDeliveryType[deliveryData.manufacturer_code]=deltypelist[0].split('(')[0];
					commondelType.selectedIndex = 0;
	
				}
			}
			
			if(PaintOrderModel.instance.hasUrgentOrderItem(deliveryData.manufacturer_code))
			{
				var deltypelisturgent:Array = urgentdeltype.labels.split(",");
				
				for(i=0;i < deltypelisturgent.length;i++)
				{
					if(deltypelisturgent[i].indexOf(OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER) >= 0)
					{
						urgentdeltype.selectedIndex = i;
						PaintOrderModel.instance.curUrgentDeliveryType[deliveryData.manufacturer_code] = OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER;
						break;
					}
				}
				
				if(PaintOrderModel.instance.curUrgentDeliveryType[deliveryData.manufacturer_code] == null && deltypelisturgent.length > 0)
				{
					PaintOrderModel.instance.curUrgentDeliveryType[deliveryData.manufacturer_code]=deltypelisturgent[0].split('(')[0];
					urgentdeltype.selectedIndex = 0;
					
				}
			}
			EventCenter.instance.event(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE);

			urgentdeltype.selectHandler = new Handler(this,selectUrgentDelType);
			commondelType.selectHandler = new Handler(this,selectCommonDelType);

		}
		
		public function refreshLabel():void
		{
			if(deliveryData != null)
			commondelType.labels = PaintOrderModel.instance.getDeliveryTypeStr(deliveryData.deliveryVoArr,false);
		}
		private function selectUrgentDelType(index:int):void
		{
			if(index == -1)
				return;
			
			var temptype:String = getDelivertyType(urgentdeltype);
			if(PaintOrderModel.instance.isValidDeliveryType(deliveryData.deliveryVoArr,temptype))
			{
				PaintOrderModel.instance.curUrgentDeliveryType[deliveryData.manufacturer_code] = temptype;
				EventCenter.instance.event(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE);

			}
			else
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"送货上门班次没有了，请选择其他配送方式"});
				Laya.timer.frameOnce(2,this,function(){
					urgentdeltype.selectedIndex = -1;
				});
				
				//PaintOrderModel.instance.curUrgentDeliveryType = "";
				
			}
		}
		
		public function refreshRadio():void
		{
			if(deliveryData == null)
				return;
			
			if(!PaintOrderModel.instance.hasCommonOrderItem(deliveryData.manufacturer_code))
				this.commondelType.selectedIndex = -1;
			else
			{
				if(this.commondelType.selectedIndex < 0)
				{
					var deltypelist:Array = commondelType.labels.split(",");
					
					for(var i:int=0;i < deltypelist.length;i++)
					{
						if(deltypelist[i].indexOf(OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER) >= 0)
						{
							commondelType.selectedIndex = i;
							PaintOrderModel.instance.curCommmonDeliveryType[deliveryData.manufacturer_code] = OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER;
							break;
						}
					}
					
					if(commondelType.selectedIndex < 0 && deltypelist.length > 0)
					{
						PaintOrderModel.instance.curCommmonDeliveryType[deliveryData.manufacturer_code]=deltypelist[0].split('(')[0];
						commondelType.selectedIndex = 0;
						
					}
				}
			}
			
			if(!PaintOrderModel.instance.hasUrgentOrderItem(deliveryData.manufacturer_code))
				this.urgentdeltype.selectedIndex = -1;	
			else
			{
				if(this.urgentdeltype.selectedIndex < 0)
				{
					var deltypelisturgent:Array = urgentdeltype.labels.split(",");
					
					for(i=0;i < deltypelisturgent.length;i++)
					{
						if(deltypelisturgent[i].indexOf(OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER) >= 0)
						{
							urgentdeltype.selectedIndex = i;
							PaintOrderModel.instance.curUrgentDeliveryType[deliveryData.manufacturer_code] = OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER;
							break;
						}
					}
					
					if(urgentdeltype.selectedIndex < 0 && deltypelisturgent.length > 0)
					{
						PaintOrderModel.instance.curUrgentDeliveryType[deliveryData.manufacturer_code]=deltypelisturgent[0].split('(')[0];
						urgentdeltype.selectedIndex = 0;
						
					}
				}
			}
			
		}
		
		private function selectCommonDelType(index:int):void
		{
			if(index == -1)
				return;
			
			PaintOrderModel.instance.curCommmonDeliveryType[deliveryData.manufacturer_code] = getDelivertyType(commondelType);
			
			//updatePrice();
			
			EventCenter.instance.event(EventCenter.UPDATE_PRICE_BY_DELIVERYDATE);

		}
		
		private function getDelivertyType(radgroup:RadioGroup):String
		{
			var labellst:Array = radgroup.labels.split(",");
			var index:int = radgroup.selectedIndex;
			
			return labellst[index].split("(")[0];
			
		}
	}
}