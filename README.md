# daikokuten-ios-sdk

El SDK de iOS proporciona un widget de chat y una API de contexto para aplicaciones Swift a través de CocoaPods.

### Instalación

Agrega esto a tu `Podfile`:

```swift
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'TEST' do
  use_frameworks!
  pod 'daikokuten', '~> 0.1.20'
end
```

Luego ejecuta:

```bash
pod install
```

**Uso - Widget de Chat**

Agrega el `ChatButtonViewController` a tu vista:

```swift
import UIKit
import DaikokutenSDK

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let chatVC = ChatButtonViewController(userId: "tuUserId", accessToken: "tuAccessToken", testMode: false)
        addChild(chatVC)
        view.addSubview(chatVC.view)
        chatVC.didMove(toParent: self)
    }
}
```

- **tuUserId**: Identificador del usuario (cadena, por defecto "user123").
- **tuAccessToken**: Token de acceso (cadena, por defecto "token").
- **testMode**: Modo de prueba (booleano, por defecto false).

### Uso - API de Contexto

Tambien enviar contexto con el ID del usuario y un ID de un evento, usa la accion "interest" para denotar que el usuario a mostrado interes en un evento o "subscribe" para denotar que esta apostando o requiere informacion o ayuda mas precisa.

```kotlin
import DaikokutenSDK

Daikokuten.context(userId: "user123", eventId: "event456", action: "subscribe")
```

- **userId**: Identificador del usuario (cadena, requerido).
- **eventId**: Identificador del evento (cadena, requerido).
- **action**: Acción a reportar (cadena, requerido).

### Requisitos

- iOS 13.0+
- Swift 5.0+
- CocoaPods
