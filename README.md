# lib-javascript

Biblioteca javascript para ofrecer integración con la aplicación khipu. Esta biblioteca permite a los comercios implementar un botón de pago para pagar sin abandonar la página. Si el usuario no tiene instalada la aplicación khipu entonces es redirigido a una página de instalación y luego el pago. Luego el usuario es redirigido de manera automática a la página del comercio una vez completado el pago.

Esta biblioteca tiene solo una función. Esta función levantará la aplicación khipu y comenzará el pago al ser llamada. Alternativamente, la función puede recibir un elemento de la página para que la aplicación se levante al hacer click sobre ese elemento.

## Como funciona

Este es el flujo de un pago utilizando la biblioteca:

- Al cargar la página del comercio la biblioteca comprueba si el la aplicación khipu está instalada. Si se ha configurado un elemento de la página, por ejemplo un botón, entonces se configurará este botón para que levante la aplicación khipu y complete el pago. Si no está especificado un botón entonces la aplicación se levantará de manera automática.
- Si el aplicación khipu no está instalado entonces se enviará al usurio al portal de khipu para que realize la instalación y complete el pago. Cuanto el pago es completado el usuario es devuelto a la página del comercio especificadada al crear el cobro.
- Cuando la aplicación se levanta en el portal del comercio, khipu avisa al navegador mediante websockets para que el usuario sea redirigido a una página del comercio que le dice que el pago está en verificación.
- Cuando la transferencia esta confirmada, el servidor de khipu avisa al comercio usando una llamada POST indicando que el pago está completo.

## Requisitos de esta biblioteca

### API REST

La biblioteca se usa en conjunto con los cobros generados usando la [API REST 2.0](https://khipu.com/page/api) de khipu, por lo cual es muy recomendable estar familiarizado con dicha documentación.

Los cobros deben estar completamente configurados al momento de pagar, esto quiere decir que deben tener asignados un correo para el pagador
y un banco asociado. Para esto se deben usar la [llamada receiverBanks](https://khipu.com/page/api#listado-de-bancos) (para dar a elegir al pagador un listado de bancos disponibles) y la [llamada para crear un pago](https://khipu.com/page/api#crear-un-pago) para crear el cobro usando el correo del pagador y el banco seleccionado.

El cobro además debe haber sido creado con el parámetro *return_url* para que al terminar el pago el usuario sea redirigido a una página avisando que está siendo verificado.

### JQuery

La biblioteca javascript  usa jQuery para el manejo de DOM y eventos. El uso de jQuery se hace con la opción [*noConlict*](https://api.jquery.com/jQuery.noConflict/) por lo que puede ser usada de manera segura con otras bibliotecas.

Es recomendable usar la versión que provee [google en sus servidores](https://developers.google.com/speed/libraries/devguide).

### Atmosphere

Khipu utiliza el framework de websockets [atmosphere-javascript](https://github.com/Atmosphere/atmosphere-javascript) para crear y utilizar
websockets. Esta plataforma viene incluida al incluir la biblioteca, así pues, no es necesario incluirla de manera externa.

## Integración con la página

Los siguientes son los pasos necesarios para integrar la biblioteca en una página de comercio. Al llegar a esta página ya debe existir un cobro en khipu y un código único de operación (id de pago) generado usando la API Rest en un paso anterior.

Lo primero que debemos hacer es incluir jQuery en nuestra página:

```javascript
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
```

Luego incluimos la biblioteca de khipu.

```javascript
<script src="//storage.googleapis.com/installer/khipu-2.0.js"></script>
```

Ahora debemos agregar un elemento _DIV_ con el id <em>khipu-chrome-extension-div</em>. Este _DIV_ sirve para la comunicación de la biblioteca con la extensión chrome.

Código fuente:

```javascript
<div id="khipu-chrome-extension-div" style="display: none"></div>
```

<div class="alert alert-info">
<strong>Importante</strong>: Este DIV debe estar creado en el html de la página y no debe ser generado de manera dinámica usando javascript, de lo contrario la extensión de khipu lo buscará antes de que se ejecuten los javascript de la página y no lo encontrará.
</div>


El último paso es hacer la llamada a la biblioteca. En el siguiente ejemplo, la llamada levantará inmediatamente la aplicación (si es que está instalada).

```javascript
KhipuLib.startKhipu("vzkeh1wk82ax", "https://khipu.com/payment/info/vzkeh1wk72ax", true);
```

Los parámetros que enviamos se obtienen de la llamada de crear pagos usando la api REST:

- El primer parametro es el identificador de un pago. Corresponde al parámetro _payment_id_.
- El segundo es la url del pago, para el caso en que el terminal no esté instalado. Corresponde al parámetros _payment_url_
- El tercer parámetro indica si el pago está listo para ser completado usando el terminal. Esto se obtiene del parámetro _ready_for_terminal_ al crear el pago.

En el caso de que queramos iniciar el pago inmediatamente cargada la página, el código sería el siguiente:

```javascript
window.onload = function () {
    KhipuLib.startKhipu("vzkeh1wk82ax", "https://khipu.com/payment/info/vzkeh1wk72ax", true);
}
```

<div class="alert alert-info">
<strong>Importante</strong>: ¿Por qué debe estar este código en en _onload_ de la página y no cuando la página está <em>ready</em>?.
<a href="http://en.wikipedia.org/wiki/NPAPI#Browser_support">Google deprecó de Chrome la API de plugins NPAPI</a>. Es por esto que khipu utiliza
una extensión para chrome para levantar el terminal. Esta extensión se conecta a los eventos de la página y la biblioteca necesita
comuncarse con la extensión <em>después</em> de que esta está lista, esto es, justo antes de ejecutar <em>onLoad</em>.
</div>

En el caso de querer asociar el click de un elemento a levantar el terminar, el código sería el siguiente:


```html
<!-- Primero el boton de pago -->
<button id="boton-pago">Pagar</button>
```
```javascript
<!-- Luego la llamada -->
window.onload = function () {
    KhipuLib.startKhipu("vzkeh1wk82ax", "https://khipu.com/payment/info/vzkeh1wk72ax", true, '#boton-pago');
}
```

Aquí la diferencia es que agregarmos un _selector CSS_ para obtener el botón de pago usando su _id_. Esto configurará el botón para que al hacer click se levante la aplicación de khipu. Se debe notar que nuevamente el código debe ejecutarse en el _onLoad_ de la página y no en el _onReady_.

## Ejemplo en línea

En la dirección [http://demo.khipu.com/js](http://demo.khipu.com/js) hay un comercio de ejemplo que utiliza esta biblioteca. Este ejemplo pide los datos necesarios (correo y banco para pagar) y al hacer el envío genera un cobro en khipu obteniendo su código único de operación. En la siguiente página aparece un botón de pago configurado para llamar al terminal.

En la demo se usa una cuenta de cobro de desarrollo, por lo que solo aparecerá el banco de pruebas, cambiando la configuración se tendrá el listado completo de bancos.
