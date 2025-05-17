package model.users
{

	public class AddressVo
	{
		public static var ADDRESS_DELETE:String = "delete";
		public static var ADDRESS_UPDATE:String = "update";
		public static var ADDRESS_INSERT:String = "insert";
		public static var ADDRESS_LIST:String = "list";

		public var receiverName:String = "";
		
		public var phone:String = "";
		
		public var zoneid:String = "";
		
		public var searchZoneid:String = "";
		
		//public var city:String = "浦东新区";
		
		//public var town:String = "周浦镇";
		
		public var address:String = "";
		
		public var id:String;
		
		public var preAddName:String;
		
		public var status:int = 0;
		
		public var customerId:String = "0";
		
		public var defaultDeliveryType:String = "";
		
		public var customerName:String;
		public var defaultPayType:String;
			
		public function AddressVo(data:Object)
		{
			receiverName = data.cnee;
			phone = data.mobileNumber;
			address= data.addr;
			id = data.id;
			
			preAddName = data.regionName;
			status = data.status;
			if(data.region != null)
			{
				var addid:Array = data.region.split("|");
				zoneid = addid[0];
				searchZoneid = addid[1];
			}
			defaultDeliveryType = data.defaultDelivery;
		}
		
		public function get addressDetail():String
		{
			return receiverName + "-" + phone + " " + preAddName + address;// + (status == 0 ? "（未审核）":"");
		}
		
		public function get addressDetailNoState():String
		{
			return receiverName + "-" + phone + " " + preAddName + address;
		}
		
		public function get proCityArea():String
		{
			return  preAddName + " " + address;
		}
	}
}