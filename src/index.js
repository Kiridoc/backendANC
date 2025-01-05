const express = require('express');
const morgan = require('morgan');
const pool = require('./database');
const bodyParser = require('body-parser');
const cors = require("cors");

//Configuración inicial
const app = express();
app.set("port", 4000);
app.listen( app.get("port"), () =>{
    console.log("Estoy escuchando las comunicaciones del puerto "+ app.get("port"));
});

//Middlewares
app.use(cors({
  origin: ["http://localhost:5173"]
}));
app.use(morgan('dev'));
app.use(bodyParser.json());


//Rutas para preguntas frecuentes
//GET
app.get('/pregunta', async (rec, res) =>{
    try{
        const result = await pool.query('SELECT * from mostrar_preguntas_frecuentes()');
        res.status(200).json(result.rows);
    }catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error obteniendo las preguntas frecuentes' })
    }
});

//GET BY ID
app.get('/pregunta/:id', async (req, res) => {
    const { id } = req.params;
    try {
      const result = await pool.query('SELECT * FROM pregunta_frecuente WHERE id = $1', [id]);
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Pregunta frecuente no encontrada' });
      }
      res.status(200).json(result.rows[0]);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error obteniendo la pregunta frecuente' });
    }
  });

  //CREATE
  app.post('/pregunta', async (req, res) => {
    const { pregunta, respuesta } = req.body;
    try {
      const result = await pool.query('SELECT agregar_pregunta_frecuente($1, $2)', [pregunta, respuesta]);
      res.status(201).json( {message: 'Pregunta frecuente creada exitosamente'} );
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error creando la pregunta frecuente' });
    }
  });
  
  //UPDATE
  app.put('/pregunta/:id', async (req, res) => {
    const { id } = req.params;
    const { pregunta, respuesta } = req.body;
    try {
      await pool.query('SELECT modificar_pregunta_frecuente($1, $2, $3)', [id, pregunta, respuesta]);
      res.status(200).json({ message: 'Pregunta frecuente actualizada exitosamente' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error actualizando la pregunta frecuente' });
    }
  });

  //DELETE
  app.delete('/pregunta/:id', async (req, res) => {
    const { id } = req.params;
    try {
      await pool.query('SELECT eliminar_pregunta_frecuente($1)', [id]); // Asegurar que el ID es un entero
      res.status(200).json({ message: 'Pregunta frecuente eliminada exitosamente' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error eliminando la pregunta frecuente' });
    }
  });
  
  

  

//Rutas para eventos
//GET
app.get('/evento', async (rec, res) =>{
  try{
      const result = await pool.query('SELECT * FROM mostrar_eventos()');
      res.status(200).json(result.rows);
  }catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error obteniendo el evento' })
  }
});

//GET BY ID
app.get('/evento/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM evento WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Evento no encontrado' });
    }
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error obteniendo el evento' });
  }
});

//CREATE
app.post('/evento', async (req, res) => {
  const { pregunta, respuesta } = req.body;
  try {
    const result = await pool.query('SELECT agregar_evento($1, $2, $3, $4, $5)', [nombre_evento, titulo, descripcion, fecha, imagen]);
    res.status(201).json( {message: 'Evento creado exitosamente'} );
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error creando el evento' });
  }
});

//UPDATE
app.put('/evento/:id', async (req, res) => {
  const { id } = req.params;
  const { pregunta, respuesta } = req.body;
  try {
    await pool.query('SELECT modificar_evento($1, $2, $3, $4, $5, $6)', [id, nombre_evento, titulo, descripcion, fecha, imagen]);
    res.status(200).json({ message: 'Evento actualizado exitosamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error actualizando el evento' });
  }
});

//DELETE
app.delete('/evento/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('SELECT eliminar_evento($1)', [id]);
    res.status(200).json({ message: 'Evento eliminado exitosamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error eliminando el evento' });
  }
});

//Rutas para usuarios
//GET
app.get('/usuario', async (rec, res) =>{
  try{
      const result = await pool.query('SELECT * from mostrar_usuarios()');
      res.status(200).json(result.rows);
  }catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error obteniendo los usuarios' })
  }
});

//GET BY ID
app.get('/usuario/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM usuario WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Usuario no encontrado' });
    }
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error obteniendo el usuario' });
  }
});

//CREATE
app.post('/usuario', async (req, res) => {
  const { pregunta, respuesta } = req.body;
  try {
    const result = await pool.query('SELECT agregar_usuario($1, $2, $3, $4, 5$)', [nombre, contraseña, telefono, is_asignado, id_rol_usuario]);
    res.status(201).json( {message: 'Usuario creado exitosamente'} );
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error creando el usuario' });
  }
});

//UPDATE
app.put('/usuario/:id', async (req, res) => {
  const { id } = req.params;
  const { pregunta, respuesta } = req.body;
  try {
    await pool.query('SELECT modificar_is_asignado($1, $2)', [id, is_asignado]);
    res.status(200).json({ message: 'Usuario actualizado exitosamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error actualizando el usuario' });
  }
});

//DELETE
app.delete('/usuario/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('SELECT eliminar_usuario($1)', [id]);
    res.status(200).json({ message: 'Usuario eliminado exitosamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error eliminando el usuario' });
  }
});


//Rutas para buzon
//GET
app.get('/buzon', async (rec, res) =>{
  try{
      const result = await pool.query('SELECT * from mostrar_preguntas_buzon()');
      res.status(200).json(result.rows);
  }catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error obteniendo las preguntas del buzon' })
  }
});

//GET BY ID
app.get('/buzon/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM buzon WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pregunta no encontrada' });
    }
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error obteniendo la pregunta' });
  }
});

//CREATE
app.post('/buzon', async (req, res) => {
  const { pregunta, respuesta } = req.body;
  try {
    const result = await pool.query('SELECT agregar_pregunta_buzon($1, $2)', [pregunta, correo]);
    res.status(201).json( {message: 'Pregunta creada exitosamente'} );
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error creando la pregunta' });
  }
});

//DELETE
app.delete('/buzon/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('SELECT eliminar_pregunta_buzon($1)', [id]);
    res.status(200).json({ message: 'Pregunta eliminado exitosamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error eliminando la pregunta' });
  }
});

//Rutas para show
//GET
app.get('/show', async (rec, res) =>{
  try{
      const result = await pool.query('SELECT * from mostrar_shows()');
      res.status(200).json(result.rows);
  }catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error obteniendo los shows' })
  }
});

//GET BY ID
app.get('/show/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const result = await pool.query('SELECT * FROM show WHERE id = $1', [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Show no encontrado' });
    }
    res.status(200).json(result.rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error obteniendo el show' });
  }
});

//UPDATE
app.put('/show/:id', async (req, res) => {
  const { id } = req.params;
  const { pregunta, respuesta } = req.body;
  try {
    await pool.query('SELECT modificar_show($1, $2, $3, $4, $5, $6, $7)', [id, is_disponible, horario, costo, intereaccion_niños, interaccion_adultos, ubicacion]);
    res.status(200).json({ message: 'Show actualizado exitosamente' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error actualizando el show' });
  }
});
  
  
