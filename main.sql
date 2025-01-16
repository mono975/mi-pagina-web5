-- Crear la base de datos para la tienda online

-- Tabla de usuarios
CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    direccion TEXT NOT NULL,
    telefono TEXT,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de productos
CREATE TABLE IF NOT EXISTS productos (
    id_producto INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre TEXT NOT NULL,
    descripcion TEXT NOT NULL,
    precio REAL NOT NULL,
    stock INTEGER NOT NULL CHECK (stock >= 0),
    imagen TEXT,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de carrito (por usuario)
CREATE TABLE IF NOT EXISTS carrito (
    id_carrito INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha_agregado DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE
);

-- Tabla de pedidos
CREATE TABLE IF NOT EXISTS pedidos (
    id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    total REAL NOT NULL,
    estado TEXT DEFAULT 'Pendiente',
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

-- Tabla de detalles de pedido
CREATE TABLE IF NOT EXISTS detalle_pedido (
    id_detalle INTEGER PRIMARY KEY AUTOINCREMENT,
    id_pedido INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario REAL NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido) ON DELETE CASCADE,
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE
);

-- Tabla de notificaciones
CREATE TABLE IF NOT EXISTS notificaciones (
    id_notificacion INTEGER PRIMARY KEY AUTOINCREMENT,
    id_usuario INTEGER NOT NULL,
    mensaje TEXT NOT NULL,
    leido BOOLEAN DEFAULT 0,
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
);

-- Índices para optimizar consultas
CREATE INDEX idx_carrito_usuario ON carrito(id_usuario);
CREATE INDEX idx_pedidos_usuario ON pedidos(id_usuario);
CREATE INDEX idx_detalle_pedido_pedido ON detalle_pedido(id_pedido);

-- Trigger para actualizar el stock cuando se realiza un pedido
CREATE TRIGGER IF NOT EXISTS actualizar_stock
AFTER INSERT ON detalle_pedido
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END;

-- Trigger para verificar stock antes de agregar al carrito
CREATE TRIGGER IF NOT EXISTS verificar_stock_carrito
BEFORE INSERT ON carrito
WHEN (SELECT stock FROM productos WHERE id_producto = NEW.id_producto) < NEW.cantidad
BEGIN
    SELECT RAISE(ABORT, 'Stock insuficiente para el producto seleccionado.');
END;

-- Función para calcular el total del pedido
CREATE VIEW IF NOT EXISTS vista_total_pedido AS
SELECT 
    p.id_pedido,
    u.nombre AS usuario,
    p.fecha_pedido,
    SUM(dp.cantidad * dp.precio_unitario) AS total
FROM pedidos p
JOIN usuarios u ON p.id_usuario = u.id_usuario
JOIN detalle_pedido dp ON p.id_pedido = dp.id_pedido
GROUP BY p.id_pedido;

-- Datos iniciales (opcional)
INSERT INTO productos (nombre, descripcion, precio, stock, imagen) VALUES
('Smartphone', 'Teléfono inteligente con características avanzadas.', 799.99, 50, 'producto1.jpg'),
('Camiseta de algodón', 'Camiseta de algodón 100% cómoda y ligera.', 19.99, 100, 'producto2.jpg'),
('Auriculares inalámbricos', 'Auriculares Bluetooth con sonido envolvente.', 59.99, 30, 'producto3.jpg'),
('Mochila deportiva', 'Mochila espaciosa y resistente para actividades deportivas.', 49.99, 20, 'producto4.jpg');

INSERT INTO usuarios (nombre, email, direccion, telefono) VALUES
('Juan Pérez', 'juan.perez@example.com', 'Calle Falsa 123', '123456789'),
('Ana López', 'ana.lopez@example.com', 'Avenida Siempre Viva 456', '987654321');

-- Prueba: Agregar productos al carrito
INSERT INTO carrito (id_usuario, id_producto, cantidad) VALUES
(1, 1, 2),
(1, 2, 1),
(2, 3, 1);

-- Prueba: Realizar un pedido
INSERT INTO pedidos (id_usuario, total) VALUES (1, 899.97);
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 2, 799.99),
(1, 2, 1, 19.99);

-- Consultar la vista del total del pedido
SELECT * FROM vista_total_pedido;