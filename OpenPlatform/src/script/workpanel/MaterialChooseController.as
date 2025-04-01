package script.workpanel
{
	import laya.components.Script;
	import laya.events.Event;
	import laya.utils.Handler;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.orderModel.AttchCatVo;
	import model.orderModel.MatetialClassVo;
	import model.orderModel.PaintOrderModel;
	import model.orderModel.ProductVo;
	
	import script.order.MaterialItem;
	import script.workpanel.items.MaterialCategoryCell;
	import script.workpanel.items.MaterialCell;
	
	import ui.inuoView.MaterialListPanelUI;
	import ui.order.MaterialNameItemUI;
	
	public class MaterialChooseController extends Script
	{
		private var uiSkin:MaterialListPanelUI;
		
		private var matCategoryItems:Array;
		
		private var materialItems:Array;

		
		private var categotySpaceX:int = 5;
		
		private var categotySpaceY:int = 5;
		
		private var matItemSpaceX:int = 10;
		
		private var matItemSpaceY:int = 36;
		

		public function MaterialChooseController()
		{
			super();
		}
		
		override public function onStart():void
		{
			
			uiSkin = this.owner as MaterialListPanelUI; 
			
			
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
			initMaterialCategory(temp);
//			Laya.timer.frameOnce(5,this,function(){
//				uiSkin.tablist.array = temp;
//
//			if(PaintOrderModel.instance.productList && PaintOrderModel.instance.productList.length > 0)
//				{
//					uiSkin.tablist.selectedIndex = 0;
//					//onSlecteMatClass(0);
//					(uiSkin.tablist.cells[0] as MaterialCategoryCell).ShowSelected = true;
//				}
//			});
			
		}
		private function initMaterialCategory(categotyList:Array):void
		{
			matCategoryItems = [];
			var startY:int = 0;
			
			for(var i:int=0;i < categotyList.length;i++)
			{
				var matCatItem:MaterialCategoryCell = new MaterialCategoryCell();
				matCatItem.setData(categotyList[i]);
				uiSkin.tabpanel.addChild(matCatItem);
				matCatItem.selbtn.on(Event.CLICK,this,onSlecteMatClass,[categotyList[i],i]);
				if(i==0)
				{
					matCatItem.x = 0;
					matCatItem.y = 0;
				}
				else
				{
					if((matCatItem.width + matCategoryItems[i - 1].x + matCategoryItems[i - 1].width  + categotySpaceX ) > uiSkin.tabpanel.width)
					{
						matCatItem.x = 0;
						startY += matCatItem.height + categotySpaceY;
						matCatItem.y = startY;
						
					}
					else
					{
						matCatItem.x =  matCategoryItems[i - 1].x + matCategoryItems[i - 1].width + categotySpaceX;
						matCatItem.y = startY;

					}
				}
				
				matCategoryItems.push(matCatItem);
			}
			
			if(categotyList.length > 0)
			{
				onSlecteMatClass(categotyList[0],0);
			}
		}
		
		private function onSlecteMatClass(matclassvo:MatetialClassVo,index:int):void
		{
			for each(var item:MaterialCategoryCell in matCategoryItems)
			{
				item.selbtn.selected = false;
			}
			matCategoryItems[index].selbtn.selected = true;
			
			refreshMatList(matclassvo);
		}
		
		
		
		
		private function refreshMatList(matvo:MatetialClassVo ):void
		{
			//var matvo:MatetialClassVo = uiSkin.tablist.array[index] as MatetialClassVo;
			if(matvo.childMatList != null)
			{
				var matlist:Array =matvo.childMatList;
				refreshMatItems(matlist);

				//uiSkin.matlist.array = matlist;
			}
			else
			{
				var selectoutputCenters:Array = PaintOrderModel.instance.getSelectedOutPutCenter();
				
				HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getProdListNew + PaintOrderModel.instance.selectAddress.zoneid + "&prodCatName=" + matvo.matclassname + "&manufacturerCodeList=" + selectoutputCenters.toString() + "&customerCode=" + Userdata.instance.founderPhone+ "&clientCode=" + Userdata.instance.clientCode+ "&orderSource=" + PaintOrderModel.instance.orderType,this,function(data:String){
					
					if(this.destroyed)
						return;
					
					var result:Object = JSON.parse(data as String);
					if(!result.hasOwnProperty("status"))
					{
						matvo.childMatList = [];
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
							
						}
						for(var mate in allmaterial)
							matvo.childMatList.push(allmaterial[mate]);
						matvo.childMatList.sort(sortMaterial);
						
						matvo.childMatList = matvo.childMatList.concat(matvo.childCategoryList);
						refreshMatItems(matvo.childMatList);
						//if(uiSkin.tablist.selectedIndex == index)
						//	uiSkin.matlist.array = matvo.childMatList;
					}
					
					
				},null,null);
			}
			
			
			
		}
		
		private function refreshMatItems(materialList:Array):void
		{
			materialItems = [];
			var startY:int = 0;
			
			while(uiSkin.matpanel.numChildren > 0)
				uiSkin.matpanel.removeChildAt(0);
			
			for(var i:int=0;i < materialList.length;i++)
			{
				var materialItem:MaterialItem = new MaterialItem();
				materialItem.setData(materialList[i]);
				uiSkin.matpanel.addChild(materialItem);
				//materialItem.selbtn.on(Event.CLICK,this,onSlecteMatClass,[materialList[i],i]);
				if(i==0)
				{
					materialItem.x = 0;
					materialItem.y = 0;
				}
				else
				{
					if((materialItem.width + materialItems[i - 1].x  +  materialItems[i - 1].width + matItemSpaceX ) > uiSkin.matpanel.width)
					{
						materialItem.x = 0;
						startY += materialItem.height + matItemSpaceY;
						materialItem.y = startY;
						
					}
					else
					{
						materialItem.x =  materialItems[i - 1].x +  materialItems[i - 1].width + matItemSpaceX;
						materialItem.y = startY;
						
					}
				}
				
				materialItems.push(materialItem);
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
		
		
	}
}