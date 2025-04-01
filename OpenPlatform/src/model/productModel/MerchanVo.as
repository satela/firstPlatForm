package model.productModel
{
	public class MerchanVo
	{
		public var prod_code:String;//产品编码
		public var prod_name:String;//产品名称
		public var measure_unit:String;//计量单位
		public var manufacturer_code:String;//输出中心编码
		public var manufacturer_name:String;//输出中心名称
		public var mer_volume:String;//成品商品体积（长*宽*高
		public var mer_weight:Number;//成品商品重量
		public var mer_price:Number;// 成品商品价格

		public function MerchanVo(data:Object)
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
	}
}