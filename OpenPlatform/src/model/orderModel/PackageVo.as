package model.orderModel
{
	import model.users.AddressVo;

	public class PackageVo
	{
		public var packageName:String = "";
		
		public var address:AddressVo;
		
		public var itemlist:Vector.<PackageItem>;
		
		public function PackageVo()
		{
			itemlist = new Vector.<PackageItem>();
		}
	}
}