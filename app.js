// Configuración para acceder a la base de datos de UNADroid
const Sequelize = require('sequelize');
const sequelize = new Sequelize('mysql://root:root@127.0.0.1:3306/unadroid');

// Configuración e instanciamiento del servidor
const express = require('express');
const app = express();
app.use(express.json());

// Ruta por defecto cuando se carga el sitio raíz: https://unadroid.tk
app.get('/', (req, res) => res.send('UNADroid Server!'));

// Modelo de usuario
const User = sequelize.define('user', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    email: {
        type: Sequelize.DataTypes.STRING
    },
    password: {
        type: Sequelize.DataTypes.STRING
    },
    firstName: {
        type: Sequelize.DataTypes.STRING
    },
    lastName: {
        type: Sequelize.DataTypes.STRING
    }
});

// ----------------------------------------------------------------------------
// Sección IAM, define las rutas y funciones para el registro e ingreso de los
// usuarios
// ----------------------------------------------------------------------------

// Ingreso de usuarios
app.post('/api/login', (req, res) => {
    User.findAll({
        where: {
            email: req.body.email
        }
    }).then(users => {
        res.setHeader('Content-type', 'application/json');

        let error = {
            error: true,
            error_msg: 'Credenciales no válidas'
        };

        // El usuario no existe
        if (users.length !== 1) {
            res.send(error);
            return;
        }

        // La contraseña no coincide
        let user = users[0];
        if(req.body.password !== user.password) {
            res.send(error);
            return;
        }

        // Se envia el usuario
        res.send(user);
    });
});

// Registro de usuario
app.post('/api/register', (req, res) => {
    User.findAll({
        where: {
            email: req.body.email
        }
    }).then(users  => {
        res.setHeader('Content-type', 'application/json');

        // Si la dirección de correo ya está registrada no se puede crear el usuario.
        if (users.length === 1) {
            let error = {
                error: true,
                error_msg: 'La dirección de correo ya está registrada'
            };

            res.send(error);

            return;
        }

        // Insertar el usuario
        User.create({
            email: req.body.email,
            password: req.body.password,
            firstName: req.body.firstName,
            lastName: req.body.lastName
        }).then(user => {
            res.send(user);
        });
    });
});

// Actualizar usuario
app.post('/api/update', (req, res) => {
    User.findOne({
        where: {
            email: req.body.email
        }
    }).then(users  => {
        res.setHeader('Content-type', 'application/json');
        // Editar el usuario
        User.create({
            email: req.body.email,
            firstName: req.body.firstName,
            lastName: req.body.lastName
        }).then(user => {
            res.send(user);
        });
    });
});


// Actualizar usuario
app.post('/api/getUser', (req, res) => {
    User.findOne({
        where: {
            email: req.body.email
        }
    }).then(user  => {
        res.setHeader('Content-type', 'application/json');
        // Enviar datos del usuario
        res.send(user);
    });
});


// ----------------------------------------------------------------------------
// Sección de recursos. Define las rutas y funciones para obtener los recursos
// del curso
// ----------------------------------------------------------------------------

const Video = sequelize.define('video', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    unit: {
        type: Sequelize.DataTypes.STRING
    },
    name: {
        type: Sequelize.DataTypes.STRING
    },
    description: {
        type: Sequelize.DataTypes.STRING
    },
    url: {
        type: Sequelize.DataTypes.STRING
    },
    order: {
        type: Sequelize.DataTypes.INTEGER
    }
});

// Videos
app.get('/api/videos', (req, res) => {
    Video.findAll().then(videos => {
        res.setHeader('Content-type', 'application/json');
        res.send(videos);
    });
});

app.listen(3000, () => console.log('UNADroid-server listening on port 3000!'));
