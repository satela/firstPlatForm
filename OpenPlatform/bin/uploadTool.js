var UploadTool = {};

 const fileStop = async (e) => {
    let array = await loopFile(e);
    console.log(array);
	//return array;

  }

  // 循环获取file
   const loopFile = (e) => {
    let array = [];
    return new Promise(resolve => {
      // 可以同时拖拽多个文件（文件夹）因此e.dataTransfer.items循环一下拖拽的文件夹
      for (let index = 0; index < e.dataTransfer.items.length; index++) {
        const webkitGetAsEntry = e.dataTransfer.items[index].webkitGetAsEntry();
        // 判断是不是文件夹
        // loopOver = index == e.dataTransfer.items.length - 1 如果是最后一个则true,但是文件还要再次去判断
        if (webkitGetAsEntry.isDirectory) {
          setfolder(webkitGetAsEntry, index == e.dataTransfer.items.length - 1, webkitGetAsEntry.fullPath);
        } else {
          setfile(webkitGetAsEntry, index == e.dataTransfer.items.length - 1, webkitGetAsEntry.fullPath)
        }
      }
      // 处理文件夹
      function setfolder(webkitGetAsEntry, loopOver, path) {
        const dirReader = webkitGetAsEntry.createReader();
        dirReader.readEntries((entries) => {
          entries.forEach((item, ind) => {
            if (item.isFile) {
              // loopOver传入的为true,则文件夹中最后一个文件夹，那就再去循环
              setfile(item, loopOver && ind == entries.length - 1, path)
            } else {
              setfolder(item, loopOver, path)
            }
          })
        })
      }
      // 处理文件
      function setfile(webkitGetAsEntry, loopOver, path) {
        webkitGetAsEntry.file(file => {
          // 只获取图片
          const fileFilter = file.type && 'image/gif,image/jpeg,image/jpg,image/png,image/bmp'.indexOf(file.type) > -1;
          if (fileFilter) {
            // 这里将路径重新进行整理
            let name = webkitGetAsEntry.fullPath.replace(path + '/', '');
            // 重新创建file数据格式，加入type和path放入到fileArr中
            const newFile = new File([file], name, { type: file.type })
            array.push(newFile);
          }
        });
        // 如果loopOver为true则抛出数据
        if (loopOver) {
          resolve(array);
        }
      }
    })
  }