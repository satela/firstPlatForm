package script.product
{
	import laya.components.Script;
	import laya.utils.Handler;
	
	import ui.product.ProductOrderPanelUI;
	
	public class ProductMainControl extends Script
	{
		private var uiSkin:ProductOrderPanelUI;
		
		public function ProductMainControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ProductOrderPanelUI;
			
			uiSkin.productlist.itemRender = ProductItemView;
			
			uiSkin.productlist.vScrollBarSkin = "";
			uiSkin.productlist.repeatX = 3;
			uiSkin.productlist.spaceY = 20;
			
			uiSkin.productlist.renderHandler = new Handler(this, updateProductList);
			uiSkin.productlist.selectEnable = false;
			
			var arr:Array = ["https://detail.tmall.com/item.htm?id=526318658145&ali_refid=a3_430583_1006:1108235969:N:1MQTVLPp62GPhglCIaZd/g==:d9254f3b567d036adb3b0c3d81c6eac7&ali_trackid=1_d9254f3b567d036adb3b0c3d81c6eac7&spm=a230r.1.14.1",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.13.3e402ebdwcU30Y&id=555521978270&cm_id=140105335569ed55e27b&abbucket=10",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.20.3e402ebdwcU30Y&id=563368098306&ns=1&abbucket=10",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.27.3e402ebdwcU30Y&id=559210560379&ns=1&abbucket=10",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.76.3e402ebdwcU30Y&id=582945215363&ns=1&abbucket=10",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.83.3e402ebdwcU30Y&id=565700275650&ns=1&abbucket=10",
				"https://item.taobao.com/item.htm?spm=a230r.1.14.278.3e402ebdwcU30Y&id=18471253099&ns=1&abbucket=10#detail",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.73.3e402ebdwcU30Y&id=569329939430&ns=1&abbucket=10",
				"https://detail.tmall.com/item.htm?id=571469150299&ali_refid=a3_430583_1006:1110650643:N:J9qj8Ni7SIVwWdQdeSY+dw==:5659d26af13796aa642628f226441b9a&ali_trackid=1_5659d26af13796aa642628f226441b9a&spm=a230r.1.14.1",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.14.68675639S5nZ2i&id=4043459487&cm_id=140105335569ed55e27b&abbucket=10",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.46.68675639S5nZ2i&id=537478190853&ns=1&abbucket=10",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.93.68675639S5nZ2i&id=575639443142&ns=1&abbucket=10&sku_properties=21433:32102",
				"https://detail.tmall.com/item.htm?spm=a230r.1.14.141.68675639S5nZ2i&id=587606286953&ns=1&abbucket=10&sku_properties=21433:21366"
				]
			var arrname:Array = ["门型x展架广告牌展示架立式易拉宝80x180海报设计落地式定制制作",
				"广告牌展示架kt板展架立式落地式宣传海报支架招聘展板招工牌架子",
				"铝合金亮盖水滴易拉宝广告海报架80 200易拉宝展架设计制作X展架",
				"kt板展架立式落地海报架广告架子支架易拉宝广告牌展示架定制制作",
				"拉网展架签名签到墙展示架立式落地式布艺拉网背景墙海报布广告牌",
				"广告牌展示牌kt板展架展板海报架立牌宣传架子立式水牌落地式招聘",
				"资料架杂志架报刊架书刊架置物宣传架展示架展架报纸收纳架子落地",
				"广告牌展示架kt板展架立式落地式户外双面海报架宣传立牌展板架子",
				"展会橱窗吊旗悬挂杆铝合金海报挂轴杆挂画轴吊挂夹天花吊画广告牌",
				"申佳铝合金A3三证合一营业执照相框挂墙a4摆台工商税务画框证书框",
				"磁吸电梯广告框海报框挂墙广告框架展板海报相框铝合金画框海报框",
				"实木广告框架亚克力相框挂墙免打孔木质海报框教练教师展示墙画框",
				"相框挂墙免打孔洗照片加画框外框创意简约冲印定制来图定做相架框"];



			var productlist:Array = [];
			for(var i:int=0;i < arr.length;i++)
			{
				var itemdata:Object = {url:arr[i],pid:i};
				itemdata.pname = arrname[i];
				itemdata.allsize = ["120*150","160*200"];
				itemdata.price = 35+i*2;
				productlist.push(itemdata);
			}
			uiSkin.productlist.array = productlist;
		}
		
		private function updateProductList(cell:ProductItemView):void
		{
			cell.setData(cell.dataSource);
		}
	}
}