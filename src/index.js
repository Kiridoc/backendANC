const express = require('express');
const morgan = require('morgan');
const bodyPatse = require('body-parser')
const pool = require('./database');
const bodyParser = require('body-parser');

//Configuración inicial
const app = express();
app.set("port", 4000);
app.listen( app.get("port"), () =>{
    console.log("Estoy escuchando las comunicaciones del puerto "+ app.get("port"));
});

//Middlewares
app.use(morgan('dev'));
app.use(bodyParser.json());

//Rutas para preguntas frecuentes

//GET
app.get('/pregunta', async (rec, res) =>{
    try{
        const result = await pool.query('SELECT * from pregunta_frecuente');
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
      const result = await pool.query('SELECT agregar_pregunta($1, $2)', [pregunta, respuesta]);
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
      await pool.query('SELECT modificar_pregunta($1, $2, $3)', [id, pregunta, respuesta]);
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
      await pool.query('SELECT eliminar_pregunta($1)', [id]);
      res.status(200).json({ message: 'Pregunta frecuente eliminada exitosamente' });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'Error eliminando la pregunta frecuente' });
    }
  });
  
  
  