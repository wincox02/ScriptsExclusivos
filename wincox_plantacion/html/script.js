// Variable para almacenar el estado del menú
var isMenuOpen = false;

// Evento de escucha para las teclas presionadas
document.addEventListener('keydown', function (event) {
    // Verifica si el menú está abierto y la tecla presionada es 'F'
    if (isMenuOpen && event.key === 'f') {
        post('cerrar');
    }
});

window.addEventListener('message', function (event) {
    var item = event.data;
    if (item.openMenu !== undefined) {
        var menu = document.getElementById('menu');
        if (item.openMenu) {
            isMenuOpen = true
            menu.style.display = "";
            agregarPlantasAlDOM(item.Plantas)
            var elementoPrecio = document.getElementById("precioPlanta");
            elementoPrecio.textContent = item.precioSiguientePlanta;
            pintarMejoras(item.Mejoras);
        } else {
            isMenuOpen = false
            menu.style.display = "none";
        }
    }
});

function pintarMejoras(mejorasActuales) {
    var botonAgua = document.getElementById('botonCompraAgua');
    if (mejorasActuales.tieneAgua) {
        // botonAgua.style.
    }

    var botonCrecimiento = document.getElementById('botonCompraCrecimiento');

    if (mejorasActuales.tieneCrecimiento) {

    }

    
}

function agregarPlantasAlDOM(plantas) {
    // Selecciona el contenedor de plantas en el DOM
    const contenedorPlantas = document.querySelector('.listaPlantas');

    contenedorPlantas.innerHTML = '';

    // Itera sobre el array de plantas
    plantas.forEach(planta => {
        // Crea elementos HTML para cada planta
        const plantaElemento = document.createElement('div');
        plantaElemento.classList.add('planta');

        const idElemento = document.createElement('div')
        idElemento.innerHTML = '<p> ' + planta.idplanta + '</p>';
        plantaElemento.appendChild(idElemento)


        const imagenElemento = document.createElement('div');
        imagenElemento.classList.add('imagen');

        const img = document.createElement('img');
        img.src = "./Marihuana.jpg";

        imagenElemento.appendChild(img);

        const barrasElemento = document.createElement('div');
        barrasElemento.classList.add('barras');

        const aguaElemento = document.createElement('div');
        aguaElemento.classList.add('agua');
        aguaElemento.innerHTML = '<div class="porcentajeAgua" style="width: ' + planta.porcentajeAgua + '%;"></div>';

        // $('.porcentajeAgua').css('width', planta.porcentajeAgua + "%")

        const crecimientoElemento = document.createElement('div');
        crecimientoElemento.classList.add('crecimiento');
        crecimientoElemento.innerHTML = '<div class="porcentajeCreci" style="width: ' + planta.porcentajeCrecimiento + '%;"></div>';

        // $('.porcentajeCreci').css('width', planta.porcentajeCrecimiento + "%")

        barrasElemento.appendChild(aguaElemento);
        barrasElemento.appendChild(crecimientoElemento);

        plantaElemento.appendChild(imagenElemento);
        plantaElemento.appendChild(barrasElemento);

        // Agrega la planta al contenedor de plantas
        contenedorPlantas.appendChild(plantaElemento);
    });
}

function cerrar() {
    post('cerrar');
}

function refresh() {
    fetch(`http://wincox_plantacion/refresh`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({
            itemId: 'pepe'
        })
    }).then(resp => resp.json()).then(resp => agregarPlantasAlDOM(resp));
}

function comprarPlanta() {
    post("comprarPlanta", {})
}

function post(name, data) {
    $.post("http://wincox_plantacion/" + name, JSON.stringify(data));
}