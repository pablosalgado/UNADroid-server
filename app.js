// Configuración para acceder a la base de datos de UNADroid
const Sequelize = require('sequelize');
const sequelize = new Sequelize('mysql://root:root@127.0.0.1:3306/unadroid');

// Configuración e instanciamiento del servidor
const express = require('express');
const app = express();
app.use(express.json());

var port = process.env.PORT || 3000;

app.listen(port, function () {
    console.log('UNADroid-server listening on port ' + port + '!');
});

// Ruta por defecto cuando se carga el sitio raíz: https://unadroid.tk
app.get('/', (req, res) => res.send('UNADroid Server!'));

// Modelo de usuario
const User = sequelize.define('user', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    email: {
        type: Sequelize.DataTypes.STRING,
        isUnique: true,
        allowNull: false,
        defaultValue: null,
        validate: {
            isEmail: {args: true, msg: 'El correo no tiene un formato valido'},
            notEmpty: { msg: 'Debe ingresar un correo' },
            isUnique: function (value, next) {
                var self = this;
                User.find({where: {email: value}})
                    .then(function (user) {
                        // reject if a different user wants to use the same email
                        if (user && self.id !== user.id) {
                            return next('El correo ingresado ya esta en uso!');
                        }
                        return next();
                    })
                    .catch(function (err) {
                        return next(err);
                    });
            }
        }
    },
    password: {
        type: Sequelize.DataTypes.STRING,
        defaultValue: null,
        validate:{
            notEmpty: { msg: 'Debe ingresar una contraseña' },
        }
    },
    firstName: {
        type: Sequelize.DataTypes.STRING,
        allowNull: false,
        defaultValue: null,
        validate:{
            notEmpty: { msg: 'Debe ingresar un nombre' },
        }
    },
    lastName: {
        type: Sequelize.DataTypes.STRING,
        allowNull: false,
        defaultValue: null,
        validate:{
            notEmpty: { msg: 'Debe ingresar apellidos' },
        }
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
    iconName: {
        type: Sequelize.DataTypes.STRING
    }
});

// Modelo de Evaluaciones (Permite mapear la entidad evaluations)
const Evaluation = sequelize.define('evaluation', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    unit_id: {
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
        }).catch(Sequelize.ValidationError, function (err) {

            var messages = '';
            Object.keys(err.errors).forEach(function (key) {
                messages += err.errors[key].message +' \n ';
            });

            let error = {
                error: true,
                error_msg: messages
            };

            res.send(error);
            return;
        });
    });
});

// datos usuario
app.get('/api/user/:email', (req, res) => {
    User.findOne({
        where: {
            email: req.params.email,
        }
    }).then(user  => {
        res.setHeader('Content-type', 'application/json');
        // Enviar datos del usuario
        res.send(user);
    });
});

//Se debe usar PUT /api/user. Se remueve en la siguiente iteración de puesta en producción
app.put('/api/user', (req, res) => {
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
            fields: ['firstName', 'lastName','email']
        }).then(u => {
            res.send(u);
        }).catch(Sequelize.ValidationError, function (err) {

            var messages = '';
            Object.keys(err.errors).forEach(function (key) {
                messages += err.errors[key].message +' \n';
            });

            let error = {
                error: true,
                error_msg: messages
            };

            res.send(error);
            return;
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
    },
    unitId: {
        type: Sequelize.DataTypes.INTEGER
    },
    unitName: {
        type: Sequelize.DataTypes.STRING
    },
});

// Videos
app.get('/api/videos', (req, res) => {
    Video.findAll().then(videos => {
        res.setHeader('Content-type', 'application/json');
        res.send(videos);
    });
});

app.get('/api/videos/:id', (req, res) =>{
    Video.findOne({
        where: {
            id: req.params.id,
        }
    }).then(video => {
        res.setHeader('Content-type', 'application/json');
        res.send(video);
    });
});

// ----------------------------------------------------------------------------
// SECCION PARA TEMATICAS
// ----------------------------------------------------------------------------
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

app.get('/api/unit/:unit_id/topics', (req, res) => {
    Topic.findAll({
        where: {
            unit_id: req.params.unit_id,
        }
    }).then(topics => {
        res.setHeader('Content-type', 'application/json');
        res.send(topics);
    })
});

// Esta seccion devuelve el listado de unidades disponibles
app.get('/api/units', (req, res) => {
    Unit.findAll().then(unit  => {
        res.setHeader('Content-type', 'application/json');
        // Enviar datos del usuario
        res.send(unit);
    });
});


// Esta seccion devuelve el listado de evaluaciones disponibles
app.get('/api/evaluations', (req, res) => {
    Evaluation.findAll().then(evaluation  => {
        res.setHeader('Content-type', 'application/json');
        // Enviar datos del usuario
        res.send(evaluation);
    });
});
