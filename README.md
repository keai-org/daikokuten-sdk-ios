# SDK de Daikokuten para iOS

El SDK de iOS proporciona un widget de chat y una API de contexto para aplicaciones Swift a través de CocoaPods.

## Instalación

Agrega esto a tu `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'TuApp' do
  use_frameworks!
  pod 'daikokuten', '~> 0.1.20'
end
```

Luego ejecuta:

```bash
pod install
```

## Uso - Widget de Chat

### Implementación Básica

Agrega el `ChatButtonViewController` a tu controlador de vista:

```swift
import UIKit
import daikokuten

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Crear controlador de vista del botón de chat
        let chatView = ChatButtonViewController(
            userId: "testUser123",
            testMode: false
        )
        
        // Agregar como controlador hijo (IMPORTANTE para el ciclo de vida correcto)
        addChild(chatView)
        view.addSubview(chatView.view)
        chatView.didMove(toParent: self)
    }
}
```

### Implementación Avanzada con Restricciones Personalizadas

Para mejor control sobre el posicionamiento del botón y asegurar que siempre sea clickeable:

```swift
import UIKit
import daikokuten

class ViewController: UIViewController {
    
    private var chatViewController: ChatButtonViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatButton()
    }
    
    private func setupChatButton() {
        // Crear controlador de vista del botón de chat
        chatViewController = ChatButtonViewController(
            userId: "testUser123",
            clientId: "tu_client_id",
            testMode: false,
            authToken: nil
        )
        
        // Agregar como controlador hijo
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        chatViewController.didMove(toParent: self)
        
        // Configurar restricciones para asegurar que el controlador de vista del chat llene la vista padre
        chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            chatViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Forzar layout para asegurar que el botón esté posicionado correctamente
        view.layoutIfNeeded()
        
        isChatButtonSetup = true
        print("ChatButtonViewController: Configuración del botón de chat completada")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Asegurar que el botón sea visible y clickeable
        chatViewController.view.isHidden = false
    }
}
```

### Implementación de Botón Personalizado

Puedes proporcionar tu propio UIButton para control completo sobre la apariencia y posicionamiento:

```swift
import UIKit
import daikokuten

class ViewController: UIViewController {
    
    private var chatViewController: ChatButtonViewController!
    private var customChatButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomButton()
        setupChatButton()
    }
    
    private func setupCustomButton() {
        // Crear tu botón personalizado
        customChatButton = UIButton(type: .custom)
        customChatButton.setTitle("💬 Chat", for: .normal)
        customChatButton.setTitleColor(.white, for: .normal)
        customChatButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        customChatButton.backgroundColor = .systemPurple
        customChatButton.layer.cornerRadius = 20
        customChatButton.layer.shadowColor = UIColor.black.cgColor
        customChatButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        customChatButton.layer.shadowRadius = 4
        customChatButton.layer.shadowOpacity = 0.3
        
        // Posicionar tu botón personalizado
        customChatButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customChatButton)
        
        NSLayoutConstraint.activate([
            customChatButton.widthAnchor.constraint(equalToConstant: 80),
            customChatButton.heightAnchor.constraint(equalToConstant: 40),
            customChatButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            customChatButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupChatButton() {
        // Crear controlador de vista del botón de chat con botón personalizado
        chatViewController = ChatButtonViewController(
            userId: "testUser123",
            clientId: "tu_client_id",
            testMode: false,
            authToken: nil,
            customButton: customChatButton // Pasar tu botón personalizado
        )
        
        // Agregar como controlador hijo
        addChild(chatViewController)
        view.addSubview(chatViewController.view)
        chatViewController.didMove(toParent: self)
        
        // Configurar restricciones
        chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chatViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            chatViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chatViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chatViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
```

**Beneficios del Botón Personalizado:**
- **Control completo de estilo**: Diseña tu botón como quieras
- **Posicionamiento flexible**: Coloca el botón en cualquier lugar de tu jerarquía de vistas
- **Manejo automático de acciones**: El SDK agrega automáticamente la funcionalidad de chat
- **Sin depuración visual**: Los botones personalizados no obtienen el borde rojo de depuración

### Opciones de Configuración

El `ChatButtonViewController` acepta los siguientes parámetros:

- **userId** (String, por defecto: UUID().uuidString): Identificador único para el usuario
- **clientId** (String, por defecto: "your_client_id"): ID del cliente de tu aplicación
- **testMode** (Bool, por defecto: false): Habilitar modo de prueba para desarrollo
- **authToken** (String?, por defecto: nil): Token de autenticación opcional
- **customButton** (UIButton?, por defecto: nil): Botón personalizado opcional para usar en lugar del predeterminado

### Comportamiento del Modal

El modal de chat se comporta de la siguiente manera:
- **Pantalla completa**: El modal cubre toda la pantalla (como la versión de Android)
- **Ocultación del botón**: El botón de chat se oculta automáticamente cuando se abre el modal
- **Mostrar botón**: El botón de chat reaparece cuando se cierra el modal
- **Cierre con JavaScript**: El modal se puede cerrar mediante el botón "X" renderizado por JavaScript
- **Alternancia automática**: Tanto el toque del botón como el cierre con JavaScript activan el mismo comportamiento de alternancia

## Uso - API de Contexto

Envía contexto con el ID del usuario y el ID del evento. Usa "interest" para denotar interés del usuario en un evento o "subscribe" para apostar o solicitar información/ayuda más precisa.

```swift
import daikokuten

Daikokuten.context(userId: "user123", eventId: "event456", action: "subscribe")
```

Parámetros:
- **userId** (String, requerido): Identificador del usuario
- **eventId** (String, requerido): Identificador del evento  
- **action** (String, requerido): Acción a reportar ("interest" o "subscribe")

## Requisitos

- iOS 13.0+
- Swift 5.0+
- CocoaPods

## Solución de Problemas

### Botón No Clickeable

Si el botón de chat aparece pero no responde a los toques:

1. **Asegurar jerarquía correcta del controlador de vista**:
   ```swift
   // ✅ Forma correcta
   addChild(chatViewController)
   view.addSubview(chatViewController.view)
   chatViewController.didMove(toParent: self)
   
   // ❌ Forma incorrecta - el botón no será clickeable
   view.addSubview(chatViewController.view)
   ```

2. **Verificar que la acción del botón esté configurada correctamente**:
   ```swift
   // ✅ El SDK usa UIAction para hacer clic confiable en el botón
   button.addAction(UIAction(title: "Click Me", handler: { [unowned self] _ in
       print("=====> BOTÓN CLICKEADO - Acción activada!")
       self.toggleModal()
   }), for: .touchUpInside)
   
   // Método tradicional alternativo (también funciona):
   // button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
   ```

2. **Verificar restricciones de vista**:
   ```swift
   // Asegurar que la vista del controlador de chat llene la vista padre
   chatViewController.view.translatesAutoresizingMaskIntoConstraints = false
   NSLayoutConstraint.activate([
       chatViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
       chatViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
       chatViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
       chatViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
   ])
   ```

3. **Verificar ciclo de vida de la vista**:
   ```swift
   override func viewDidAppear(_ animated: Bool) {
       super.viewDidAppear(animated)
       // Forzar layout para asegurar que el botón esté posicionado correctamente
       view.layoutIfNeeded()
   }
   ```

### Botón No Visible

Si el botón no aparece:

1. **Verificar jerarquía de vistas**: Asegurar que la vista del controlador de chat esté agregada a la vista padre
2. **Verificar restricciones**: Asegurar que la vista del controlador de chat tenga restricciones apropiadas
3. **Verificar vistas superpuestas**: Asegurar que ninguna otra vista esté cubriendo el área del botón
4. **Habilitar modo de depuración**: El SDK incluye depuración visual - el botón tendrá un borde rojo cuando esté posicionado correctamente

### WebView No Carga

Si el modal se abre pero la interfaz de chat no carga:

1. **Verificar conectividad de red**: El SDK carga recursos desde URLs externas
2. **Verificar Política de Seguridad de Contenido**: El SDK incluye encabezados CSP necesarios
3. **Verificar logs de consola**: Buscar errores de JavaScript en la consola del WebView
4. **Manejo de tokens**: Verificar que el token de autenticación se pase correctamente al WebView

### Problemas de Cierre del Modal

Si el modal no se cierra correctamente:

1. **Botón de cierre con JavaScript**: Asegurar que el botón "X" en la interfaz de chat esté funcionando
2. **Manejador de mensajes**: Verificar que `WKScriptMessageHandler` esté configurado correctamente
3. **Visibilidad del botón**: Verificar que el botón de chat reaparezca después de cerrar
4. **Comportamiento de alternancia**: Tanto el toque del botón como el cierre con JavaScript deben funcionar idénticamente

### Problemas de Carga de Contenido

Si el contenido del WebView no carga correctamente:

1. **Método único**: El SDK usa un método consolidado `loadWebViewContent(token:)`
2. **Manejo de tokens**: El método acepta parámetro de token opcional para autenticación
3. **Carga inicial**: El WebView carga con el token de autenticación inicial (si se proporciona) durante la configuración
4. **Actualización de token**: El WebView se recarga con el nuevo token después de la atestación

### Problemas Comunes y Soluciones

| Problema | Causa | Solución |
|----------|-------|----------|
| Botón no responde a toques | Configuración incorrecta del controlador de vista o acción faltante | Usar `addChild()` y `didMove(toParent:)` + verificar `addAction` |
| Botón no visible | Restricciones faltantes o incorrectas | Asegurar que el controlador de vista del chat llene la vista padre |
| Modal no se abre | Problemas de conectividad de red | Verificar conexión a internet y disponibilidad del servidor |
| Errores de JavaScript en WebView | CSP bloqueando recursos | Verificar que los encabezados CSP permitan dominios necesarios |
| Acción del botón no activada | `addAction` faltante o evento incorrecto | Usar evento `.touchUpInside` con manejador apropiado |
| Modal no se cierra | Botón de cierre con JavaScript no funciona | Verificar `WKScriptMessageHandler` y mensaje "closeModal" |
| Botón no reaparece | Problema de lógica de cierre del modal | Verificar que la visibilidad del botón se alterne correctamente |

## Implementación de Acción del Botón

El SDK usa la API moderna `UIAction` para hacer clic confiable en el botón:

```swift
// ✅ Enfoque moderno UIAction (usado en SDK)
button.addAction(UIAction(title: "Click Me", handler: { [unowned self] _ in
    print("=====> BOTÓN CLICKEADO - Acción activada!")
    self.toggleModal()
}), for: .touchUpInside)

// Enfoque tradicional alternativo (también soportado)
button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

@objc private func buttonTapped() {
    print("=====> BOTÓN CLICKEADO - Método tradicional!")
    toggleModal()
}
```

**Puntos Clave:**
- Las acciones se agregan **DESPUÉS** de que el botón se agregue a la jerarquía de vistas
- Usa evento `.touchUpInside` para detección confiable de toques
- Incluye gestión de memoria apropiada con `[unowned self]`
- Proporciona logging detallado para depuración

## Modo de Depuración

Habilitar modo de prueba para ver información de depuración:

```swift
let chatView = ChatButtonViewController(
    userId: "testUser123",
    testMode: true  // Habilitar modo de depuración
)
```

En modo de depuración, verás:
- Logs de consola con prefijo "=====>"
- Indicadores visuales (borde rojo en el botón)
- Mensajes de error detallados
- Logs de confirmación de acción del botón

## Mejores Prácticas

1. **Siempre usar patrón de controlador hijo**: Esto asegura gestión apropiada del ciclo de vida
2. **Configurar restricciones correctamente**: La vista del controlador de chat debe llenar la vista padre
3. **Manejar ciclo de vida de vista**: Llamar `layoutIfNeeded()` en `viewDidAppear`
4. **Usar IDs de usuario únicos**: Cada usuario debe tener un identificador único
5. **Probar en ambas orientaciones**: Asegurar que el botón funcione en retrato y paisaje
6. **Verificar fugas de memoria**: El SDK maneja apropiadamente el ciclo de vida del WebView

## Proyecto de Ejemplo

Para un ejemplo completo y funcional, consulta la prueba de integración en el repositorio del SDK que demuestra la configuración y uso apropiados.
