// Configuración para acceder a la base de datos de UNADroid
const Sequelize = require('sequelize');
const sequelize = new Sequelize('mysql://root:root@127.0.0.1:3306/unadroid');

// Configuración e instanciamiento del servidor
const express = require('express');
const app = express();
app.use(express.json());

// Configuración para enviar correos
const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

var port = process.env.PORT || 3000;

app.listen(port, function () {
    console.log('UNADroid-server listening on port ' + port + '!');
});

app.use(express.static('public'));

// Ruta por defecto cuando se carga el sitio raíz: https://unadroid.tk
app.get('/', (req, res) => res.send('UNADroid Server!'));

// Modelo de usuario
const User = sequelize.define('user', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
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
    name: {
        type: Sequelize.DataTypes.STRING
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

// Modelo de Resources (Permite mapear la entidad resources)
const Resource = sequelize.define('resource', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    resource_type_id: {
        type: Sequelize.DataTypes.INTEGER
    },
    unit_id: {
        type: Sequelize.DataTypes.INTEGER
    },
    topic_id: {
        type: Sequelize.DataTypes.INTEGER
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
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    iconName: {
        type: Sequelize.DataTypes.STRING
    },
    createdAt: {
        type: Sequelize.DataTypes.DATE
    },
    updatedAt: {
        type: Sequelize.DataTypes.DATE
    }
});

// Modelo de preguntas (Permite mapear la entidad evaluation_question)
const Question = sequelize.define('question', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    evaluation_id: {
        type: Sequelize.DataTypes.INTEGER
    },
    question_type_id: {
        type: Sequelize.DataTypes.INTEGER
    },
    question: {
        type: Sequelize.DataTypes.STRING
    },
    createdAt: {
        type: Sequelize.DataTypes.DATE
    },
    updatedAt: {
        type: Sequelize.DataTypes.DATE
    }
},
{
  freezeTableName: true,
  // define the table's name
  tableName: 'evaluation_question',
}
);

// Modelo de respuestas (Permite mapear la entidad evaluation_answer)
const Answer = sequelize.define('answer', {
    id: {
        type: Sequelize.DataTypes.INTEGER,
        primaryKey: true
    },
    evaluation_question_id: {
        type: Sequelize.DataTypes.INTEGER
    },
    answer: {
        type: Sequelize.DataTypes.STRING
    },
    correct: {
        type: Sequelize.DataTypes.INTEGER
    },
    createdAt: {
        type: Sequelize.DataTypes.DATE
    },
    updatedAt: {
        type: Sequelize.DataTypes.DATE
    }
},
{
  freezeTableName: true,
  // define the table's name
  tableName: 'evaluation_answer',
}
);

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
                error_msg: 'La dirección de correo ya está registrada.'
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
            user.reload();

            const msg = {
                to: user.email,
                from: 'admin@unadroid.tk',
                subject: 'UNADroid - registro exitoso',
                // text: 'and easy to do anywhere, even with Node.js',
                html: '<p>Hola ' + user.firstName + ':</p>' +
                '<p>Hemos creado tu cuenta en UNADroid</p>' +
                '<p><strong>El equipo de UNADroid</strong></p>',
            };
            sgMail.send(msg);

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

// Recuperación de acceso
app.get('/api/recover/:email', (req, res) => {
    User.findOne({
        where: {
            email: req.params.email,
        }
    }).then(user => {
        res.setHeader('Content-type', 'application/json');

        const msg = {
            to: user.email,
            from: 'admin@unadroid.tk',
            subject: 'UNADroid - recuperación de acceso',
            html: '<p>Hola ' + user.firstName + ':</p>' +
            '<p>Tu contraseña de acceso es: </p>' + user.password +
            '<p><strong>El equipo de UNADroid</strong></p>',
        };
        sgMail.send(msg);

        res.send({});
    }).catch(() => {
        res.setHeader('Content-type', 'application/json');

        let error = {
            error: true,
            error_msg: "Usa tu dirección de correo electrónico"
        };

        res.send(error);
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

// Cambiar contraseña
app.put('/api/user/setPassword', (req, res) => {
    User.findOne({
        where: {
            email: req.body.email,
        }
    }).then(user  => {
        res.setHeader('Content-type', 'application/json');

        if (!user) {
            let error = {
                error: true,
                error_msg: 'El usuario no existe.'
            };

            res.send(error);

            return;
        }

        user.password = req.body.password;

        user.save({
            fields: ['password']
        }).then(user => {
            res.send(user);
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


// Esta seccion devuelve el listado de recursos segun una unidad y un tema
app.get('/api/resource/unit/:unit_id/topic_id/:topic_id', (req, res) => {
    Resource.findAll({
        where: {
            unit_id: req.params.unit_id,
            topic_id:req.params.topic_id
        }
    }).then(resources => {
        res.setHeader('Content-type', 'application/json');
        res.send(resources);
    })
});

// Esta seccion devuelve el listado de preguntas segun un codigo de evaluacion
app.get('/api/question/evaluation_id/:evaluation_id', (req, res) => {
    Question.findAll({
        where: {
            evaluation_id: req.params.evaluation_id
        }
    }).then(questions => {
        res.setHeader('Content-type', 'application/json');
        res.send(questions);
    })
});

// Esta seccion devuelve el listado de preguntas segun un codigo de evaluacion
app.get('/api/answer/question_id/:question_id', (req, res) => {
    Answer.findAll({
        where: {
            evaluation_question_id: req.params.question_id
        }
    }).then(answers => {
        res.setHeader('Content-type', 'application/json');
        res.send(answers);
    })
});
