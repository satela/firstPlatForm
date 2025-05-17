package script.order 
{
	import eventUtil.EventCenter;
	
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.utils.Browser;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.AttchCatVo;
	import model.orderModel.ConstraintTool;
	import model.orderModel.MaterialItemVo;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.OrderConstant;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProcessCatVo;
	import model.orderModel.ProductVo;
	import model.picmanagerModel.PicInfoVo;
	
	import script.ViewManager;
	
	import ui.order.SelectMaterialPanelUI;
	import ui.order.TechorItemUI;
	
	import utils.UtilTool;
	
	public class SelectMaterialControl extends Script
	{
		private var uiSkin:SelectMaterialPanelUI;
		
		
		private var startposx:int = 10;
		
		public var param:PicInfoVo;
		
		private var itemheight:int = 40;
		
		private var itemspaceH:int = 30;
		private var itemspaceV:int = 10;
		
		private var allitemlist:Array;
		
		private var hasShowItemList:Array;
		
		private var firstTechlist:Vector.<TechBoxItem>;
		
		private var linelist:Vector.<Sprite>;
		
		private var hasFinishAllFlow:Boolean = false;
		
		private var curclickItem:TechBoxItem;
		
		public function SelectMaterialControl()
		{
			super();
		}
		
		override public function onStart():void
		{
			hasFinishAllFlow = false;
			uiSkin = this.owner as SelectMaterialPanelUI; 
			uiSkin.main_panel.vScrollBarSkin = "";
			uiSkin.main_panel.hScrollBarSkin = "";
			
			uiSkin.main_panel.vScrollBar.mouseWheelEnable = false;
			uiSkin.main_panel.hScrollBar.mouseWheelEnable = false;

			uiSkin.tablist.itemRender = MaterialClassBtn;
			uiSkin.tablist.vScrollBarSkin = "";
			uiSkin.tablist.selectEnable = true;
			uiSkin.tablist.spaceY = 2;
			uiSkin.tablist.renderHandler = new Handler(this, updateMatClassItem);
			
			uiSkin.tablist.selectHandler = new Handler(this,onSlecteMatClass);
			
			uiSkin.originimg.skin = "";
			
			uiSkin.backimg.skin = "";
			
			uiSkin.yixingimg.skin = "";
			
			uiSkin.yingxBack.skin = "";
			
			if(param != null)
			{
				if(param.picWidth > param.picHeight)
				{
					uiSkin.originimg.width = 250;					
					uiSkin.originimg.height = 250/param.picWidth * param.picHeight;
					
				}
				else
				{
					uiSkin.originimg.height = 250;
					uiSkin.originimg.width = 250/param.picHeight * param.picWidth;
					
				}
				
				uiSkin.yixingimg.width = uiSkin.originimg.width;
				uiSkin.yixingimg.height = uiSkin.originimg.height;
				
				uiSkin.backimg.width = uiSkin.originimg.width;
				uiSkin.backimg.height = uiSkin.originimg.height;
				
				uiSkin.yingxBack.width = uiSkin.originimg.width;
				uiSkin.yingxBack.height = uiSkin.originimg.height;
				
				uiSkin.originimg.visible = true;
				uiSkin.originimg.skin = HttpRequestUtil.biggerPicUrl + param.fid + ".jpg";	

				//uiSkin.qiegeoriginimg.width = uiSkin.originimg.width;
				//uiSkin.qiegeoriginimg.height = uiSkin.originimg.height;

			}
			
//			uiSkin.factoryList.itemRender = FactoryChooseBtn;
//			uiSkin.factoryList.vScrollBarSkin = "";
//			uiSkin.factoryList.selectEnable = true;
//			uiSkin.factoryList.spaceY = 2;
//			uiSkin.factoryList.renderHandler = new Handler(this, updateFactoryItem);
//			
//			uiSkin.factoryList.selectHandler = new Handler(this,onSlecteFactory);
//			
//			if(PaintOrderModel.instance.selectFactoryAddress != null &&PaintOrderModel.instance.selectFactoryAddress.length > 0)
//			{
//				uiSkin.factoryList.array = PaintOrderModel.instance.selectFactoryAddress;
//				
//				PaintOrderModel.instance.selectFactoryInMat = PaintOrderModel.instance.selectFactoryAddress[0];
//			}
//			else
//				uiSkin.factoryList.array = [];
			
			uiSkin.matlist.itemRender = MaterialItem;
			uiSkin.matlist.vScrollBarSkin = "";
			uiSkin.matlist.selectEnable = true;
			uiSkin.matlist.spaceY = 10;
			uiSkin.matlist.renderHandler = new Handler(this, updateMatNameItem);
			this.uiSkin.selecttech.text = "无";
			//uiSkin.matlist.selectHandler = new Handler(this,onSlecteMat);
			uiSkin.hasSelMat.text = "无";
			uiSkin.matlist.array = [];
			
			var temp:Array = [];
			if(PaintOrderModel.instance.productList != null)
			{
				for(var i:int=0;i < PaintOrderModel.instance.productList.length;i++)
				{
					if(PaintOrderModel.instance.productList[i].matclassname == "户内写真")
						temp.unshift(PaintOrderModel.instance.productList[i]);
					else if(PaintOrderModel.instance.productList[i].matclassname == "户外写真")
					{
						if(temp.length > 0 && temp[0].matclassname == "户内写真")
						{
							var hueni:* = temp.shift();
							temp.unshift(PaintOrderModel.instance.productList[i]);
							temp.unshift(hueni);
	
						}
						else
							temp.unshift(PaintOrderModel.instance.productList[i]);
						
					}
					else
						temp.push(PaintOrderModel.instance.productList[i]);
	
				}
			}
			uiSkin.tablist.array = temp;//PaintOrderModel.instance.productList;
			
			this.uiSkin.techcontent.vScrollBar.hide = true;
			this.uiSkin.techcontent.hScrollBar.hide = true;
			
			//this.uiSkin.main_panel.vScrollBarSkin = "";
			uiSkin.subtn.on(Event.CLICK,this,onSubItemNum);
			uiSkin.addbtn.on(Event.CLICK,this,onAddItemNum);
			uiSkin.numinput.on(Event.INPUT,this,onNumChange);
			uiSkin.numinput.text = "1";
			uiSkin.numinput.restrict = "0-9";

			if(PaintOrderModel.instance.productList && PaintOrderModel.instance.productList.length > 0)
			{
				uiSkin.tablist.selectedIndex = 0;
				//onSlecteMatClass(0);
				(uiSkin.tablist.cells[0] as MaterialClassBtn).ShowSelected = true;
			}
			
			uiSkin.box_tech.visible = false;
			uiSkin.backBtn.label = "工艺";
			
			uiSkin.btncancel.on(Event.CLICK,this,onCloseView);
			uiSkin.btnok.on(Event.CLICK,this,onConfirmTech);
			uiSkin.backBtn.on(Event.CLICK,this,onSwitchPanel);
			
			EventCenter.instance.on(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.on(EventCenter.SHOW_SELECT_TECH,this,initTechView);
			EventCenter.instance.on(EventCenter.CLOSE_PANEL_VIEW,this,onUpdateTechDes);
			//EventCenter.instance.on(EventCenter.SELECT_PIC_ORDER,this,checkShowEffectImg);
			EventCenter.instance.on(EventCenter.CLOSE_PANEL_VIEW,this,checkShowEffectImg);
			EventCenter.instance.on(EventCenter.CANCEL_CHOOSE_ATTACH,this,onCancaleChooseAttach);

			//uiSkin.main_panel.height = Browser.height;
			//uiSkin.main_panel.width = Browser.width;
			uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			uiSkin.dragImg.on(Event.MOUSE_DOWN,this,startDragPanel);
			//uiSkin.dragImg.on(Event.MOUSE_OUT,this,stopDragPanel);
			uiSkin.dragImg.on(Event.MOUSE_UP,this,stopDragPanel);

		}
		
		
		private function startDragPanel(e:Event):void
		{			
			if(e.target == uiSkin.techcontent.vScrollBar.slider.bar || e.target == uiSkin.techcontent.hScrollBar.slider.bar)
				return;

			uiSkin.dragImg.startDrag();//new Rectangle(0,0,Browser.width,Browser.height));
			e.stopPropagation();
		}
		private function stopDragPanel():void
		{
			uiSkin.dragImg.stopDrag();
		}
		private function onSubItemNum():void
		{
			var num:int = parseInt(uiSkin.numinput.text);
			if(num > 1)
				num--;
			uiSkin.numinput.text = num.toString();
			onNumChange();
		}
		private function onAddItemNum():void
		{
			var num:int = parseInt(uiSkin.numinput.text);
			num++;
			uiSkin.numinput.text = num.toString();
			onNumChange();
		}
		private function onNumChange():void
		{
			EventCenter.instance.event(EventCenter.BATCH_CHANGE_PRODUCT_NUM,uiSkin.numinput.text);
		}

		private function onResizeBrower():void
		{
			// TODO Auto Generated method stub
			// uiSkin.main_panel.height = Browser.height;
			// uiSkin.main_panel.width = Browser.width;
			 uiSkin.height = Browser.clientHeight *1920/Browser.clientWidth;

			// uiSkin.dragImg.x = 320;
			// uiSkin.dragImg.y = 50;
		}
		
		private function updateMatClassItem(cell:MaterialClassBtn):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onSlecteMatClass(index:int):void
		{
			for each(var item:MaterialClassBtn in uiSkin.tablist.cells)
			{
				item.ShowSelected = item.matclassvo == uiSkin.tablist.array[index];
			}
			
			
			refreshMatList(index);
		}
		
		private function updateFactoryItem(cell:FactoryChooseBtn):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function onSlecteFactory(index:int):void
		{
//			for each(var item:FactoryChooseBtn in uiSkin.factoryList.cells)
//			{
//				item.setSelected(item.factorydata == uiSkin.factoryList.array[index]);
//			}
//			
//			PaintOrderModel.instance.selectFactoryInMat = uiSkin.factoryList.array[index];
			
			
			refreshMatList(index);
//			var matvo:MatetialClassVo = uiSkin.tablist.array[index] as MatetialClassVo;
//			if(matvo.childMatList != null)
//				uiSkin.matlist.array = (uiSkin.tablist.array[index] as MatetialClassVo).childMatList;
//			else
//				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdList + PaintOrderModel.instance.selectAddress.searchZoneid + "&prodCat_name=" + matvo.matclassname,this,onGetProductListBack,null,null);
			
		}
		
		private function refreshMatList(index:int):void
		{
			var matvo:MatetialClassVo = uiSkin.tablist.array[index] as MatetialClassVo;
			if(matvo.childMatList != null)
			{
				var matlist:Array =matvo.childMatList;
//				var temp:Array = [];
//				for(var i:int=0;i < matlist.length;i++)
//				{
//					if(matlist[i].manufacturer_code == PaintOrderModel.instance.selectFactoryInMat.org_code)
//						temp.push(matlist[i]);
//				}
				uiSkin.matlist.array = matlist;
			}
			else
			{
				var selectoutputCenters:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
			
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdList + PaintOrderModel.instance.selectAddress.searchZoneid + "&prodCat_name=" + matvo.matclassname + "&manufacturerList=" + selectoutputCenters.toString() + "&customer_code=" + Userdata.instance.founderPhone,this,onGetProductListBack,null,null);
			
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdList + PaintOrderModel.instance.selectAddress.zoneid + "&prodCat_name=" + matvo.matclassname + "&manufacturerList=" + selectoutputCenters.toString() + "&customer_code=" + Userdata.instance.founderPhone,this,function(data:String){
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdListNew + PaintOrderModel.instance.selectAddress.zoneid + "&prodCatName=" + matvo.matclassname + "&manufacturerCodeList=" + selectoutputCenters.toString() + "&customerCode=" + Userdata.instance.founderPhone+ "&clientCode=" + Userdata.instance.clientCode + "&orderSource=" + PaintOrderModel.instance.orderType,this,function(data:String){

					if(this.destroyed)
						return;
					
					var result:Object = JSON.parse(data as String);
					if(!result.hasOwnProperty("status"))
					{
						//var matvo:MatetialClassVo = uiSkin.tablist.array[uiSkin.tablist.selectedIndex] as MatetialClassVo;
						matvo.childMatList = [];
						//var temp:Array = [];
						var allmaterial:Object = {};
						
						for(var i:int=0;i < result.length;i++)
						{
							if(!allmaterial.hasOwnProperty(result[i].prodCode))
							{
								var proVo:ProductVo = new ProductVo(result[i]);
								proVo.priority = PaintOrderModel.instance.getManuFacturePriority(proVo.manufacturerCode);
								allmaterial[result[i].prodCode] = proVo;
							}
							else
							{
								if(allmaterial[result[i].prodCode].priority > PaintOrderModel.instance.getManuFacturePriority(result[i].manufacturerCode))
								{
									proVo = new ProductVo(result[i]);
									proVo.priority = PaintOrderModel.instance.getManuFacturePriority(proVo.manufacturerCode);
									allmaterial[result[i].prodCode] = proVo;
								}
								else if(result[i].isClientProd)
								{
									proVo = new ProductVo(result[i]);
									allmaterial[result[i].uniqueCode] = proVo;
									
								}
							}
							///matvo.childMatList.push(new ProductVo(result[i]));
							//trace("产品类型：" + result[i].is_merchandise);
							//if(result[i].manufacturer_code == PaintOrderModel.instance.selectFactoryInMat.org_code)
							//	temp.push(matvo.childMatList[matvo.childMatList.length - 1]);
							
						}
						for(var mate in allmaterial)
							matvo.childMatList.push(allmaterial[mate]);
						matvo.childMatList.sort(sortMaterial);
						
						matvo.childMatList = matvo.childMatList.concat(matvo.childCategoryList);

						if(uiSkin.tablist.selectedIndex == index)
						uiSkin.matlist.array = matvo.childMatList;
					}
					
				
					},null,null);
				}

			
			
		}
				
		private function sortMaterial(a:ProductVo,b:ProductVo):int
		{
			//var anum:String = a.prod_code;
			//var bnum:String = b.prod_code;
			
			var anum:String = a.materialCode;
			var bnum:String = b.materialCode;
			
			var ano:String = "";
			for(var i:int=0;i < anum.length;i++)
			{
				if(anum.charCodeAt(i) <= 57 && anum.charCodeAt(i) >= 48)
					ano = ano + anum[i];
			}
			var bno:String = "";
			for(var i:int=0;i < bnum.length;i++)
			{
				if(bnum.charCodeAt(i) <= 57 && bnum.charCodeAt(i) >= 48)
					bno = bno + bnum[i];
			}
		
			if(parseInt(ano) <= parseInt(bno))
				return -1;
			else
				return 1;
		}
		private function updateMatNameItem(cell:MaterialItem):void
		{
			cell.setData(cell.dataSource);
		}
		
		private function showCaibcPreview():void
		{
			
			ViewManager.instance.openView(ViewManager.VIEW_CBC_PREVIEW_PANEL,false);
		}
		private function onSwitchPanel():void
		{
			if(uiSkin.box_mat.visible)
			{
				if(PaintOrderModel.instance.curSelectMat == null)
				{
					ViewManager.showAlert("请先选择一种材料");
					return;
				}
				else
					showTechView();
					
			}
			else
			{
				uiSkin.box_mat.visible = true;
				uiSkin.box_tech.visible = false;
				uiSkin.backBtn.label = "工艺";
			}
		}
		//选择工艺---------------------------------------------
		
		private function showTechView():void
		{
			uiSkin.box_mat.visible = false;
			uiSkin.box_tech.visible = true;
			uiSkin.backBtn.label = "材料";
			if(PaintOrderModel.instance.curSelectMat == null)
			{
				ViewManager.showAlert("未选择材料");
				
			}
			if(PaintOrderModel.instance.curSelectMat != null && PaintOrderModel.instance.curSelectMat.procTreeList.length == 0)
			{
				ViewManager.showAlert("未获取到工艺流");
				
			}
		}
		private function initTechView():void
		{
			uiSkin.hasSelMat.text =  PaintOrderModel.instance.curSelectMat.prodName;
			
			uiSkin.mattext.text = "已选材料:" + PaintOrderModel.instance.curSelectMat.prodName;
			
			updateSelectedTech();
			showTechView();
			
			checkShowEffectImg();
			var list:Array = [];
			hasShowItemList = [];
			linelist = new Vector.<Sprite>();
			firstTechlist = new Vector.<TechBoxItem>();
			//var num:int = Math.random()*18;
			//this.uiSkin.techcontent.vScrollBarSkin = "";
			//this.uiSkin.main_panel.vScrollBarSkin = "";
			var arr:Array = PaintOrderModel.instance.curSelectMat.procTreeList;
			var startpos:int = (this.uiSkin.techcontent.height - arr.length*itemheight -  itemspaceV * (arr.length - 1))/2;
			
			while(uiSkin.techcontent.numChildren > 0)
				uiSkin.techcontent.removeChildAt(0);
			
			if(arr.length > 0)
			{
				var manufacturecode = PaintOrderModel.instance.curSelectMat.manufacturerCode;
				var matvo:ProductVo = PaintOrderModel.instance.curSelectMat;
				
				//HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProcessFlow + manufacturecode + "&procCat_name=" + arr[0].procCat_Name,this,function(data:Object):void{
					
					if(this.destroyed)
						return;
					if(matvo != PaintOrderModel.instance.curSelectMat)
						return;
					
					//var result:Object = JSON.parse(data as String);
					//if(!result.hasOwnProperty("status"))
					//{
						//PaintOrderModel.instance.curSelectProcList = result as Array;
						//arr[0].selected = true;
						//arr[0].initProcFlow(result);
						//onClickMat(parentitem,processCatvo);
						//var materials:Vector.<MaterialItemVo> = arr[0].nextMatList;
						PaintOrderModel.instance.curSelectProcList = [];
						var materials:Array = matvo.procTreeList;
						
						for(var i:int=0;i < materials.length;i++)
						{
							//var tcvo:TechMainVo = new TechMainVo();
							var itembox:TechBoxItem = new TechBoxItem();
							itembox.setData(materials[i]);
							itembox.on(Event.CLICK,this,onClickMat,[itembox,materials[i]]);		
							
							itembox.x = startposx;
							
							itembox.y = startpos;
							startpos += itembox.height + itemspaceV;
							this.uiSkin.techcontent.addChild(itembox);
							firstTechlist.push(itembox);
							hasShowItemList.push(itembox);
						}
						
					//}
					
				//},null,null);
			}
			
			
			
			//this.uiSkin.btnok.on(Event.CLICK,this,onConfirmTech);
			//this.uiSkin.btncancel.on(Event.CLICK,this,onCloseView);
			allitemlist = [];
			
			//(uiSkin.main_panel).height = Browser.height;
			
		}
		
		private function drawCurves(a:TechBoxItem,b:TechBoxItem):void
		{
			var sp:Sprite = new Sprite();
			this.uiSkin.techcontent.addChild(sp);
			
			var endy = b.y - a.y;
			
			sp.graphics.drawLine(0, a.y + 0.5 * itemheight, itemspaceH*0.5, a.y + 0.5 * itemheight,"#ff4400", 1);
			
			sp.graphics.drawLine( itemspaceH*0.5, a.y + 0.5 * itemheight, itemspaceH*0.5, b.y + 0.5 * itemheight,"#ff4400", 1);
			
			sp.graphics.drawLine( itemspaceH*0.5, b.y + 0.5 * itemheight,itemspaceH, b.y + 0.5 * itemheight,"#ff4400", 1);


			//sp.graphics.drawCurves(0, a.y + 0.5 * itemheight, [0, 0, 0.4*itemspaceH, 0.8 * endy,itemspaceH,endy], "#ff4400", 1);
			sp.x =a.x + a.width;
			
			linelist.push(sp);
		}
		
		private function onGetProFlowt(parentitem:TechBoxItem,processCatvo:ProcessCatVo):void
		{
			var manufacturecode = PaintOrderModel.instance.curSelectMat.manufacturerCode;
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProcessFlow + manufacturecode + "&procCat_name=" + processCatvo.procCat_Name,this,function(data:Object):void{
				if(uiSkin.destroyed)
					return;
				
				var result:Object = JSON.parse(data as String);
				if(!result.hasOwnProperty("status"))
				{
					PaintOrderModel.instance.curSelectProcList = result as Array;
					processCatvo.initProcFlow(result);
					onClickMat(parentitem,processCatvo);
				}
				
			},null,null);
		}
		private function onClickMat(parentitem:TechBoxItem,matvo:Object):void
		{
			
			if(matvo.nextMatList == null && matvo is ProcessCatVo)
			{
				onGetProFlowt(parentitem, matvo as ProcessCatVo);
				
				return;
			}
			
			if(matvo is MaterialItemVo && OrderConstant.yiXingCutProcess((matvo as MaterialItemVo).procCode))
			{
				if(!PaintOrderModel.instance.checkCanSelYixing())
				{
					ViewManager.showAlert("图片未关联异形切割图片或者关联的异形切割图片不符合下单要求，请重新关联异形切割图片");
					return;
				}
			}
			if(matvo is MaterialItemVo && OrderConstant.backSideUnSame((matvo as MaterialItemVo).procCode))
			{
				if(!PaintOrderModel.instance.checkCanDoubleSide())
				{
					ViewManager.showAlert("图片未关联反面图片，请关联后再下单");
					return;
				}
			}
			if(matvo is MaterialItemVo && OrderConstant.whitePartProcess((matvo as MaterialItemVo).procCode))
			{
				if(!PaintOrderModel.instance.checkCanPartWhite())
				{
					ViewManager.showAlert("图片未关联局部铺白图片，请关联后再下单");
					return;
				}
			}
			
			hasFinishAllFlow = false;

			for(var i:int=0;i < hasShowItemList.length;i++)
			{
				hasShowItemList[i].stopshine();
			}
			curclickItem = parentitem;

			if(parentitem.isSelected)
			{
				//hideItems(parentitem.x,true);
				refreshHashowItem(parentitem.techmainvo,parentitem.x);
				updateSelectedTech();
				
			}
			
			
			if(!hasShowNextMaterial(matvo as MaterialItemVo))
			{
				hideItems(parentitem.x,true);
			}
			
			parentitem.setSelected(true);
			parentitem.setTechSelected(true);
			
			
			showNextMaterialItems(parentitem);
			

			if(UtilTool.needChooseAttachPic(matvo as MaterialItemVo))
			{
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_PIC_TO_ORDER,false,matvo);
			}


			if(matvo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN) >=0 || matvo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT) >=0)
				ViewManager.instance.openView(ViewManager.VIEW_SELECT_ATTACH,false,matvo);			
			else if(matvo.attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0)
				ViewManager.instance.openView(ViewManager.INPUT_CUT_NUM,false,false);
			
			else if(matvo.attachmentList.indexOf(OrderConstant.AVERAGE_CUTOFF) >=0)
				ViewManager.instance.openView(ViewManager.AVG_CUT_VIEW,false,matvo);
			else if(matvo.attachmentList.indexOf(OrderConstant.FEIBIAO_DAKOU) >=0)
				ViewManager.instance.openView(ViewManager.VIEW_DAKOU_PANEL,false,matvo);
			

			updateSelectedTech();
		}
		
		private function showNextMaterialItems(parentitem:TechBoxItem):void
		{
			var matvo:MaterialItemVo = parentitem.techmainvo;
			if(matvo == null)
				return;
			
			if(matvo.nextMatList && matvo.nextMatList.length > 0 && !hasShowNextMaterial(matvo as MaterialItemVo))
			{
				var arr:Vector.<MaterialItemVo> = matvo.nextMatList;
				var startpos:int = parentitem.y + 0.5 * itemheight - (arr.length*itemheight +  itemspaceV * (arr.length - 1))/2;
				if(startpos < 0)
					startpos = 0;
				var starpox:int = parentitem.x + parentitem.width + itemspaceH;
				for(var i:int=0;i < arr.length;i++)
				{
					//var tcvo:TechMainVo = new TechMainVo();
					var itembox:TechBoxItem = getItembox();
					itembox.setData(arr[i]);
					hasShowItemList.push(itembox);
					itembox.on(Event.CLICK,this,onClickMat,[itembox,arr[i]]);		
					
					//if(curclickItem.techmainvo.nextProcRequired || arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V ) >=0 )
					if((arr[i].parentMaterialVo != null && arr[i].parentMaterialVo.nextProcRequired) || arr[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V ) >=0 )
					{
						itembox.startshine();
					}
					else
						itembox.stopshine();
					
					
					itembox.x = starpox;
					
					itembox.y = startpos;
					
					drawCurves(parentitem,itembox);
					
					startpos += itembox.height + itemspaceV;
					this.uiSkin.techcontent.addChild(itembox);
				}
				
				if(itembox != null && (itembox.x + itembox.width) > uiSkin.techcontent.width)
				{
					this.uiSkin.techcontent.hScrollBar.hide = false;
					Laya.timer.frameOnce(2,this,function(){
						this.uiSkin.techcontent.scrollTo(itembox.x + itembox.width,this.uiSkin.techcontent.vScrollBar.value);
					});
				}
				else
					this.uiSkin.techcontent.hScrollBar.visible = false;
				
				
				if(itembox != null && (itembox.y + itembox.height) > uiSkin.techcontent.height)
				{
					this.uiSkin.techcontent.vScrollBar.hide = false;
					
					Laya.timer.frameOnce(2,this,function(){
						this.uiSkin.techcontent.scrollTo(this.uiSkin.techcontent.hScrollBar.value,itembox.y + itembox.height);
					});
				}
				else if(itembox != null && itembox.y < 0 )
				{
					this.uiSkin.techcontent.vScrollBar.hide = false;
					
					Laya.timer.frameOnce(2,this,function(){
						this.uiSkin.techcontent.scrollTo(this.uiSkin.techcontent.hScrollBar.value,itembox.y);
					});
				}
				else
					this.uiSkin.techcontent.vScrollBar.visible = false;
				
			}
				
			else
			{
				hasFinishAllFlow = true;
			}
		}
		private function hasShowNextMaterial(matvo:MaterialItemVo):Boolean
		{
			var nextmat:Vector.<MaterialItemVo> = matvo.nextMatList;
			if(nextmat != null)
			{
				for(var i:int=0;i < hasShowItemList.length;i++)
				{
					if((hasShowItemList[i] as TechBoxItem).techmainvo == nextmat[0])
						return true;
				}
			}
			
			return false;
		}
		
		private function onClickAttach(parentitem:TechBoxItem,attachvo:AttchCatVo):void
		{
			if(parentitem.isSelected)
				hideItems(parentitem.x,true);
			else if(firstTechlist.indexOf(parentitem) >= 0)
				hideItems(parentitem.x,false);
			else
				hideItems(parentitem.x,true);
			
			
			if(parentitem.isSelected)
			{
				parentitem.setSelected(false);
				parentitem.setTechSelected(false);
				if(firstTechlist.indexOf(parentitem) >= 0)
					cancelTech(parentitem.processCatVo.nextMatList);
				updateSelectedTech();
				
				return;
				
			}
			parentitem.setSelected(true);
			//attachvo.materialItemVo.selectAttachVo = attachvo;
			updateSelectedTech();

			hideItems(firstTechlist[0].x,false,true);
		}
		private function hideItems(curposx:Number,changedata:Boolean,finishselectTech:Boolean = false):void
		{
			for(var i:int=0;i < hasShowItemList.length;i++)
			{
				if(hasShowItemList[i].x > curposx)
				{
					hasShowItemList[i].removeSelf();
					hasShowItemList[i].setSelected(false);
					if(changedata && hasShowItemList[i].techmainvo != null)
						hasShowItemList[i].techmainvo.selected = false;
					allitemlist.push(hasShowItemList[i]);
					(hasShowItemList[i] as TechBoxItem).offAll();
					hasShowItemList.splice(i,1);
					i--;
				}
				else if(hasShowItemList[i].x == curposx)
				{
					if(!finishselectTech)
					hasShowItemList[i].setSelected(false);
					if(changedata && hasShowItemList[i].techmainvo != null)
						hasShowItemList[i].techmainvo.selected = false;

				}
			}
			
			for(var i:int=0;i < linelist.length;i++)
			{
				if(linelist[i].x > curposx)
				{
					linelist[i].graphics.clear(true);
					linelist[i].removeSelf();				
					linelist.splice(i,1);
					i--;
				}
			}
			
		}
		
		private function refreshHashowItem(matvo:MaterialItemVo,curposx:Number):void
		{
			for(var i:int=0;i < hasShowItemList.length;i++)
			{
				if(hasShowItemList[i].x > curposx)
				{
					hasShowItemList[i].setSelected(false);
					
					if(hasShowItemList[i].techmainvo != null)
					{
						hasShowItemList[i].techmainvo.selected = false;			
						if(hasShowItemList[i].techmainvo.attachmentList.indexOf(OrderConstant.FEIBIAO_DAKOU) >= 0)
						{
							if(PaintOrderModel.instance.curSelectOrderItem != null)
								PaintOrderModel.instance.curSelectOrderItem.ordervo.holeList = [];
							else if(PaintOrderModel.instance.batchChangeMatItems != null)
							{
								for(var i:int=0;i < PaintOrderModel.instance.batchChangeMatItems.length;i++)
								{
									PaintOrderModel.instance.batchChangeMatItems[i].ordervo.holeList = [];
								}
							}
						}
						
					}						
					if(matvo.nextMatList.indexOf(hasShowItemList[i].techmainvo) < 0)
					{
						hasShowItemList[i].removeSelf();
						
						allitemlist.push(hasShowItemList[i]);
						(hasShowItemList[i] as TechBoxItem).offAll();
						hasShowItemList.splice(i,1);
						i--;
					}
					else
					{
						if(hasShowItemList[i].techmainvo.parentMaterialVo != null && hasShowItemList[i].techmainvo.parentMaterialVo.nextProcRequired)
						{
							hasShowItemList[i].startshine();
						}
					}
				}
				
			}
			
			for(var i:int=0;i < linelist.length;i++)
			{
				if(linelist[i].x > curposx + itemspaceH + 140)
				{
					linelist[i].graphics.clear(true);
					linelist[i].removeSelf();				
					linelist.splice(i,1);
					i--;
				}
			}
		}
		private function updateSelectedTech():void
		{
			
			this.uiSkin.selecttech.text = PaintOrderModel.instance.curSelectMat.getTechDes(true);
			checkShowEffectImg();
		}
		
		private function cancelTech(arr:Vector.<MaterialItemVo>):void
		{
			//var arr:Vector.<MaterialItemVo> = matvo.nextMatList;
			if(arr)
			{
				for(var i:int=0;i < arr.length;i++)
				{
					arr[i].selected = false;
					cancelTech(arr[i].nextMatList);
				}
			}
		}
		
		private function onCancaleChooseAttach(matvo:MaterialItemVo):void
		{
			if(curclickItem != null)
			{
				hideItems(curclickItem.x,true);
				updateSelectedTech();
			}
		}
		
		private function checkShowEffectImg():void
		{
			if(param == null)
				return;
			
			if(PaintOrderModel.instance.batchChangeMatItems != null && PaintOrderModel.instance.batchChangeMatItems.length > 0)
			{
				return;
			}
			var hasSelectedTech:Array = PaintOrderModel.instance.curSelectMat.getAllSelectedTech();
			var doublesideImg:String = "";
			var yixingqiegeImg:String = "";
			var doublesame:Boolean = false;
			for(var i:int=0;i < hasSelectedTech.length;i++)
			{
				if(hasSelectedTech[i].procCode == OrderConstant.DOUBLE_SIDE_SAME_TECHNO || hasSelectedTech[i].procCode == OrderConstant.DOUBLE_SIDE_SAME_TECHNO_UV )
				{
					doublesame = true;
				}
				else if(OrderConstant.backSideUnSame(hasSelectedTech[i].procCode))
				{
					doublesideImg = PaintOrderModel.instance.curSelectOrderItem.ordervo.picinfo.backFid; //hasSelectedTech[i].attchFileId;

				}
				else if(OrderConstant.yiXingCutProcess(hasSelectedTech[i].procCode))
				{
					yixingqiegeImg = PaintOrderModel.instance.curSelectOrderItem.ordervo.picinfo.yixingFid; //hasSelectedTech[i].attchFileId;
				}
			}
			
			uiSkin.backimg.visible = doublesideImg != "" || doublesame;
			
			uiSkin.yingxBack.visible = (doublesideImg != "" || doublesame) && yixingqiegeImg != "";
			//uiSkin.backimg.visible = doublesideImg != "" || doublesame;

			if(doublesideImg != "")
			{
				//uiSkin.originimg.skin = HttpRequestUtil.biggerPicUrl + param.fid + ".jpg";				
				uiSkin.backimg.skin = HttpRequestUtil.biggerPicUrl +doublesideImg + ".jpg";	
			}
			if(doublesame)
			{
				//uiSkin.originimg.skin = HttpRequestUtil.biggerPicUrl + param.fid + ".jpg";				
				uiSkin.backimg.skin = HttpRequestUtil.biggerPicUrl +param.fid + ".jpg";	
			}
			//uiSkin.originimg.visible = yixingqiegeImg != "";
			uiSkin.yixingimg.visible = yixingqiegeImg != "";
			
			if(yixingqiegeImg != "")
			{
				//uiSkin.originimg.skin = HttpRequestUtil.biggerPicUrl + param.fid + ".jpg";		
				uiSkin.yixingimg.skin = HttpRequestUtil.biggerPicUrl +yixingqiegeImg + ".jpg";	
							
				if(uiSkin.yingxBack.visible)
				{
					uiSkin.yingxBack.skin = HttpRequestUtil.biggerPicUrl +yixingqiegeImg + ".jpg";	
					
				}

			}
		}
		private function getItembox():TechBoxItem
		{
			if(allitemlist.length > 0)
			{
				return allitemlist.splice(0,1)[0];
			}
				
			else
			{
				var itembox:TechBoxItem = new TechBoxItem();
				return itembox;
			}
		}
		private function onConfirmTech():void
		{
			if(!hasFinishAllFlow)
			{
				//ViewManager.showAlert("未选择完整工艺");
				//return;
			}
			if(PaintOrderModel.instance.curSelectMat == null || PaintOrderModel.instance.curSelectMat.getTechDes(true) == "")
			{
				ViewManager.showAlert("请选择一个工艺");
				return;

			}
			
			if(curclickItem.techmainvo.nextProcRequired && (curclickItem.techmainvo.nextMatList.length > 0 && curclickItem.techmainvo.nextMatList[0].parentMaterialVo ==  curclickItem.techmainvo))
			{
				ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"后置工艺必须选一个"});
				return;
			}
			
			var hasSelectedTech:Array = PaintOrderModel.instance.curSelectMat.getAllSelectedTech();
			var picOrderItem:PicOrderItem = PaintOrderModel.instance.curSelectOrderItem;
			if(picOrderItem == null)
				picOrderItem= PaintOrderModel.instance.batchChangeMatItems[0];
			
			for(var i:int=0;i < hasSelectedTech.length;i++)
			{
				if(hasSelectedTech[i].attachmentList.indexOf(OrderConstant.FEIBIAO_DAKOU) >= 0)
				{
					if(picOrderItem != null && picOrderItem.ordervo.holeList.length == 0)
					{
						ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"非标打扣工艺未设置打孔信息，请重新设置"});

						return ;
					}
				}
			}
			if(hasSelectedTech.length > 0 && hasSelectedTech[hasSelectedTech.length - 1].is_mandatory)
			{
				if(hasSelectedTech[hasSelectedTech.length - 1].nextMatList.length > 0 && hasSelectedTech[hasSelectedTech.length - 1].nextMatList[0].parentMaterialVo == hasSelectedTech[hasSelectedTech.length - 1])
				{
					ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"后置工艺必须选一个"});
					return;

				}
			}
			
			
			for(var i:int=0;i < hasSelectedTech.length;i++)
			{
				if(hasSelectedTech[i].attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN) >=0 || hasSelectedTech[i].attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT))
				{
					if(hasSelectedTech[i].selectAttachVoList == null || hasSelectedTech[i].selectAttachVoList.length == 0 )
					{
						ViewManager.showAlert("未选择配件");
						return;
					}
				}
			}
			
			var nextmatlist:Vector.<MaterialItemVo> = curclickItem.techmainvo.nextMatList;
			if(nextmatlist != null && nextmatlist.length == 1)
			{
				for(var i:int=0;i < nextmatlist.length;i++)
				{
					if(nextmatlist[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >=0)
					{
						ViewManager.showAlert("当前有必选工艺，请选择");
						return;
					}
					else if(nextmatlist[i].showType == ConstraintTool.RESULT_VALUE_SELETED)
					{
						ViewManager.showAlert("当前有必选工艺，请选择");
						return;
					}
				}
			}
			
			PaintOrderModel.instance.curSelectMat.getProductDiscount(updatePicOrderProduct,this);

			
		}
		private function updatePicOrderProduct():void
		{
			if(PaintOrderModel.instance.curSelectOrderItem)
				PaintOrderModel.instance.curSelectOrderItem.changeProduct(PaintOrderModel.instance.curSelectMat);
			else if(PaintOrderModel.instance.batchChangeMatItems && PaintOrderModel.instance.batchChangeMatItems.length > 0)
			{
				for(var i:int=0;i < PaintOrderModel.instance.batchChangeMatItems.length;i++)
					PaintOrderModel.instance.batchChangeMatItems[i].changeProduct(PaintOrderModel.instance.curSelectMat);
			}
			
			EventCenter.instance.event(EventCenter.UPDATE_ORDER_ITEM_TECH);
			
			onCloseView();
		}
		private function onUpdateTechDes(viewname:String):void
		{
			if(viewname == ViewManager.VIEW_SELECT_ATTACH && curclickItem != null && curclickItem.techmainvo != null)
			{
				if(curclickItem.techmainvo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN) >=0 || curclickItem.techmainvo.attachmentList.indexOf(OrderConstant.ATTACH_PEIJIAN_MAT) >=0)
				{
					if(curclickItem.techmainvo.attachList == null || curclickItem.techmainvo.attachList.length == 0)
					{
						hideItems(curclickItem.x,true);
					}
					else
						updateNextMaterialItems();
				}
				updateSelectedTech();
				
			}
		}
		
		private function updateNextMaterialItems():void
		{
			
			var nextmat:Vector.<MaterialItemVo> = curclickItem.techmainvo.nextMatList;
			if(nextmat != null)
			{
				for(var i:int=0;i < hasShowItemList.length;i++)
				{
					var index:int = nextmat.indexOf((hasShowItemList[i] as TechBoxItem).techmainvo);
					
					if(index >= 0)
					{
						hasShowItemList[i].updateState();
					}
				}
			}
						
		}
		

		private function onCloseView():void
		{
			// TODO Auto Generated method stub
			ViewManager.instance.closeView(ViewManager.VIEW_SELECT_MATERIAL);
		}
		
		public override function onDestroy():void
		{
			EventCenter.instance.off(EventCenter.BROWER_WINDOW_RESIZE,this,onResizeBrower);
			EventCenter.instance.off(EventCenter.SHOW_SELECT_TECH,this,initTechView);
			EventCenter.instance.off(EventCenter.CLOSE_PANEL_VIEW,this,onUpdateTechDes);
			EventCenter.instance.off(EventCenter.CLOSE_PANEL_VIEW,this,checkShowEffectImg);
			EventCenter.instance.off(EventCenter.CANCEL_CHOOSE_ATTACH,this,onCancaleChooseAttach);

		}
	}
}