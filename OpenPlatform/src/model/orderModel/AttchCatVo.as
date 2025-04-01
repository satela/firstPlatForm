package model.orderModel
{
	public class AttchCatVo
	{
		public var accessory_code:String = "";// 配件编码
		public var accessory_name: String = "";//  配件名称
		public var accessory_color: String = "";// 配件颜色
		public var accessory_brand: String = "";// 配件品牌
		public var accessory_ssupplier: String = "";//  配件供应商
		public var measure_unit: String = "";//  计量单位
		public var unit_weight: Number = 0;//  单位重量
		public var accessory_price: Number = 0;//  配件价格
		public var unique_code:String = "";
		public var is_belongtoClient:Boolean;
		
		public var materialItemVo:MaterialItemVo;
		public function AttchCatVo(data:Object)
		{
			if(data != null)
			{
				for(var key in data)
				{
					if(this.hasOwnProperty(key))
						this[key] = data[key];
				}
			}
		}
		
		public function cloneData():AttchCatVo
		{
			var attvo:AttchCatVo = new AttchCatVo(this);
			return attvo;
		}
	}
}