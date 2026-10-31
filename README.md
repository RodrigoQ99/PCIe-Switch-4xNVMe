# Switch PCIe Gen3 x4 a 4 SSD NVMe

Proyecto final: una tarjeta PCIe x4 que reparte su enlace a cuatro SSD NVMe M.2 usando el switch PI7C9X3G808GP de Diodes/Pericom. Parte del esquemático de la tarjeta de evaluación del fabricante (EVB V1.6), quitando los signal switches y conectando las lanes directo: los gold fingers al switch y cada puerto de bajada a un M.2.

Diseñado en OrCAD X 25.1: esquemático en Capture y PCB en Allegro.

Hecho por José Rodrigo Quiroa Dávila, estudiante de Ingeniería en Electrónica y Telecomunicaciones de la Universidad del Istmo.

## Estado del proyecto

**Esquemático: casi terminado.**
- Upstream x4 directo de los gold fingers al switch.
- Hoja 10 rehecha con cuatro M.2 M-key 2280 (J44–J47), cada uno con sus caps AC de 220 nF, REFCLK, PERST# y desacople. Revisada pin por pin.
- Potencia ajustada al slot: 12 V para los reguladores y 3.3 V del slot como entrada de potencia de los LMZ31704.
- Todas las partes tienen footprint asignado.

**PCB: placa creada.** El netlist pasa sin errores y la placa `layout/PCIe_Switch_4xNVMe.brd` ya tiene las 345 partes y sus nets. Allegro ya carga los footprints que vienen del EVB; faltan 9 por dibujar. Ya están definidos el stackup de 6 capas y las reglas de 85 Ω diferencial, tomados del EVB.

## Qué hay en cada carpeta

- `orcad`: el proyecto de Capture (`PCIe_Switch_4xNVMe.opj`) y el esquemático.
- `layout`: la placa de Allegro.
- `docs`: decisiones de diseño, tabla de conexiones lane por lane y plan de captura.
- `herramientas/capture_tcl`: scripts de TCL que usé en Capture para armar los sockets M.2, asignar footprints y revisar las conexiones.
- `entregables`: aquí irán el PDF del esquemático, los Gerbers y los archivos de taladro.

El kit de diseño y la tarjeta de evaluación del fabricante no se incluyen en el repositorio; se descargan de la página de Diodes.

## Lo que falta

1. Dibujar los 9 footprints que faltan: M.2 M-key 2280, LMZ31704 (B3QFN-42), LMZ31530 (QFN-72), AP7361C (DFN8 3×3), SO-14, TSSOP-20, ferrita 1812, tantalio 7343 y el conector auxiliar de 6 pines.
3. Contorno, colocación, ruteo de PCIe y potencia, y DRC.
4. Gerbers, reporte y video.
