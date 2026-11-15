# Laboratorio Unidad 6 — Instrucciones y direccionamiento x86

**Estudiante:** Johan Barrera  
**Código:** 1152538  
**Asignatura:** Arquitectura de computadores  
**Universidad:** UFPS — Cúcuta  
**Repositorio:** `barrera-post1-u6`

## Parte 1

### Decisión técnica 1 — SHL/SHR frente a ROL/ROR

El estudiante selecciona SHL y SHR cuando necesita desplazar posiciones binarias para operaciones aritméticas con valores sin signo. SHL equivale a multiplicar por una 
potencia de dos dentro del ancho disponible, siempre que se controle el desbordamiento; SHR equivale a una división entera sin signo y descarta los bits asociados al 
resto. Para enteros negativos, SHR no sustituye sin más a una división con signo.

El estudiante selecciona ROL o ROR cuando necesita conservar los bits mediante una permutación circular, como en el intercambio de nibbles o una transformación 
circular de datos. Sobre AL=81h, SHL expulsa el bit 7 y deja AL=02h, con CF=1; ROL reinserta ese bit como bit 0 y produce AL=03h. Aplicar solamente SHL pierde 
información y un OR posterior no puede reconstruirla si no existe una copia del valor original u otra fuente de esos bits.

Sí es posible intercambiar nibbles mediante desplazamientos y OR cuando se conserva previamente el original: `(x << 4) | (x >> 4)`, limitado a ocho bits. Por tanto, la 
imposibilidad se refiere a recuperar información descartada sin haberla conservado, no a todas las combinaciones posibles con OR.

En el intercambio de nibbles, una rotación de cuatro posiciones transforma A5h en 5Ah sin necesitar una copia auxiliar. El resultado conserva los ocho bits originales 
y únicamente cambia su posición.

### Decisión técnica 2 — LOOP frente a DEC/JNZ

**Aspectos del enunciado que se responden:** Legibilidad y tamaño; instrucciones frente a ciclos; cinco iteraciones frente a millones.

El estudiante conserva LOOP por la claridad del propósito didáctico: una instrucción expresa el decremento del contador CX y la repetición condicionada a que sea 
distinto de cero. En este código de 16 bits, LOOP con salto corto ocupa dos bytes; DEC CX seguido de JNZ corto ocupa tres. Sin embargo, la cantidad de instrucciones 
escritas no determina por sí sola la velocidad.

Cada procesador implementa decodificación, ejecución y predicción de saltos de forma distinta; una instrucción compacta puede requerir más trabajo interno que dos 
instrucciones sencillas. En muchos procesadores modernos LOOP puede resultar más costosa, aunque no existe una regla de ciclos universal para todas las 
microarquitecturas. En cinco iteraciones la diferencia no es perceptible para el usuario.

En millones de repeticiones conviene medir el procesador objetivo y comparar variantes equivalentes. Además, DEC/JNZ modifica banderas que LOOP conserva: la 
sustitución exige revisar si el código posterior depende de ellas. DOSBox es un entorno de emulación y no debe emplearse para inferir automáticamente tiempos de una }CPU física moderna.

## Parte 2

### Decisión técnica 3 — directo frente a indexado

**Aspectos del enunciado que se responden:** Posición fija y costo del cálculo; índices variables; recorrido de las nueve posiciones.

El estudiante considera apropiado el modo directo cuando la posición de un elemento se conoce al ensamblar. Para matriz[1][2], la instrucción `mov dx,[matriz+10]` 
evita calcular en ejecución el producto de fila por ancho, los desplazamientos y la suma de offsets del ejemplo didáctico. La dirección se codifica como un 
desplazamiento en la instrucción; no es correcto afirmar que forma parte del opcode en sentido estricto.

La comparación de eficiencia corresponde a estas secuencias completas, no a una regla que declare siempre más lento cualquier acceso indexado. Cuando fila o columna }
dependen de entradas o valores calculados durante la ejecución, conviene obtener dinámicamente la dirección mediante registros. Para recorrer nueve posiciones, un 
bucle indexado expresa una sola operación y reduce repetición, facilitando cambiar el tamaño del arreglo.

Nueve accesos directos siguen siendo técnicamente posibles e incluso podrían usarse en un bucle desenrollado por optimización; no son imposibles, pero resultan menos 
generales y más repetitivos para este ejercicio. El estudiante prefiere el recorrido indexado por claridad y mantenimiento.

Con tres columnas y elementos de dos bytes, el desplazamiento de matriz[1][2] se resuelve al ensamblar como (1×3+2)×2=10. Así se elimina la secuencia de MUL, SHL, ADD 
y movimientos auxiliares usada para calcular esa posición durante la ejecución.

### Decisión técnica 4 — BP frente a BX/SI

**Aspectos del enunciado que se responden:** Segmento predeterminado; diferencia entre COM y EXE; sobrescritura de segmento y uso práctico.

El estudiante utiliza BP como referencia estable para el marco de pila porque el direccionamiento de 16 bits basado en BP selecciona SS como segmento predeterminado. 
Los accesos habituales por BX, SI y DI usan DS, lo que facilita separar datos generales de parámetros y variables locales. La elección predeterminada está definida por 
la arquitectura, mientras que el uso de BP como marco es una convención de programación apoyada por ella.

En este programa COM, DS y SS coinciden al cargar el ejecutable, por lo que offsets iguales pueden referirse a la misma memoria. En un programa EXE con segmentos 
distintos, sustituir BX por BP sin considerar el segmento puede leer datos ajenos o sobrescribir la pila. Para imponer DS se utiliza un prefijo de sobrescritura de 
segmento, por ejemplo `mov ax,[ds:bp+2]`.

Esto puede resultar útil si BP se reutiliza como puntero a datos cuando los demás registros están ocupados y el programa controla expresamente su marco. Los registros 
no son completamente intercambiables: en direccionamiento de 16 bits no se admite cualquier combinación arbitraria de bases e índices.
