package model.orderModel
{
	import laya.Const;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	
	import utils.TimeManager;
	import utils.UtilTool;

	public class DeliveryTypeVo
	{
		public var delivery_code:String = "";//  配送方式编码
		public var delivery_name: String = "";// 配送方式名称
		public var start_weight: Number = 0;//  首重(kg)
		public var post_weight:  Number = 0;//  续重(kg)
		public var first_volume:  Number = 0;//  首体积(立方)
		public var post_volume:  Number = 0;//  续体积(立方)
		public var factor:  Number = 0;//  转换系数
		public var limit_weight:  Number = 0;//  限重(kg)
		public var limit_length:  Number = 0;//  限长(cm)
		public var limit_width:  Number = 0;//  限宽(cm)
		public var limit_height:  Number = 0;//  限高(cm)
		public var deliverynet_code: String = "";//  网点编码
		public var deliverynet_name: String = "";//  网点名称
		private var _firstweight_price: Number = 0;//  首重价格
		public var addedweight_price: Number = 0;//  续重价格
		public var firstvol_price: Number = 0;//  首体积价格
		public var addedvol_price: Number = 0;//  续体积价格
		
		public var shitf1_dateList:Array = [];
		public var shitf1_time:String;
		
		public var shitf2_dateList:Array = [];
		public var shitf2_time:String;
		
		public var shitf3_dateList:Array = [];
		public var shitf3_time:String;

		public var belongManuCode:String;//所属喷印中心编码
		
		public function DeliveryTypeVo(data:Object)
		{
			for(var key in data)
				this[key] = data[key];
			
			if(data.shift1Date != null && data.shift1Date != "")
			{
				shitf1_dateList = data.shift1Date.split(",");
			}
			
			if(data.shift1Time != null && data.shift1Time != "")
			{
				shitf1_time = data.shift1Time;
			}
			
			if(data.shift2Date != null && data.shift2Date != "")
			{
				shitf2_dateList = data.shift2Date.split(",");
			}
			
			if(data.shift2Time != null && data.shift2Time != "")
			{
				shitf2_time = data.shift2Time;
			}
			
			if(data.shift3Date != null && data.shift3Date != "")
			{
				shitf3_dateList = data.shift3Date.split(",");
			}
			
			if(data.shift3Time != null && data.shift3Time != "")
			{
				shitf3_time = data.shift3Time;
			}
			
//			if(delivery_name == OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
//			{
//				firstweight_price = Userdata.instance.deliveryFee;				
//				
//			}
			
		}
		
		public function get deliveryDesc():String
		{
			return delivery_name + "，" + deliverynet_name + "，首重:" + start_weight + "kg," + "续重" + post_weight + "kg，" + "首重价格:" + deliveryPrice + "元/kg，" + "续重价格:" + addedweight_price + "元/kg。";
		}
		
		public function get deliveryPrice():Number
		{
			var total:Number = PaintOrderModel.instance.getTotalWeightByManuCode(belongManuCode);
			
			var deliveryFee:Number = _firstweight_price;
			if(total > start_weight)
			{
				deliveryFee += Math.ceil((total - start_weight)/post_weight) * addedweight_price;
			}
			if(delivery_name != OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
				return deliveryFee;
			return deliveryFee + PaintOrderModel.instance.getDeliveryFeeByManuCode(belongManuCode);
		}
		
		public function set firstweight_price(value:Number):void
		{
			_firstweight_price = value;
		}
		
		public function canbeslected(curdate:Date):Boolean
		{
			if(delivery_name != OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
			{
				return true;
			}
			
			var day:String = curdate.getDay().toString();
			if(day == "0")
				day = "7";
			var alltime:Array = [];
			
			if(shitf1_dateList.length > 0 && shitf1_dateList.indexOf(day) >= 0)
			{
				if(shitf1_time != null)
					alltime.push(shitf1_time);
			}
			
			if(shitf2_dateList.length > 0 && shitf2_dateList.indexOf(day) >= 0)
			{
				if(shitf2_time != null)
					alltime.push(shitf2_time);
			}
			
			if(shitf3_dateList.length > 0 && shitf3_dateList.indexOf(day) >= 0)
			{
				if(shitf3_time != null)
					alltime.push(shitf3_time);
			}
			
			if(alltime.length == 0)
				return false;
			
			
			var maxhour:int = parseInt(alltime[0].split(":")[0]);
			var mins:int = parseInt(alltime[0].split(":")[1]);
			
			
			for(var i:int=1;i < alltime.length;i++)
			{
				var hous:int = parseInt(alltime[i].split(":")[0]);
				if(hous > maxhour)
				{
					maxhour = hous;
					mins = parseInt(alltime[i].split(":")[1]);
					
				}
			}
			
			var housstr:String = maxhour > 9 ? maxhour.toString():("0" + maxhour.toString());
			var minstr:String = mins > 9 ? mins.toString():("0" + mins.toString());

			var latesttimestr:String = UtilTool.formatFullDateTime(curdate,false).replace("-","/") + " " + housstr + ":" +  minstr + ":00";
			
			
			var latestime:Date = new Date(Date.parse(latesttimestr));
			
			//trace("timedeif:" + (latestime.getTime() - curdate.getTime())/1000);
			if((latestime.getTime() - curdate.getTime())/1000 > 7200)
				return true;
			return false;
			
		}
	}
}