package script.usercenter.item
{
	import ui.usercenter.OrderPriceSellPhoneItemUI;
	
	import utils.UtilTool;
	
	public class OrderPriceSharePhoneItem extends OrderPriceSellPhoneItemUI
	{
		public var adjustHeight:Function;
		public var caller:Object;
		
		public var ordata:Object;
		
		private var ordersn:String;
		private var hasgetState:Boolean = false;
		
		public function OrderPriceSharePhoneItem()
		{
			super();
		}
		public function setData(orderdata:Object):void
		{
			this.itemseq.text = orderdata.itemSeq;
			if(orderdata.conponent.thumbnailsPath != null && orderdata.conponent.thumbnailsPath != "")
				this.picimg.skin = orderdata.conponent.thumbnailsPath;
			else
				this.picimg.skin = "commers/blackbg.png";
			
			
			
			this.isurgent.visible = orderdata.isUrgent;
			
			ordata = orderdata;
			ordersn = orderdata.orderId;
			//this.fileimg.skin = 
			//this.txtMaterial.text = ;
			this.matname.text = orderdata.conponent.prodName;
			var sizearr:Array = (orderdata.conponent.LWH as String).split("/");
			
			if(orderdata.deliveryDate  != null)
				this.deliverydate.text = UtilTool.getNextDayStr(orderdata.deliveryDate  + " 00:00:00");
			else
				this.deliverydate.text = "";
			
			
			this.widthtxt.text = sizearr[0];
			this.heighttxt.text = sizearr[1];
			
			var picwidth:Number = parseFloat(sizearr[0]);
			var picheight:Number = parseFloat(sizearr[1]);
			
			if(picwidth > picheight)
			{
				this.picimg.width = 155;					
				this.picimg.height = 155/picwidth * picheight;
				
			}
			else
			{
				this.picimg.height = 155;
				this.picimg.width = 155/picheight * picwidth;
				
			}
			
			this.pronum.text = orderdata.itemNumber + "";
			var techstr:String =  "";
			if(orderdata.conponent.procInfoList != null)
			{
				for(var i:int=0;i < orderdata.conponent.procInfoList.length;i++)
					techstr += orderdata.conponent.procInfoList[i].procDescription + "-";
			}
			
			this.tech.text = techstr.substr(0,techstr.length - 1);
			
			//this.money.text = (Number(orderdata.itemPrice) * Number(orderdata.itemNumber)).toFixed(2);
			//this.unitPriceTxt.text = orderdata.itemPrice;
			
			
			this.measureUnit.text = orderdata.measureUnit != null? orderdata.measureUnit:"平方米";
			
			if(orderdata.totalMeasureNum != null && orderdata.totalMeasureNum != "" && ordata.totalSalesPrice != null && ordata.totalSalesPrice != "")
				var unitprice:String = (parseFloat(ordata.totalSalesPrice)/parseFloat(orderdata.totalMeasureNum)).toFixed(2);
			else
				unitprice = orderdata.itemPrice;
			
			
			this,unitPriceInput.text = (ordata.unitSalesPrice != null && ordata.unitSalesPrice != "")?ordata.unitSalesPrice:unitprice;
			
			this.totalPriceInput.text = (ordata.totalSalesPrice != null && ordata.totalSalesPrice != "")?ordata.totalSalesPrice:"0";
			
			//this.unitPriceInput.on(Event.INPUT,this,onChangeUnitPrice);
			//this.totalPriceInput.on(Event.INPUT,this,onChangeTotalPrice);
			
			
			
			
			if(orderdata.conponent.filename != null)
				this.filename.text = orderdata.conponent.filename;
			else
				this.filename.text = "";
			//this.txtDetailInfo.text = "收货地址：" + orderdata.address;
			
		}
		
		
		
		
		
		
	}
}