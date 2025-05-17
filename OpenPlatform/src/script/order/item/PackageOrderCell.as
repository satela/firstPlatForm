package script.order.item
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.orderModel.PackageVo;
	import model.orderModel.PaintOrderModel;
	
	import ui.order.PackageOrderItemUI;
	import ui.usercenter.OderDetailPanelUI;
	
	public class PackageOrderCell extends PackageOrderItemUI
	{
		private var orderData:Object;
		public function PackageOrderCell()
		{
			super();
			this.averageBtn.on(Event.CLICK,this,onAverageNum);
		}
		
		public function setOrderData(data:*):void
		{
			orderData = data;
			this.fileimg.skin = data.conponent.previewImagePath;
			
			
			var size:Array = data.conponent.LWH.split("/");
			
			var picwidth:Number = parseFloat(size[0]);
			var picheight:Number = parseFloat(size[1]);
			
			this.seqNum.text = data.itemSeq + "";
			
			if(picwidth > picheight)
			{
				this.fileimg.width = 108;					
				this.fileimg.height = 108/picwidth * picheight;
				
			}
			else
			{
				this.fileimg.height = 108;
				this.fileimg.width = 108/picheight * picwidth;
				
			}
			
			this.filenametxt.text = data.conponent.filename;
			
			this.mattext.text = data.conponent.prodName;
			
			this.numtxt.text = data.itemNumber + "";
		}
		
		private function onAverageNum():void
		{
			var total:int = orderData.itemNumber;
			if(PaintOrderModel.instance.packageList.length == 1)
				return;
			
//			var average:int = Math.floor(total/(PaintOrderModel.instance.packageList.length - 1 ));
//			if(average == 0)
//				average = 1;
//			
//			var left:int = total - average*(PaintOrderModel.instance.packageList.length - 1);
//			if(left < 0)
//				left = 0;
//			
//			var fisrtNum = average + left;
//			var hasDistrictNum = 0;
			
//			var firstpackvo:PackageVo = PaintOrderModel.instance.packageList[0];
//			for(var j:int=0;j < firstpackvo.itemlist.length;j++)
//			{
//				if(firstpackvo.itemlist[j].itemId == orderData.orderItemSn)
//				{
//					firstpackvo.itemlist[j].itemCount = 0;
//					break;
//				}
//			}
//			
//			for(var i:int=1;i < PaintOrderModel.instance.packageList.length;i++)
//			{
//				if(hasDistrictNum < total)
//				{
//					var packvo:PackageVo = PaintOrderModel.instance.packageList[i];
//					for(var j:int=0;j < packvo.itemlist.length;j++)
//					{
//						if(packvo.itemlist[j].itemId == orderData.orderItemSn)
//						{
//							packvo.itemlist[j].itemCount = i == 1?fisrtNum:average;
//							hasDistrictNum += packvo.itemlist[j].itemCount;
//							break;
//						}
//					}
//				}
//			}
			
			
			var average:int = Math.floor(total/(PaintOrderModel.instance.packageList.length ));
			if(average == 0)
				average = 1;
			
			var left:int = total - average*(PaintOrderModel.instance.packageList.length);
			if(left < 0)
				left = 0;
			
			var fisrtNum = average + left;
			var hasDistrictNum = 0;
			

			
			for(var i:int=0;i < PaintOrderModel.instance.packageList.length;i++)
			{
				if(hasDistrictNum < total)
				{
					var packvo:PackageVo = PaintOrderModel.instance.packageList[i];
					for(var j:int=0;j < packvo.itemlist.length;j++)
					{
						if(packvo.itemlist[j].itemId == orderData.orderItemSn)
						{
							packvo.itemlist[j].itemCount = i == 0?fisrtNum:average;
							hasDistrictNum += packvo.itemlist[j].itemCount;
							break;
						}
					}
				}
			}
			
			EventCenter.instance.event(EventCenter.UPDATE_PACKAGE_ORDER_ITEM_COUNT);

		}
	}
}