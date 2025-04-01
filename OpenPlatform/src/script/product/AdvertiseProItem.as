package script.product
{
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.productModel.MerchanVo;
	import model.productModel.ProductInShopCar;
	
	import ui.product.AdvertiseItemUI;
	
	public class AdvertiseProItem extends AdvertiseItemUI
	{
		public var productvo:MerchanVo;
		private var goodsOrCard:Boolean;
		public function AdvertiseProItem()
		{
			super();
		}
		public function setData(data:Object):void
		{
			productvo = data as MerchanVo;
			if(data.goodsNum == null)
			{
				this.btnok.label = "加入购物车";
				this.proNum.text = "1";
				this.proPrice.text = productvo.mer_price + "";

				goodsOrCard = true;
			}
			else
			{
				this.btnok.label = "移出购物车";
				this.proNum.text = data.goodsNum + "";
				this.proPrice.text = productvo.mer_price * data.goodsNum + "";

				goodsOrCard = false;
			}
			this.proName.text = productvo.prod_name + "";
			
			this.btnadd.on(Event.CLICK,this,onAddNum);
			this.btnsub.on(Event.CLICK,this,onSubNum);
			
			this.btnok.on(Event.CLICK,this,onClickOk);

		}
		
		private function onAddNum():void
		{
			var curNum:int = parseInt(this.proNum.text);
			curNum++;
			this.proNum.text = curNum.toString();
			if(goodsOrCard == false)
			{
				(productvo as ProductInShopCar).goodsNum = curNum;
				this.proPrice.text = (productvo.mer_price * curNum).toFixed(2) + "";

			}
		}
		
		private function onSubNum():void
		{
			var curNum:int = parseInt(this.proNum.text);
			if(curNum > 1)
				curNum--;
			this.proNum.text = curNum.toString();
			if( goodsOrCard == false)
			{
				(productvo as ProductInShopCar).goodsNum = curNum;
				this.proPrice.text = (productvo.mer_price * curNum).toFixed(2) + "";
			}
		}
		
		private function onClickOk():void
		{
			if(!goodsOrCard)
			{
				EventCenter.instance.event(EventCenter.PRODUCT_DELETE_GOODS,this);
			}
			else
			{
				var newgoods:ProductInShopCar = new ProductInShopCar(productvo);
				newgoods.goodsNum = parseInt(this.proNum.text);
				
				EventCenter.instance.event(EventCenter.PRODUCT_ADD_GOODS,newgoods);

			}
		}
	}
}