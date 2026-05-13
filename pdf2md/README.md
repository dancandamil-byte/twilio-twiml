# pdf2md - Conversor de PDF a Markdown

Herramienta de linea de comandos para convertir archivos PDF a formato Markdown. Soporta tanto PDFs con texto nativo como PDFs escaneados (mediante OCR).

## Requisitos del sistema

### Tesseract OCR

Para la funcionalidad de OCR (PDFs escaneados), es necesario instalar Tesseract:

**Ubuntu/Debian:**
```bash
sudo apt-get install tesseract-ocr tesseract-ocr-spa
```

**macOS:**
```bash
brew install tesseract
brew install tesseract-lang
```

**Windows:**
- Descargar el instalador desde: https://github.com/UB-Mannheim/tesseract/wiki
- Agregar Tesseract al PATH del sistema

### Python

Se requiere Python 3.9 o superior.

## Instalacion

```bash
# Clonar o copiar el proyecto
cd pdf2md

# Instalar en modo desarrollo
pip install -e .

# O instalar dependencias directamente
pip install -r requirements.txt
```

## Uso

### Convertir un archivo PDF

```bash
pdf2md convert archivo.pdf
```

### Convertir todos los PDFs en un directorio

```bash
pdf2md convert ./carpeta/ -o ./salida/
```

### Opciones disponibles

```bash
pdf2md convert --help
```

| Opcion      | Descripcion                           | Valor por defecto |
|-------------|---------------------------------------|-------------------|
| `--output`  | Directorio de salida                  | `./output/`       |
| `--lang`    | Idioma para OCR                       | `spa`             |
| `--dpi`     | DPI para conversion de imagenes       | `300`             |
| `--force`   | Sobrescribir archivos existentes      | Desactivado       |
| `--verbose` | Mostrar informacion detallada         | Desactivado       |

### Ejemplos

```bash
# Conversion basica
pdf2md convert documento.pdf

# Especificar directorio de salida
pdf2md convert documento.pdf -o ./markdown/

# Convertir con OCR en ingles
pdf2md convert escaneado.pdf -l eng

# Forzar reconversion
pdf2md convert documento.pdf --force

# Modo verbose
pdf2md convert ./pdfs/ -v
```

## Tipos de PDF soportados

- **PDFs con texto nativo**: Extraen texto directamente con metadatos de fuente para detectar encabezados, negritas e italicas.
- **PDFs escaneados**: Utilizan OCR (Tesseract) para extraer texto de las imagenes.

## Deteccion automatica

La herramienta detecta automaticamente si un PDF es nativo o escaneado analizando la cantidad de texto extraible por pagina. Si el promedio es menor a 50 caracteres por pagina, se clasifica como escaneado.

## Limitaciones

- La deteccion de tablas se basa en heuristica de espaciado y puede no funcionar con todas las tablas.
- La calidad del OCR depende de la resolucion y claridad del documento escaneado.
- No se preservan imagenes del PDF original en la salida Markdown.
- La deteccion de encabezados por texto en mayusculas puede generar falsos positivos con acronimos largos.
- Se requiere Tesseract instalado en el sistema para procesar PDFs escaneados.
