#ifdef SPANISH
	#define STR0001 "Servicio de presentacion del institucional de la empresa propietaria del portal"
	#define STR0002 "Metodo de presentacion del institucional de empresa <br><br><i> Este metodo retorna un texto que se inserira en la interfaz principal de portales, el texto puede contener tag's y formaciones especificas lenguaje html.  <br>El texto obtiene de parametro MV_PORTAL1, y este parametro debera contener el nombre del archivo que tendra el texto. Vale destacar que el archivo se buscara en directorio estandar del Server Aplication, respetando el Rootpath del mismo.</i>"
	#define STR0003 "Metodo de consulta a foto de la empresa. <br><br><i> Este metodo devulve la imagen que se insertara en la interfaz principal de los portales. <br>La imagen se obtendra del parametro MV_PORTAL2, siendo que ese parametro debera contener el nombre del archivo que contendra la imagen. Se destaca que se buscara el archivo en el directorio estandar del Server Aplication, respetando su RootPath.</i>"
	#define STR0004 "Metodo de consulta a las not�cias diarias de la empresa.<br><br><i>Este, devuelve las not�cias que se incluyen en la interfaz principal de los portales.<br>Las noticias se obtienen del parametro MV_PORTAL3, el cual debe tener el nombre del archivo con las noticias que se mostrar�n. Cabe resaltar que el archivo se buscara en el directorio estandar del Server Aplication, respetando el RootPath del mesmo.<br>La aplicacion muestra las noticias segun el n� de lineas del archivo"
	#define STR0005 "Metodo de consulta al logo de empresa. <br><br><i> Este metodo retorna la imagen que se inserira en interfaz de portales.   <br>La imagen se obtendra de parametro MV_PORTAL4, y este parametro debera contener el nombre del archivo que tendra la imagen. Vale destacar que el archivo se buscara en directorio estandar del Server Aplication, respetando el RootPath del mismo. </i>"
	#define STR0006 "Rellene el parametro MV_PORTAL1 con un archivo que contenga un texto normal o con uso de  tag's html"
	#define STR0007 "Configuracion"
	#define STR0008 "Complete el par�metro MV_PORTAL3 con un archivo que contenga un texto normal o con uso de tags html. Utilice el signo de igual para identificar el encabezado de la noticia. Ejemplo: Promociones=10% de descuento en todos los productos en la l�nea de Software"
	#define STR0009 "<br>La aplicaci�n mostr� las noticias de acuerdo con el n�mero de l�neas del archivo, es decir una l�nea representa una noticia, dos l�neas representan dos noticias, etc... El t�tulo de la noticia se obtendr� por medio de la siguiente nomenclatura: t�tulo=noticia</i>"
#else
	#ifdef ENGLISH
		#define STR0001 "Institutional presentation service concerning the company that owns the portal."
		#define STR0002 "Company institutional presentation method. <br><br><i> This method brings a text that will be inserted in the portal main interface; this text may have tags and specific formation of html language. <br>The text is got from the parameter MV_PORTAL1 which must have the name of the file that will comprise the text. We emphasize that the file will be searched in the Server Application standard directory, respecting its RootPath, respeitando o RootPath do mesmo.</i>"
		#define STR0003 "Query method to company photo. <br><br><i> This method returns an image that is added to the portal main surface. <br>The image is obtained from parameter MV_PORTAL2 - this parameter has the file name with the image. The file is searched in the Server Application standard directory, following its rootpath .</i>"
		#define STR0004 "Query Method to the company daily news.<br><br><i>This method returns the portal main interface news.<br>News are obtained from the parameter MV_PORTAL3, and this parameter must have the file name which has the displayed news .The file is searched in the Server Application default directory, according to its RootPath .<br>The application displays the news according to file lines number."
		#define STR0005 "Search method for the company logo. <br><br><i> This method brings the image to be inserted in the portals main interface. <br>The image will be got from the parameter  MV_PORTAL4 which must have the name of the file that will comprise the image. We emphasize that the file will be searched in the Server Application standard directory, respecting its RootPath</i>"
		#define STR0006 "Fill in the parameter MV_PORTAL1with a file that comprises a regular text or one that use html tag. "
		#define STR0007 "Setup"
		#define STR0008 "Enter parameter MV_PORTAL3 with a file containing a regular text or with the use of html tags. Use the equal sign to identify the header with the news. Example: Promotions = 10% of discount in all the products of the software line"
		#define STR0009 "<br> The application displays the news according to the number of rows of the file, that is, one row represents one piece of news, two rows represent two pieces of news etc. The title of the news is obtained as follows: title=news<i>"
	#else
		#define STR0001 "Servi�o de apresenta��o do institucional da empresa propriet�ria do portal"
		#define STR0002 "M�todo de apresenta��o do institucional da empresa. <br><br><i> Este m�todo retorna um texto que ser� inserido na interface principal dos portais, podendo o texto conter tag�s e forma��es espec�ficas da linguagem html. <br>O texto � obtido do par�metro MV_PORTAL1, sendo que este par�metro dever� conter o nome do arquivo que conter� o texto. Vale ressaltar que o arquivo ser� procurado no diret�rio padr�o do Server Aplication, respeitando o RootPath do mesmo.</i>"
		#define STR0003 "M�todo de consulta a foto da empresa. <br><br><i> Este m�todo retorna a imagem que ser� inserida na interface principal dos portais. <br>A imagem  ser� obtida do par�metro MV_PORTAL2, sendo que este par�metro dever� conter o nome do arquivo que conter� a imagem. Vale ressaltar que o arquivo ser� procurado no diret�rio padr�o do Server Aplication, respeitando o RootPath do mesmo.</i>"
		#define STR0004 If( cPaisLoc $ "ANG|PTG", "M�todo de consulta as not�cias di�rias da empresa.<br><br><i>Este m�todo retorna as not�cias que ser�o inseridas na interface principal dos portais.<br>As not�cias  ser�o obtidas do par�metro MV_PORTAL3, sendo que este par�metro dever� conter o nome do arquivo que conter� as not�cias que ser�o exibidas.Vale ressaltar que o arquivo ser� procurado no diret�rio padr�o do Server Aplication,respeitando o RootPath do mesmo.<br>A aplica��o exibir� as not�cias conforme o n�mero de linhas do ficheiro", "M�todo de consulta as not�cias di�rias da empresa.<br><br><i>Este m�todo retorna as not�cias que ser�o inseridas na interface principal dos portais.<br>As not�cias  ser�o obtidas do par�metro MV_PORTAL3, sendo que este par�metro dever� conter o nome do arquivo que conter� as not�cias que ser�o exibidas.Vale ressaltar que o arquivo ser� procurado no diret�rio padr�o do Server Aplication,respeitando o RootPath do mesmo.<br>A aplica��o exibir� as not�cias conforme o n�mero de linhas do arquivo" )
		#define STR0005 "M�todo de consulta ao logo da empresa. <br><br><i> Este m�todo retorna a imagem que ser� inserida na interface dos portais. <br>A imagem  ser� obtida do par�metro MV_PORTAL4, sendo que este par�metro dever� conter o nome do arquivo que conter� a imagem. Vale ressaltar que o arquivo ser� procurado no diret�rio padr�o do Server Aplication, respeitando o RootPath do mesmo.</i>"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Preencha o par�metro mv_portal1 com um ficheiro que contenha um texto normal ou com utiliza��o de tag�s html", "Preencha o param�tro MV_PORTAL1 com um arquivo que contenha um texto normal ou com uso de tag�s html" )
		#define STR0007 "Configura��o"
		#define STR0008 "Preencha o param�tro MV_PORTAL3 com um arquivo que contenha um texto normal ou com uso de tag�s html. Utilize o sinal de igual para identificar o cabe�alho da noticia. Exemplo: Promo��es=10% de desconto em todos os produtos na linha de Software"
		#define STR0009 "<br>A aplicac�o exibira as noticias conforme o numero de linhas do arquivo, ou seja uma linha representa uma noticia, duas linhas representam duas noticias, etc... O titulo da noticia sera obtida atraves da seguinte nomeclatura: titulo=noticia</i>"
	#endif
#endif
