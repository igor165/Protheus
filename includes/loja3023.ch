#ifdef SPANISH
	#define STR0001 "Codigo"
	#define STR0002 "Descripcion"
	#define STR0003 "Categoria de productos"
	#define STR0004 "Categorias"
	#define STR0005 "Producto/Categoria"
	#define STR0006 "Buscar"
	#define STR0007 "Productos seleccionados"
	#define STR0008 "Producto:"
	#define STR0009 "Productos seleccionados:"
	#define STR0010 "OK"
	#define STR0011 "Anular"
	#define STR0012 "Digite el codigo de producto o categoria a buscar."
	#define STR0013 "No encontrado"
	#define STR0014 "Producto no encontrado"
	#define STR0015 "¡Disponible solamente para regla de descuento por ítem!"
	#define STR0016 "Atención"
#else
	#ifdef ENGLISH
		#define STR0001 "Code"
		#define STR0002 "Description"
		#define STR0003 "Product category"
		#define STR0004 "Categories"
		#define STR0005 "Product/Category"
		#define STR0006 "Search"
		#define STR0007 "Products selected"
		#define STR0008 "Product:"
		#define STR0009 "Products selected:"
		#define STR0010 "OK"
		#define STR0011 "Cancel"
		#define STR0012 "Type the product code or category to search."
		#define STR0013 "Not found"
		#define STR0014 "Product not found"
		#define STR0015 "Available only for Discount Rule per item!"
		#define STR0016 "Attention"
	#else
		#define STR0001 "Código"
		#define STR0002 "Descrição"
		#define STR0003 If( cPaisLoc $ "ANG|PTG", "Categoria de artigos", "Categoria de produtos" )
		#define STR0004 "Categorias"
		#define STR0005 If( cPaisLoc $ "ANG|PTG", "Artigo/Categoria", "Produto/Categoria" )
		#define STR0006 "Pesquisar"
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Artigos seleccionados", "Produtos selecionados" )
		#define STR0008 If( cPaisLoc $ "ANG|PTG", "Artigo:", "Produto:" )
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "Artigos seleccionados:", "Produtos selecionados:" )
		#define STR0010 "OK"
		#define STR0011 "Cancelar"
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Digite o código do artigo ou categoria para pesquisar.", "Digite o código do produto ou categoria para pesquisar." )
		#define STR0013 "Não encontrado"
		#define STR0014 If( cPaisLoc $ "ANG|PTG", "Artigo não encontrado", "Produto não encontrado" )
		#define STR0015 "Disponível somente para Regra de Desconto por Item!"
		#define STR0016 "Atenção"
	#endif
#endif
