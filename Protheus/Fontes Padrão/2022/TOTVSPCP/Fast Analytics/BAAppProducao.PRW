#INCLUDE "BADEFINITION.CH"

NEW APP PRODUC

//-------------------------------------------------------------------
/*/{Protheus.doc} BAAppProducao
Modelagem da área de Produção.

@author  Helio Leal
@author  henrique.cesar
@since   02/03/2018
/*/
//-------------------------------------------------------------------
Class BAAppProducao
	Data cApp

	Method Init() CONSTRUCTOR
	Method ListEntities()
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Init
Instancia a classe de App e gera um nome único para a área. 

@author  Helio Leal
@author  henrique.cesar
@since   02/03/2018
/*/
//-------------------------------------------------------------------
Method Init() Class BAAppProducao
	::cApp := "Producao"
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ListEntities
Lista as entidades (fatos e dimensões) disponíveis da área, deve ser 
necessariamente o nome das classes das entidades.

@author  Helio Leal
@author  henrique.cesar
@since   02/03/2018
/*/
//-------------------------------------------------------------------
Method ListEntities() Class BAAppProducao
Return	{ "PRODCART", + ; //Fato BAProdCart
		  "PRODREAL", + ; //Fato BAProdReal
		  "EMPRESA", + ; //Dimensão BAEmpresa
		  "FILIAL", + ; //Dimensão BAFilial
		  "ITEM", + ; //Dimensão BAItem
		  "FAMMAT", + ; //Dimensão BAFamMat
		  "FAMCOM", + ; //Dimensão BAFamCom
		  "GRPESTOQUE", + ; //Dimensão BAGrpEstoque
		  "GRPCLIENTE", + ; //Dimensão BAGrpCliente
		  "DEPOSITO", + ;	//Dimensão BADeposito	
		  "CLIENTE", + ;  //Dimensão BACliente
		  "REGIAO" } //Dimensão BARegiao