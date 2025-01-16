let carrito = [];
let wishlist = [];
let historialCompras = [];
const tasaImpuesto = 0.15; // 15% de impuestos
let moneda = "USD"; // Moneda predeterminada

// Función para agregar un producto al carrito
function agregarAlCarrito(nombre, precio) {
    carrito.push({ nombre: nombre, precio: precio });
    actualizarCarrito();
    actualizarContador();
    mostrarNotificacion(`${nombre} ha sido agregado al carrito.`);
}

// Función para eliminar un producto del carrito
function eliminarDelCarrito(index) {
    const producto = carrito[index];
    carrito.splice(index, 1);
    actualizarCarrito();
    actualizarContador();
    mostrarNotificacion(`${producto.nombre} ha sido eliminado del carrito.`);
}

// Función para actualizar la visualización del carrito
function actualizarCarrito() {
    let carritoHTML = '';
    let total = 0;

    if (carrito.length === 0) {
        carritoHTML = `<p>Tu carrito está vacío.</p>`;
    } else {
        carrito.forEach((producto, index) => {
            carritoHTML += `<p>${producto.nombre} - ${formatearMoneda(producto.precio)} <button onclick="eliminarDelCarrito(${index})">Eliminar</button></p>`;
            total += producto.precio;
        });

        carritoHTML += `<h3>Total: ${formatearMoneda(total)}</h3>`;
        carritoHTML += `<h4>Total con impuestos: ${formatearMoneda(total * (1 + tasaImpuesto))}</h4>`;
    }

    document.getElementById('carrito').innerHTML = carritoHTML;
}

// Función para actualizar el contador de productos en el carrito
function actualizarContador() {
    document.getElementById('carrito-count').textContent = carrito.length;
}

// Lista de productos
const productos = [
    { nombre: "Smartphone", precio: 799.99, categoria: "Tecnología", imagen: "producto1.jpg" },
    { nombre: "Camiseta de algodón", precio: 19.99, categoria: "Ropa", imagen: "producto2.jpg" },
    { nombre: "Auriculares inalámbricos", precio: 59.99, categoria: "Tecnología", imagen: "producto3.jpg" },
    { nombre: "Mochila deportiva", precio: 49.99, categoria: "Accesorios", imagen: "producto4.jpg" }
    // Agrega más productos aquí...
];

// Generar los productos dinámicamente en el HTML
function renderizarProductos(listaProductos) {
    document.getElementById('productos').innerHTML = '';
    listaProductos.forEach((producto, index) => {
        const productoHTML = `
            <div class="producto">
                <h3>${producto.nombre}</h3>
                <img src="${producto.imagen}" alt="${producto.nombre}">
                <p>Precio: ${formatearMoneda(producto.precio)}</p>
                <button id="btnProducto${index}">Añadir al carrito</button>
                <button id="btnWishlist${index}">Añadir a Wishlist</button>
            </div>
        `;
        document.getElementById('productos').innerHTML += productoHTML;

        // Eventos para agregar productos
        document.getElementById(`btnProducto${index}`).addEventListener('click', function() {
            agregarAlCarrito(producto.nombre, producto.precio);
        });

        document.getElementById(`btnWishlist${index}`).addEventListener('click', function() {
            agregarAWishlist(producto);
        });
    });
}

renderizarProductos(productos);

// Función para formatear moneda según configuración
function formatearMoneda(cantidad) {
    return new Intl.NumberFormat('es-ES', { style: 'currency', currency: moneda }).format(cantidad);
}

// Función para agregar a Wishlist
function agregarAWishlist(producto) {
    wishlist.push(producto);
    mostrarNotificacion(`${producto.nombre} ha sido añadido a tu Wishlist.`);
    actualizarWishlist();
}

// Actualizar la visualización de Wishlist
function actualizarWishlist() {
    let wishlistHTML = '';

    if (wishlist.length === 0) {
        wishlistHTML = `<p>Tu Wishlist está vacía.</p>`;
    } else {
        wishlist.forEach((producto, index) => {
            wishlistHTML += `<p>${producto.nombre} - ${formatearMoneda(producto.precio)} <button onclick="eliminarDeWishlist(${index})">Eliminar</button></p>`;
        });
    }

    document.getElementById('wishlist').innerHTML = wishlistHTML;
}

// Eliminar un producto de la Wishlist
function eliminarDeWishlist(index) {
    const producto = wishlist[index];
    wishlist.splice(index, 1);
    mostrarNotificacion(`${producto.nombre} ha sido eliminado de tu Wishlist.`);
    actualizarWishlist();
}

// Función para aplicar un cupón de descuento
function aplicarCupon(codigo) {
    const descuento = codigo === "DESCUENTO10" ? 0.10 : 0; // 10% de descuento
    if (descuento > 0) {
        carrito = carrito.map(producto => ({ ...producto, precio: producto.precio * (1 - descuento) }));
        mostrarNotificacion("Cupón aplicado con éxito. 10% de descuento en tu compra.");
        actualizarCarrito();
    } else {
        mostrarNotificacion("Cupón inválido.");
    }
}

// Función para guardar el carrito en localStorage
function guardarCarrito() {
    localStorage.setItem('carrito', JSON.stringify(carrito));
}

// Función para cargar el carrito desde localStorage
function cargarCarrito() {
    const carritoGuardado = localStorage.getItem('carrito');
    if (carritoGuardado) {
        carrito = JSON.parse(carritoGuardado);
        actualizarCarrito();
        actualizarContador();
    }
}

// Función para cambiar entre modo oscuro/claro
function alternarModoOscuro() {
    document.body.classList.toggle('modo-oscuro');
}

// Cargar carrito al iniciar
cargarCarrito();


