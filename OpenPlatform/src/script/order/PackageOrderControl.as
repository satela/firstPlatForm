package script.order
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.ui.TextInput;
	import laya.utils.Handler;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.orderModel.OrderConstant;
	import model.orderModel.PackageItem;
	import model.orderModel.PackageVo;
	import model.orderModel.PaintOrderModel;
	
	import script.ViewManager;
	
	import ui.order.PackageItemUI;
	import ui.order.PackagePanelUI;
	
	import utils.TimeManager;
	import utils.UtilTool;
	import utils.WaitingRespond;
	
	public class PackageOrderControl extends Script
	{
		public function PackageOrderControl()
		{
			super();
		}
		
		private var uiSkin:PackagePanelUI;
		
		private var param:Object;
		
		private var orderDatas:Array;
		
		private var requestnum:int = 0;
		
		override public function onStart():void
		{
			uiSkin = this.owner as PackagePanelUI;
			
			uiSkin.productlist.itemRender = OrderPackItem;
			uiSkin.productlist.selectEnable = false;
			uiSkin.productlist.spaceY = 2;
			uiSkin.productlist.renderHandler = new Handler(this, updateOrderItem);
			
			uiSkin.cancelbtn.on(Event.CLICK,this,onCloseView);
			uiSkin.okbtn.on(Event.CLICK,this,onConfirmPackage);

			orderDatas = param as Array;
			for(var i:int=0;i < orderDatas.length;i++)
			{
				var numlist:Array = [];
				
				numlist.push(orderDatas[i].itemNumber);
				for(var j:int=1;j < OrderConstant.packagemaxCout;j++)
				{
					numlist.push(0);
				}
				orderDatas[i].numlist = numlist;
				
			}
			uiSkin.addpackbtn.on(Event.CLICK,this,addnewPack);
			
			var defaultPrefer:String = UtilTool.getLocalVar("timePrefer","1");

			uiSkin.timepreferRdo.selectedIndex = parseInt(defaultPrefer);
			
			
			addnewPack();
			
			uiSkin.productlist.array = orderDatas;
			uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);
			
		}
		
		private function startDragPanel(e:Event):void
		{			
			
			(uiSkin.dragImg.parent as Image).startDrag();//new Rectangle(0,0,Browser.width,Browser.height));
			e.stopPropagation();
		}
		private function stopDragPanel():void
		{
			(uiSkin.dragImg.parent as Image).stopDrag();
		}
		
		private function addnewPack():void
		{
			
			
//			if(uiSkin.packagebox.numChildren >= OrderConstant.packagemaxCout)
//				return;
//			if(uiSkin.packagebox.numChildren >= 1)
//			{
//				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"功能开发中，敬请期待！"});
//				return;
//			}
			
			var packitem:PackageItemUI = new PackageItemUI();
			
			packitem.packname.maxChars = 6;
			
			packitem.packname.focus = true;
		
			packitem.packname.select();
			
			uiSkin.packagebox.addChild(packitem);

			packitem.packname.on(Event.INPUT,this,onchangePackName,[packitem.packname,uiSkin.packagebox.numChildren - 1]);
			
			packitem.delbtn.on(Event.CLICK,this,ondeletepack,[packitem,uiSkin.packagebox.numChildren - 1]);

			packitem.x = (uiSkin.packagebox.numChildren - 1)*55;
			
			uiSkin.addpackbtn.x = 110 + uiSkin.packagebox.numChildren*55;
			
			
			packitem.packname.text = "包裹" + uiSkin.packagebox.numChildren;
			
			
			//PaintOrderModel.instance.addPackage("包裹" + uiSkin.packagebox.numChildren);
			
			if(PaintOrderModel.instance.packageList.length > 1)
			{
				for(var i:int=0;i < uiSkin.productlist.cells.length;i++)
				{
					(uiSkin.productlist.cells[i] as OrderPackItem).addpacakge();
				}
			}
			if(uiSkin.packagebox.numChildren >= OrderConstant.packagemaxCout)
				uiSkin.addpackbtn.visible = false;
			
		}
		
		private function onchangePackName(nametext:TextInput,index:int):void
		{
			if(PaintOrderModel.instance.packageList[index] != null)
				PaintOrderModel.instance.packageList[index].packageName = nametext.text;
		}
		
		private function ondeletepack(packitem:PackageItemUI,index:int):void
		{
			index = uiSkin.packagebox.getChildIndex(packitem);

			if(index == 0)
			return;
			
			packitem.removeSelf();
			
			uiSkin.addpackbtn.visible = true;

			for(var i:int=index;i < uiSkin.packagebox.numChildren;i++)
			{
				(uiSkin.packagebox.getChildAt(i) as PackageItemUI).x -= 55;
			}
			uiSkin.addpackbtn.x -= 55;
			
			
			var arr:Array = orderDatas;
			
			for(var i:int=0;i < arr.length;i++)
			{
				arr[i].numlist[0] += arr[i].numlist[index];
				for(var j:int=index;j < OrderConstant.packagemaxCout - 1;j++)
				{
					arr[i].numlist[j] = arr[i].numlist[j +1 ];
				}
				arr[i].numlist[OrderConstant.packagemaxCout - 1] = 0;
			}
			PaintOrderModel.instance.packageList.splice(index,1);

			//if(PaintOrderModel.instance.packageList.length > 1)
			//{				
				for(var i:int=0;i < uiSkin.productlist.cells.length;i++)
				{
					(uiSkin.productlist.cells[i] as OrderPackItem).deletepack(index);
				}
			//}

		}
		private function onCloseView():void
		{
			PaintOrderModel.instance.packageList = new Vector.<PackageVo>();
			ViewManager.instance.closeView(ViewManager.VIEW_PACKAGE_ORDER_PANEL);
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
		
		
		private function onConfirmPackage():void
		{			

//			PaintOrderModel.instance.setPackageData();
//
//			var arr:Array = PaintOrderModel.instance.finalOrderData;
//			
//			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.placeOrder,this,onPlaceOrderBack,{data:JSON.stringify(arr)},"post");
//			
//			return;
			
			var arr:Array = PaintOrderModel.instance.finalOrderData;			
			requestnum = 0;
			for(var i:int=0;i < arr.length;i++)
			{
				
				PaintOrderModel.instance.curTimePrefer = uiSkin.timepreferRdo.selectedIndex + 1;
				
				var datas:String = PaintOrderModel.instance.getOrderCapcaityData(arr[i],uiSkin.timepreferRdo.selectedIndex + 1);
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAvailableDateBack,datas,"post");

				
			}
			uiSkin.okbtn.disabled = true;
			//ViewManager.instance.openView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL,false,orderDatas);
			//PaintOrderModel.instance.packageList = new Vector.<PackageVo>();

		}
		
		private function ongetAvailableDateBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var alldates:Array = result as Array;
//				for(var i:int=0;i < alldates.length;i++)
//				{
//					
//					PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn] = {};
//					PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList = [];
//					
//					var orderdata:Object = PaintOrderModel.instance.getSingleProductOrderData(alldates[i].orderItem_sn);
//					
//					var currentdate:String = alldates[i].current_date;
//					
//					var curtime:Number = Date.parse(currentdate.replace("-","/"));
//					TimeManager.instance.serverDate = curtime/1000;
//						
//					currentdate = currentdate.split(" ")[0];
//					
//					PaintOrderModel.instance.currentDayStr = currentdate;
//						
//					if(orderdata != null && alldates[i].default_deliveryDate != null && alldates[i].default_deliveryDate != "")
//					{
//						orderdata.delivery_date = alldates[i].default_deliveryDate;
//					
//						orderdata.is_urgent = (orderdata.delivery_date == currentdate && PaintOrderModel.instance.curTimePrefer == Constast.ORDER_TIME_PREFER_URGENT);
//						orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
//					}
//
//					for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
//					{
//						if(alldates[i].deliveryDateList[j].urgent == false)
//						{
//							if(alldates[i].deliveryDateList[j].discount == 0)
//								alldates[i].deliveryDateList[j].discount = 1;
//							
//							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
//							
//							if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.is_urgent == false)
//							{
//								orderdata.discount = alldates[i].deliveryDateList[j].discount;
//							}
//						}
//						else if(currentdate == alldates[i].deliveryDateList[j].availableDate)
//						{
//							if(alldates[i].deliveryDateList[j].discount == 0)
//								alldates[i].deliveryDateList[j].discount = 1;
//							
//							if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.is_urgent)
//							{
//								orderdata.discount = alldates[i].deliveryDateList[j].discount;
//							}
//							
//							PaintOrderModel.instance.availableDeliveryDates[alldates[i].orderItem_sn].urgentDate = alldates[i].deliveryDateList[j];
//						}
//						
//						
//					}										
//					
//				}
				
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
					
						PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn] = {};
						PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].deliveryDateList = [];
						
						if(orderdata != null && alldates[i].default_deliveryDate != null && alldates[i].default_deliveryDate != "")
						{
							orderdata.delivery_date = alldates[i].default_deliveryDate;
							
							orderdata.isUrgent = (orderdata.delivery_date == currentdate && PaintOrderModel.instance.curTimePrefer == Constast.ORDER_TIME_PREFER_URGENT) ? 1:0;
							orderdata.lefttime = OrderConstant.OCCUPY_CAPACITY_COUNTDOWN;
						}
						
						for(var j:int=0;j < alldates[i].deliveryDateList.length;j++)
						{
							if(alldates[i].deliveryDateList[j].urgent == false)
							{
								if(alldates[i].deliveryDateList[j].discount == 0)
									alldates[i].deliveryDateList[j].discount = 1;
								
								PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].deliveryDateList.push(alldates[i].deliveryDateList[j]);
								
								if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent == false)
								{
									orderdata.discount = alldates[i].deliveryDateList[j].discount;
								}
							}
							else if(currentdate == alldates[i].deliveryDateList[j].availableDate)
							{
								if(alldates[i].deliveryDateList[j].discount == 0)
									alldates[i].deliveryDateList[j].discount = 1;
								
								if(orderdata.delivery_date == alldates[i].deliveryDateList[j].availableDate && orderdata.isUrgent)
								{
									orderdata.discount = alldates[i].deliveryDateList[j].discount;
								}
								
								PaintOrderModel.instance.availableDeliveryDates[orderdata.orderItem_sn].urgentDate = alldates[i].deliveryDateList[j];
							}
							
							
						}										
					}
				}
				requestnum++;
				if(requestnum == PaintOrderModel.instance.finalOrderData.length)
				{
					if(PaintOrderModel.instance.packageList == null || PaintOrderModel.instance.packageList.length <= 0)
						return;
					PaintOrderModel.instance.setPackageData();

					ViewManager.instance.closeView(ViewManager.VIEW_PACKAGE_ORDER_PANEL);

					ViewManager.instance.openView(ViewManager.VIEW_CHOOSE_DELIVERY_TIME_PANEL,false,{orders:orderDatas,delaypay:false});
					PaintOrderModel.instance.packageList = new Vector.<PackageVo>();
				}
				else
				{
					WaitingRespond.instance.showWaitingView();
				}
			}
			
			else
				uiSkin.okbtn.disabled = false;

		}
		private function updateOrderItem(cell:OrderPackItem):void
		{
			cell.setData(cell.dataSource);
		}
	}
}