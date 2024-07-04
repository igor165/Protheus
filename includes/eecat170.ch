#ifdef SPANISH
	#define STR0001 "Buscar"
	#define STR0002 "Visualizar"
	#define STR0003 "Incluir"
	#define STR0004 "Modificar"
	#define STR0005 "Borrar"
	#define STR0006 "Mantenimiento de embalajes"
	#define STR0007 "¿Confirma el borrado?"
	#define STR0008 "Atencion"
	#define STR0009 "Grabando relacion de embalajes ..."
	#define STR0010 "Actualizando informaciones de embalajes ..."
	#define STR0011 "Embalajes de la embalaje "
	#define STR0012 "Este embalaje se esta utilizando en los empaques ###por lo tanto, no podra borrarse."
	#define STR0013 "Este embalaje se esta utilizando en el empaque ###por lo tanto, no podra borrarse."
	#define STR0014 "Mantenimiento"
	#define STR0015 "Este embalaje se está utilizando en los productos ###por lo tanto, no podrá borrarse."
	#define STR0016 "Este embalaje se está utilizando en el producto ###por lo tanto, no podrá borrarse."
#else
	#ifdef ENGLISH
		#define STR0001 "Search"
		#define STR0002 "View"
		#define STR0003 "Insert"
		#define STR0004 "Edit"
		#define STR0005 "Delete"
		#define STR0006 "Maintain packages"
		#define STR0007 "OK to Delete?"
		#define STR0008 "Attention"
		#define STR0009 "Saving packages relations ..."
		#define STR0010 "Updating packages information ..."
		#define STR0011 "Packages Package "
		#define STR0012 "This package is being used in packages ###therefore, it cannot be deleted. "
		#define STR0013 "This package is being used in package ###therefore, it cannot be deleted. "
		#define STR0014 "Maintenance"
		#define STR0015 "This packaging is being used in products ###, so it cannot be removed."
		#define STR0016 "This packaging is being used in product ###, so it cannot be removed."
	#else
		#define STR0001 "Pesquisar"
		#define STR0002 "Visualizar"
		#define STR0003 "Incluir"
		#define STR0004 "Alterar"
		#define STR0005 "Excluir"
		#define STR0006 If( cPaisLoc $ "ANG|PTG", "Manutenção De Embalagens", "Manutenção de Embalagens" )
		#define STR0007 If( cPaisLoc $ "ANG|PTG", "Cofacturairma Eliminação?", "Confirma Exclusão?" )
		#define STR0008 "Atenção"
		#define STR0009 If( cPaisLoc $ "ANG|PTG", "A gravar relação de embalagens ...", "Gravando relação de embalagens ..." )
		#define STR0010 If( cPaisLoc $ "ANG|PTG", "A actualizar informações de embalagens ...", "Atualizando informações de embalagens ..." )
		#define STR0011 If( cPaisLoc $ "ANG|PTG", "Embalagens da embalagem ", "Embalagens da Embalagem " )
		#define STR0012 If( cPaisLoc $ "ANG|PTG", "Esta embalagem está a ser utilizada nas embalagens ###portanto, não poderá ser excluída.", "Esta embalagem está sendo utilizada nas embalagens ###portanto, não poderá ser excluída." )
		#define STR0013 If( cPaisLoc $ "ANG|PTG", "Esta embalagem está a er utilizada na embalagem ###portanto, não poderá ser excluída.", "Esta embalagem está sendo utilizada na embalagem ###portanto, não poderá ser excluída." )
		#define STR0014 "Manutenção"
		#define STR0015 "Esta embalagem está sendo utilizada nos produtos ###portanto, não poderá ser excluída."
		#define STR0016 "Esta embalagem está sendo utilizada no produto ###portanto, não poderá ser excluída."
	#endif
#endif
