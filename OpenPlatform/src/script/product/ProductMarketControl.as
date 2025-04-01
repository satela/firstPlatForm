package script.product
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	import laya.utils.Utils;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.DeliveryTypeVo;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProductVo;
	import model.productModel.MerchanVo;
	import model.productModel.ProductInShopCar;
	import model.users.AddressVo;
	import model.users.FactoryInfoVo;
	
	import script.ViewManager;
	
	import ui.order.OrderAddressItemUI;
	import ui.order.OutPutCenterUI;
	import ui.product.ProductMarketPanelUI;
	import ui.product.TreeClipUI;
	
	import utils.UtilTool;
	
	public class ProductMarketControl extends Script
	{
		private var uiSkin:ProductMarketPanelUI;
		public var param:Object;
		
		private var list:Array = [];
		private var treedic:Object = {};
		private var curselectItemId:String = "";
		
		private var selectAddress:AddressVo;
		private var outPutAddr:Array;
		
		private var goodsInCar:Array=[];
		private var deliveryAddress:DeliveryTypeVo;
		public function ProductMarketControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as ProductMarketPanelUI;
			
			uiSkin.panel_main.vScrollBarSkin = "";
			uiSkin.panel_main.hScrollBarSkin = "";
			
			uiSkin.panel_main.width = Browser.width;
			uiSkin.panel_main.height = Browser.height;// - 20;
			uiSkin.downbox.height = 710;
			
			uiSkin.myaddresstxt.on(Event.CLICK,this,onShowSelectAddress);

			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedSelfAddress);

			uiSkin.productCateList.itemRender = ProductCategoryItem;
			
			uiSkin.productCateList.vScrollBarSkin = "";
			uiSkin.productCateList.repeatX = 1;
			uiSkin.productlist.spaceY = 5;
			
			uiSkin.productCateList.renderHandler = new Handler(this, updateProductcateList);
			uiSkin.productCateList.selectEnable = true;
			uiSkin.productCateList.selectHandler = new Handler(this,onSelectCategory);
			uiSkin.productCateList.array = [];
			
			
			uiSkin.textTotalPrice.style.fontSize = 22;
			uiSkin.textTotalPrice.style.font = "SimHei";
			
			uiSkin.textDeliveryType.style.fontSize = 22;
			uiSkin.textDeliveryType.style.font = "SimHei";
			
			uiSkin.textPayPrice.style.fontSize = 22;
			uiSkin.textPayPrice.style.font = "SimHei";
			
			uiSkin.productlist.itemRender = AdvertiseProItem;
			
			uiSkin.productlist.vScrollBarSkin = "";
			uiSkin.productlist.repeatX = 1;
			uiSkin.productlist.spaceY = 2;
			
			uiSkin.productlist.renderHandler = new Handler(this, updateProductList);
			uiSkin.productlist.selectEnable = false;
			uiSkin.productlist.array = [];
			
			uiSkin.haschooselist.itemRender = AdvertiseProItem;
			
			uiSkin.haschooselist.vScrollBarSkin = "";
			uiSkin.haschooselist.repeatX = 1;
			//uiSkin.productlist.spaceY = 2;
			
			uiSkin.haschooselist.renderHandler = new Handler(this, updateProductList);
			uiSkin.haschooselist.selectEnable = false;
			//uiSkin.haschooselist.array = [];
			uiSkin.haschooselist.array = [];

			uiSkin.panelbottom.hScrollBarSkin = "";			
			uiSkin.panelbottom.width = Browser.width;
			
			if(Browser.height > Laya.stage.height)
				this.uiSkin.height = 1080;
			else
				this.uiSkin.height = Browser.height;
			
			
			if(Userdata.instance.getDefaultAddress() != null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + Userdata.instance.getDefaultAddress().searchZoneid + "&manufacturer_type=喷印输出中心",this,onGetOutPutAddress,null,null);
				uiSkin.myaddresstxt.text = Userdata.instance.getDefaultAddress().addressDetail;
				selectAddress = Userdata.instance.getDefaultAddress();
			}
			if(Userdata.instance.company == null || Userdata.instance.company == "")
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getAuditInfo ,this,getCompanyInfo,null,"post");
			
			uiSkin.paybtn.on(Event.CLICK,this,onPayProductNow);
			EventCenter.instance.on(EventCenter.PRODUCT_ADD_GOODS,this,onAddGoods);
			EventCenter.instance.on(EventCenter.PRODUCT_DELETE_GOODS,this,onDeleteGoods);
			resetOrderInfo();
		}
		
		private function getCompanyInfo(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			if(result.status == 0)
			{
				if(result[0] != null)
				{
					
					if(result[0].info != null && result[0].info != "")
					{
						var cominfo:Object = JSON.parse(result[0].info);
						Userdata.instance.company = cominfo.gp_name;
						Userdata.instance.companyShort = cominfo.gp_shortname;
					}
				}
			}
			
		}
		private function onAddGoods(goodvo:ProductInShopCar):void
		{
			for(var i:int=0;i < goodsInCar.length;i++)
			{
				if(goodvo.prod_code == goodsInCar[i].prod_code)
				{
					goodsInCar[i].goodsNum += goodvo.goodsNum;
					uiSkin.haschooselist.array = goodsInCar;
					return;;
				}
			}
			
			goodsInCar.push(goodvo);
			uiSkin.haschooselist.array = goodsInCar;
			resetOrderInfo();
		}
		
		private function onDeleteGoods(items:AdvertiseProItem):void
		{
			uiSkin.haschooselist.deleteItem(uiSkin.haschooselist.array.indexOf(items.productvo));
			resetOrderInfo();

		}
		private function onGetOutPutAddress(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				this.initOutputAddr(result as Array);
				
				while(uiSkin.outputbox.numChildren > 0)
					uiSkin.outputbox.removeChildAt(0);
				if(outPutAddr.length > 0)
				{
					//PaintOrderModel.instance.selectFactoryAddress = PaintOrderModel.instance.outPutAddr[0];
					//this.uiSkin.factorytxt.text = PaintOrderModel.instance.selectFactoryAddress[0].name + " " + PaintOrderModel.instance.selectFactoryAddress[0].addr;
					for(var i:int=0;i < outPutAddr.length;i++)
					{
						var outputitem:OutPutCenterUI = new OutPutCenterUI();
						outputitem.holaday.text = "";
						uiSkin.outputbox.addChild(outputitem);
						outputitem.checkselect.selected = true;
						outputitem.qqContact.on(Event.CLICK,this,onClickOpenQQ);
						outputitem.factorytxt.text = outPutAddr[i].name;// + " " + PaintOrderModel.instance.selectFactoryAddress[i].addr;
					}
					uiSkin.downbox.y = 295 + (outPutAddr.length - 1)*40 + (outPutAddr.length - 1)*uiSkin.outputbox.space;
					if(outPutAddr.length > 0)
					{
						HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdCategory + "addr_id=" + selectAddress.searchZoneid ,this,onGetMerchanProductBack,null,null);
						HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + outPutAddr[0].org_code + "&addr_id=" + selectAddress.searchZoneid,this,onGetDeliveryBack,null,null);
					}

				}
				else
					uiSkin.downbox.y = 295 ;

			}
			
			uiSkin.panel_main.refresh();
		}
		
		private function onGetMerchanProductBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var product:Array = result as Array;
				//PaintOrderModel.instance.productList = [];
				
				var hasMatName:Array = [];
				var tempArr:Array = [];
				for(var i:int=0;i < product.length;i++)
				{
					if(hasMatName.indexOf(product[i].prodCat_name) < 0)
					{
						var proVo:MatetialClassVo = new MatetialClassVo(product[i].prodCat_name);						
						tempArr.push(proVo);
						hasMatName.push(product[i].prodCat_name);
					}
				}
				
				this.uiSkin.productCateList.array = tempArr;
			}
		}
		
		private function onSelectCategory(index:int):void
		{
			for each(var item:ProductCategoryItem in uiSkin.productCateList.cells)
			{
				item.ShowSelected = item.matvo == uiSkin.productCateList.array[index];
			}
						
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getMerchandiseList + "addr_id=" + selectAddress.searchZoneid + "&prodCat_name=" + uiSkin.productCateList.array[index].matclassname,this,onGetProductListBack,null,null);
			
		}
		private function initMerchanTree(allmatClass:Array):void
		{
			
		}
		
		private function resetOrderInfo():void
		{
			//			if(PaintOrderModel.instance.selectDelivery == null)
			//				uiSkin.textDeliveryType.text = "送货方式：无";
			//			else
			//				uiSkin.textDeliveryType.text = "送货方式：" + PaintOrderModel.instance.selectDelivery.delivery_name;
			
			//uiSkin.textProductNum.text = "商品总数：" + orderlist.length + "";
			var total:Number = 0;
			for(var i:int=0;i < goodsInCar.length;i++)
			{
				total += Number(goodsInCar[i].goodsNum * goodsInCar[i].mer_price);
			}
			
			uiSkin.textTotalPrice.innerHTML = "<span color='#262B2E' size='20'>折后总额：</span>" + "<span color='#FF4400' size='20'>" + total.toFixed(2) + "</span>" + "<span color='#262B2E' size='20'>元</span>";
			uiSkin.textDeliveryType.innerHTML = "<span color='#262B2E' size='20'>运费总额：</span>" + "<span color='#FF4400' size='20'>" + "0" + "</span>" + "<span color='#262B2E' size='20'>元</span>";
			
			uiSkin.textPayPrice.innerHTML = "<span color='#262B2E' size='20'>应付总额：</span>" + "<span color='#FF4400' size='20'>" + total.toFixed(2) + "</span>" + "<span color='#262B2E' size='20'>元</span>";
			
		}
		
		private function onClickOpenQQ():void
		{
			window.open('tencent://message/?uin=10987654321');
		}
		private function onShowSelectAddress():void
		{			
			
			ViewManager.instance.openView(ViewManager.VIEW_SELECT_ADDRESS);
		}
		private function onSelectedSelfAddress(add:AddressVo):void
		{
			if(add)
			{
				selectAddress = add;
				uiSkin.myaddresstxt.text = selectAddress.addressDetail;
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + selectAddress.searchZoneid + "&manufacturer_type=喷印输出中心",this,onGetOutPutAddress,null,null);
			}
		}
		public function initOutputAddr(addrobj:Array):void
		{
			outPutAddr = [];
			for(var i:int=0;i < addrobj.length;i++)
			{
				var addvo:FactoryInfoVo = new FactoryInfoVo(addrobj[i]);
				outPutAddr.push(addvo);
			}
		}
		
		private function updateProductList(cell:AdvertiseProItem):void
		{
			cell.setData(cell.dataSource);
		}
		private function onResizeBrower():void
		{
			// TODO Auto Generated method stub
			if(Browser.height > Laya.stage.height)
				this.uiSkin.height = 1080;
			else
				this.uiSkin.height = Browser.height;
			
			(uiSkin.panel_main).height = Browser.height;// - 50;
			uiSkin.panel_main.width = Browser.width;
			uiSkin.panelbottom.width = Browser.width;

		}
		
		private function updateProductcateList(cell:ProductCategoryItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onGetProductListBack(data:Object):void
		{
			var result:Array = JSON.parse(data as String) as Array;
			if(result != null)
			{
				var list:Array = [];
				for(var i:int=0;i < result.length;i++)
				{
					
					var temp:MerchanVo = new MerchanVo(result[i]);
					
					list.push(temp);
					
				}
				uiSkin.productlist.array = list;

			}
		}
		
		private function onGetDeliveryBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			while(uiSkin.deliverbox.numChildren > 0)
				uiSkin.deliverbox.removeChildAt(0);
			if(!result.hasOwnProperty("status"))
			{
				//PaintOrderModel.instance.deliveryList = [];
				for(var i:int=0;i < result.length;i++)
				{
					var tempdevo:DeliveryTypeVo = new DeliveryTypeVo(result[i]);
					var deliveritem:OrderAddressItemUI = new OrderAddressItemUI();
					deliveritem.addresstxt.text = tempdevo.deliveryDesc;
					if(tempdevo.delivery_name == "送货上门")
					{
						deliveritem.btnsel.selected = true;
						deliveritem.selCheck.selected = true;
						deliveryAddress = tempdevo;
					}
					
					deliveritem.on(Event.CLICK,this,onSelectDeliverAdd,[deliveritem,tempdevo]);
					uiSkin.deliverbox.addChild(deliveritem);
					//PaintOrderModel.instance.deliveryList.push(tempdevo);
				}
			}
			Laya.timer.frameOnce(2,this,function(){
				uiSkin.deliversp.size(1280,uiSkin.deliverbox.height);
				//uiSkin.mainvbox.refresh();
			});
		}
		
		private function onSelectDeliverAdd(deliitem:OrderAddressItemUI,delivervo:DeliveryTypeVo):void
		{
			for(var i:int=0;i < uiSkin.deliverbox.numChildren;i++)
			{
				var deitem:OrderAddressItemUI = uiSkin.deliverbox.getChildAt(i) as OrderAddressItemUI;
				if(deitem)
				{
					deitem.btnsel.selected = false;
					deitem.selCheck.selected = false;
				}
			}
			
			deliitem.btnsel.selected = true;
			deliitem.selCheck.selected = true;
			deliveryAddress = delivervo;
			
			
		}
		
		private function onPayProductNow():void
		{
			var orderFactory:Object = {};
			
			if(goodsInCar.length <=0 )
			{
				ViewManager.showAlert("未选择任何产品");
				return;
			}
			if(selectAddress == null)
			{
				ViewManager.showAlert("请选择收货地址");
				return;
			}
			if(deliveryAddress == null)
			{
				ViewManager.showAlert("请选择配送中心");
				return;
			}
			for(var i:int=0; i < goodsInCar.length;i++)
			{
				
				var orderdata:Object;
				if(!orderFactory.hasOwnProperty(goodsInCar[i].manufacturer_code))
				{
					orderdata = {};
					orderdata.order_sn = PaintOrderModel.getOrderSn();
					orderdata.client_code = "CL10200";
					orderdata.consignee = Userdata.instance.companyShort + "#" + selectAddress.receiverName;
					orderdata.tel = selectAddress.phone;
					orderdata.address = selectAddress.proCityArea;
					orderdata.order_amountStr = 0;
					orderdata.shipping_feeStr = "0";
					orderdata.money_paidStr = "0";
					orderdata.discount = "1";
					orderdata.pay_timeStr = UtilTool.formatFullDateTime(new Date());
					orderdata.delivery_dateStr = UtilTool.formatFullDateTime(new Date(),false);
					
					orderdata.manufacturer_code = goodsInCar[i].manufacturer_code;
					orderdata.manufacturer_name = goodsInCar[i].manufacturer_name;
					
					var totalMoney:Number = 0;
					if(deliveryAddress != null)
					{
						orderdata.logistic_code = deliveryAddress.deliverynet_code + "#" +  deliveryAddress.delivery_name;
						//orderdata.logistic_name = PaintOrderModel.instance.selectDelivery.delivery_name;
					}
					
					orderdata.orderItemList = [];
					orderFactory[goodsInCar[i].manufacturer_code] = orderdata;
				}
				else
					orderdata = orderFactory[goodsInCar[i].manufacturer_code];
				
				
				if(goodsInCar[i] != null)
				{
					orderdata.order_amountStr += goodsInCar[i].mer_price * goodsInCar[i].goodsNum;
					//totalMoney += orderlist[i].getPrice();
					
					
					var proddata:Object = goodsInCar[i].getOrderData();
					proddata.item_seq = i+1;
					orderdata.orderItemList.push(proddata);
				}
				else
				{
					//ViewManager.showAlert("有图片未选择材料工艺");
					return;
				}
				
				
				//orderdata.order_amountStr = totalMoney.toString();
				//orderdata.money_paidStr =  "0.01";//totalMoney.toString();
				
			}
			var arr:Array = [];
			for each(var odata in orderFactory)
			{
				odata.money_paidStr = (odata.order_amountStr as Number).toFixed(2);
				odata.order_amountStr = (odata.order_amountStr as Number).toFixed(2);				
				arr.push(odata);
			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.placeOrder,this,onPlaceOrderBack,{data:JSON.stringify(arr)},"post");

		}
		
		private function onPlaceOrderBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.status == 0)
			{
				//ViewManager.showAlert("下单成功");
				var totalmoney:Number = 0;
				var allorders:Array = [];
				for(var i:int=0;i < result.orders.length;i++)
				{
					var orderdata:Object = JSON.parse(result.orders[i]);
					totalmoney += Number(orderdata.money_paidStr);
					allorders.push(orderdata.order_sn);
				}
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_PAYTYPE_PANEL,false,{amount:Number(totalmoney.toFixed(2)),orderid:allorders});
				
			}
		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedSelfAddress);

		}
	}
	
	
}