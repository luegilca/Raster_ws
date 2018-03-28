# Taller raster

## Propósito

Comprender algunos aspectos fundamentales del paradigma de rasterización.

## Tareas

Emplee coordenadas baricéntricas para:

1. Rasterizar un triángulo;
2. Implementar un algoritmo de anti-aliasing para sus aristas; y,
3. Hacer shading sobre su superficie.

Implemente la función ```triangleRaster()``` del sketch adjunto para tal efecto, requiere la librería [frames](https://github.com/VisualComputing/framesjs/releases).

## Integrantes

Máximo 3.

Complete la tabla:

| Integrante | github nick |
|------------|-------------|
|Luis Ernesto Gil Castellanos|luegilca|
|Juan Sebastián Martínez Beltrán|juasmartinezbel|

## Discusión

Describa los resultados obtenidos. Qué técnicas de anti-aliasing y shading se exploraron? Adjunte las referencias. Discuta las dificultades encontradas.
### Referencias:
Se implementó un algoritmo de Multisampling anti-aliasing (MSAA) de [malla fija](https://en.wikipedia.org/wiki/Multisample_anti-aliasing#Regular_grid), donde se puede aumentar el muestreo a 2x, 4x, 8x, 16x, y para efectos de este ejercicio de rasterización de una sola primitiva, hasta 32x por pixel.

En el shading, se utilizó una técnica donde se añadió a los vértices un atributo: el color, cada vértice en orden contrario a las manecillas del reloj se le otorgó el color rojo, verde y azul respectivamente. Gracias a las coordenadas baricéntricas y a estos atributos de color, se sombrea con la interpolación de los tres colores sobre la superficie de la primitiva.

Una de las dificultades encontradas fue lograr implementar el algoritmo de antialiasing, pues particularmente se intentó uno que no fuera MSAA, como un SuperSampling aleatorio, sin embargo, los resultados a cualquier escala no fueron tan satisfactorios, como los del muestreo múltiple.

### Referencias

[The barycentric conspiracy](https://fgiesen.wordpress.com/2013/02/06/the-barycentric-conspirac/)
[The rasterization stage](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage)

## Entrega

* Modo de entrega: [Fork](https://help.github.com/articles/fork-a-repo/) la plantilla en las cuentas de los integrantes (de las que se tomará una al azar).
* Plazo: 1/4/18 a las 24h.
