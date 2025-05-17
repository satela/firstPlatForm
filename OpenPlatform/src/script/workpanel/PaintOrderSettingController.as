package script.workpanel
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	
	import model.Constast;
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.PicOrderItemVo;
	import model.picmanagerModel.DirectoryFileModel;
	
	import script.ViewManager;
	import script.order.PicOrderItem;
	
	import ui.inuoView.OrderPicManagerPanelUI;
	import ui.inuoView.SetMaterialPanelUI;
	import ui.order.ChooseDeliveryTimePanelUI;
	import ui.order.PackageOrderPanelUI;
	
	import utils.TimeManager;
	import utils.UtilTool;
	import utils.WaitingRespond;
	
	public class PaintOrderSettingController extends Script
	{
		private var uiSkin:SetMaterialPanelUI;
		public var param:Object;
		
		private var orderlist:Vector.<PicOrderItem>;
		private var mianvbox:Number = 0;

		private var requestnum:int = 0;
		
		public function PaintOrderSettingController()
		{
			super();
		}
		
		override public function onStart():void
		{
			//PaintOrderModel.instance.resetData();
			PaintOrderModel.instance.getDynamicDeliveryFeeCfg();
			uiSkin = this.owner as SetMaterialPanelUI; 
			
			var i:int= 1;
			var num:int=0;
			uiSkin.orderlistpanel.vScrollBarSkin = "";
			orderlist = new Vector.<PicOrderItem>();
			
			if(PaintOrderModel.instance.tempPicOrderItemVoList != null)
			{
				for(var j:int=0;j < PaintOrderModel.instance.tempPicOrderItemVoList.length;j++)
				{
					
					var item:PicOrderItem = new PicOrderItem(PaintOrderModel.instance.tempPicOrderItemVoList[j]);
					uiSkin.ordervbox.addChild(item);
					i++;
					
					orderlist.push(item);
					if(num > 0)
						uiSkin.ordervbox.height += item.height + uiSkin.ordervbox.space;
					
					num++;
				}
			}
			for each(var fvo in DirectoryFileModel.instance.haselectPic)
			{
				var ovo:PicOrderItemVo = new PicOrderItemVo(fvo);
				ovo.indexNum = i++;
				var item:PicOrderItem = new PicOrderItem(ovo);
				uiSkin.ordervbox.addChild(item);
				orderlist.push(item);
				if(num > 0)
					uiSkin.ordervbox.height += item.height + uiSkin.ordervbox.space;
				//totalheight += item.height + uiSkin.ordervbox.space;
				num++;
			}
			uiSkin.productNum.text = orderlist.length.toString();

			DirectoryFileModel.instance.haselectPic = {};

			
			uiSkin.batchChange.on(Event.CLICK,this,onBatchChangeMaterial);
			uiSkin.selectAll.on(Event.CLICK,this,onSelectAll);
			uiSkin.batchDelete.on(Event.CLICK,this,onBatchDelete);
			uiSkin.goToNext.on(Event.CLICK,this,onOrderPaint);
			uiSkin.btnaddpic.on(Event.CLICK,this,onShowSelectPic);

			EventCenter.instance.on(EventCenter.DELETE_PIC_ORDER,this,onDeletePicOrder);

			//EventCenter.instance.on(EventCenter.SELECT_DELIVERY_TYPE,this,updateDeliveryType);
			
			EventCenter.instance.on(EventCenter.ADJUST_PIC_ORDER_TECH,this,onAdjustHeight);
			//EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.UPDATE_ORDER_ITEM_TECH,this,resetOrderInfo);
			EventCenter.instance.on(EventCenter.BATCH_CHANGE_PRODUCT_NUM,this,changeProductNum);
			EventCenter.instance.on(EventCenter.PAY_ORDER_SUCESS,this,onPaySucess);
			EventCenter.instance.on(EventCenter.CANCEL_PAY_ORDER,this,onCancelPay);
			EventCenter.instance.on(EventCenter.FIRST_PAGE_SHRINK,this,updateLblPos);
			resetOrderInfo();
			updateLblPos(Userdata.instance.shrinkState);
			
			if(PaintOrderModel.instance.selectAddress.customerId != "0")
			{
				uiSkin.curCustomer.text = "当前客户：" + PaintOrderModel.instance.selectAddress.customerName;
				uiSkin.curCustomer.visible = true;
				if(PaintOrderModel.instance.selectAddress.defaultPayType >= 0)
				{
					uiSkin.curCustomer.text +="(" + Constast.PAY_TYPE_NAME[PaintOrderModel.instance.selectAddress.defaultPayType - 1] + ")";
				}
			}
			else
				uiSkin.curCustomer.visible = false;
			
			if(Userdata.instance.company == null || Userdata.instance.company == "")
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo ,this,getCompanyInfo,null,null);
			
		}
		
		private function updateLblPos(state:int):void
		{
			if(state == 0)
			{
				uiSkin.opeBox.x = 1456;
				uiSkin.pricelbl.x = 1364;
				uiSkin.unitpricelbl.x = 1273;

			}
			else
			{
				uiSkin.opeBox.x = 1556;
				uiSkin.pricelbl.x= 1468;
				uiSkin.unitpricelbl.x = 1373;
			}
		}
		private function resetOrderInfo():void
		{
			if(this.destroyed)
				return;
			var total:Number = 0;
			var nodiscountTotal:Number = 0;
			
			//			for(var i:int=0;i < orderlist.length;i++)
			//			{
			//				total += Number(orderlist[i].total.text);
			//			}
			//var arr:Array = [];
			if(orderlist.length > 0)
			{
				
				var orderFactory:Object = {};
				
				PaintOrderModel.instance.calculateProductDiscount(orderlist);
				
				for(var i:int=0; i < orderlist.length;i++)
				{
					var orderitem:PicOrderItem = orderlist[i];
					//				if(!orderitem.checkCanOrder())
					//				{
					//					//ViewManager.showAlert("未选择材料工艺");
					//					return null;
					//				}
					
					orderitem.updateProductPrice();
					var orderdata:Object;
					if(orderitem.ordervo.orderData != null && !orderFactory.hasOwnProperty(orderitem.ordervo.manufacturer_code))
					{
						orderdata = {};
						orderdata.order_sn = PaintOrderModel.getOrderSn();
						orderdata.client_code = Userdata.instance.clientCode;
						orderdata.consignee = Userdata.instance.companyShort + "#" + PaintOrderModel.instance.selectAddress.receiverName;
						orderdata.tel = PaintOrderModel.instance.selectAddress.phone;
						orderdata.address = PaintOrderModel.instance.selectAddress.proCityArea;
						orderdata.order_amountStr = 0;
						orderdata.shipping_feeStr = "0";
						orderdata.money_paidStr = "0";
						orderdata.discountStr = "1";
						orderdata.pay_timeStr = UtilTool.formatFullDateTime(new Date());
						orderdata.delivery_dateStr = UtilTool.formatFullDateTime(new Date(),false);
						
						orderdata.manufacturer_code = orderitem.ordervo.manufacturer_code;
						orderdata.manufacturer_name = orderitem.ordervo.manufacturer_name;
						orderdata.contact_phone = PaintOrderModel.instance.getContactPhone(orderitem.ordervo.manufacturer_code);
						
						var totalMoney:Number = 0;
						if(PaintOrderModel.instance.selectDelivery)
						{
							orderdata.logistic_code = PaintOrderModel.instance.selectDelivery.deliverynet_code + "#" +  PaintOrderModel.instance.selectDelivery.delivery_name;
							//orderdata.logistic_name = PaintOrderModel.instance.selectDelivery.delivery_name;
						}
						
						orderdata.orderItemList = [];
						orderFactory[orderitem.ordervo.manufacturer_code] = orderdata;
					}
					else
						orderdata = orderFactory[orderitem.ordervo.manufacturer_code];
					
					if(orderlist[i].ordervo.orderData != null)
					{
						orderdata.order_amountStr += orderlist[i].getPrice();
						nodiscountTotal += parseFloat(orderlist[i].getNoDiscountPrice().toFixed(1));
						//totalMoney += orderlist[i].getPrice();
						
						//if(orderlist[i].ordervo.orderData.comments == "")
						//	orderlist[i].ordervo.orderData.comments = uiSkin.commentall.text;
						orderlist[i].ordervo.orderData.itemSeq = i+1;
						orderdata.orderItemList.push(orderlist[i].ordervo.orderData);
					}
					else
					{
						//ViewManager.showAlert("有图片未选择材料工艺");
						//return null;
					}
					
				}
				//orderdata.order_amountStr = totalMoney.toString();
				//orderdata.money_paidStr =  "0.01";//totalMoney.toString();
				for each(var odata in orderFactory)
				{
					if( (odata.order_amountStr as Number) < Userdata.instance.orderBasePrice)
						odata.order_amountStr = Userdata.instance.orderBasePrice;
					
					total += (Number)((odata.order_amountStr as Number).toFixed(2));
					
					//odata.order_amountStr = (odata.order_amountStr as Number).toFixed(2);
					
					//arr.push(odata);
				}				
				
			}
			
			var discountTotal:Number = parseFloat(nodiscountTotal.toFixed(1)) -  parseFloat(total.toFixed(1));
			if(discountTotal < 0)
				discountTotal = 0;
			PaintOrderModel.instance.rawPrice = nodiscountTotal.toFixed(1);
			
			var copy:int = 1;//parseInt(uiSkin.copynum.text);
			total = parseFloat(total.toFixed(1));
			total = total * copy;
			
			uiSkin.textTotalPrice.text =  nodiscountTotal.toFixed(1);
			uiSkin.textDiscount.text = discountTotal.toFixed(1);
			
			uiSkin.textPayPrice.text =  total.toFixed(1);
			if(Userdata.instance.isHidePrice())
			{
				uiSkin.textTotalPrice.text = "***";
				uiSkin.textDiscount.text = "***";
				
				uiSkin.textPayPrice.text =  "***";
			}
			
		}
		
		private function onDeletePicOrder(orderitem:PicOrderItem):void
		{
			var ordervo:PicOrderItemVo = orderitem.ordervo;
			
			if(orderlist.indexOf(orderitem) >=0 )
				orderlist.splice(orderlist.indexOf(orderitem),1);
			
			for(var i:int=0;i < uiSkin.ordervbox.numChildren;i++)
			{
				var pvo:PicOrderItemVo = (uiSkin.ordervbox.getChildAt(i) as PicOrderItem).ordervo;
				if(pvo.indexNum > ordervo.indexNum)
					pvo.indexNum--;
				(uiSkin.ordervbox.getChildAt(i) as PicOrderItem).updateIndex();
			}
			uiSkin.ordervbox.removeChild(orderitem);
			if(uiSkin.ordervbox.height - orderitem.height - uiSkin.ordervbox.space < 0)			
				uiSkin.ordervbox.height = 0;
			else
				uiSkin.ordervbox.height -= orderitem.height + uiSkin.ordervbox.space;
			if(uiSkin.ordervbox.numChildren == 0)
				uiSkin.ordervbox.height = 0;
			uiSkin.ordervbox.size(uiSkin.ordervbox.width,0);
			uiSkin.ordervbox.refresh();
			resetOrderInfo();
			//(uiSkin.panel_main).height = uiSkin.mainvbox.height;
			uiSkin.productNum.text = orderlist.length.toString();
			
		}
		private function onSelectAll():void
		{
			for(var i:int=0;i < orderlist.length;i++)
			{
				orderlist[i].checkSel.selected = uiSkin.selectAll.selected;				
			}
		}
		
		private function onBatchDelete():void
		{
			for(var i:int=0;i < orderlist.length;i++)
			{
				if(orderlist[i].checkSel.selected)
				{
					onDeletePicOrder(orderlist[i]);
					i--;
				}
			}
		}
		private function onBatchChangeMaterial():void
		{			
			if(PaintOrderModel.instance.selectAddress == null)
			{
				ViewManager.showAlert("请先选择收货地址");
				return;
			}
			
			PaintOrderModel.instance.batchChangeMatItems = new Vector.<PicOrderItem>();
			for(var i:int=0;i < orderlist.length;i++)
			{
				if(orderlist[i].checkSel.selected)
				{
					PaintOrderModel.instance.batchChangeMatItems.push(orderlist[i]);
				}
			}
			if(PaintOrderModel.instance.batchChangeMatItems.length <= 0)
			{
				ViewManager.showAlert("请至少选择一个需要更换的产品");
				return;
			}
			PaintOrderModel.instance.curSelectMat = null;
			//ViewManager.instance.openView(ViewManager.VIEW_SELECT_MATERIAL);
			ViewManager.instance.openView(ViewManager.VIEW_SET_MATERIAL_PROCESS_PANEL);

			
			PaintOrderModel.instance.curSelectOrderItem = null;
		}
		private function changeProductNum(numstr:String):void
		{
			for(var i:int=0;i < orderlist.length;i++)
			{
				if(orderlist[i].checkSel.selected)
				{
					orderlist[i].inputnum.text = numstr;
					
					orderlist[i].onNumChange();
				}
			}
		}
		private function onAdjustHeight(changeht:int):void
		{
			this.uiSkin.ordervbox.height += changeht;
			//(uiSkin.panel_main).height = uiSkin.mainvbox.height;
		}
		private function onPaySucess():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
			
		}
		
		private function onCancelPay():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
			
		}
		private function getCompanyInfo(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			if(result.code == "0")
			{
				Userdata.instance.company = result.data.name;
				Userdata.instance.companyShort = result.data.shortName;
				Userdata.instance.founderPhone = result.data.founderMobileNumber;
				Userdata.instance.isVipCompany = result.vip == "1";
				
				
			}
			
		}
		
		private function onOrderPaint():void
		{
			if(uiSkin.textPayPrice.text == "NaN")
			{
				ViewManager.showAlert("价格异常，请检查工艺或联系客服");
				return;
			}
			if(Userdata.instance.companyShort == null)
			{
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo ,this,function(data:Object){
					
					if(this.destroyed)
						return;
					var result:Object = JSON.parse(data as String);
					
					if(result.code == "0")
					{
						Userdata.instance.company = result.data.name;
						Userdata.instance.companyShort = result.data.shortName;
						Userdata.instance.founderPhone = result.data.founderMobileNumber;
						
					}
					
					onOrderPaint();		
				}
					,null,null);	
				
				return;
			}
			var arr:Array = getOrderData();
			if(arr == null)
				return;
			
			
			var itemlist:Array = [];
			
			for(var i:int=0;i < arr.length;i++)
			{
				itemlist = itemlist.concat(arr[i].orderItemList);
			}
			
			if(itemlist.length > OrderConstant.MAX_ORDER_NUMER)
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"下单图片不能超过100个，请分批下单。"});
				return;
			}
			
			PaintOrderModel.instance.finalOrderData = arr;
			
			
			
			var params:Object = {"count":itemlist.length.toString()};
			
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProductUids,this,ongetUidsBack,JSON.stringify(params),"post");
		}
		
		private function ongetUidsBack(data:*):void
		{
			if(this.destroyed)
				return;
			
			var result:Object = JSON.parse(data as String);
			if(result.code == "0")
			{
				var ids:Array = result.data;
				
				var itemlist:Array = [];
				
				for(var i:int=0;i < PaintOrderModel.instance.finalOrderData.length;i++)
				{
					itemlist = itemlist.concat(PaintOrderModel.instance.finalOrderData[i].orderItemList);
				}
				
				
				for(var i:int=0;i < ids.length;i++)
				{
					itemlist[i].orderItemSn = ids[i];
				}
				//ViewManager.instance.setViewVisible(ViewManager.VIEW_PAINT_ORDER,false);
				
				EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[PackageOrderPanelUI,0,itemlist]);
				
				
				//不走打包
				//initPackage(itemlist);
				
			}
		}
		
		
		private function initPackage(orderDatas:Array):void
		{
			PaintOrderModel.instance.addPackage(PaintOrderModel.instance.selectAddress,orderDatas);
			
			var arr:Array = PaintOrderModel.instance.finalOrderData;			
			requestnum = 0;
			for(var i:int=0;i < arr.length;i++)
			{
				
				var defaultPrefer:String = UtilTool.getLocalVar("timePrefer","2");
				if(parseInt(defaultPrefer) < 2)
					defaultPrefer = "2";
				PaintOrderModel.instance.curTimePrefer = parseInt(defaultPrefer);

				var datas:String = PaintOrderModel.instance.getOrderCapcaityData(arr[i],PaintOrderModel.instance.curTimePrefer);
				//var datas=JSON.stringify({"manufacturer_code":"SP0792300","addr_id":"330681117","orderItemList":[{"orderItem_sn":"CL010000911","prod_code":"MPR231020145318433","processList":[{"proc_code":"SPTE231020140227874","cap_occupy":0.1468,"proc_seq":1},{"proc_code":"SPTE231020151954497","cap_occupy":0,"proc_seq":2},{"proc_code":"SPTE12330","cap_occupy":0,"proc_seq":3}]}],"delivery_prefer":2});

				trace("产能数据:" + datas);
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryTimeList,this,ongetAvailableDateBack,datas,"post");
				
				
			}
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
					
					var itemlist:Array = [];
					
					for(var i:int=0;i < PaintOrderModel.instance.finalOrderData.length;i++)
					{
						itemlist = itemlist.concat(PaintOrderModel.instance.finalOrderData[i].orderItemList);
					}
					
					EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[ChooseDeliveryTimePanelUI,0,{orders:itemlist,delaypay:false}]);
					
					PaintOrderModel.instance.packageList = [];
				}
				else
				{
					WaitingRespond.instance.showWaitingView();
				}
			}			
			else
			{
				ViewManager.showAlert(result.message);
			}
			
		}
		
		private function getOrderData():Array
		{
			
			if(orderlist.length <= 0)
			{
				ViewManager.showAlert("未选择下单图片");
				return null;
			}
			
			//if(PaintOrderModel.instance.selectDelivery == null)
			//{
			//ViewManager.showAlert("请选择配送方式");
			//return null;
			//}
			var orderFactory:Object = {};
			
			for(var i:int=0; i < orderlist.length;i++)
			{
				var orderitem:PicOrderItem = orderlist[i];
				if(!orderitem.checkCanOrder())
				{
					//ViewManager.showAlert("未选择材料工艺");
					return null;
				}
				
				var orderdata:Object;
				if(!orderFactory.hasOwnProperty(orderitem.ordervo.manufacturer_code))
				{
					orderdata = {};
					orderdata.orderSn = PaintOrderModel.getOrderSn();
					orderdata.clientCode = Userdata.instance.clientCode;//"CL10600";
					orderdata.userCode = Userdata.instance.userAccount;
					orderdata.userOrgCode = Userdata.instance.founderPhone;
					orderdata.customerId = PaintOrderModel.instance.selectAddress.customerId.toString();
					
					//orderdata.consignee = Userdata.instance.companyShort + "#" + PaintOrderModel.instance.selectAddress.receiverName;
					//orderdata.tel = PaintOrderModel.instance.selectAddress.phone;
					//orderdata.address = PaintOrderModel.instance.selectAddress.proCityArea;
					orderdata.addressId = PaintOrderModel.instance.selectAddress.zoneid;
					
					//orderdata.addressStatus = PaintOrderModel.instance.selectAddress.status;
					orderdata.clientVersion = Userdata.instance.version;

					orderdata.orderAmount = 0;
					orderdata.shippingFee = "0";
					orderdata.moneyPaid = "0";
					orderdata.discount = "1";
					orderdata.checkCapacity = true;
					orderdata.payTime  = UtilTool.formatFullDateTime(new Date());
					orderdata.deliveryDate  = UtilTool.formatFullDateTime(new Date(),false);
					
					orderdata.manufacturerCode = orderitem.ordervo.manufacturer_code;
					orderdata.manufacturerName = orderitem.ordervo.manufacturer_name;
					orderdata.contact_phone = PaintOrderModel.instance.getContactPhone(orderitem.ordervo.manufacturer_code);
					
					var totalMoney:Number = 0;
					if(PaintOrderModel.instance.selectDelivery)
					{
						orderdata.logistic_code = PaintOrderModel.instance.selectDelivery.deliverynet_code + "#" +  PaintOrderModel.instance.selectDelivery.delivery_name;
						//orderdata.logistic_name = PaintOrderModel.instance.selectDelivery.delivery_name;
					}
					
					orderdata.orderItemList = [];
					orderFactory[orderitem.ordervo.manufacturer_code] = orderdata;
				}
				else
					orderdata = orderFactory[orderitem.ordervo.manufacturer_code];
				
				
				if(orderlist[i].ordervo.orderData != null)
				{
					orderdata.orderAmount += orderlist[i].getPrice();
					//totalMoney += orderlist[i].getPrice();
					
					//if(orderlist[i].ordervo.orderData.comments == "")
					//	orderlist[i].ordervo.orderData.comments = uiSkin.commentall.text;
					orderlist[i].ordervo.orderData.itemSeq = i+1;
					orderdata.orderItemList.push(orderlist[i].ordervo.orderData);
				}
				else
				{
					ViewManager.showAlert("有图片未选择材料工艺");
					return null;
				}
				
				
				//orderdata.order_amountStr = totalMoney.toString();
				//orderdata.money_paidStr =  "0.01";//totalMoney.toString();
				
			}
			var arr:Array = [];
			for each(var odata in orderFactory)
			{
				if( (odata.order_amountStr as Number) < Userdata.instance.orderBasePrice)
				{
					odata.orderAmount = Userdata.instance.orderBasePrice;
					var itemarr:Array = odata.orderItemList;
					if(itemarr.length > 0)
					{
						var eachprice:Number = Number((Userdata.instance.orderBasePrice/itemarr.length).toFixed(2));
						
						var overflow:Number = Userdata.instance.orderBasePrice - eachprice*itemarr.length;
						for(var j:int=0;j < itemarr.length;j++)
						{
							if(j==0)
								itemarr[j].itemPrice = (((eachprice + overflow)/itemarr[j].itemNumber) as Number).toFixed(2);
							else
								itemarr[j].itemPrice =  ((eachprice/itemarr[j].itemNumber) as Number).toFixed(2);
						}
					}
				}
				
				odata.moneyPaid = (odata.orderAmount as Number).toFixed(1);
				odata.orderAmount = (odata.orderAmount as Number).toFixed(1);
				//odata.order_amountStr = "0.01";
				//odata.money_paidStr = "0.01";
				arr.push(odata);
			}
			
			var copy:int = 1;//parseInt(uiSkin.copynum.text);
			var copyarr:Array = [];
			for(i=1;i < copy;i++)
			{
				for(var j:int=0;j < arr.length;j++)
				{
					var copydata:Object =  JSON.parse(JSON.stringify(arr[j]));
					copyarr.push(copydata);
				}
			}
			if(copyarr.length > 0)
				arr = arr.concat(copyarr);
			return arr;
		}
		private function onShowSelectPic():void
		{
			// TODO Auto Generated method stub
			PaintOrderModel.instance.tempPicOrderItemVoList = new Vector.<PicOrderItemVo>();
			
			for(var i:int=0;i < orderlist.length;i++)
			{
				PaintOrderModel.instance.tempPicOrderItemVoList.push(orderlist[i].ordervo);
			}
			
			EventCenter.instance.event(EventCenter.SHOW_CONTENT_PANEL,[OrderPicManagerPanelUI,0]);
		}
		
		
		
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.DELETE_PIC_ORDER,this,onDeletePicOrder);
			EventCenter.instance.off(EventCenter.ADJUST_PIC_ORDER_TECH,this,onAdjustHeight);

			
			EventCenter.instance.off(EventCenter.UPDATE_ORDER_ITEM_TECH,this,resetOrderInfo);
			EventCenter.instance.off(EventCenter.BATCH_CHANGE_PRODUCT_NUM,this,changeProductNum);
			EventCenter.instance.off(EventCenter.PAY_ORDER_SUCESS,this,onPaySucess);
			EventCenter.instance.off(EventCenter.CANCEL_PAY_ORDER,this,onCancelPay);
			EventCenter.instance.off(EventCenter.FIRST_PAGE_SHRINK,this,updateLblPos);
		}
		
	}
}