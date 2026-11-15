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