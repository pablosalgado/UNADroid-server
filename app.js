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


// Modelo de unidades (Permite mapear la entidad units)
const Unit = sequelize.define('unit', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    name: {
        type: Sequelize.DataTypes.STRING
    },
    order: {
        type: Sequelize.DataTypes.INTEGER
    },
    description: {
        type: Sequelize.DataTypes.STRING
    },
    createdAt: {
        type: Sequelize.DataTypes.DATE
    },
    updatedAt: {
        type: Sequelize.DataTypes.DATE
    },
    iconname: {
        type: Sequelize.DataTypes.STRING
    },
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
        },
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

// datos usuario
app.post('/api/user', (req, res) => {
    User.findOne({
        where: {
            email: req.body.email,
        }
    }).then(user  => {
        res.setHeader('Content-type', 'application/json');
        // Enviar datos del usuario
        res.send(user);
    });
});


// Actualización de usuario
app.post('/api/userUpdate', (req, res) => {
    User.findOne({
        where: {
            id: req.body.id,
        }
    }).then(user => {
        res.setHeader('Content-type', 'application/json');

        if (!user) {
            let error = {
                error: true,
                error_msg: 'El usuario no existe.'
            };

            res.send(error);

            return;
        }

        user.firstName = req.body.firstName;
        user.lastName = req.body.lastName;
        user.email = req.body.email;

        user.save({
            fields: ['firstName', 'lastName']
        }).then(u => {
            res.send(u);
        });
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

//SECCION PARA TEMATICAS

const Topic = sequelize.define('topic', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    name: {
        type: Sequelize.DataTypes.STRING
    },
    description: {
        type: Sequelize.DataTypes.STRING
    },
    order: {
        type: Sequelize.DataTypes.INTEGER
    },
    unit_id: {
        type: Sequelize.DataTypes.INTEGER
    }
});


app.post('/api/topics', (req, res) => {
    Topic.findAll({
        where: {
            unit_id: req.body.unit_id,
        }
    }).then(topics => {
        res.setHeader('Content-type', 'application/json');
        res.send(topics);
    })
});


var port = process.env.PORT || 3000;

app.listen(port, function () {
    console.log('UNADroid-server listening on port ' + port + '!');
});

// Esta seccion devuelve el llstado de unidades disponibles
app.post('/api/getUnits', (req, res) => {
    Unit.findAll().then(unit  => {
        res.setHeader('Content-type', 'application/json');
        // Enviar datos del usuario
        res.send(unit);
    });
});
