package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Button;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.DeliveryTypeVo;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.picmanagerModel.DirectoryFileModel;
	import model.users.AddressVo;
	import model.users.CustomVo;
	
	import script.ViewManager;
	
	import ui.characterpaint.CharacterPaintUI;
	import ui.dengxiang.DengxiangOrderPanelUI;
	import ui.inuoView.OrderPicManagerPanelUI;
	import ui.inuoView.OrderTypePanelUI;
	import ui.inuoView.SetMaterialPanelUI;
	import ui.lailiao.LailiaoOrderPanelUI;
	
	import utils.UtilTool;
	
	public class OrderTypeChooseController extends Script
	{
		private var uiSkin:OrderTypePanelUI;
		
		private var btnlist:Array;
		
		public var param:Object;
		private var customer:CustomVo;
		
		public function OrderTypeChooseController()
		{
			super();
		}
		
		override public function onStart():void
		{
			//ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"通知：品赋阳光1月18号放假，如有下单需求请移步至色彩飞扬 www.cmyk.vip",caller:this,callback:onbacktoFirst});
			
			uiSkin = this.owner as OrderTypePanelUI; 
			
			btnlist = [uiSkin.paintOrderBtn,uiSkin.dingzhiBtn,uiSkin.productBtn,uiSkin.zipaiBtn,uiSkin.kailiaoBtn,uiSkin.modelOrderBtn,uiSkin.biaoPinBtn,uiSkin.dengxiangBtn];
			for(var i:int=0; i < btnlist.length;i++)
			{
				btnlist[i].visible = false;
			}
			
			customer = param as CustomVo;
			
			btnlist.push(uiSkin.paintOrderBtn);
			uiSkin.myaddresstxt.on(Event.CLICK,this,onShowSelectAddress);
			uiSkin.changeAddr.on(Event.CLICK,this,onShowSelectAddress);

			//uiSkin.dingzhiBtn.disabled= true;
			//uiSkin.productBtn.disabled= true;
			//uiSkin.zipaiBtn.disabled= true;

			PaintOrderModel.instance.resetData();
			uiSkin.paintOrderBtn.on(Event.CLICK,this,function(){
				
				if(PaintOrderModel.instance.selectAddress == null)
				{
					ViewManager.showAlert("请先添加收货地址");
					return;
				}
				if(PaintOrderModel.instance.outPutAddr.length <= 0)
				{
					ViewManager.showAlert("您当前的收货地址没有可服务的输出中心，请选择其他收货地址");
					return;
				}
				PaintOrderModel.instance.orderType = OrderConstant.PAINTING;
				var num:int = 0;
				for each(var fvo in DirectoryFileModel.instance.haselectPic)
				{
					num++;
				}
				getProdcategory(OrderConstant.PAINTING);
				if(num == 0)
					EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[OrderPicManagerPanelUI,0,customer]);
				else
					EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[SetMaterialPanelUI,0]);

				
			})
				
			uiSkin.zipaiBtn.on(Event.CLICK,this,function(){
				
				getProdcategory(OrderConstant.CUTTING);

				PaintOrderModel.instance.orderType = OrderConstant.CUTTING;
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[CharacterPaintUI,0]);
				
			})
				
			uiSkin.kailiaoBtn.on(Event.CLICK,this,function(){
				
				getProdcategory(OrderConstant.KAILIAO_ORDER);

				PaintOrderModel.instance.orderType = OrderConstant.KAILIAO_ORDER;
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[LailiaoOrderPanelUI,0]);
				
			})
				
			uiSkin.biaoPinBtn.on(Event.CLICK,this,function(){
				
				getProdcategory(OrderConstant.BIAOPIN_ORDER);
				
				PaintOrderModel.instance.orderType = OrderConstant.BIAOPIN_ORDER;
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[LailiaoOrderPanelUI,0]);
				
			})
				
			uiSkin.dengxiangBtn.on(Event.CLICK,this,function(){
				
				getProdcategory(OrderConstant.DENGXIANG_ORDER);
				
				PaintOrderModel.instance.orderType = OrderConstant.DENGXIANG_ORDER;
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[DengxiangOrderPanelUI,0]);
				
			})
				
			uiSkin.productBtn.on(Event.CLICK,this,function(){
				
				getProdcategory(OrderConstant.CHENGPIN_ORDER);

				PaintOrderModel.instance.orderType = OrderConstant.MODEL_ORDER;
				
				//EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[ModelProdListPanelUI,0]);
				
			})
				
				
			EventCenter.instance.on(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedSelfAddress);

			if(customer == null || customer.id == "0")
			{
				if(Userdata.instance.getDefaultAddress() != null)
				{
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + Userdata.instance.getDefaultAddress().zoneid + "&manufacturer_type=喷印输出中心" + "&client_code=" + Userdata.instance.clientCode,this,onGetOutPutAddress,null,null);
					uiSkin.myaddresstxt.text = Userdata.instance.getDefaultAddress().addressDetail;
					uiSkin.myaddresstxt.width = uiSkin.myaddresstxt.textWidth;
					uiSkin.addbox.refresh();
					
					PaintOrderModel.instance.selectAddress = Userdata.instance.getDefaultAddress();
				}
			}
			else
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.listCustomerAddress + "customerId=" + customer.id,this,getCustomerAddressBack,null,null,null);

			}
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getClientOrderSource + "clientCode=" + Userdata.instance.clientCode,this,onGetClientOrderSource,null,null);

		}
		
		private function getCustomerAddressBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				//Userdata.instance.initMyAddress(result.data.expressList as Array);
				//Userdata.instance.defaultAddId = result.data.defaultId;
				
				var addressList:Array = [];
				for(var i:int=0;i < result.data.expressList.length;i++)
				{
					addressList.push(new AddressVo(result.data.expressList[i]));
					addressList[i].customerId = customer.id;

				}
				if(addressList.length > 0)
				{
					PaintOrderModel.instance.selectAddress = addressList[0];
					
					uiSkin.myaddresstxt.text = addressList[0].addressDetail;
					uiSkin.myaddresstxt.width = uiSkin.myaddresstxt.textWidth;
					uiSkin.addbox.refresh();
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + PaintOrderModel.instance.selectAddress.zoneid + "&manufacturer_type=喷印输出中心" + "&client_code=" + Userdata.instance.clientCode,this,onGetOutPutAddress,null,null);

				}
			}
		}
		private function onGetClientOrderSource(data:*):void
		{
			if(uiSkin.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var sources:Array = result as Array;
				var btn:Button;
				for(var i:int=0;i < sources.length;i++)
				{
					if((sources[i].code as String) == OrderConstant.PAINTING)
					{
						btnlist[0].visible = true;
						btn = btnlist[0];
					}
					else if((sources[i].code as String) == OrderConstant.CLOTHES_ORDER)
					{
						btnlist[1].visible = true;
						btn = btnlist[1];

						
					}
					else if((sources[i].code as String) == OrderConstant.CHENGPIN_ORDER)
					{
						btnlist[2].visible = true;
						btn = btnlist[2];

						
					}
					else if((sources[i].code as String) == OrderConstant.CUTTING)
					{
						btnlist[3].visible = true;
						btn = btnlist[3];

						
					}
					else if((sources[i].code as String) == OrderConstant.KAILIAO_ORDER)
					{
						btnlist[4].visible = true;
						btn = btnlist[4];

						
					}
					else if((sources[i].code as String) == OrderConstant.MODEL_ORDER)
					{
						btnlist[5].visible = true;
						btn = btnlist[5];

					}
					
					else if((sources[i].code as String) == OrderConstant.BIAOPIN_ORDER)
					{
						btnlist[6].visible = true;
						btn = btnlist[6];
						
					}
					
					else if((sources[i].code as String) == OrderConstant.DENGXIANG_ORDER)
					{
						btnlist[7].visible = true;
						btn = btnlist[7];
						
					}
					btn.x = 50 + i%4 * 390 ;
					btn.y = 285 + Math.floor(i/4) * 169;
				}
			}
		}
		private function onbacktoFirst():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);
		}
		private function onShowSelectAddress():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_SELECT_ADDRESS,false,customer);

		}
		private function onSelectedSelfAddress(customvo:CustomVo):void
		{
			if(PaintOrderModel.instance.selectAddress)
			{
				uiSkin.myaddresstxt.text = PaintOrderModel.instance.selectAddress.addressDetail;
				uiSkin.myaddresstxt.width = uiSkin.myaddresstxt.textWidth;
				uiSkin.addbox.refresh();

				if(customvo != null && PaintOrderModel.instance.selectAddress.customerId == customvo.id)
					customer = customvo;
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + PaintOrderModel.instance.selectAddress.zoneid + "&manufacturer_type=喷印输出中心" + "&client_code=" + Userdata.instance.clientCode,this,onGetOutPutAddress,null,null);
			}
		}
		private function onGetOutPutAddress(data:*):void
		{
			if(uiSkin.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				PaintOrderModel.instance.initOutputAddr(result as Array);
				
				PaintOrderModel.instance.selectFactoryAddress = PaintOrderModel.instance.outPutAddr.concat();
				while(uiSkin.outputbox.numChildren > 0)
					uiSkin.outputbox.removeChildAt(0);
				if(PaintOrderModel.instance.outPutAddr.length > 0)
				{
					//PaintOrderModel.instance.selectFactoryAddress = PaintOrderModel.instance.outPutAddr[0];
					//this.uiSkin.factorytxt.text = PaintOrderModel.instance.selectFactoryAddress[0].name + " " + PaintOrderModel.instance.selectFactoryAddress[0].addr;
					for(var i:int=0;i < PaintOrderModel.instance.outPutAddr.length;i++)
					{
						var outputitem:OutputCenterCell = new OutputCenterCell(PaintOrderModel.instance.outPutAddr[i],i);
						uiSkin.outputbox.addChild(outputitem);
						
					}
									
					
//					var manufacurerList:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
//					
//					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdCategory + "addr_id=" + PaintOrderModel.instance.selectAddress.zoneid + "&orderSource=Penyin&" + "manufacturerList=" + manufacurerList.join(",") ,this,onGetProductBack,null,null);
//					
					//var params:Object = {"manufacturer_list":PaintOrderModel.instance.getManufactureCodeList(),"addr_id":PaintOrderModel.instance.selectAddress.searchZoneid};
					var params:Object = "manufacturerList="+PaintOrderModel.instance.getManufactureCodeList().toString() + "&addr_id=" + PaintOrderModel.instance.selectAddress.zoneid;
					
//					Userdata.instance.getLastMonthRatio(this,function():void{
//						
//						HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + params,this,onGetDeliveryBack,null,null);
//						
//					});
					
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + params,this,onGetDeliveryBack,null,null);

					
					//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList,this,onGetDeliveryBack,params,"post");
					
				}
				else
				{
					PaintOrderModel.instance.selectFactoryAddress = null;
					PaintOrderModel.instance.productList = [];
					//this.uiSkin.factorytxt.text = "你选择的地址暂无生产商";
				}
			}
			
			
		}
		
		private function getProdcategory(orderEntry:String):void
		{
			var manufacurerList:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
			
			if(manufacurerList.length == 0)
			{
				ViewManager.showAlert("您当前的收货地址没有可服务的输出中心，请选择其他收货地址");
				return;
			}
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdCategory + "addr_id=" + PaintOrderModel.instance.selectAddress.zoneid + "&orderSource=" + orderEntry + "&client_code=" + Userdata.instance.clientCode + "&manufacturerList=" + manufacurerList.join(",") ,this,onGetProductBack,null,null);
			
		}
		private function onGetDeliveryBack(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			if(!result.hasOwnProperty("status"))
			{
				PaintOrderModel.instance.deliveryList = {};
				
				
				
				for(var i:int=0;i < result.length;i++)
				{
					var deliverys:Array = result[i].deliveryList;
					PaintOrderModel.instance.deliveryList[result[i].manufacturer_code] = [];
					for(var j:int=0;j < deliverys.length;j++)
					{
						var tempdevo:DeliveryTypeVo = new DeliveryTypeVo(deliverys[j]);
						tempdevo.belongManuCode = result[i].manufacturer_code;
						
						PaintOrderModel.instance.deliveryList[result[i].manufacturer_code].push(tempdevo);
						
						if(tempdevo.delivery_name == OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
						{							
							PaintOrderModel.instance.selectDelivery = tempdevo;
						}
					}
					
				}
			}
			
		}
		private function onGetProductBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var product:Array = result[0].children as Array;
				
				PaintOrderModel.instance.productList = [];
				
				var hasMatName:Array = [];
				for(var i:int=0;i < product.length;i++)
				{
					if( hasMatName.indexOf(product[i].prodCat_name) < 0)
					{
						var matvo:MatetialClassVo = new MatetialClassVo(product[i]);
						PaintOrderModel.instance.productList.push(matvo);
						hasMatName.push(product[i].prodCat_name);
					}
				}
			}
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.SELECT_ORDER_ADDRESS,this,onSelectedSelfAddress);

		}
		
	}
}