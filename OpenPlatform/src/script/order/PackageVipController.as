package script.order
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.orderModel.OrderConstant;
	import model.orderModel.PackageVo;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	import script.order.item.PackageOrderCell;
	
	import ui.order.ChooseDeliveryTimePanelUI;
	import ui.order.PackageOrderItemUI;
	import ui.order.PackageOrderPanelUI;
	
	import utils.TimeManager;
	import utils.UtilTool;
	import utils.WaitingRespond;
	
	public class PackageVipController extends Script
	{
		private var uiSkin:PackageOrderPanelUI;
		
		private var param:Object;
		
		private var orderDatas:Array;
		
		private var requestnum:int = 0;

		public function PackageVipController()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as PackageOrderPanelUI;
			

			
			uiSkin.addpackbtn.visible = false;
			uiSkin.packagelist.itemRender = PackageEditCell;
			uiSkin.packagelist.repeatY = 1;
			uiSkin.packagelist.spaceY = 1;
			
			uiSkin.packagelist.renderHandler = new Handler(this, updatePackageList);
			uiSkin.packagelist.selectEnable = false;
			
			uiSkin.packagelist.hScrollBarSkin = "";
			uiSkin.packagelist.array = new Array(18);
			
			
			uiSkin.mainpanel.hScrollBarSkin = "";
			uiSkin.mainpanel.hScrollBar.mouseWheelEnable = false;
			

//			if(Browser.height > Laya.stage.height)
//				this.uiSkin.height = 1080;
//			else
//				this.uiSkin.height = Browser.height;
			
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			
			initProductList();
			PaintOrderModel.instance.addPackage(PaintOrderModel.instance.selectAddress,orderDatas);
			uiSkin.packagelist.array = PaintOrderModel.instance.packageList;
			uiSkin.curPackgaeNum.text = PaintOrderModel.instance.packageList.length + "";

			uiSkin.packagelist.height = 140*orderDatas.length + 110;
			
			var defaultPrefer:String = UtilTool.getLocalVar("timePrefer","2");
			if(parseInt(defaultPrefer) < 2)
				defaultPrefer = "2";
			uiSkin.timepreferRdo.selectedIndex = parseInt(defaultPrefer) - 2;
			
			uiSkin.packagelist.on(Event.MOUSE_OVER,this,pauseMainScroll);
			uiSkin.packagelist.on(Event.MOUSE_OUT,this,resumeMainScroll);
			uiSkin.cancelbtn.on(Event.CLICK,this,onCloseView);
			uiSkin.okbtn.on(Event.CLICK,this,onConfirmPackage);
			uiSkin.addpackbtn.on(Event.CLICK,this,onShowAddress);
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.UPDATE_PACKAGE_ORDER_ITEM_COUNT,this,updatePackCount);
			EventCenter.instance.on(EventCenter.SELECT_PACK_ADDRESS_OK,this,onaddPackage);
			EventCenter.instance.on(EventCenter.DELETE_PACKAGE_ITEM,this,onDeletePackageItem);

		}
		
		private function initProductList():void
		{
			orderDatas = param as Array;
			for(var i:int=0;i < orderDatas.length;i++)
			{
				var numlist:Array = [];
				
				numlist.push(orderDatas[i].itemNumber);
				
				orderDatas[i].numlist = numlist;
				
				var orderitem:PackageOrderCell = new PackageOrderCell();
				orderitem.setOrderData(orderDatas[i]);
				
				uiSkin.productbox.addChild(orderitem);
				
				
			}
			uiSkin.productNum.text = orderDatas.length + "";


			uiSkin.textTotalPrice.text = PaintOrderModel.instance.rawPrice;
			
			
			var total:Number = 0;
			for(var i:int=0;i < orderDatas.length;i++)
			{
				var ordermoney:Number = Number(orderDatas[i].itemPrice) * Number(orderDatas[i].itemNumber);
				
				ordermoney = parseFloat(ordermoney.toFixed(1));
				
				total += ordermoney;
			}
			
			uiSkin.textDiscount.text = (parseFloat(PaintOrderModel.instance.rawPrice) - total).toFixed(1);
			uiSkin.textPayPrice.text = total.toFixed(1) + "元";
			

		}
		private function onaddPackage(arr:Array):void
		{
			for(var i:int=0;i < arr.length;i++)
			{
				if(!PaintOrderModel.instance.hasExistAddress(arr[i].id))
					PaintOrderModel.instance.addPackage(arr[i],orderDatas);

			}
			uiSkin.packagelist.array = PaintOrderModel.instance.packageList;
			uiSkin.curPackgaeNum.text = PaintOrderModel.instance.packageList.length + "";

		}
		private function updatePackCount():void
		{
			for(var i:int=0;i < uiSkin.packagelist.cells.length;i++)
			{
				(uiSkin.packagelist.cells[i] as PackageEditCell).updateNum();
			}
		}
		
		private function onDeletePackageItem(packagecell:PackageEditCell):void
		{
			uiSkin.packagelist.array = PaintOrderModel.instance.packageList;
			uiSkin.curPackgaeNum.text = PaintOrderModel.instance.packageList.length + "";

		}
		private function onResizeBrower():void
		{
			// TODO Auto Generated method stub
			//if(Browser.height - 350 > 0)
			//	(uiSkin.panel_main).height = (Browser.height - 350);
			//(uiSkin.panel_main).bottom = 298 + (Browser.height - 1080);
			
			//(uiSkin.panelout).height = (Browser.height - 80);
//			if(Browser.height > Laya.stage.height)
//				this.uiSkin.height = 1080;
//			else
//				this.uiSkin.height = Browser.height;
//			uiSkin.mainpanel.width = Browser.width;
//			uiSkin.bottomBox.width = Browser.width;
			
			this.uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			
		}
		private function updatePackageList(cell:PackageEditCell,index:int):void
		{
			cell.setData(cell.dataSource);

		}
		
		private function pauseMainScroll():void
		{
			uiSkin.packagepanel.vScrollBar.target = null;
		}
		
		private function resumeMainScroll():void
		{
			uiSkin.packagepanel.vScrollBar.target = uiSkin.packagepanel;
		}
		
		private function onShowAddress():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_SELECT_PACK_ADDRESS_PANEL);

		}
		
		private function onConfirmPackage():void
		{			
			
			if(PaintOrderModel.instance.packageList.length > 1)
			{
				var firstpack:PackageVo = PaintOrderModel.instance.packageList[0];
				for(var i:int=0;i < firstpack.itemlist.length;i++)
				{
					if(firstpack.itemlist[i].itemCount > 0)
					{
						ViewManager.showAlert("第一个包裹的所有产品数量必须为0");
						return;
					}
				}
			}
			
			var arr:Array = PaintOrderModel.instance.finalOrderData;			
			requestnum = 0;
			for(var i:int=0;i < arr.length;i++)
			{
				
				PaintOrderModel.instance.curTimePrefer = uiSkin.timepreferRdo.selectedIndex + 2;
				
				//var datas:String = PaintOrderModel.instance.getOrderCapcaityData(arr[i],uiSkin.timepreferRdo.selectedIndex + 2);
				var datas:String =  JSON.stringify({"manufacturer_code":"SP0792300","addr_id":"330681117","orderItemList":[{"orderItem_sn":"CL010000911","prod_code":"MPR231020145318433","processList":[{"proc_code":"SPTE231020140227874","cap_occupy":0.1468,"proc_seq":1},{"proc_code":"SPTE231020151954497","cap_occupy":0,"proc_seq":2},{"proc_code":"SPTE12330","cap_occupy":0,"proc_seq":3}]}],"delivery_prefer":2});
				trace("产能数据:" + datas);
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAvailableDateBack,datas,"post");
				
				
			}
			uiSkin.okbtn.disabled = true;
			
			
		}
		private function ongetAvailableDateBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status") && !result.hasOwnProperty("code"))
			{
				var alldates:Array = result as Array;
								
				for(var i:int=0;i < alldates.length;i++)
				{
					
					var currentdate:String = alldates[i].current_date;
					
					var curtime:Number = Date.parse(currentdate.replace("-","/"));
					TimeManager.instance.serverDate = curtime/1000;
					
					currentdate = currentdate.split(" ")[0];
					
					PaintOrderModel.instance.currentDayStr = currentdate;
					
					
					var orderdataList:Array = PaintOrderModel.instance.getProductOrderDataList(alldates[i].orderItem_sn);
					
					
					for(var k:int=0;k < orderdataList.length;k++)
					{
						var orderdata:Object = orderdataList[k];
						
						PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn] = {};
						PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList = [];
						
						if(orderdata != null && alldates[i].default_deliveryDate != null && alldates[i].default_deliveryDate != "")
						{
							orderdata.deliveryDate  = alldates[i].default_deliveryDate;
							
							orderdata.isUrgent = (orderdata.deliveryDate  == currentdate && PaintOrderModel.instance.curTimePrefer == Constast.ORDER_TIME_PREFER_URGENT) ? 1:0;
							orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
						}
						
						for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
						{
							if(alldates[i].deliveryDateList[j].urgent == false)
							{
								if(alldates[i].deliveryDateList[j].discount == 0)
									alldates[i].deliveryDateList[j].discount = 1;
								
								PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
								
								if(orderdata.deliveryDate  == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent == false)
								{
									orderdata.discount = alldates[i].deliveryDateList[j].discount;
								}
							}
							else if(currentdate == alldates[i].deliveryDateList[j].availableDate)
							{
								if(alldates[i].deliveryDateList[j].discount == 0)
									alldates[i].deliveryDateList[j].discount = 1;
								
								if(orderdata.deliveryDate  == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent)
								{
									orderdata.discount = alldates[i].deliveryDateList[j].discount;
								}
								
								PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItemSn].urgentDate = alldates[i].deliveryDateList[j];
							}
							
							
						}										
					}
				}
				requestnum++;
				if(requestnum == PaintOrderModel.instance.finalOrderData.length)
				{
					if(PaintOrderModel.instance.packageList == null || PaintOrderModel.instance.packageList.length <= 0)
						return;
					if(!PaintOrderModel.instance.setVipPackageData())
					{
						ViewManager.showAlert("打包异常，请返回上一步重新打包");
						return;
					}
					
					//ViewManager.instance.closeView(ViewManager.VIEW_PACKAGE_ORDER_VIP_PANEL);
					
					//ViewManager.instance.openView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL,false,{orders:orderDatas,delaypay:false});
					
					EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[ChooseDeliveryTimePanelUI,0,{orders:orderDatas,delaypay:false}]);

					PaintOrderModel.instance.packageList = [];
				}
				else
				{
					WaitingRespond.instance.showWaitingView();
				}
			}			
			else
			{
				uiSkin.okbtn.disabled = false;
				ViewManager.showAlert(result.message);
			}
			
		}
		private function onCloseView():void
		{
			PaintOrderModel.instance.packageList = new Vector.<PackageVo>();
			//ViewManager.instance.closeView(ViewManager.VIEW_PACKAGE_ORDER_VIP_PANEL);
			ViewManager.instance.setViewVisible(ViewManager.VIEW_PAINT_ORDER,true);

		}
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.UPDATE_PACKAGE_ORDER_ITEM_COUNT,this,updatePackCount);
			EventCenter.instance.off(EventCenter.SELECT_PACK_ADDRESS_OK,this,onaddPackage);
			EventCenter.instance.off(EventCenter.DELETE_PACKAGE_ITEM,this,onDeletePackageItem);

		}
	}
}