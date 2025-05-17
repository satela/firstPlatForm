package script.lailiao
{
	
	import eventUtil.EventCenter;
	
	import laya.events.Event;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.PicOrderItemVo;
	import model.orderModel.ProductVo;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	import script.order.PicOrderItem;
	
	import ui.order.OrderItemUI;
	
	import utils.UtilTool;
	
	public class LailiaoOrderItemCell extends OrderItemUI
	{
		public var ordervo:PicOrderItemVo;
		public var locked:Boolean = true;
		
		public var finalWidth:Number;
		public var finalHeight:Number;
		
		public var curproductvo:ProductVo;
		
		private var fanmianFid:String;
		
		
		
		public var discount:Number = 1;
		
		public function LailiaoOrderItemCell(vo:PicOrderItemVo)
		{
			super();
			ordervo = vo;
			EventCenter.instance.on(EventCenter.FIRST_PAGE_SHRINK,this,updateLblPos);
			updateLblPos(Userdata.instance.shrinkState);
			
			initItem();
			if(ordervo.orderData != null)
			{
				curproductvo = ordervo.productVo;
				
				this.inputnum.text = ordervo.orderData.itemNumber;
				
				var size:Array = this.ordervo.orderData.conponent.LWH.split("/");
				if(size.length > 1)
				{
					this.editwidth.text = size[0];
					this.editheight.text = size[1];
					finalWidth = parseFloat(size[0]);
					finalHeight = parseFloat(size[1]);
				}
				
				initEditData();
			}
		}
		
		private function updateLblPos(state:int):void
		{
			if(state == 0)
			{
				this.deletBtn.x = 1466;
				this.total.x = 1314;
				this.unitPrice.x = 1223;
			}
			else
			{
				this.deletBtn.x = 1566;
				this.total.x = 1415;
				this.unitPrice.x = 1324;
				
			}
		}
		 public function initItem():void
		{
			this.numindex.text = ordervo.indexNum.toString();
			
			
			this.subtn.on(Event.CLICK,this,onSubItemNum);
			this.addbtn.on(Event.CLICK,this,onAddItemNum);
			this.hascomment.visible = false;
			this.addmsg.visible = false;
			
			if(ordervo.type == PicOrderItemVo.PAINT_ITEM)
			{
				this.fileimg.skin = HttpRequestUtil.smallerrPicUrl + ordervo.picinfo.fid + ordervo.picinfo.tailFix;
	
				if(ordervo.picinfo.picWidth > ordervo.picinfo.picHeight)
				{
					this.fileimg.width = 108;					
					this.fileimg.height = 108/ordervo.picinfo.picWidth * ordervo.picinfo.picHeight;
					
				}
				else
				{
					this.fileimg.height = 108;
					this.fileimg.width = 108/ordervo.picinfo.picHeight * ordervo.picinfo.picWidth;
					
				}
			}
			else
				this.fileimg.skin = "commers/blackbg.png";

			this.yixingimg.width = this.fileimg.width;
			this.yixingimg.height = this.fileimg.height;
			
			this.backimg.width = this.fileimg.width;
			this.backimg.height = this.fileimg.height;
			
			this.yingxback.width = this.fileimg.width;
			this.yingxback.height = this.fileimg.height;
			
			this.yixingimg.visible = false;
			this.backimg.visible = false;
			this.yingxback.visible = false;
			//			if(ordervo.picinfo.yixingFid != null && ordervo.picinfo.yixingFid != 0)
			//			{
			//				this.yixingimg.visible = true;
			//				this.yixingimg.skin = HttpRequestUtil.smallerrPicUrl + ordervo.picinfo.yixingFid + ".jpg";
			//
			//			}
			//			if(ordervo.picinfo.backFid != null && ordervo.picinfo.backFid != 0)
			//			{
			//				this.backimg.visible = true;
			//				this.backimg.skin = HttpRequestUtil.smallerrPicUrl + ordervo.picinfo.backFid + ".jpg";
			//				
			//			}if(ordervo.picinfo.partWhiteFid != null && ordervo.picinfo.partWhiteFid != 0)
			//			{
			//				this.yingxback.visible = true;
			//				this.yingxback.skin = HttpRequestUtil.smallerrPicUrl + ordervo.picinfo.partWhiteFid + ".jpg";
			//				
			//			}
			this.fileimg.on(Event.CLICK,this,onShowBigImg);
			this.backimg.on(Event.CLICK,this,onShowBackImg);
			
			finalWidth = ordervo.picinfo.picPhysicWidth;
			finalHeight = ordervo.picinfo.picPhysicHeight;
			
			this.editwidth.text = ordervo.picinfo.picPhysicWidth.toString();
			this.editheight.text = ordervo.picinfo.picPhysicHeight.toString();
			this.editwidth.restrict = "0-9" + ".";
			this.editheight.restrict = "0-9" + ".";
			this.filename.text = ordervo.picinfo.directName;
			this.architype.text = ordervo.techStr;
			this.total.text = "0";
			this.deleteorder.underline = true;
			this.deleteorder.underlineColor = "#222222";
			this.inputnum.text = "1";
			this.inputnum.restrict = "0-9";
			//this.deleteorder.on(Event.CLICK,this,onDeleteOrder);
			this.deletBtn.on(Event.CLICK,this,onDeleteOrder);
			
			this.addmsg.underline = true;
			this.addmsg.underlineColor = "#222222";
			this.addmsg.on(Event.CLICK,this,onAddComment);
			
			//this.price.visible = Userdata.instance.accountType == 1;
			this.total.visible = !Userdata.instance.isHidePrice();
			
			this.unitPrice.text = "0";
			//this.changearchitxt.on(Event.CLICK,this,onchangeTech);
			this.inputnum.on(Event.INPUT,this,onNumChange);
			
			this.editwidth.on(Event.INPUT,this,onWidthSizeChange);
			this.editheight.on(Event.INPUT,this,onHeightSizeChange);
			this.lockratio.on(Event.CLICK,this,onLockChange);
			
			if(this.architype.textField.textHeight > 124)
				this.architype.height = this.architype.textField.textHeight;
			else
				this.architype.height = 124;
			
			this.manuicon.visible = false;
			this.setMatBtn.visible = this.curproductvo == null;
			this.editmat.visible = this.curproductvo != null;
			this.setMatBtn.on(Event.CLICK,this,onShowMaterialView);
			this.editmat.on(Event.CLICK,this,onShowMaterialView);
			
			//this.changearchitxt.y = this.architype.y + this.architype.height - 15;
			
			if(this.architype.height > 124)
				this.height = this.architype.height + 10;
			else
				this.height = 134;
			//this.bgimg.height = this.height;
			alighComponet();
		}
		
		private function initEditData():void
		{
			this.setMatBtn.visible = this.curproductvo == null;
			this.editmat.visible = this.curproductvo != null;
			
			this.manuicon.visible = true;
			
			this.manuicon.skin = "commers/" + OrderConstant.OUTPUT_ICON[PaintOrderModel.instance.getManuFactureIndex(curproductvo.manufacturerCode)]
			
			var area:Number = (finalHeight * finalWidth)/10000;
			var perimeter:Number = (finalHeight + finalWidth)*2/100;
			
			var provo:ProductVo = this.ordervo.productVo;
			
			var hasSelectedTech:Array = provo.getAllSelectedTech();
			var doublesideImg:String = "";
			var yixingqiegeImg:String = "";
			var doublesame:Boolean = false;
			for(var i:int=0;i < hasSelectedTech.length;i++)
			{
				if(hasSelectedTech[i].procCode == OrderConstant.DOUBLE_SIDE_SAME_TECHNO || hasSelectedTech[i].procCode == OrderConstant.DOUBLE_SIDE_SAME_TECHNO_UV )
				{
					doublesame = true;
					fanmianFid = this.ordervo.picinfo.fid;
					
				}
				else if(OrderConstant.backSideUnSame(hasSelectedTech[i].procCode))
				{
					doublesideImg = ordervo.picinfo.backFid; //hasSelectedTech[i].attchFileId;
					fanmianFid = doublesideImg;
					
				}
				else if(OrderConstant.yiXingCutProcess(hasSelectedTech[i].procCode))
				{
					yixingqiegeImg =  ordervo.picinfo.yixingFid;//hasSelectedTech[i].attchFileId;
				}
			}
			
			this.backimg.visible = doublesideImg != "" || doublesame;
			this.yingxback.visible = (doublesideImg != "" || doublesame) && yixingqiegeImg != "";
			
			if(doublesideImg != "")
			{
				this.backimg.skin = HttpRequestUtil.biggerPicUrl +doublesideImg + ".jpg";	
			}
			if(doublesame)
			{
				this.backimg.skin = HttpRequestUtil.biggerPicUrl + ordervo.picinfo.fid + ".jpg";	
			}
			
			this.yixingimg.visible = yixingqiegeImg != "";
			
			if(yixingqiegeImg != "")
			{
				this.yixingimg.skin = HttpRequestUtil.biggerPicUrl +yixingqiegeImg + ".jpg";	
				
				if(this.yingxback.visible)
				{
					this.yingxback.skin = HttpRequestUtil.biggerPicUrl +yixingqiegeImg + ".jpg";	
					
					
				}
			}
			
			
			
			
			
			this.total.text = (parseInt(this.inputnum.text) *provo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo,true) *  discount).toFixed(1) + "";
			this.unitPrice.text = this.ordervo.orderData.unitPrice;
			
			//this.mattxt.text = provo.prodName;
			
			var tech:String = provo.getTechDes(false,finalWidth,finalHeight);
			
			if(tech.indexOf("超宽拼接") >= 0)
				tech = tech.replace("超宽拼接","超宽拼接" + "(" + ["V","H"][this.ordervo.cuttype] + "-" +  this.ordervo.cutnum+ "-" + this.ordervo.eachCutLength.join(";") +")");
			
			if(tech.indexOf("超幅拼接") >= 0)
				tech = tech.replace("超幅拼接","超幅拼接" + "(" + ["V","H"][this.ordervo.cuttype] + "-" +  this.ordervo.cutnum+ "-" + this.ordervo.eachCutLength.join(";") +")");
			
			if(tech.indexOf("小块裁切") >= 0)
				tech = tech.replace("小块裁切","小块裁切"+ "(H-" + this.ordervo.horiCutNum+ ",V-" + this.ordervo.verCutNum + ")");
			
			if(tech.indexOf("正上方打扣") >= 0)
			{
				//				if(this.ordervo.dakouNum == 1)
				//					tech = tech.replace("正上方打扣","正上方打扣"+ "(" + this.ordervo.dakouNum+ "-" + this.ordervo.dkleftpos.toFixed(2) + ")");
				//				else
				//					tech = tech.replace("正上方打扣","正上方打扣"+ "(" + this.ordervo.dakouNum+ "-" + this.ordervo.dkleftpos.toFixed(2) + "-" + this.ordervo.dkrightpos.toFixed(2) + ")");
				
			}
			this.architype.text = provo.prodName + "\n" + tech;
			
			
			if(this.architype.textField.textHeight > 134)
				this.architype.height = this.architype.textField.textHeight;
			else
				this.architype.height = 134;
			
			//this.changearchitxt.y = this.architype.y + this.architype.height - 15;
			
			if(this.architype.height > 134)
				this.height = this.architype.height + 10;
			else
				this.height = 134;
			//this.bgimg.height = this.height;
			alighComponet();
		}
		
		 public function reset():void
		{
			this.architype.text = "";
			this.unitPrice.text = "0";
			this.total.text = "0";
			
			this.ordervo.orderData = null;
			this.ordervo.productVo = null;
			this.curproductvo = null;
			
			this.yixingimg.visible = false;
			this.backimg.visible = false;
			this.yingxback.visible = false;
			this.manuicon.visible = false;
			this.setMatBtn.visible = true;
			this.editmat.visible = false;
			
		}
		
		
		private function onLockChange():void
		{
			if(locked)
			{
				this.lockratio.skin = "commers/unlock.png";
				locked = false;
			}
			else
			{
				this.lockratio.skin = "commers/lock.png";
				locked = true;
			}
		}
		private function onWidthSizeChange():void
		{
			var curwidth:Number = Number(this.editwidth.text);
			
			finalWidth = curwidth;
			if(locked)
			{
				var heightration:Number = curwidth/ordervo.picinfo.picPhysicWidth*ordervo.picinfo.picPhysicHeight;
				finalHeight = heightration;
				
				this.editheight.text = heightration.toFixed(2);
			}
			//			if(finalHeight != 0)
			//			{
			//				if(Math.abs(finalWidth/finalHeight - ordervo.picinfo.picPhysicWidth/ordervo.picinfo.picPhysicHeight) > 0.2)
			//				{
			//					ViewManager.showAlert("修改图片比例不能超过原图比例的20%");
			//					finalWidth = ordervo.picinfo.picPhysicWidth;
			//					finalHeight = ordervo.picinfo.picPhysicHeight;
			//					this.editwidth.text = ordervo.picinfo.picPhysicWidth.toString();
			//					this.editheight.text = ordervo.picinfo.picPhysicHeight.toString();
			//
			//				}
			//					
			//			}
			reset();
			
			updatePrice();
		}
		private function onHeightSizeChange():void
		{
			var curheight:Number = Number(this.editheight.text);
			finalHeight = curheight;
			
			if(locked)
			{
				var widthration:Number = curheight/ordervo.picinfo.picPhysicHeight*ordervo.picinfo.picPhysicWidth;
				finalWidth = widthration;
				
				this.editwidth.text = widthration.toFixed(2);
			}
			
			
			
			reset();
			updatePrice();
		}
		
		private function onSubItemNum():void
		{
			var num:int = parseInt(this.inputnum.text);
			if(num > 1)
				num--;
			this.inputnum.text = num.toString();
			onNumChange();
		}
		private function onAddItemNum():void
		{
			var num:int = parseInt(this.inputnum.text);
			num++;
			this.inputnum.text = num.toString();
			onNumChange();
		}
		
		private function onShowBigImg():void
		{
			if(this.ordervo.type == PicOrderItemVo.LAILIAO_ITEM)
				return;
			
			if(this.yixingimg.visible)
			{
				var obj:Array = [];
				obj.push(this.ordervo.picinfo);
				obj.push(this.yixingimg.skin);
				obj.push(1);
				ViewManager.instance.openView(ViewManager.VIEW_PICTURE_CHECK,false,obj);
				
			}
			else
				ViewManager.instance.openView(ViewManager.VIEW_PICTURE_CHECK,false,this.ordervo.picinfo);
			
			
		}
		
		private function onShowBackImg():void
		{
			var obj:PicInfoVo = new PicInfoVo({},1);  
			obj.fid = fanmianFid;
			obj.picWidth = this.ordervo.picinfo.picWidth;
			obj.picHeight = this.ordervo.picinfo.picHeight;
			
			if(this.yingxback.visible)
			{
				var objdata:Array = [];
				objdata.push(obj);
				objdata.push(this.yingxback.skin);
				objdata.push(-1);
				ViewManager.instance.openView(ViewManager.VIEW_PICTURE_CHECK,false,objdata);
			}
			else
				ViewManager.instance.openView(ViewManager.VIEW_PICTURE_CHECK,false,obj);
			
		}
		private function onAddComment():void
		{
			ViewManager.instance.openView(ViewManager.VIEW_ADD_MESSAGE,false,{msg:this.ordervo.comment,caller:this,callback:onAddMsgBack});
		}
		
		private function onAddMsgBack(msg:String):void
		{
			this.ordervo.comment = msg;
			this.hascomment.visible = this.ordervo.comment != "";
			
			if(this.ordervo.orderData)
			{
				this.ordervo.orderData.comments = this.ordervo.comment;
			}
		}
		
		private function alighComponet():void
		{
			this.checkSel.y = (this.height - 28)/2;
			
			this.numindex.y = (this.height - this.numindex.height)/2;
			
			this.fileimg.y = this.height/2;
			
			this.backimg.y =  this.height/2;
			this.yingxback.y =  this.height/2;
			
			this.yixingimg.y = this.height/2;
			
			this.filename.y = (this.height - this.filename.height)/2;
			this.editbox.y = (this.height - this.editbox.height)/2;
			//this.viprice.y = (this.height - this.viprice.height)/2;
			this.numbox.y = (this.height)/2 - 12;
			//this.price.y = (this.height - this.price.height)/2;
			this.total.y = (this.height - this.total.height)/2;
			this.editmat.y = (this.height - this.editmat.height)/2;
			this.deletBtn.y = (this.height - this.deletBtn.height)/2;
			
			this.operatebox.y = (this.height - this.operatebox.height)/2 - 10;
			
		}
		 public function updateIndex():void
		{
			this.numindex.text = ordervo.indexNum.toString();
		}
		private function onDeleteOrder():void
		{
			// TODO Auto Generated method stub
			EventCenter.instance.event(EventCenter.DELETE_PIC_ORDER,this);
		}
		
		private function updatePrice():void
		{
			if(curproductvo != null)
			{
				updateOrderData(curproductvo);
				var area:Number = (finalHeight * finalWidth)/10000;
				var perimeter:Number = (finalHeight + finalWidth)*2/100;
				//var longside:Number = Math.max(finalHeight,finalWidth)/100;
				
				//				if(area < 0.1)
				//					area = 0.1;
				//				
				
				
				this.total.text = (parseInt(this.inputnum.text) *curproductvo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo,true) * discount).toFixed(1) + "";
				
			}
			EventCenter.instance.event(EventCenter.UPDATE_ORDER_ITEM_TECH);
			
		}
		 public function onNumChange():void
		{
			if(this.inputnum.text == "")
				this.inputnum.text = "1";
			
			//this.total.text = (parseInt(this.inputnum.text) * this.ordervo.orderPrice * discount).toFixed(1).toString();
			this.total.text = (parseInt(this.inputnum.text) * this.ordervo.noDiscountOrderPrice * discount).toFixed(1).toString();
			
			if(this.ordervo.orderData)
			{
				this.ordervo.orderData.itemNumber = parseInt(this.inputnum.text);
				this.ordervo.orderData.item_payPrice = parseFloat((parseInt(this.inputnum.text) * this.ordervo.orderPrice * discount).toFixed(1));
			}
			
			EventCenter.instance.event(EventCenter.UPDATE_ORDER_ITEM_TECH);
			
		}
		private function onShowMaterialView():void
		{
			if(PaintOrderModel.instance.selectAddress == null)
			{
				ViewManager.showAlert("请选择收货地址");
				return;
			}
			if(PaintOrderModel.instance.outPutAddr == null || PaintOrderModel.instance.outPutAddr.length == 0)
			{
				ViewManager.showAlert("当前的收货地址没有输出中心，请重新选择收货地址");
				return;
			}
			for(var i:int=0;i < PaintOrderModel.instance.outPutAddr.length;i++)
			{
				if(PaintOrderModel.instance.allManuFacutreMatProcPrice[PaintOrderModel.instance.outPutAddr[i].org_code] == null)
				{					
					ViewManager.showAlert("暂未获取到生产商材料工艺价格，请重新选择收货地址或稍后再试");
					return;
				}
			}
			
			if(PaintOrderModel.instance.productList == null || PaintOrderModel.instance.productList.length == 0)
			{
				ViewManager.showAlert("未获取到材料列表，请重新选择收货地址或者刷新页面");
				return;
			}
			// TODO Auto Generated method stub
			if(PaintOrderModel.instance.selectAddress == null)
			{
				ViewManager.showAlert("请先选择收货地址");
				return;
			}
			
			if(finalHeight != 0 && ordervo.type == PicOrderItemVo.PAINT_ITEM)
			{
				if(Math.abs((finalWidth/finalHeight - ordervo.picinfo.picPhysicWidth/ordervo.picinfo.picPhysicHeight)/(ordervo.picinfo.picPhysicWidth/ordervo.picinfo.picPhysicHeight)) > 0.2)
				{
					ViewManager.showAlert("修改图片比例不能超过原图比例的20%");
					finalWidth = ordervo.picinfo.picPhysicWidth;
					finalHeight = ordervo.picinfo.picPhysicHeight;
					this.editwidth.text = ordervo.picinfo.picPhysicWidth.toString();
					this.editheight.text = ordervo.picinfo.picPhysicHeight.toString();
					return;
				}
				
			}
			
			PaintOrderModel.instance.curSelectOrderItem = this;
			PaintOrderModel.instance.batchChangeMatItems = [];
			
			PaintOrderModel.instance.curSelectMat = null;
			
			
			if(PaintOrderModel.instance.orderType == OrderConstant.CUTTING)
				ViewManager.instance.openView(ViewManager.VIEW_CHARACTER_DEMONSTRATE_PANEL,false,ordervo.picinfo);
			else
				ViewManager.instance.openView(ViewManager.VIEW_SET_MATERIAL_PROCESS_PANEL,false,ordervo.picinfo);

			
		}
		
		 public function updateProductPrice():void
		{
			if(this.ordervo.orderData != null)
			{
				if(curproductvo != null)
				{
					updateOrderDataPrice();
					var area:Number = (finalHeight * finalWidth)/10000;
					var perimeter:Number = (finalHeight + finalWidth)*2/100;
					//var longside:Number = Math.max(finalHeight,finalWidth)/100;
					
					//				if(area < 0.1)
					//					area = 0.1;
					//				
					
					
					this.total.text = (parseInt(this.inputnum.text) *curproductvo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo,true) * discount).toFixed(1) + "";
					
				}
			}
		}
		
		
		 public function changeProduct(provo:ProductVo):void
		{
			//this.ordervo.orderData = provo;
			curproductvo = provo.cloneData(this);
			
			ordervo.productVo = curproductvo;
			
			fanmianFid = "";
			updateOrderData(curproductvo);
			var lastheight:int = this.height;
			
			initEditData();
			
			EventCenter.instance.event(EventCenter.ADJUST_PIC_ORDER_TECH,this.height - lastheight);
		}
		
		 public function getPrice():Number
		{			
			return parseFloat((parseInt(this.inputnum.text) * this.ordervo.orderPrice * discount).toFixed(1));
			//return parseFloat(this.total.text);
		}
		
		 public function getNoDiscountPrice():Number
		{			
			//return parseInt(this.inputnum.text) * this.ordervo.orderPrice * discount;
			if(this.ordervo.orderData != null)
				return parseInt(this.inputnum.text) * this.ordervo.noDiscountOrderPrice;
			else 
				return 0 ;
		}
		
		
		private function updateOrderDataPrice():void
		{
			if(curproductvo != null && this.ordervo.orderData != null)
			{
				var area:Number = (finalHeight * finalWidth)/10000;
				var perimeter:Number = (finalHeight + finalWidth)*2/100;
				
				//			if(area < 0.1)
				//				area = 0.1;
				
				this.ordervo.orderPrice = curproductvo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo);
				if(this.ordervo.orderPrice < 0.15)
					this.ordervo.orderPrice = 0.15;
				this.ordervo.noDiscountOrderPrice = curproductvo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo,true);
				
				if(this.ordervo.noDiscountOrderPrice < 0.15)
					this.ordervo.noDiscountOrderPrice = 0.15;
				
				this.ordervo.orderData.itemPrice = this.ordervo.orderPrice.toString();
				this.ordervo.orderData.discountProcessPrice = curproductvo.getDiscountProcessPrice(finalWidth/100,finalHeight/100,false,ordervo);
				this.ordervo.orderData.materialPrice = this.ordervo.orderPrice - this.ordervo.orderData.discountProcessPrice;
				
				this.ordervo.orderData.one_mat_cost = curproductvo.getMaterialPrice(finalWidth/100,finalHeight/100,false,ordervo);
				var cost:Array = curproductvo.getProcessAndGrossPrices(finalWidth/100,finalHeight/100,false,ordervo);
				this.ordervo.orderData.one_proc_cost = cost[0];
				
				//this.ordervo.orderData.gross_margin = cost[1] + cost[2];
				
				this.ordervo.orderData.oneDiscountGrossMargin = cost[1];
				this.ordervo.orderData.oneNoDiscountGrossMargin = cost[2];
				
			}
		}
		
		private function updateOrderData(productVo:ProductVo)
		{
			
			var area:Number = (finalHeight * finalWidth)/10000;
			var perimeter:Number = (finalHeight + finalWidth)*2/100;
			
			//			if(area < 0.1)
			//				area = 0.1;
			
			this.ordervo.orderPrice = productVo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo);
			this.ordervo.noDiscountOrderPrice = productVo.getTotalPrice(finalWidth/100,finalHeight/100,false,ordervo,true);
			
			if(this.ordervo.orderPrice < 0.15)
				this.ordervo.orderPrice = 0.15;
			
			if(this.ordervo.noDiscountOrderPrice < 0.15)
				this.ordervo.noDiscountOrderPrice = 0.15;
			
			
			ordervo.manufacturer_code = productVo.manufacturerCode;
			ordervo.manufacturer_name = productVo.manufacturerName;
			
			var orderitemdata:Object = {};
			
			//orderitemdata.prodName = productVo.prodName;
			//orderitemdata.prodCode = productVo.prodCode;
			orderitemdata.material_code = productVo.materialCode;
			
			//orderitemdata.prod_description = "";
			//orderitemdata.LWH = finalWidth.toFixed(2) + "/" + finalHeight.toFixed(2) + "/1";
			
			//orderitemdata.weightStr = productVo.getOrderSingleWeight(finalWidth/100,finalHeight/100,ordervo);
			//orderitemdata.weightStr = 1;
			
			orderitemdata.conponent = {};
			orderitemdata.conponent.prodName = productVo.prodName;
			orderitemdata.conponent.prodCode = productVo.prodCode;
			orderitemdata.conponent.num = 1;
			
			orderitemdata.conponent.LWH = finalWidth.toFixed(2) + "/" + finalHeight.toFixed(2) + "/1";
			orderitemdata.conponent.prodDescription = "";
			orderitemdata.conponent.weight = productVo.getOrderSingleWeight(finalWidth/100,finalHeight/100,ordervo).toFixed(2);
			if(this.ordervo.type == PicOrderItemVo.PAINT_ITEM)
			{
				orderitemdata.conponent.imageFilePath =  HttpRequestUtil.originPicPicUrl + this.ordervo.picinfo.fid + "." + this.ordervo.picinfo.picClass;
				orderitemdata.conponent.previewImagePath =  HttpRequestUtil.biggerPicUrl + this.ordervo.picinfo.fid + this.ordervo.picinfo.tailFix;
				orderitemdata.conponent.thumbnailsPath =  HttpRequestUtil.smallerrPicUrl + this.ordervo.picinfo.fid + this.ordervo.picinfo.tailFix;
			}
			else
				orderitemdata.conponent.previewImagePath = "commers/blackbg.png";
			
			orderitemdata.conponent.filename = this.ordervo.picinfo.directName;
			
			orderitemdata.itemNumber = parseInt(this.inputnum.text);
			orderitemdata.itemPrice = this.ordervo.orderPrice.toString();
			orderitemdata.actualAmount = parseFloat((parseInt(this.inputnum.text) * this.ordervo.orderPrice * discount).toFixed(1)).toExponential();
			
			orderitemdata.isMerchandise = 1;
			orderitemdata.itemStatus = "0";
			orderitemdata.fixedDiscount = productVo.isFixedCustomerRatio;
			
			orderitemdata.discountProcessPrice = productVo.getDiscountProcessPrice(finalWidth/100,finalHeight/100,false,ordervo);
			orderitemdata.materialPrice = this.ordervo.orderPrice - orderitemdata.discountProcessPrice;
			orderitemdata.unitPrice = this.ordervo.orderPrice - productVo.getAllAttachPrice(finalWidth/100,finalHeight/100,false,ordervo);
			
			orderitemdata.unitPrice = orderitemdata.unitPrice/(finalWidth/100*finalHeight/100);
			orderitemdata.unitPrice = orderitemdata.unitPrice.toFixed(2);
			
			orderitemdata.one_mat_cost = productVo.getMaterialPrice(finalWidth/100,finalHeight/100,false,ordervo);
			var cost:Array = productVo.getProcessAndGrossPrices(finalWidth/100,finalHeight/100,false,ordervo);
			orderitemdata.one_proc_cost = cost[0];
			
			orderitemdata.gross_margin = cost[1] + cost[2];
			
			orderitemdata.oneDiscountGrossMargin = cost[1];
			orderitemdata.oneNoDiscountGrossMargin = cost[2];
			
			//orderitemdata.is_urgent = false;
			
			var tempstr:String = "";
			var hasfinddot:Boolean = false;
			for(var i:int= this.ordervo.picinfo.directName.length - 1;i >= 0;i--)
			{
				if(this.ordervo.picinfo.directName.charAt(i) == "." && hasfinddot == false)
				{
					hasfinddot = true;
				}
				else if(hasfinddot)
				{
					tempstr = this.ordervo.picinfo.directName.charAt(i) + tempstr;
				}
			}
			
			orderitemdata.comments = tempstr.substr(0,20);// this.ordervo.picinfo.directName.split(".");
			//orderitemdata.imagefile_path = HttpRequestUtil.originPicPicUrl + this.ordervo.picinfo.fid + "." + this.ordervo.picinfo.picClass;
			//orderitemdata.previewImage_path = HttpRequestUtil.biggerPicUrl + this.ordervo.picinfo.fid + ".jpg";
			//orderitemdata.thumbnails_path = HttpRequestUtil.smallerrPicUrl + this.ordervo.picinfo.fid + ".jpg";
			//orderitemdata.filename = this.ordervo.picinfo.directName;
			
			orderitemdata.conponent.procInfoList = productVo.getProInfoList(this.ordervo.picinfo,finalWidth/100,finalHeight/100,this.ordervo);
			var cutlength:Number = 99999999;
			for(var i:int=0;i < orderitemdata.conponent.procInfoList.length;i++)
			{
				if(orderitemdata.conponent.procInfoList[i].procDescription.indexOf("超幅拼接") >=0 || orderitemdata.conponent.procInfoList[i].procDescription.indexOf("超宽拼接") >= 0)
				{
					cutlength = this.ordervo.eachCutLength[0];
				}
			}
			orderitemdata.minSideLength = Math.min(this.finalWidth,this.finalHeight,cutlength).toFixed(2);
			
			orderitemdata.colorFormat = this.ordervo.picinfo.colorspace;
			
			
			this.ordervo.orderData =  orderitemdata;
		}
		
		 public function getProcessPrice():Number
		{
			if(this.curproductvo != null)
				return this.curproductvo.getProcessPrice(finalWidth/100,finalHeight/100,ordervo)*parseInt(this.inputnum.text);
			else
				return 0;
		}
		 public function checkCanOrder():Boolean
		{
			
			if(ordervo.orderData == null)
			{
				ViewManager.showAlert("未选择材料工艺");
				return false;
			}
			
			if(this.ordervo.orderData.conponent.prodName.indexOf("户内") >= 0 && this.architype.text.indexOf("户外") >=0 )
			{
				
				var errordata:String = "user_phone=" + Userdata.instance.userAccount + "&error_msg=" + this.ordervo.orderData.conponent.prodName + ",工厂：" + this.ordervo.manufacturer_name  + ",材料不匹配" + "&request_url=下单验证";
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addErrorLog,null,null,errordata,"post");
				ViewManager.showAlert("材料和工艺不匹配，请重新选择材料和工艺");
				return false;
			}
			
			if(this.ordervo.orderData.conponent.prodName.indexOf("户外") >= 0 && this.architype.text.indexOf("户内") >=0 )
			{
				var errordata:String = "user_phone=" + Userdata.instance.userAccount + "&error_msg=" + this.ordervo.orderData.conponent.prodName + ",工厂：" + this.ordervo.manufacturer_name  + ",材料不匹配" + "&request_url=下单验证";
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.addErrorLog,null,null,errordata,"post");
				ViewManager.showAlert("材料和工艺不匹配，请重新选择材料和工艺");
				return false;
			}
			if(this.ordervo.orderData.conponent.procInfoList == null ||  this.ordervo.orderData.conponent.procInfoList.length == 0)
			{
				ViewManager.showAlert("未选择工艺");
				return false;
			}
			
			//			if(curproductvo != null)
			//				return curproductvo.checkCurTechValid();
			//			else
			return true;
			
		}
	}
	
}