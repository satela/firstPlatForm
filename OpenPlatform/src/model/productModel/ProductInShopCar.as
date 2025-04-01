package model.productModel
{
	public class ProductInShopCar extends MerchanVo
	{
		public var goodsNum:int = 1;
		public function ProductInShopCar(data:Object)
		{
			super(data);
		}
		
		public function getOrderData():Object
		{
			var orderitemdata:Object = {};
			
			orderitemdata.prod_name = prod_name;
			orderitemdata.prod_code = prod_code;
			orderitemdata.is_merchandise = 1;
			orderitemdata.prod_description = "";
			orderitemdata.LWH = mer_volume;
			orderitemdata.weightStr = mer_weight;
			orderitemdata.item_number = goodsNum;
			orderitemdata.item_priceStr = (goodsNum * mer_price).toFixed(2);
			orderitemdata.item_status = "1";
			orderitemdata.comments = "";
			orderitemdata.imagefile_path = "";
			orderitemdata.previewImage_path = "";
			orderitemdata.thumbnails_path = "";
			orderitemdata.filename = "";
			
			return orderitemdata;
		}
	}
}