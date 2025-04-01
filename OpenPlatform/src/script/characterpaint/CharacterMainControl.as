package script.characterpaint
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.ui.Label;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.DeliveryTypeVo;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.PicOrderItemVo;
	import model.picmanagerModel.DirectoryFileModel;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.order.OutputCenterCell;
	
	import ui.characterpaint.CharacterPaintUI;
	
	import utils.UtilTool;
	
	public class CharacterMainControl extends Script
	{
		private var uiSkin:CharacterPaintUI;
		
		private static var u3ddiv:Object;
		private static var script:*;
		private static var scriptpr:*;

		private var picurl:String = "http://large-thumbnail-image.oss-cn-hangzhou.aliyuncs.com/18014398509938750.jpg";
		
		//public var param:PicInfoVo;
		
		private var allsilder:Array;
		
		private var curselectColor:Label;
		
		private var carvingPicInfoVos:Array;
		
		public var curOrdervo:PicOrderItemVo;

		public function CharacterMainControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			uiSkin = this.owner as CharacterPaintUI;
			
			u3ddiv = Browser.document.querySelector("#unity-paint-container");
			Browser.document.body.appendChild(u3ddiv);
			
			//uiSkin.panel_main.vScrollBarSkin = "";
			//uiSkin.panel_main.hScrollBarSkin = "";
			
			uiSkin.productlist.visible = false;
			
			uiSkin.productlist.itemRender = CarvingOrderItemCell;
			
			//uiSkin.productlist.vScrollBarSkin = "";
			uiSkin.productlist.repeatX = 1;
			uiSkin.productlist.spaceY = 2;

			
			uiSkin.productlist.renderHandler = new Handler(this, updateProductList);
			uiSkin.productlist.selectEnable = false;
			
			carvingPicInfoVos = new Array(5);
			
			uiSkin.productlist.array = carvingPicInfoVos;
			
			this.uiSkin.closebtn.on(Event.CLICK,this,closeView);
			
			uiSkin.mattype1.selectedIndex = 0;
			uiSkin.mattype2.selectedIndex = 0;
			uiSkin.mattype3.selectedIndex = 0;

			uiSkin.depth1.text = "1";
			uiSkin.depth2.text = "10";
			uiSkin.depth3.text = "10";

			uiSkin.lighton.on(Event.CHANGE,this,onSwitchLigth);
			uiSkin.lightcolor.on(Event.CLICK,this,showColorChoosePanel);

			uiSkin.createlayer1.on(Event.CLICK,this,oncreateLayer1);
			uiSkin.createlayer2.on(Event.CLICK,this,oncreateLayer2);
			
			uiSkin.createlayer3.on(Event.CLICK,this,oncreateLayer3);
			
			 allsilder = [uiSkin.alphasilder1,uiSkin.alphasilder2,uiSkin.alphasilder3];
			for(var i:int=0;i<allsilder.length;i++)
				allsilder[i].on(Event.CHANGE,this,onChangeAlpha,[i]);
			uiSkin.closeOperate.on(Event.CLICK,this,function(){
				
				uiSkin.leftOptPanel.visible = false;
				var scaleNum:Number = Browser.clientWidth/1920;
				u3ddiv.style.right = 334 * scaleNum;

			});
			
//			uiSkin.lightIntensity.on(Event.CHANGE,this,onChangeLigthIntensity);
//			
//			uiSkin.horiCaustic.on(Event.CHANGE,this,onChangeHoriCaustic);
//
//			uiSkin.vertCaustic.on(Event.CHANGE,this,onChangeVerticalCaustic);
//
//			uiSkin.causticStrength.on(Event.CHANGE,this,onChangeCausticStrength);
//
//			uiSkin.reflectFov.on(Event.CHANGE,this,onChangeFov);
			
			
			

			//uiSkin.moveleft.on(Event.CLICK,this,moveCameraLeft);
			//uiSkin.moveright.on(Event.CLICK,this,moveCameraRight);

			//this.uiSkin.fontsizeinput.on(Event.INPUT,this,onSizeChange);
			onResizeBrower();
			uiSkin.backimglist.itemRender = BackGroundItem;
			
			uiSkin.backimglist.vScrollBarSkin = "";
			uiSkin.backimglist.repeatX = 2;
			
			var imgback:Array = ["stone/stone1","stone/stone2","stone/stone3","wall/wall","wall/wall1","wall/wall2","wood/wood1","wood/wood2","wood/wood3"];
			
			uiSkin.backimglist.array = imgback;
			
			
			uiSkin.backimglist.renderHandler = new Handler(this, updateBackgroundList);
			uiSkin.backimglist.selectHandler = new Handler(this, onSelectHandler);

			uiSkin.backimglist.selectEnable = true;
			

			uiSkin.colorlist.itemRender = ColorItem;
			
			//uiSkin.fontsizeinput.text = param.picPhysicWidth + "";
			
			//uiSkin.colorlist.vScrollBarSkin = "";
			uiSkin.colorlist.repeatX = 2;
			uiSkin.colorlist.spaceX = 2;
			uiSkin.colorlist.spaceY = 5;
			
			var colorlist:Array = ["FF0000","000000","808080","D3D3D3","FFFFFF","800000","F08080","A0522D","FF8C00","FFA500","DAA520","808000","BDB76B",
									"FFFF00","6B8E23","9ACD32","ADFF2F","006400","008000","00FF00","90EE90","40E0D0","008B8B","00FFFF","00BFFF","1E90FF",
									"4169E1","00008B","0000FF","48CD8B","7B68EE","8A2BE2","9400D3","800080","FF00FF","EE82EE"];
			
			uiSkin.colorlist.array = colorlist;
			
			
			uiSkin.colorlist.renderHandler = new Handler(this, updateColorList);
			uiSkin.colorlist.selectHandler = new Handler(this, onSelectColor);
			
			uiSkin.colorlist.selectEnable = true;
			
			uiSkin.colorpanel.visible = false;
			
			uiSkin.closecolor.on(Event.CLICK,this,onCloseColorPanel);

//			if(param != null)
//			{
//				picurl = HttpRequestUtil.biggerPicUrl + param.fid + ".plt";
//			}
			
			var colorlbl:Array = [uiSkin.choosecolor1,uiSkin.choosecolor2,uiSkin.choosecolor3];
			for(var i:int=0;i < colorlbl.length;i++)
			{
				colorlbl[i].on(Event.CLICK,this,showColorPanel,[i]);
			}
			uiSkin.changSizeBtn.on(Event.CLICK,this,onchangeFontSize);
			initU3dWeb();
			
			Browser.window.layaCaller = this;
			
			//uiSkin.panel_main.vScrollBarSkin = "";
			//uiSkin.panel_main.hScrollBarSkin = "";
			
			//uiSkin.panelbottom.hScrollBarSkin = "";
			//uiSkin.panel_main.hScrollBar.mouseWheelEnable = false;
			
			
			//uiSkin.panel_main.width = Browser.width;
			//uiSkin.panelbottom.width = Browser.width;
			
//			if(Browser.height > Laya.stage.height)
//				this.uiSkin.height = 1080;
//			else
//				this.uiSkin.height = Browser.height;
			
			if(Userdata.instance.company == null || Userdata.instance.company == "")
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getCompanyInfo ,this,getCompanyInfo,null,"post");
			
			//uiSkin.textTotalPrice.visible = !Userdata.instance.isHidePrice();
			//uiSkin.textDeliveryType.visible = !Userdata.instance.isHidePrice();
			//uiSkin.textPayPrice.visible = !Userdata.instance.isHidePrice();
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.ADD_PIC_FOR_ORDER,this,onUpdateOrderPic);
			EventCenter.instance.on(EventCenter.SELECT_CARVING_ITEM,this,onselectCarvingItem);

			EventCenter.instance.on(EventCenter.HIDE_U3D_DIV,this,hideU3dDiv);

			PaintOrderModel.instance.selectAddress = null;
			
			resetOrderInfo();
//			if(Userdata.instance.getDefaultAddress() != null)
//			{
//				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getOuputAddr + "addr_id=" + Userdata.instance.getDefaultAddress().searchZoneid + "&manufacturer_type=字牌输出中心",this,onGetOutPutAddress,null,null);
//				uiSkin.myaddresstxt.text = Userdata.instance.getDefaultAddress().addressDetail;
//				PaintOrderModel.instance.selectAddress = Userdata.instance.getDefaultAddress();
//			}
			
		}
		
		private function hideU3dDiv(isshow:Boolean):void
		{
			if(u3ddiv == null)
				return;
			if(isshow)
			{
				u3ddiv.style.display = "";
			}
			else
				u3ddiv.style.display = "none";

		}
		
		private function onselectCarvingItem(index:int):void
		{
			for(var i:int=0;i < this.uiSkin.productlist.cells.length;i++)
			{
				(this.uiSkin.productlist.cells[i] as CarvingOrderItemCell).selectItem(i == index);
			}
			
			curOrdervo = this.uiSkin.productlist.array[index];
			
			uiSkin.leftOptPanel.visible = true;
			var scaleNum:Number = Browser.clientWidth/1920;

			u3ddiv.style.right = 569 * scaleNum;

		}
		private function initProductList():void
		{
			var i:int = 0;
			for each(var fvo in DirectoryFileModel.instance.haselectPic)
			{
				var ovo:PicOrderItemVo = new PicOrderItemVo(fvo);
				ovo.indexNum = i;
				
				carvingPicInfoVos[i++] = ovo;
			}
			this.uiSkin.productlist.array = carvingPicInfoVos;
			DirectoryFileModel.instance.haselectPic = {};

		}
		
		private function onUpdateOrderPic():void
		{
			
			for each(var fvo in DirectoryFileModel.instance.haselectPic)
			{
				
				var ovo:PicOrderItemVo = new PicOrderItemVo(fvo);
				var curlist:Vector.<Box> = uiSkin.productlist.cells;
				for(var i:int=0;i < curlist.length;i++)
				{
					if((curlist[i] as CarvingOrderItemCell).ordervo == null)
					{
						ovo.indexNum = i;
						(uiSkin.productlist.cells[i] as CarvingOrderItemCell).setData(ovo);
						uiSkin.productlist.array[i] = ovo;
						break;
					}
				}
			}
			DirectoryFileModel.instance.haselectPic = {};

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
//			uiSkin.panel_main.width = Browser.width;
//			uiSkin.panelbottom.width = Browser.width;
			var scaleNum:Number = Browser.clientWidth/1920;
			
			u3ddiv.style.left = 296 * scaleNum;
			
			u3ddiv.style.top = 124 * scaleNum;

			u3ddiv.style.bottom = 120 * scaleNum;
			if(this.uiSkin.leftOptPanel.visible)
				u3ddiv.style.right = 569 * scaleNum;
			else
				u3ddiv.style.right = 334 * scaleNum;


		}
				
		private function resetOrderInfo():void
		{
			var total:Number = 0;
			//			for(var i:int=0;i < orderlist.length;i++)
			//			{
			//				total += Number(orderlist[i].total.text);
			//			}
			//var arr:Array = [];
			var orderlist:Vector.<Box> = uiSkin.productlist.cells;
			if(orderlist.length > 0)
			{
				
				var orderFactory:Object = {};
				
				for(var i:int=0; i < orderlist.length;i++)
				{
					var orderitem:CarvingOrderItemCell = orderlist[i] as CarvingOrderItemCell;
					//				if(!orderitem.checkCanOrder())
					//				{
					//					//ViewManager.showAlert("未选择材料工艺");
					//					return null;
					//				}
					
					var orderdata:Object;
					if(orderitem.ordervo != null)
					{
						if (orderitem.ordervo.orderData != null && !orderFactory.hasOwnProperty(orderitem.ordervo.manufacturer_code))
						{
							orderdata = {};
							orderdata.order_sn = PaintOrderModel.getOrderSn();
							orderdata.client_code = "CL10200";
							orderdata.consignee = Userdata.instance.companyShort + "#" + PaintOrderModel.instance.selectAddress.receiverName;
							orderdata.tel = PaintOrderModel.instance.selectAddress.phone;
							orderdata.address = PaintOrderModel.instance.selectAddress.proCityArea;
							orderdata.order_amountStr = 0;
							orderdata.shipping_feeStr = "0";
							orderdata.money_paidStr = "0";
							orderdata.discountStr = "0";
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
						
						
						if(orderitem.ordervo.orderData != null)
						{
							orderdata.order_amountStr += orderitem.getPrice();
							//totalMoney += orderlist[i].getPrice();
							
							//if(orderlist[i].ordervo.orderData.comments == "")
							//	orderlist[i].ordervo.orderData.comments = uiSkin.commentall.text;
							orderitem.ordervo.orderData.item_seq = i+1;
							orderdata.orderItemList.push(orderitem.ordervo.orderData);
						}
						else
						{
							//ViewManager.showAlert("有图片未选择材料工艺");
							//return null;
						}
					}
					
				}
				//orderdata.order_amountStr = totalMoney.toString();
				//orderdata.money_paidStr =  "0.01";//totalMoney.toString();
				for each(var odata in orderFactory)
				{
					if( (odata.order_amountStr as Number) < 2)
						odata.order_amountStr = 2.00;
					
					total += (Number)((odata.order_amountStr as Number).toFixed(2));
					
					//odata.order_amountStr = (odata.order_amountStr as Number).toFixed(2);
					
					//arr.push(odata);
				}				
				
			}
			
			//var copy:int = parseInt(uiSkin.copynum.text);
			total = parseFloat(total.toFixed(1));
			//total = total * copy;
			
			//uiSkin.textTotalPrice.innerHTML = "<span color='#262B2E' size='20'>折后总额：</span>" + "<span color='#FF4400' size='20'>" + total.toFixed(1) + "</span>" + "<span color='#262B2E' size='20'>元</span>";
			//uiSkin.textDeliveryType.innerHTML = "<span color='#262B2E' size='20'>运费总额：</span>" + "<span color='#FF4400' size='20'>" + "0" + "</span>" + "<span color='#262B2E' size='20'>元</span>";
			
			//uiSkin.textPayPrice.innerHTML = "<span color='#262B2E' size='20'>应付总额：</span>" + "<span color='#FF4400' size='20'>" + total.toFixed(1) + "</span>" + "<span color='#262B2E' size='20'>元</span>";
			
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
				//while(uiSkin.outputbox.numChildren > 0)
				///	uiSkin.outputbox.removeChildAt(0);
				if(PaintOrderModel.instance.outPutAddr.length > 0)
				{
//					for(var i:int=0;i < PaintOrderModel.instance.outPutAddr.length;i++)
//					{
//						var outputitem:OutputCenterCell = new OutputCenterCell(PaintOrderModel.instance.outPutAddr[i],i);
//						uiSkin.outputbox.addChild(outputitem);
//						
//					}
					
									
					
					var manufacurerList:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
					
					HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdCategory + "addr_id=" + PaintOrderModel.instance.selectAddress.searchZoneid + "&manufacturerList=" + manufacurerList.join(",") ,this,onGetProductBack,null,null);
					
					//var params:Object = {"manufacturer_list":PaintOrderModel.instance.getManufactureCodeList(),"addr_id":PaintOrderModel.instance.selectAddress.searchZoneid};
					var params:Object = "manufacturerList="+PaintOrderModel.instance.getManufactureCodeList().toString() + "&addr_id=" + PaintOrderModel.instance.selectAddress.searchZoneid;
					
					Userdata.instance.getLastMonthRatio(this,function():void{
						
						HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList + params,this,onGetDeliveryBack,null,null);
						
					});
					
					
					
					//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryList,this,onGetDeliveryBack,params,"post");
					
				}
				else
				{
					PaintOrderModel.instance.selectFactoryAddress = null;
					PaintOrderModel.instance.productList = [];
					//this.uiSkin.factorytxt.text = "你选择的地址暂无生产商";
				}
			}
			var orderlist:Vector.<Box> = uiSkin.productlist.cells;
			for(var i:int=0; i < orderlist.length;i++)
			{
				var orderitem:CarvingOrderItemCell = orderlist[i] as CarvingOrderItemCell;
				orderitem.resetOrderData();
			}
			
			this.resetOrderInfo();
		}
		
		private function onGetProductBack(data:Object):void
		{
			var result:Object = JSON.parse(data as String);
			if(!result.hasOwnProperty("status"))
			{
				var product:Array = result as Array;
				PaintOrderModel.instance.productList = [];
				
				var hasMatName:Array = [];
				for(var i:int=0;i < product.length;i++)
				{
					if(product[i].prodCat_name.indexOf("雕刻") < 0 && hasMatName.indexOf(product[i].prodCat_name) < 0)
					{
						var matvo:MatetialClassVo = new MatetialClassVo(product[i].prodCat_name);
						PaintOrderModel.instance.productList.push(matvo);
						hasMatName.push(product[i].prodCat_name);
					}
				}
			}
		}
		
		private function onGetDeliveryBack(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			//while(uiSkin.deliverbox.numChildren > 0)
			//	uiSkin.deliverbox.removeChildAt(0);
			if(!result.hasOwnProperty("status"))
			{
				PaintOrderModel.instance.deliveryList = {};
				
				//				var tempdevo:DeliveryTypeVo = new DeliveryTypeVo(result[0]);
				//				tempdevo.delivery_name = "专车配送";
				//				tempdevo.firstweight_price = 50;
				
				//PaintOrderModel.instance.deliveryList.push(tempdevo);
				
				//var deliverys:Array = result.deliveryList;
				
				for(var i:int=0;i < result.length;i++)
				{
					var deliverys:Array = result[i].deliveryList;
					PaintOrderModel.instance.deliveryList[result[i].manufacturer_code] = [];
					for(var j:int=0;j < deliverys.length;j++)
					{
						var tempdevo:DeliveryTypeVo = new DeliveryTypeVo(deliverys[j]);
						tempdevo.belongManuCode = result[i].manufacturer_code;
						
						PaintOrderModel.instance.deliveryList[result[i].manufacturer_code].push(tempdevo);
						//PaintOrderModel.instance.selectDelivery = tempdevo;
						
						if(tempdevo.delivery_name == OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER)
						{
							PaintOrderModel.instance.selectDelivery = tempdevo;
						}
					}
					
				}
			}
			
		}
		private function updateProductList(cell:CarvingOrderItemCell,index:int):void
		{
			cell.setData(cell.dataSource);
		}
		private function getCompanyInfo(data:Object):void
		{
			if(this.destroyed)
				return;
			var result:Object = JSON.parse(data as String);
			
			if(result.status == 0)
			{
				Userdata.instance.company = result.name;
				Userdata.instance.companyShort = result.shortname;
			}
			
		}
		
		private function updateBackgroundList(cell:BackGroundItem):void
		{
			cell.setData(cell.dataSource);
			
			cell.setSelected(cell.dataSource == uiSkin.backimglist.array[uiSkin.backimglist.selectedIndex]);
		}
		
		private function onSelectHandler(index:int):void
		{
			for(var i:int=0;i < uiSkin.backimglist.cells.length;i++)
			{
				(uiSkin.backimglist.cells[i] as BackGroundItem).setSelected((uiSkin.backimglist.cells[i] as BackGroundItem).urlpath == uiSkin.backimglist.array[index]);
			}
			
			Browser.window.UnityPaintWeb.changebackground(uiSkin.backimglist.array[index]);

		}
		
		private function updateColorList(cell:ColorItem):void
		{
			cell.setData(cell.dataSource);
			
		}
		
		private function onSelectColor(index:int):void
		{
			if(index < 0)
				return;
			if(this.curselectColor == uiSkin.lightcolor)
			{
				Browser.window.UnityPaintWeb.changeLigthColor( "#" + uiSkin.colorlist.array[index]);
				return;

			}
			//Browser.window.Unity3dWeb.changebackground(uiSkin.backimglist.array[index]);
			curselectColor.bgColor = "#" + uiSkin.colorlist.array[index];
			uiSkin.colorpanel.visible = false;

		}
		
		private function showColorPanel(index:int):void
		{
			uiSkin.colorlist.selectedIndex = -1;
			uiSkin.colorpanel.visible = true;
			curselectColor = uiSkin["choosecolor" + (index+1)];
					
		}
		
		private function showColorChoosePanel():void
		{
			uiSkin.colorlist.selectedIndex = -1;
			uiSkin.colorpanel.visible = true;
			curselectColor = uiSkin.lightcolor;

		}
		private function onCloseColorPanel():void
		{
			uiSkin.colorpanel.visible = false;
		}
		private function initU3dWeb():void
		{
			Browser.window.UnityPaintWeb.createUnity();
			
//			if(u3ddiv == null)
//			{
//				u3ddiv = Browser.document.createElement("div");
//				
//				//u3ddiv.style = "width: 1200px; height: 790px;left:360px;top:80px";
//				
//				u3ddiv.style = "position: absolute; left:360px;top:80px;right:360px;bottom:60px";
//				
//				u3ddiv.id = "gameContainer";
//				
//				Browser.document.body.appendChild(u3ddiv);
//				
//				var complete:int = 0;
//				script = Browser.document.createElement("script");
//				script.src = "webglout/Build/UnityLoader.js";
//				script.onload = function(){
//					//加载完成函数，开始调用模块的功能。
//					//new一个js中的对象
//					//var client = new Laya.Browser.window.Demo1()
//					//client.start();
//					trace("on load unoty");
//					complete++;
//					if(complete >= 2)
//					{
//						Browser.window.Unity3dWeb.createUnity();
//					}
//				}
//				script.onerror = function(){
//					//加载错误函数
//				}
//				Browser.document.body.appendChild(script);
//				
//				scriptpr = Browser.document.createElement("script");
//				scriptpr.src = "webglout/TemplateData/UnityProgress.js";
//				scriptpr.onload = function(){
//					//加载完成函数，开始调用模块的功能。
//					//new一个js中的对象
//					//var client = new Laya.Browser.window.Demo1();
//					//client.start();
//					trace("on load unoty");
//					complete++;
//					if(complete >= 2)
//					{
//						Browser.window.Unity3dWeb.createUnity();
//					}
//				}
//				scriptpr.onerror = function(){
//					//加载错误函数
//				}
//				Browser.document.body.appendChild(scriptpr);
//			}
//			else
//			{
//				u3ddiv.style.display = "block";
//				
//				Browser.window.Unity3dWeb.setSceneActive("1");
//
//				Browser.window.Unity3dWeb.startRender();
//
//				//var size:Number = parseInt(uiSkin.fontsizeinput.text)/100;
//				
//				//Browser.window.Unity3dWeb.changefontSize(param.picPhysicWidth/100 + "&" + param.picPhysicHeight/100);
//				
//				//Browser.window.Unity3dWeb.createMesh(picurl);
//				uiSkin.productlist.visible = true;
//
//				initProductList();
//
//			}
			
		}
		
		private function unityIsReady():void
		{
			//var size:Number = parseInt(uiSkin.fontsizeinput.text)/100;
			
			//Browser.window.Unity3dWeb.changefontSize(param.picPhysicWidth/100 + "&" + param.picPhysicHeight/100);
			
			//Browser.window.Unity3dWeb.createMesh(picurl);
			uiSkin.productlist.visible = true;

			initProductList();

		}
		
		private function selectCharacter(index:String):void
		{
			for(var i:int=0;i < this.uiSkin.productlist.cells.length;i++)
			{
				(this.uiSkin.productlist.cells[i] as CarvingOrderItemCell).selectItem(i.toString() == index);
			}
		}
		private function onChangeAlpha(index:int):void
		{
			
			Browser.window.UnityPaintWeb.changelayerAlpha(index + "&" + allsilder[index].value/100);

		}
		
//		private function onChangeLigthIntensity():void
//		{
//			Browser.window.Unity3dWeb.changeligthIntensity(uiSkin.lightIntensity.value/100+"");
//
//		}
//		
//		private function onChangeHoriCaustic():void
//		{
//			Browser.window.Unity3dWeb.changeCausticUVX(uiSkin.horiCaustic.value+"");
//		}
//		
//		private function onChangeVerticalCaustic():void
//		{
//			Browser.window.Unity3dWeb.changeCausticUVY(uiSkin.vertCaustic.value+"");
//		}
//		
//		private function onChangeCausticStrength():void
//		{
//			Browser.window.Unity3dWeb.changeCausticStrength(uiSkin.causticStrength.value+"");
//
//		}
//		
//		private function onChangeFov():void
//		{
//			Browser.window.Unity3dWeb.changeCameraFov(uiSkin.reflectFov.value+"");
//		}
		
		private function moveCameraLeft():void
		{
			Browser.window.UnityPaintWeb.moveCamera("-0.1");

		}
		private function moveCameraRight():void
		{
			Browser.window.UnityPaintWeb.moveCamera("0.1");
			
		}
		
		private function onSwitchLigth():void
		{
			if(curOrdervo)
			{
				Browser.window.UnityPaintWeb.turnCharacterLight(HttpRequestUtil.biggerPicUrl + curOrdervo.picinfo.fid + ".jpg");
			
			}

		}
		private function oncreateLayer1():void
		{
			var str:String = "";
			
			var depth:Number = parseInt(uiSkin.depth1.text)/100;
			
			str += "0&";
			
			str += depth + "&";
			
			str += (uiSkin.mattype1.selectedIndex+1) + "&";
			
			str += (uiSkin.choosecolor1.bgColor);
			
			Browser.window.UnityPaintWeb.createLayer(str);
		}
		private function oncreateLayer2():void
		{
			var str:String = "";
			str += "1&";
			
			var depth:Number = parseInt(uiSkin.depth2.text)/100;

			
			str += depth + "&";
			
			str += (uiSkin.mattype2.selectedIndex+1) + "&";
			
			str += (uiSkin.choosecolor2.bgColor);
			
			Browser.window.UnityPaintWeb.createLayer(str);
		}
		
		private function oncreateLayer3():void
		{
			var str:String = "";
			str += "2&";
			
			var depth:Number = parseInt(uiSkin.depth3.text)/100;
			
			
			str += depth + "&";
			
			str += (uiSkin.mattype3.selectedIndex+1) + "&";
			
			str += (uiSkin.choosecolor3.bgColor);
			
			Browser.window.UnityPaintWeb.createLayer(str);
		}
		
		
		private function onchangeFontSize():void
		{
			if(uiSkin.fontsizeinput.text == "")
				return;
			var size:Number = parseInt(uiSkin.fontsizeinput.text)/100;
			
			Browser.window.UnityPaintWeb.changefontSize(size.toString());
		}
		
		
		private function closeView():void
		{
			ViewManager.instance.closeView(ViewManager.VIEW_CHARACTER_DEMONSTRATE_PANEL);
			ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE);

		}
		
		public override function onDestroy():void
		{
			if(u3ddiv != null)
			{
				for(var i:int=0;i < 5;i++)
				{
					Browser.window.UnityPaintWeb.setCharacterEdgeIndex(i.toString());
					
					Browser.window.UnityPaintWeb.setFrontFaceActive(0);
				}
				Browser.window.UnityPaintWeb.stopRender();

				Browser.window.UnityPaintWeb.setSceneActive("0");

				u3ddiv.style.display = "none";
				EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
				EventCenter.instance.off(EventCenter.ADD_PIC_FOR_ORDER,this,onUpdateOrderPic);
				EventCenter.instance.off(EventCenter.HIDE_U3D_DIV,this,hideU3dDiv);
				EventCenter.instance.off(EventCenter.SELECT_CARVING_ITEM,this,onselectCarvingItem);

				//Browser.window.Unity3dWeb.closeUnity();
				//Browser.document.body.removeChild(u3ddiv);//添加到舞台
				//Browser.document.body.removeChild(script);
				//Browser.document.body.removeChild(scriptpr);
			}
		}
	}
}