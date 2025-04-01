package model.users
{
	public class VipAddressVo extends AddressVo
	{
		public var selected:Boolean = false;
		
		public function VipAddressVo(data:Object)
		{
			super(data);
			selected = false;
		}
	}
}