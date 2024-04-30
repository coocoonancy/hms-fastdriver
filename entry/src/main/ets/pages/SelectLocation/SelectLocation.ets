import { MapComponent } from '@hms.core.map.MapComponent'
import { HmCard, HmCardItem, HmNavBar } from '@hms/basic/Index'
import { map, site } from '@kit.MapKit'
import { geoLocationManager } from '@kit.LocationKit'
import { router } from '@kit.ArkUI'

@Entry
@Component
struct SelectLocation {
  @State
  locations: SiteClass[] = []
  controller: map.MapComponentController = new map.MapComponentController()
  async getLocation() {
    const res = await geoLocationManager.getCurrentLocation()
    // 挪动相机位置
    this.controller.moveCamera(map.newCameraPosition({
      target: {
        longitude: res.longitude,
        latitude: res.latitude
      },
      zoom: 16
    }))
    // 添加点标记和文案
    this.controller.addPointAnnotation({
      position: {
        longitude: res.longitude,
        latitude: res.latitude
      },
      titles: [{
        content: '您当前的位置'
      }]
    })

    // 搜索最近地区位置
    const locations = await site.nearbySearch({
      location: {
        longitude: res.longitude,
        latitude: res.latitude
      },
      pageSize: 4,
      pageIndex: 1,
      radius: 50
    })
    this.locations = locations.sites?.slice(0,4) as SiteClass[] // 只拿4条数据

  }
  build() {
    Column() {
      HmNavBar({ title: '当前位置' })
      Stack({ alignContent: Alignment.Bottom }) {
        //  地图区域
        //  地图区域
        MapComponent({
          mapOptions: {
            position: {
              target: {
                latitude: 39.9,
                longitude: 116.4
              },
              zoom: 10
            }
          },
          mapCallback: (err, controller) => {
            if (!err) {
              this.controller = controller // 此时此刻 地图渲染完毕 地图控制器也有值了
              this.getLocation() // 获取定位
            }
          }
        })
          .width('100%')
          .height('100%')
        Column() {
          HmCard() {
            ForEach(this.locations, (item: SiteClass) => {
              HmCardItem({ leftTitle: item.name, rightText: `${item.distance}m` })
                .onClick(() => {
                  router.back({
                    url: "pages/ExceptionReport/ExceptionReport",
                    params: {
                      location: item.name
                    }
                  })
                })
            })

          }
        }
        .padding({
          bottom: 60
        })
      }
    }
    .height('100%').backgroundColor($r('app.color.background_page'))
  }
}

class SiteClass {
  name: string = ""
  distance: number = 0
}