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
    }
});

//
// Ingreso de usuarios
//
app.post('/api/login', (req, res) => {
    res.setHeader('Content-type', 'application/json');

    let error = {
        error: true,
        error_msg: 'Credenciales no válidas'
    };

    User.findAll({
        where: {
            email: req.body.email
        }
    }).then(users => {
        if (users.length !== 1) {
            res.send(JSON.stringify(error));
            return;
        }

        let user = users[0];
        if(req.body.password !== user.password) {
            res.send(JSON.stringify(error));
            return;
        }

        res.send(user);
    });
});

app.listen(3000, () => console.log('UNADroid-server listening on port 3000!'));
