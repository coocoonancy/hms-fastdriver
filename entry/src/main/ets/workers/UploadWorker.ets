import { ImageList } from '@hms/basic/Index';
import { ErrorEvent, MessageEvents, ThreadWorkerGlobalScope, util, worker } from '@kit.ArkTS';
import { image } from '@kit.ImageKit';
import { fileIo } from '@kit.CoreFileKit';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

export class PostParams {
  files: ImageList[] = []
  filePath: string = ""
}

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessage = async (e: MessageEvents) => {
  const params = e.data as PostParams
  if (params && params.files.length) {
    try {
      // 原图
      const list = params.files
      const imageCompressor = image.createImagePacker()
      const filePath = params.filePath;
      let packOpts: image.PackingOption = { format: "image/jpeg", quality: 50 };
      let arr: ImageList[] = []
      while (list.length) {
        const obj = list.pop()
        let sourceFile = fileIo.openSync(obj?.url, fileIo.OpenMode.READ_ONLY)
        let fileName = filePath + "/" + util.generateRandomUUID() + ".jpg"
        const targetFile = fileIo.openSync(fileName, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
        await imageCompressor.packToFile(image.createImageSource(sourceFile.fd), targetFile.fd, packOpts)
        arr.push({ url: fileName })
        fileIo.closeSync(sourceFile)
        fileIo.closeSync(targetFile)
      }
      workerPort.postMessage({ files: arr })
      workerPort.close()
    }
    catch (error) {
      console.log(error.message)
    }
  }
}

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessageerror = (e: MessageEvents) => {
}

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param e error message
 */
workerPort.onerror = (e: ErrorEvent) => {
}