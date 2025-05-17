package model.orderModel
{
	import laya.maths.MathUtil;
	
	import model.HttpRequestUtil;
	import model.Userdata;
	import model.picmanagerModel.PicInfoVo;
	import model.users.AddressVo;
	import model.users.CityAreaVo;
	import model.users.CustomVo;
	import model.users.FactoryInfoVo;
	
	import script.ViewManager;
	import script.carving.CarvingOrderItemCell;
	import script.order.MaterialItem;
	import script.order.PicOrderItem;
	
	import utils.TimeManager;
	import utils.UtilTool;
	
	public class PaintOrderModel
	{
		private static var _instance:PaintOrderModel;
		public static function get instance():PaintOrderModel
		{
			if(_instance == null)
				_instance = new PaintOrderModel();
			return _instance;
		}
		
		public var curSelectOrderItem:PicOrderItem;
		public var curSelectCarvingItem:CarvingOrderItemCell;
		
		public var selectAddress:AddressVo;//当前选择的收获地址
		
		public var selectFactoryAddress:Array; //当前选中的输出中心 可 多个
		
		public var selectFactoryInMat:FactoryInfoVo; //选中工艺的时候 当前选中的输出中心 
		
		public var curSelectPic:PicInfoVo;
		
		public var curSelectMat:ProductVo;
		
		public var outPutAddr:Array;
		
		public var productList:Array;//产品材料 列表
		
		public var deliveryList:Object;//配送方式列表
		
		public var selectDelivery:DeliveryTypeVo;//选择的配送方式
		
		public var curSelectProcList:Array;
		
		//public var batchChangeMatItems:Vector.<PicOrderItem>;
		public var batchChangeMatItems:Array;

		public var packageList:Array;
		//public var orderPackageData:Object;
		
		public var finalOrderData:Array;//最终下单数据
		
		public var allManuFacutreMatProcPrice:Object = {};
		
		public var availableDeliveryDates:Object = {};
		
		public var orderType:String;//当前下单类型 
		
		public var curTimePrefer:int = 0;//当前选择的交付策略
		
		public var curCommmonDeliveryType:Object ;//当前选择的普通配送方式
		public var curUrgentDeliveryType:Object;//当前选择的加急配送方式
		
		public var currentDayStr:String = "";
		
		public var batchOrders:Object = {};
		
		public var dynamicDeliveryFeeCfg:Object;
		
		public var productDisount:Object;
		
		public var rawPrice:String = "0";//订单原价
		
		public var tempPicOrderItemVoList:Vector.<PicOrderItemVo>;
		
		public var curOrderCustomer:CustomVo;//当前代客下单客户
				
		public function PaintOrderModel()
		{
			
		}
		
		public function resetData():void
		{
			selectAddress = null;
			selectFactoryAddress = null;
			curSelectMat = null;
			outPutAddr = null;
			productList = null;
			deliveryList = null;
			selectDelivery = null;	
			allManuFacutreMatProcPrice = {};
			packageList = [];
			finalOrderData = [];
			availableDeliveryDates = {};
			dynamicDeliveryFeeCfg = null;
			productDisount = null;
			batchOrders = {};
			PaintOrderModel.instance.rawPrice = "0";
			tempPicOrderItemVoList = new Vector.<PicOrderItemVo>();
			curOrderCustomer = null;
		}
		public function initOutputAddr(addrobj:Array):void
		{
			outPutAddr = [];
			for(var i:int=0;i < addrobj.length;i++)
			{
				var addvo:FactoryInfoVo = new FactoryInfoVo(addrobj[i]);
				outPutAddr.push(addvo);
			}
			
			outPutAddr.sort(function(a:FactoryInfoVo,b:FactoryInfoVo){
				
				var apri:int = parseInt(a.manu_priority.toString());
				var bpri:int = parseInt(b.manu_priority.toString());
				return apri - bpri;
				
			}
			);
			
		}
		
		public function getContactPhone(manuFactoryCode:String):String
		{
			for(var i:int=0;i < outPutAddr.length;i++)
			{
				if(outPutAddr[i].org_code == manuFactoryCode)
					return outPutAddr[i].contact_phone;
				
			}
			
			return "";
			
		}
		
		public function getManufactureCodeList():Array
		{
			var list:Array = [];
			for(var i:int=0;i < outPutAddr.length;i++)
			{
				list.push(outPutAddr[i].org_code)
				
			}
			
			return list;
		}
		
		public function getProcDataByProcName(procName:String):Object
		{
			if(curSelectProcList == null)
				return null;
			for(var i:int=0;i < curSelectProcList.length;i++)
			{
				if(curSelectProcList[i].preProc_Name == procName)
					return curSelectProcList[i];
			}
			
			return null;
		}
		
		public function initManuFacuturePrice(orgcode:String,dataStr:*):void
		{
			try
			{
				allManuFacutreMatProcPrice[orgcode] = JSON.parse(dataStr);
				if(allManuFacutreMatProcPrice[orgcode].code != null)
				{
					ViewManager.showAlert("获取生产商工艺价格出错！");
					ViewManager.instance.openView(ViewManager.VIEW_FIRST_PAGE,true);
					return;
				}
				//var arr:Array = allManuFacutreMatProcPrice[orgcode];
				//				for(var i:int=0;i < arr.length;i++)
				//				{
				//					var matlist:Array = arr[i].mat_list;
				//					arr[i].matlist = {};
				//					for(var j:int=0;j < matlist.length;j++)
				//					{
				//						arr[i].matlist[matlist[j].mat_code] = matlist[j];
				//					}
				//				}
			}
			catch(err:Error)
			{
				ViewManager.showAlert("获取生产商材料工艺价格失败");
			}
			
		}
		
		public function getSelectedOutPutCenter():Array
		{
			if(this.outPutAddr == null || this.outPutAddr.length == 0)
				return [];
			
			var selfatCode:Array = [];
			for(var i:int=0;i < outPutAddr.length;i++)
			{
				if(outPutAddr[i].isSelected)
				{
					selfatCode.push(outPutAddr[i].org_code);
				}
			}
			return selfatCode;
		}
		
		public function getProcePriceUnit(orgcode:String,procCode:String,matcode:String,attachVo:AttchCatVo,processList:Array):Array
		{
			if(allManuFacutreMatProcPrice == null || allManuFacutreMatProcPrice[orgcode] == null)
				return [];
			else
			{
				var list:Array = allManuFacutreMatProcPrice[orgcode];
				if(list == null)
					return [];
				
				if(OrderConstant.yiXingCutProcess(procCode))
					return getYixingProcPrice(orgcode,procCode,matcode,processList);
				var reslutInfo:Array;
				for(var i:int=0;i < list.length;i++)
				{
					if(list[i].proc_code == procCode)
					{
						//if(list[i].matlist[matcode] != null)
						//	return [list[i].measure_unit,list[i].matlist[matcode].baseprice,list[i].matlist[matcode].unit_procprice];
						//else
						//	return [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice];
						if(list[i].mat_code == matcode)
						{
							reslutInfo = [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice,list[i].unit_grossmargin];
							break;
						}
					}
				}
				if(attachVo != null)
				{
					for(var i:int=0;i < list.length;i++)
					{
						if(list[i].proc_code == procCode)
						{
							
							if(list[i].mat_code == attachVo.accessory_code)
							{
								if(reslutInfo == null || list[i].unit_procprice > reslutInfo[2])
									reslutInfo = [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice,list[i].unit_grossmargin];
								break;
							}
						}
					}
				}
				
				if(reslutInfo != null)
					return reslutInfo;
				
				for(var i:int=0;i < list.length;i++)
				{
					if(list[i].proc_code == procCode && list[i].mat_code == "")
					{		
						reslutInfo = [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice,list[i].unit_grossmargin];
						break;
					}
				}
				
				return reslutInfo || [];
			}
		}
		
		//获取工艺材料价格数据
		public function getProdProceessDate(orgcode:String,procCode:String):Object
		{
			if(allManuFacutreMatProcPrice == null || allManuFacutreMatProcPrice[orgcode] == null)
				return null;
			else
			{
				var list:Array = allManuFacutreMatProcPrice[orgcode];
				if(list == null)
					return null;
				
				
				for(var i:int=0;i < list.length;i++)
				{
					if(list[i].proc_code == procCode)
					{
						
						return list[i];
					}
				}
			}
			
			return null;
		}
		
		public function getCapacityData(orgcode:String,procCode:String,matcode:String):Array
		{
			if(allManuFacutreMatProcPrice == null || allManuFacutreMatProcPrice[orgcode] == null)
				return [];
			else
			{
				var list:Array = allManuFacutreMatProcPrice[orgcode];
				if(list == null)
					return [0,0,0];
				
				
				for(var i:int=0;i < list.length;i++)
				{
					if(list[i].proc_code == procCode && list[i].mat_code == matcode)
					{
						//						if(list[i].matlist[matcode] != null)
						//							return [list[i].cap_unit,list[i].matlist[matcode].unit_capacity,list[i].matlist[matcode].unit_urgentcapacity];
						//						else
						return [list[i].cap_unit,list[i].unit_capacity,list[i].unit_urgentcapacity];
					}
				}
				for(var i:int=0;i < list.length;i++)
				{
					if(list[i].proc_code == procCode && list[i].mat_code == "")
					{
						//						if(list[i].matlist[matcode] != null)
						//							return [list[i].cap_unit,list[i].matlist[matcode].unit_capacity,list[i].matlist[matcode].unit_urgentcapacity];
						//						else
						return [list[i].cap_unit,list[i].unit_capacity,list[i].unit_urgentcapacity];
					}
				}
				return [0,0,0];
			}
		}
		
		//异形切割的工艺价格寻找加个最高的那个（根据选择的附件材料查找有没有对应的加个，再选择最高的价格)
		public function getYixingProcPrice(orgcode:String,procCode:String,matcode:String,processList:Array):Array
		{
			var allprice:Array = [];
			var hasselectMat:Array = [];
			hasselectMat.push(matcode);
			for(var i:int=0;i < processList.length;i++)
			{
				var attchvo:Vector.<AttchCatVo> = processList[i].selectAttachVoList;
				if(attchvo != null && attchvo.length > 0)
				{
					hasselectMat.push(attchvo[0].accessory_code);
				}
			}
			
			var list:Array = allManuFacutreMatProcPrice[orgcode];
			if(list == null)
				return [];
			for(var i:int=0;i < list.length;i++)
			{
				if(list[i].proc_code == procCode)
				{
					if(allprice.length == 0)
						allprice = [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice,list[i].unit_grossmargin];
					for(var j:int=0;j < hasselectMat.length;j++)
					{
						if(list[i].mat_code == hasselectMat[j]  && list[i].unit_procprice > allprice[2])
							allprice = [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice,list[i].unit_grossmargin];
						
					}
					if(list[i].mat_code == "" && list[i].unit_procprice > allprice[2])
					{
						allprice = [list[i].measure_unit,list[i].baseprice,list[i].unit_procprice,list[i].unit_grossmargin];
					}
					
				}
			}
			
			return allprice;
			
		}
		public static var VOCABURARY:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
		public static function getOrderSn():String
		{
			var sn:String = "";
			
			for(var i:int=0;i<20;i++)
			{
				var rnd:int = Math.round(Math.random() * VOCABURARY.length);
				sn += VOCABURARY.charAt(rnd);
			}
			return sn;
		}
		
		public function getManuFacturePriority(manufacCode:String):int
		{
			var manuFacList:Array = outPutAddr;
			if(manuFacList != null)
			{
				for(var i:int=0;i < manuFacList.length;i++)
				{
					if(manuFacList[i].org_code == manufacCode)
						return parseInt(manuFacList[i].manu_priority);
				}
			}
			
			return 0;
		}
		
		public function checkCanSelYixing():Boolean
		{
			var picitems:Vector.<PicOrderItem> = this.batchChangeMatItems;
			if(picitems != null && picitems.length > 0)
			{
				for(var i:int=0;i < picitems.length;i++)
				{
					var picinfo:PicInfoVo = picitems[i].ordervo.picinfo;
					//if(picinfo.relatedRoadNum <= 0 || picinfo.yixingFid == "0")
					if(picinfo.yixingFid == "0" || picinfo.yixingFid == "")
						return false;
				}
				return true;
			}
			else if(curSelectOrderItem != null && curSelectOrderItem.ordervo.picinfo.relatedRoadNum >= 0 && curSelectOrderItem.ordervo.picinfo.yixingFid != "0" && curSelectOrderItem.ordervo.picinfo.yixingFid != "")
				return true;
			
			return false;
		}
		
		public function checkCanDoubleSide():Boolean
		{
			var picitems:Vector.<PicOrderItem> = this.batchChangeMatItems;
			if(picitems != null && picitems.length > 0)
			{
				for(var i:int=0;i < picitems.length;i++)
				{
					var picinfo:PicInfoVo = picitems[i].ordervo.picinfo;
					if(picinfo.backFid == "0" || picinfo.backFid == "")
						return false;
				}
				return true;
			}
			else if(curSelectOrderItem != null && curSelectOrderItem.ordervo.picinfo.backFid != "0" && curSelectOrderItem.ordervo.picinfo.backFid != "")
				return true;
			
			return false;
		}
		
		public function checkCanPartWhite():Boolean
		{
			var picitems:Vector.<PicOrderItem> = this.batchChangeMatItems;
			if(picitems != null && picitems.length > 0)
			{
				for(var i:int=0;i < picitems.length;i++)
				{
					var picinfo:PicInfoVo = picitems[i].ordervo.picinfo;
					if(picinfo.partWhiteFid == "0" || picinfo.partWhiteFid == "")
						return false;
				}
				return true;
			}
			else if(curSelectOrderItem != null  && curSelectOrderItem.ordervo.picinfo.partWhiteFid != "0" && curSelectOrderItem.ordervo.picinfo.partWhiteFid != "")
				return true;
			
			return false;
		}
		
		
		//判断图片是否不符合等份裁切的尺寸要求
		public function checkIslongerForDfcq():Boolean
		{
			var vect:Vector.<PicOrderItem> = new Vector.<PicOrderItem>();
			if(this.curSelectOrderItem != null)
				vect.push(this.curSelectOrderItem);
			else
				vect = this.batchChangeMatItems;
			
			for(var i:int=0;i < vect.length;i++)
			{
				var minside:Number = Math.min(vect[i].finalWidth,vect[i].finalHeight);
				var longside:Number = Math.max(vect[i].finalWidth,vect[i].finalHeight);
				if(minside > OrderConstant.DFCQ_MAX_HEIGHT || longside > OrderConstant.DFCQ_MAX_WIDTH)
					return true;
				
			}
			
			return false;
		}
		
		//判断是否需要重新选择超幅拼接参数
		public function checkNeedReChooseCfpj():Boolean
		{
			var curprocesslst:Vector.<MaterialItemVo> = PaintOrderModel.instance.curSelectMat.getAllSelectedTech() as Vector.<MaterialItemVo>;
			var picorderitems:Vector.<PicOrderItem> = new Vector.<PicOrderItem>();
			if(PaintOrderModel._instance.curSelectOrderItem != null)
				picorderitems.push(PaintOrderModel._instance.curSelectOrderItem);
			else
				picorderitems = PaintOrderModel._instance.batchChangeMatItems;
			
			var hascfpj:Boolean = false;
			for(var i:int=0;i < curprocesslst.length;i++)
			{
				if(curprocesslst[i].attachmentList.indexOf(OrderConstant.CUTOFF_H_V) >= 0)
				{
					hascfpj = true;
					break;
				}
			}
			
			if(hascfpj)
			{
				for(var i:int=0;i < picorderitems.length;i++)
				{
					var cutlengths:Array = picorderitems[i].ordervo.eachCutLength;
					if(cutlengths != null)
					{
						for(var j:int=0;j < cutlengths.length;j++)
						{
							if(cutlengths[j] > OrderConstant.FUBAI_WOOD_MAX_WIDTH)
							{
								return true;
							}
						}
					}
				}
			}
			
			return false;
			
		}
		
		public function getCurPicOrderItems():Vector.<PicOrderItem>
		{
			var picorderitems:Vector.<PicOrderItem> = new Vector.<PicOrderItem>();
			if(PaintOrderModel._instance.curSelectOrderItem != null)
				picorderitems.push(PaintOrderModel._instance.curSelectOrderItem);
			else
				picorderitems = PaintOrderModel._instance.batchChangeMatItems;
			
			return picorderitems;
			
		}
		
		public function checkExceedMaterialSize(material:ProductVo):Boolean
		{
			
			var picorderitems:Vector.<PicOrderItem> = getCurPicOrderItems();
			if(picorderitems == null)
				return false;
			
			for(var i:int=0;i < picorderitems.length;i++)
			{
				var minside:Number = Math.min(picorderitems[i].finalWidth,picorderitems[i].finalHeight);
				var longside:Number = Math.max(picorderitems[i].finalWidth,picorderitems[i].finalHeight);
				
				if(minside > material.maxWidth || longside > material.maxLength)
					return true;
				
				if(minside < material.minWidth || longside < material.minLength)
					return true;
			}
			
			return false;
		}
		
		public function checkUnFitFileType(material:ProductVo,showtip:Boolean=true):Boolean
		{
			var picorderitems:Vector.<PicOrderItem> = getCurPicOrderItems();
			
			var limitwidth:Number = 0;
			if(material.prodCode == "MPR230402103702134") //切割字
			{
				
				for(var i:int=0;i < picorderitems.length;i++)
				{
					if(picorderitems[i].ordervo.picinfo.colorspace.toUpperCase() != "GRAY")
					{
						if(showtip)
						{
							ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG,false,{msg:"图片不符合切割字下单要求，必须是灰度图"});
						}
						return true;
						
					}
				}
			}
			if(material.prodCode == "SPPR60100" || material.prodCode == "SPPR60110")
			{
				if(material.prodCode == "SPPR60100")
					limitwidth = 42.5;
				else
					limitwidth = 52.5;
				
				for(var i:int=0;i < picorderitems.length;i++)
				{
					if(picorderitems[i].ordervo.picinfo.colorspace.toUpperCase() != "GRAY")
					{
						if(showtip)
						{
							ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG_WITH_PICTURE,false,{msg:"图片不符合条幅材料下单要求",picurl:"bigpic/tiaofutp.jpg"});
						}
						return true;
						
					}
					else if(picorderitems[i].ordervo.picinfo.iswhitebg == false)
					{
						if(showtip)
						{
							ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG_WITH_PICTURE,false,{msg:"图片不符合条幅材料下单要求",picurl:"bigpic/tiaofutp.jpg"});
						}
						return true;
					}
					else if(picorderitems[i].ordervo.picinfo.iswhitebg)
					{
						var finalwidth:Number = 0;
						if(picorderitems[i].ordervo.picinfo.picHeight > picorderitems[i].ordervo.picinfo.picWidth)
						{
							finalwidth = picorderitems[i].ordervo.picinfo.tiaofuwidth * picorderitems[i].finalWidth/picorderitems[i].ordervo.picinfo.picPhysicWidth;
						}
						else 
							finalwidth = picorderitems[i].ordervo.picinfo.tiaofuwidth * picorderitems[i].finalHeight/picorderitems[i].ordervo.picinfo.picPhysicHeight;
						
						if(finalwidth > limitwidth && showtip)
						{
							ViewManager.instance.openView(ViewManager.VIEW_POPUPDIALOG_WITH_PICTURE,false,{msg:"图片不符合条幅材料下单要求",picurl:"bigpic/tiaofutp.jpg"});
						}
						return finalwidth > limitwidth;
					}
				}
				
			}
			return false;
		}
		
		public function getManuFactureIndex(manucode:String):int
		{
			if(outPutAddr != null && outPutAddr.length > 0)
			{
				for(var i:int=0;i < outPutAddr.length;i++)
				{
					if(manucode == (outPutAddr[i] as FactoryInfoVo).org_code)
						return i;
				}
			}
			
			
			return 0;
		}
		
		public function hasExistAddress(id:int):Boolean
		{
			for(var i:int=0;i < this.packageList.length;i++)
			{
				if(this.packageList[i].address.id == id)
					return true;
			}
			return false;
		}
		public function addPackage(address:AddressVo,orderDatas:Array):void
		{
			if(packageList == null)
				packageList = [];
			
			var pack:PackageVo = new PackageVo();
			pack.packageName = "包裹" + (packageList.length+1);//address.addressDetail;
			pack.address = address;
			pack.itemlist = new Vector.<PackageItem>();
			for(var i:int=0;i < orderDatas.length;i++)
			{
				var packageItem:PackageItem = new PackageItem();
				packageItem.itemId = orderDatas[i].orderItemSn;
				if(packageList.length == 0)
					packageItem.itemCount = orderDatas[i].itemNumber;
				else
					packageItem.itemCount = 0;
				
				pack.itemlist.push(packageItem);
			}
			
			packageList.push(pack);
			
			//pack.itemlist = new 
		}
		public function getPackageVoByItemSn(itemsn:String):PackageVo
		{
			if(packageList == null)
				return null;
			for(var i:int=0;i < packageList.length;i++)
			{
				if(packageList[i].itemlist[0].itemId == itemsn)
					return packageList[i];
			}
			
			return null;
		}
		public function setPackageData():void
		{
			if(finalOrderData == null)
				return;
			
			for(var i:int=0;i < finalOrderData.length;i++)
			{
				finalOrderData[i].packageList = [];
				
				for(var j:int=0;j < packageList.length;j++)
				{
					
					var packdata:Object = {};
					packdata.package_name = packageList[j].packageName;
					packdata.consignee = "";
					packdata.tel = "";
					packdata.addr = "";
					packdata.itemList = [];
					for(var k:int=0;k < finalOrderData[i].orderItemList.length;k++)
					{
						if(finalOrderData[i].orderItemList[k].numlist[j] > 0)
						{
							var itemdata:Object = {};
							itemdata.orderItemSn = finalOrderData[i].orderItemList[k].orderItemSn;
							itemdata.count = finalOrderData[i].orderItemList[k].numlist[j];
							packdata.itemList.push(itemdata);
						}
					}
					
					finalOrderData[i].packageList.push(packdata);
					
				}
				for(var k:int=0;k < finalOrderData[i].orderItemList.length;k++)
				{
					
					delete finalOrderData[i].orderItemList[k].numlist;
				}
				
			}
			
			
		}
		
		public function setVipPackageData():Boolean
		{
			if(finalOrderData == null || finalOrderData.length == 0)
				return false;
			
			for(var i:int=0;i < finalOrderData.length;i++)
			{
				finalOrderData[i].packageList = [];
				
				for(var j:int=0;j < packageList.length;j++)
				{
					var packvo:PackageVo = packageList[j];
					
					var packdata:Object = {};
					packdata.packageName = packvo.packageName;
					if(packageList.length == 1)
					{
						if(curOrderCustomer != null && curOrderCustomer.id != "0")
							packdata.consignee =   curOrderCustomer.customerName + "#" + packvo.address.receiverName;
						else
							packdata.consignee =   Userdata.instance.companyShort + "#" + packvo.address.receiverName;
					}
					else
						packdata.consignee = packvo.address.receiverName;

					packdata.tel = packvo.address.phone;
					packdata.addr = packvo.address.proCityArea;
					packdata.addrId =  packvo.address.zoneid;
					packdata.shippingFee = 0;
					
					packdata.itemList = [];
					for(var k:int=0;k<packvo.itemlist.length;k++)
					{
						if(packvo.itemlist[k].itemCount > 0)
						{
							for(var m:int=0;m < finalOrderData[i].orderItemList.length;m++)
							{
								if(	finalOrderData[i].orderItemList[m].orderItemSn == packvo.itemlist[k].itemId)
								{
									var itemdata:Object = {};
									itemdata.orderItemSn = packvo.itemlist[k].itemId;
									itemdata.count = packvo.itemlist[k].itemCount;
									packdata.itemList.push(itemdata);
									break;
								}
							}
						}
						
					}
					if(packdata.itemList.length == 0)
					{
						ViewManager.showAlert("包裹产品项数量不能都是0");
						return false

					}
					
					finalOrderData[i].packageList.push(packdata);
					
				}
				for(var k:int=0;k < finalOrderData[i].orderItemList.length;k++)
				{
					
					delete finalOrderData[i].orderItemList[k].numlist;
				}
				
			}
			return true;
			
			
		}
		
		public function getOrderCapcaityData(orderdata:Object,deliveryprefer:int):String
		{
			var resultdata:Object = {};
			resultdata.manufacturer_code = orderdata.manufacturerCode;
			if(finalOrderData.length > 0)
			resultdata.addr_id = finalOrderData[0].addressId;
			
			resultdata.orderItemList = [];
			resultdata.delivery_prefer = deliveryprefer;
			
			var orderitems:Array = orderdata.orderItemList;
			
			var productProcMap:Object = {};
			for(var i:int=0;i < orderitems.length;i++)
			{
				var itemdata:Object = {};
				itemdata.orderItem_sn = orderitems[i].orderItemSn;
				
				itemdata.prod_code = orderitems[i].conponent.prodCode;
				var tempkey:String = itemdata.prod_code + "-";
				
				itemdata.processList = [];
				
				for(var j:int=0;j < orderitems[i].conponent.procInfoList.length;j++)
				{
					var procedata:Object = {};
					procedata.proc_code = orderitems[i].conponent.procInfoList[j].procCode;
					var size:Array = orderitems[i].conponent.LWH.split("/");
					
					var picwidth:Number = parseFloat(size[0]);
					var picheight:Number = parseFloat(size[1]);
					tempkey += procedata.proc_code + "-";
					
					procedata.cap_occupy = orderitems[i].itemNumber * getProcessNeedCapacity(orderdata.manufacturerCode,orderitems[i].material_code,picwidth,picheight,orderitems[i].conponent.procInfoList[j].procCode);
					
					procedata.proc_seq = j+1;
					
					itemdata.processList.push(procedata);
				}
				if(productProcMap.hasOwnProperty(tempkey))
				{
					var prococcupydata:Array = productProcMap[tempkey].processList;
					for(var k:int=0;k < prococcupydata.length;k++)
					{
						prococcupydata[k].cap_occupy += itemdata.processList[k].cap_occupy;
					}
					orderitems[i].batchOrderItemSn = productProcMap[tempkey].orderItem_sn;
					
					batchOrders[productProcMap[tempkey].orderItem_sn]++;
					
				}
				else
				{
					productProcMap[tempkey] = itemdata;
					resultdata.orderItemList.push(itemdata);
					batchOrders[orderitems[i].orderItemSn] = 1;
					orderitems[i].batchOrderItemSn = orderitems[i].orderItemSn;
				}
				//resultdata.orderItemList.push(itemdata);
				
			}
			
			for(i=0;i < orderitems.length;i++)
			{
				if(batchOrders[orderitems[i].batchOrderItemSn] == 1)
				{
					orderitems[i].batchOrderItemSn = "";
				}
				
			}
			return JSON.stringify(resultdata);
			
			
		}
		
		public function getSingleOrderItemCapcaityData(orderItemdata:Object):String
		{
			var resultdata:Object = {};
			resultdata.manufacturer_code = getManufacturerCode(orderItemdata.orderItemSn);
			resultdata.orderItemList = [];
			
			resultdata.delivery_prefer = 0;
			
			//var orderitems:Array = orderdata.orderItemList;
			
			//for(var i:int=0;i < orderitems.length;i++)
			//{
			var itemdata:Object = {};
			itemdata.orderItem_sn = orderItemdata.orderItemSn;
			itemdata.prod_code = orderItemdata.conponent.prodCode;
			
			itemdata.processList = [];
			
			for(var j:int=0;j < orderItemdata.conponent.procInfoList.length;j++)
			{
				var procedata:Object = {};
				procedata.proc_code = orderItemdata.conponent.procInfoList[j].procCode;
				var size:Array = orderItemdata.conponent.LWH.split("/");
				
				var picwidth:Number = parseFloat(size[0]);
				var picheight:Number = parseFloat(size[1]);
				
				procedata.cap_occupy = orderItemdata.itemNumber * getProcessNeedCapacity(resultdata.manufacturer_code,orderItemdata.material_code,picwidth,picheight,orderItemdata.conponent.procInfoList[j].procCode);
				
				procedata.proc_seq = j+1;
				
				itemdata.processList.push(procedata);
			}
			resultdata.orderItemList.push(itemdata);
			
			//	}
			
			return JSON.stringify(resultdata);
			
			
		}
		
		//计算工艺占用产能时
		public function getProcessNeedCapacity(manufacturerCode:String,matcode:String,picwidth:Number,picheight:Number,processcode:String):Number
		{
			var capacitydata:Array = getCapacityData(manufacturerCode,processcode,matcode);
			
			if(capacitydata.length < 3)
				return 0;
			
			if(capacitydata[1] == 0 || capacitydata[1] == null)
				return 0;
			
			var amout:Number = UtilTool.getAmoutByUnit(picwidth/100.0,picheight/100.0,capacitydata[0]);
			
			if(capacitydata[1] > 0)
				return parseFloat((amout/capacitydata[1] as Number).toFixed(4));
			else
				return 0;
			
		}
		
		public function hasUrgentOrderItem(manufacturecode:String):Boolean
		{
			if(finalOrderData == null)
				return false;
			
			for(var j:int=0;j < finalOrderData.length;j++)
			{
				var orderDatas:Array = finalOrderData[j].orderItemList;
				
				for(var i:int=0;i < orderDatas.length;i++)
				{
					var manucode:String = PaintOrderModel.instance.getManufacturerCode(orderDatas[i].orderItemSn);
					
					if(orderDatas[i].isUrgent == 1  &&  orderDatas[i].deliveryDate  != null && manucode == manufacturecode)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		public function hasCommonOrderItem(manufacturecode:String):Boolean
		{
			if(finalOrderData == null)
				return false;
			
			for(var j:int=0;j < finalOrderData.length;j++)
			{
				var orderDatas:Array = finalOrderData[j].orderItemList;
				for(var i:int=0;i < orderDatas.length;i++)
				{
					var manucode:String = PaintOrderModel.instance.getManufacturerCode(orderDatas[i].orderItemSn);
					
					if(orderDatas[i].isUrgent == false  &&  orderDatas[i].deliveryDate  != null && manucode == manufacturecode)
					{
						return true;
					}
				}
			}
			return false;
		}
		
		
		public function getManufacturerCode(orderitemsn:String):String{
			
			var arr:Array = finalOrderData;
			for(var i:int=0;i < arr.length;i++)
			{
				var orderitems:Array = arr[i].orderItemList;
				for(var j:int=0;j < orderitems.length;j++)
				{
					if(orderitems[j].orderItemSn == orderitemsn)
						return arr[i].manufacturerCode;
				}
			}
			
			return "";
		}
		
		public function getManufacturerNameBySn(orderitemsn:String):String{
			
			var arr:Array = finalOrderData;
			for(var i:int=0;i < arr.length;i++)
			{
				var orderitems:Array = arr[i].orderItemList;
				for(var j:int=0;j < orderitems.length;j++)
				{
					if(orderitems[j].orderItemSn == orderitemsn)
						return arr[i].manufacturerName;
				}
			}
			
			return "";
		}
		
		public function getSingleProductOrderData(orderitemsn:String):Object{
			
			var arr:Array = finalOrderData;
			for(var i:int=0;i < arr.length;i++)
			{
				var orderitems:Array = arr[i].orderItemList;
				for(var j:int=0;j < orderitems.length;j++)
				{
					if(orderitems[j].orderItemSn == orderitemsn)
						return orderitems[j];
				}
			}
			
			return null;
		}	
		
		public function getProductOrderDataList(orderitemsn:String):Array{
			
			var arr:Array = finalOrderData;
			var batchItemDatas:Array = [];
			for(var i:int=0;i < arr.length;i++)
			{
				var orderitems:Array = arr[i].orderItemList;
				for(var j:int=0;j < orderitems.length;j++)
				{
					if(orderitems[j].batchOrderItemSn == orderitemsn || orderitems[j].orderItemSn == orderitemsn)
					{
						batchItemDatas.push(orderitems[j]);
					}
				}
			}
			
			return batchItemDatas;
		}	
		
		public function getDeliveryList():Array
		{
			var arr:Array = finalOrderData;
			var selectManufacturerDelviery:Array = [];
			
			curCommmonDeliveryType = {};
			curUrgentDeliveryType = {};
			
			for(var i:int=0;i < arr.length;i++)
			{
				selectManufacturerDelviery.push({'manufacturer_code':arr[i].manufacturerCode,'manufacturer_name':arr[i].manufacturerName,'deliveryVoArr':deliveryList[arr[i].manufacturerCode]});
				
			}
			
			return selectManufacturerDelviery;
		}
		public function getDeliveryTypeStr(deliveryarr:Array,needurgetn:Boolean):String
		{
			if(deliveryarr == null || deliveryarr.length <= 0)
				return "";
			
			var typestr:String = "";
			var servertime:Date = new Date(TimeManager.instance.serverDate*1000);
			
			//var addressstatus:int = parseInt(PaintOrderModel.instance.finalOrderData[0].addressStatus);
			
			var orderitemlist:Array;
			for(var i:int=0;i < finalOrderData.length;i++)
			{
				if(finalOrderData[i].manufacturerCode == deliveryarr[i].belongManuCode)
				{
					orderitemlist = finalOrderData[i].orderItemList;
					break;
				}
			}
			for(var i:int=0;i < deliveryarr.length;i++)
			{
				var deliveryVO:DeliveryTypeVo = deliveryarr[i] as DeliveryTypeVo;
				
				//if(addressstatus == 0 && deliveryVO.delivery_name.indexOf("送货上门") >=0 )
				//	continue;
				//else
				//{
					var outOfSize:Boolean = false;

					if(deliveryarr[i].limit_length != 0 && deliveryarr[i].limit_width != 0 &&  deliveryarr[i].limit_height != 0)
					{
						for(var j:int=0;j < orderitemlist.length;j++)
						{
							if(parseFloat(orderitemlist[j].minSideLength) > deliveryarr[i].limit_length && parseFloat(orderitemlist[j].minSideLength) > deliveryarr[i].limit_width)
							{
								outOfSize = true;
								break;
							}
						}
					
					}
					if(!outOfSize)
					{
						if(!needurgetn  || deliveryVO.canbeslected(servertime))
						{
							if(i < deliveryarr.length - 1)
								typestr += deliveryVO.delivery_name + "(" + deliveryVO.deliveryPrice.toFixed(1) + "元)" + ",";
							else
								typestr += deliveryVO.delivery_name + "(" + deliveryVO.deliveryPrice.toFixed(1) + "元)";
							
						}
					}
				//}
			}
			
			return typestr;
		}
		
		
		public function isValidDeliveryType(deliveryarr:Array,deliveryname:String):Boolean
		{
			if(deliveryname.indexOf(OrderConstant.DELIVERY_TYPE_BY_MANUFACTURER) < 0)
				return true;
			
			var servertime:Date = new Date(TimeManager.instance.serverDate*1000);
			for(var i:int=0;i < deliveryarr.length;i++)
			{
				var deliveryVO:DeliveryTypeVo = deliveryarr[i] as DeliveryTypeVo;
				if(deliveryVO.delivery_name == deliveryname && deliveryVO.canbeslected(servertime))
				{
					return true;
				}
			}
			
			return false;
		}
		
		public function getDeliveryPrice(deliveryarr:Array,deliveryname:String,manucode:String=""):Number
		{
			
			//var servertime:Date = new Date(TimeManager.instance.serverDate);
			if(Userdata.instance.ignoreDelivery)
				return 0;
			if(deliveryname == "" || deliveryarr == null)
				return 0;
			
			for(var i:int=0;i < deliveryarr.length;i++)
			{
				var deliveryVO:DeliveryTypeVo = deliveryarr[i] as DeliveryTypeVo;
				if(deliveryVO.delivery_name == deliveryname)
				{
					return deliveryVO.deliveryPrice;
				}
			}
			
			return 0;
		}
		
		public function getDeliveryOrgCode(deliveryarr:Array):String
		{
			if(!Userdata.instance.ignoreDelivery && deliveryarr.length > 0)
			{
				return (deliveryarr[0] as DeliveryTypeVo).deliverynet_code;
			}
			return "";
		}
		
		public function getDynamicDeliveryFeeCfg(caller:* = null,callfun:Function = null):void
		{
			if(this.dynamicDeliveryFeeCfg != null)
			{
				if(caller && callfun) callfun.call(caller);
				return;
			}
			HttpRequestUtil.instance.Request(HttpRequestUtil.httpUrl + HttpRequestUtil.getDeliveryFeeConfig+Userdata.instance.userAccount + "&client_code=" + Userdata.instance.clientCode,this,function(data:*):void{
				
				var result:Object = JSON.parse(data as String);
				
				if(!result.hasOwnProperty("status"))
				{
					this.dynamicDeliveryFeeCfg = result.deliveryFeeList;
				}
				
				if(caller && callfun) callfun.call(caller);
				
			},null,null);
			
			
		}
		
		private function onGetDynamicDeliveryFeeBack(data:*):void
		{
			var result:Object = JSON.parse(data as String);
			
			if(!result.hasOwnProperty("status"))
			{
				this.dynamicDeliveryFeeCfg = result.deliveryFeeList;
			}
		}
		
		public function getDeliveryFeeByManuCode(manucode:String):Number
		{
			if(finalOrderData == null || finalOrderData.length == 0)
				return 0;
			var total:Number = 0;
			for(var i:int=0;i < finalOrderData.length;i++)
			{
				//if(finalOrderData[i].manufacturer_code == manucode)
				//{
					var orderDatas:Array = finalOrderData[i].orderItemList;
					for(var j:int=0;j < orderDatas.length;j++)
					{
						var ordermoney:Number = Number(orderDatas[j].itemPrice) * Number(orderDatas[j].itemNumber);
						
						if(orderDatas[j].isUrgent == 1 || orderDatas[j].deliveryDate  != null)
						{
							ordermoney = ordermoney*orderDatas[j].discount;
							
						}
						
						
						ordermoney = parseFloat(ordermoney.toFixed(1));
						total += ordermoney;
					}
				//}
			}
			
			return getDeliveryFee(total);
		}
		
		public function getTotalWeightByManuCode(manucode:String):Number
		{
			if(finalOrderData == null || finalOrderData.length == 0)
				return 0;
			var total:Number = 0;
			for(var i:int=0;i < finalOrderData.length;i++)
			{
				if(finalOrderData[i].manufacturerCode == manucode)
				{
					var orderDatas:Array = finalOrderData[i].orderItemList;
					for(var j:int=0;j < orderDatas.length;j++)
					{						
						
						total += parseFloat(orderDatas[j].conponent.weight) * orderDatas[j].itemNumber;
					}
				}
			}
			
			return total;;
		}
		
		
		private function getDeliveryFee(ordermoney:Number):Number
		{
			if(this.dynamicDeliveryFeeCfg != null)
			{
//				if(dynamicDeliveryFeeCfg.length > 0)
//				{
//					if(Userdata.instance.orderAmoutRatio >= dynamicDeliveryFeeCfg[0].percentage_lessThan)
//						return 0;
//				}
				for(var i:int=0;i < dynamicDeliveryFeeCfg.length;i++)
				{
					if(ordermoney >= dynamicDeliveryFeeCfg[i].moreOrEqual_than && ordermoney < dynamicDeliveryFeeCfg[i].less_than)
						return dynamicDeliveryFeeCfg[i].delivery_fee;
				}
				
				return 0;
			}
			else
				getDynamicDeliveryFeeCfg();
			return 0;
		}
		
		/*
		计算订单内每个产品的折扣*/
		
		public function calculateProductDiscount(orderlist:Vector.<PicOrderItem>):void
		{
			productDisount = {};
			
			for(var i:int=0;i < orderlist.length;i++)
			{
				var picorderitem:PicOrderItem = orderlist[i];
				if(picorderitem.ordervo.orderData != null)
				{
					if(productDisount[picorderitem.ordervo.manufacturer_code] == null)
						productDisount[picorderitem.ordervo.manufacturer_code] = {};
					
					if(productDisount[picorderitem.ordervo.manufacturer_code][picorderitem.ordervo.orderData.conponent.prodCode] == null)
					{
						productDisount[picorderitem.ordervo.manufacturer_code][picorderitem.ordervo.orderData.conponent.prodCode] = 0;
						//productDisount[picorderitem.ordervo.manufacturer_code][picorderitem.ordervo.orderData.prod_code].productvo = picorderitem.curproductvo;
						//productDisount[picorderitem.ordervo.manufacturer_code][picorderitem.ordervo.orderData.prod_code].productvo.
					}
					
					var processPrice:Number = picorderitem.getProcessPrice();
					productDisount[picorderitem.ordervo.manufacturer_code][picorderitem.ordervo.orderData.conponent.prodCode] += processPrice;
				}
				
				
			}
		}
		
		
		public function getProductTotalPrice(manucode:String,prodcode:String):Number
		{
			if(productDisount != null && productDisount[manucode] != null && productDisount[manucode][prodcode] != null)
				return productDisount[manucode][prodcode];
			return 1;
			
		}
		
		
		
	}
}