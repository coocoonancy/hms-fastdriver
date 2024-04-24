export * from './advert'
export * from './tab'
export * from './router'
export * from './common'
export class ResponseData<T> {
  code: number = 0
  msg: string = ""
  data: T | null = null // 这里应该必须只能这么声明！！！！
}