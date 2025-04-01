package script.usercenter
{
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import script.ViewManager;
	
	import ui.usercenter.OrderQuestItemUI;
	
	import utils.UtilTool;
	
	public class QuestOrderItem extends OrderQuestItemUI
	{
		public var adjustHeight:Function;
		public var caller:Object;

		public var ordata:Object;
		
		private var ordersn:String;
		private var hasgetState:Boolean = false;
		public function QuestOrderItem()
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
			
			this.money.text = (Number(orderdata.itemPrice) * Number(orderdata.itemNumber)).toFixed(2);
			
			if(Userdata.instance.isHidePrice())
				this.money.text = "****";
			
			if(orderdata.conponent.filename != null)
				this.filename.text = orderdata.conponent.filename;
			else
				this.filename.text = "";
			//this.txtDetailInfo.text = "收货地址：" + orderdata.address;
			
			this.commentmark.visible = orderdata.comments != "";
			this.comment.on(Event.CLICK,this,onShowComment);
			
			this.detailbox.visible = false;
			//this.bgimg.height = 90;
			this.detailbtn.on(Event.CLICK,this,onClickShowDetail);
		}
		
		private function onShowComment():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ADD_MESSAGE,false,{msg:ordata.comments});

		}
		private function onClickShowDetail():void
		{
			this.detailbox.visible = !this.detailbox.visible;
			
			if(this.detailbox.visible && hasgetState == false)
			{
				//var requestdata:String = "order_sn=" + ordersn + "&item_seq=" + ordata.itemSeq + "&prod_code=" + ordata.conponent.prodCode;
				
				var requestdata:String = "orderItemSn=" + this.ordata.orderItemSn ;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOrderState + requestdata,this,onGetStateBack,null,null);

			}
//			if(this.detailbox.visible)
//				this.bgimg.height = 165;
//			else
//				this.bgimg.height = 90;
//			adjustHeight.call(caller);
		}
		
		private function onGetStateBack(data:*):void{
			
			try
			{
				var msg:Object = JSON.parse(data as String);
				if(msg != null)
				{
					hasgetState = true;
					if(msg.status == -1)
					{
						this.txtDetailInfo.text = "未查询到生产信息";
					}
					else if(msg.status == 0)
						this.txtDetailInfo.text = "产品状态：生产未完成" ;
					else if(msg.status == 3)
						this.txtDetailInfo.text = "产品状态：生产已完成" ;
	
				}
			}
			catch(err:Error)
			{
				
			}
			
		}
		private function hideDetail():void
		{
			this.detailbox.visible = false;
			//this.bgimg.height = 90;
		}
	}
}